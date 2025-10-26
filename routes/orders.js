const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Checkout page
router.get('/checkout', async (req, res) => {
    try {
        const sessionId = req.session.id;
        const [cartItems] = await db.query(`
            SELECT c.quantity, p.name, p.price, p.id as product_id
            FROM cart c
            JOIN products p ON c.product_id = p.id
            WHERE c.session_id = ?
        `, [sessionId]);
        
        if (cartItems.length === 0) {
            return res.redirect('/cart');
        }
        
        const cartItemsWithNumbers = cartItems.map(item => ({
            ...item,
            price: parseFloat(item.price)
        }));
        
        const total = cartItemsWithNumbers.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const cartCount = req.session.cartCount || 0;
        
        res.render('checkout', { 
            cartItems: cartItemsWithNumbers, 
            total, 
            cartCount, 
            page: 'checkout',
            useS3: process.env.USE_S3 === 'true',
            s3Url: process.env.S3_BUCKET_URL || ''
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading checkout');
    }
});

// Place order
router.post('/place', async (req, res) => {
    const connection = await db.getConnection();
    
    try {
        await connection.beginTransaction();
        
        const { customer_name, customer_email, customer_phone, customer_address, payment_method } = req.body;
        const sessionId = req.session.id;
        
        const [cartItems] = await connection.query(`
            SELECT c.quantity, p.name, p.price, p.id as product_id
            FROM cart c
            JOIN products p ON c.product_id = p.id
            WHERE c.session_id = ?
        `, [sessionId]);
        
        if (cartItems.length === 0) {
            throw new Error('Cart is empty');
        }
        
        const cartItemsWithNumbers = cartItems.map(item => ({
            ...item,
            price: parseFloat(item.price)
        }));
        
        const total = cartItemsWithNumbers.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        
        const [orderResult] = await connection.query(
            `INSERT INTO orders (customer_name, customer_email, customer_phone, customer_address, total_amount, payment_method, order_status)
             VALUES (?, ?, ?, ?, ?, ?, 'Pending')`,
            [customer_name, customer_email, customer_phone, customer_address, total, payment_method]
        );
        
        const orderId = orderResult.insertId;
        
        for (const item of cartItemsWithNumbers) {
            await connection.query(
                `INSERT INTO order_items (order_id, product_id, product_name, quantity, price)
                 VALUES (?, ?, ?, ?, ?)`,
                [orderId, item.product_id, item.name, item.quantity, item.price]
            );
        }
        
        await connection.query('DELETE FROM cart WHERE session_id = ?', [sessionId]);
        req.session.cartCount = 0;
        
        await connection.commit();
        
        res.redirect(`/orders/confirmation/${orderId}`);
    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(500).send('Error placing order');
    } finally {
        connection.release();
    }
});

// Order confirmation page
router.get('/confirmation/:id', async (req, res) => {
    try {
        const [order] = await db.query('SELECT * FROM orders WHERE id = ?', [req.params.id]);
        const [orderItems] = await db.query('SELECT * FROM order_items WHERE order_id = ?', [req.params.id]);
        
        if (order.length === 0) {
            return res.redirect('/products');
        }
        
        const orderWithNumbers = {
            ...order[0],
            total_amount: parseFloat(order[0].total_amount)
        };
        
        const orderItemsWithNumbers = orderItems.map(item => ({
            ...item,
            price: parseFloat(item.price)
        }));
        
        res.render('confirmation', { 
            order: orderWithNumbers, 
            orderItems: orderItemsWithNumbers, 
            cartCount: 0, 
            page: 'confirmation',
            useS3: process.env.USE_S3 === 'true',
            s3Url: process.env.S3_BUCKET_URL || ''
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading confirmation');
    }
});

// Admin - View all orders
router.get('/admin/orders', async (req, res) => {
    try {
        const [orders] = await db.query(`
            SELECT * FROM orders ORDER BY created_at DESC
        `);
        
        const cartCount = req.session.cartCount || 0;
        
        res.render('admin-orders', { 
            orders: orders,
            cartCount: cartCount, 
            page: 'admin',
            useS3: process.env.USE_S3 === 'true',
            s3Url: process.env.S3_BUCKET_URL || ''
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading orders');
    }
});

// Admin - View specific order details
router.get('/admin/orders/:id', async (req, res) => {
    try {
        const [order] = await db.query('SELECT * FROM orders WHERE id = ?', [req.params.id]);
        const [orderItems] = await db.query('SELECT * FROM order_items WHERE order_id = ?', [req.params.id]);
        
        if (order.length === 0) {
            return res.status(404).send('Order not found');
        }
        
        const orderWithNumbers = {
            ...order[0],
            total_amount: parseFloat(order[0].total_amount)
        };
        
        const orderItemsWithNumbers = orderItems.map(item => ({
            ...item,
            price: parseFloat(item.price)
        }));
        
        const cartCount = req.session.cartCount || 0;
        
        res.render('admin-order-detail', { 
            order: orderWithNumbers, 
            orderItems: orderItemsWithNumbers, 
            cartCount: cartCount, 
            page: 'admin',
            useS3: process.env.USE_S3 === 'true',
            s3Url: process.env.S3_BUCKET_URL || ''
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading order details');
    }
});

module.exports = router;

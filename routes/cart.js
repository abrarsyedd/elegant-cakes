const express = require('express');
const router = express.Router();
const db = require('../config/database');

function transformImageUrl(imageUrl, useS3, s3Url) {
    if (useS3 && imageUrl.startsWith('/images/')) {
        return s3Url + imageUrl;
    }
    return imageUrl;
}

// View Cart Page
router.get('/', async (req, res) => {
    try {
        const sessionId = req.session.id;
        const [cartItems] = await db.query(`
            SELECT c.id, c.quantity, p.name, p.price, p.image_url, p.id as product_id
            FROM cart c
            JOIN products p ON c.product_id = p.id
            WHERE c.session_id = ?
        `, [sessionId]);

        const useS3 = process.env.USE_S3 === 'true';
        const s3Url = process.env.S3_BUCKET_URL || '';

        const cartItemsWithNumbers = cartItems.map(item => ({
            ...item,
            price: parseFloat(item.price),
            image_url: transformImageUrl(item.image_url, useS3, s3Url)
        }));

        const total = cartItemsWithNumbers.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const cartCount = cartItemsWithNumbers.reduce((sum, item) => sum + item.quantity, 0);

        res.render('cart', { cartItems: cartItemsWithNumbers, total, cartCount, page: 'cart' });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading cart');
    }
});

// Add to cart API
router.post('/add', async (req, res) => {
    try {
        const { product_id, quantity } = req.body;
        const sessionId = req.session.id;

        const [existing] = await db.query(
            'SELECT * FROM cart WHERE session_id = ? AND product_id = ?',
            [sessionId, product_id]
        );

        if (existing.length > 0) {
            await db.query(
                'UPDATE cart SET quantity = quantity + ? WHERE session_id = ? AND product_id = ?',
                [parseInt(quantity), sessionId, product_id]
            );
        } else {
            await db.query(
                'INSERT INTO cart (session_id, product_id, quantity) VALUES (?, ?, ?)',
                [sessionId, product_id, parseInt(quantity)]
            );
        }

        const [cartItems] = await db.query(
            'SELECT SUM(quantity) as count FROM cart WHERE session_id = ?',
            [sessionId]
        );

        req.session.cartCount = cartItems[0].count || 0;

        res.json({ success: true, cartCount: req.session.cartCount, message: 'Added to cart!' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Error adding to cart' });
    }
});

// Update Quantity API
router.post('/update', async (req, res) => {
    try {
        const { cart_id, quantity } = req.body;
        const sessionId = req.session.id;

        if (parseInt(quantity) <= 0) {
            await db.query('DELETE FROM cart WHERE id = ? AND session_id = ?', [cart_id, sessionId]);
        } else {
            await db.query(
                'UPDATE cart SET quantity = ? WHERE id = ? AND session_id = ?',
                [parseInt(quantity), cart_id, sessionId]
            );
        }

        const [cartItems] = await db.query(
            'SELECT SUM(quantity) as count FROM cart WHERE session_id = ?',
            [sessionId]
        );
        req.session.cartCount = cartItems[0].count || 0;

        res.json({ success: true, cartCount: req.session.cartCount });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false });
    }
});

// Remove from Cart API
router.post('/remove', async (req, res) => {
    try {
        const { cart_id } = req.body;
        const sessionId = req.session.id;

        await db.query('DELETE FROM cart WHERE id = ? AND session_id = ?', [cart_id, sessionId]);

        const [cartItems] = await db.query(
            'SELECT SUM(quantity) as count FROM cart WHERE session_id = ?',
            [sessionId]
        );
        req.session.cartCount = cartItems[0].count || 0;

        res.json({ success: true, cartCount: req.session.cartCount });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false });
    }
});


module.exports = router;

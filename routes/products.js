const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Helper function to transform image URLs to S3
function transformImageUrl(imageUrl, useS3, s3Url) {
    if (!imageUrl) return imageUrl;
    
    if (useS3 && imageUrl.startsWith('/images/')) {
        return s3Url + imageUrl;
    }
    return imageUrl;
}

// Home/Products Page
router.get('/', async (req, res) => {
    try {
        const [products] = await db.query('SELECT * FROM products LIMIT 5');
        
        const useS3 = process.env.USE_S3 === 'true';
        const s3Url = process.env.S3_BUCKET_URL || '';

        const productsWithNumbers = products.map(product => ({
            ...product,
            price: parseFloat(product.price),
            image_url: transformImageUrl(product.image_url, useS3, s3Url)
        }));

        res.render('index', {
            page: 'home',
            products: productsWithNumbers,
            cartCount: req.session.cartCount || 0
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading home page');
    }
});

// Cakes Page with Category Filtering
router.get('/cakes', async (req, res) => {
    try {
        const chosenCategory = req.query.category || 'All';
        
        // Get all categories
        const [categoriesRows] = await db.query('SELECT DISTINCT category FROM products ORDER BY category ASC');

        let productsSql;
        let params = [];

        if (chosenCategory === 'All') {
            productsSql = 'SELECT * FROM products ORDER BY id ASC';
        } else {
            productsSql = 'SELECT * FROM products WHERE category = ? ORDER BY id ASC';
            params = [chosenCategory];
        }

        const [products] = await db.query(productsSql, params);

        const useS3 = process.env.USE_S3 === 'true';
        const s3Url = process.env.S3_BUCKET_URL || '';

        // Convert prices to numbers and transform image URLs
        const productsWithNumbers = products.map(product => ({
            ...product,
            price: parseFloat(product.price),
            image_url: transformImageUrl(product.image_url, useS3, s3Url)
        }));

        res.render('cakes', {
            page: 'cakes',
            categories: categoriesRows.map(row => row.category),
            selected: chosenCategory,
            products: productsWithNumbers,
            cartCount: req.session.cartCount || 0
        });

    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading cakes');
    }
});

// Product Detail Page
router.get('/product/:id', async (req, res) => {
    try {
        const productId = req.params.id;
        
        const [products] = await db.query('SELECT * FROM products WHERE id = ?', [productId]);
        
        if (products.length === 0) {
            return res.status(404).send('Product not found');
        }

        const product = products[0];

        // Fetch related products from same category (exclude current product)
        const [relatedProductsData] = await db.query(
            'SELECT * FROM products WHERE category = ? AND id != ? LIMIT 4',
            [product.category, productId]
        );

        const useS3 = process.env.USE_S3 === 'true';
        const s3Url = process.env.S3_BUCKET_URL || '';

        const productWithImages = {
            ...product,
            price: parseFloat(product.price),
            image_url: transformImageUrl(product.image_url, useS3, s3Url)
        };

        const relatedProducts = relatedProductsData.map(p => ({
            ...p,
            price: parseFloat(p.price),
            image_url: transformImageUrl(p.image_url, useS3, s3Url)
        }));

        res.render('product-detail', {
            page: 'product',
            product: productWithImages,
            relatedProducts: relatedProducts,
            cartCount: req.session.cartCount || 0
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading product');
    }
});

module.exports = router;

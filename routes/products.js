const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/', async (req, res) => {
    try {
        const chosenCategory = req.query.category || 'All';
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

        res.render('cakes', {
            page: 'cakes',
            categories: categoriesRows.map(row => row.category),
            selected: chosenCategory,
            products,
            cartCount: req.session.cartCount || 0,
            useS3: process.env.USE_S3 === 'true',
            s3Url: process.env.S3_BUCKET_URL || ''
        });

    } catch (error) {
        console.error(error);
        res.status(500).send('Error loading cakes');
    }
});

module.exports = router;

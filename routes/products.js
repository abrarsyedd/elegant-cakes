const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Helper function to transform image URLs for S3
function transformImageUrl(imageUrl, useS3, s3Url) {
  if (useS3 && imageUrl.startsWith('/images/')) {
    return s3Url + imageUrl;
  }
  return imageUrl;
}

// Signature cakes IDs for home page display
const SIGNATURE_IDS = [1, 2, 3, 4, 5];

// Home - shows signature cakes
router.get('/', async (req, res) => {
  try {
    const [signatureProducts] = await db.query(
      `SELECT * FROM products WHERE id IN (${SIGNATURE_IDS.join(",")}) ORDER BY FIELD(id, ${SIGNATURE_IDS.join(",")})`
    );
    const useS3 = process.env.USE_S3 === 'true';
    const s3Url = process.env.S3_BUCKET_URL || '';
    const productsWithNumbers = signatureProducts.map(product => ({
      ...product,
      price: parseFloat(product.price),
      image_url: transformImageUrl(product.image_url, useS3, s3Url),
    }));
    const cartCount = req.session.cartCount || 0;
    res.render('index', { products: productsWithNumbers, cartCount, page: 'home' });
  } catch (err) {
    console.error(err);
    res.status(500).send('Error loading home page products');
  }
});

// Cakes page - all cakes with category filtering
router.get('/cakes', async (req, res) => {
  try {
    const chosenCategory = req.query.category || 'All';
    const [categoriesRows] = await db.query('SELECT DISTINCT category FROM products ORDER BY category ASC');
    const categories = categoriesRows.map(row => row.category);

    let productsSql;
    let params = [];
    if (chosenCategory !== 'All') {
      productsSql = 'SELECT * FROM products WHERE category = ? ORDER BY id ASC';
      params = [chosenCategory];
    } else {
      productsSql = 'SELECT * FROM products ORDER BY id ASC';
    }
    const [products] = await db.query(productsSql, params);

    const useS3 = process.env.USE_S3 === 'true';
    const s3Url = process.env.S3_BUCKET_URL || '';
    const productsWithNumbers = products.map(product => ({
      ...product,
      price: parseFloat(product.price),
      image_url: transformImageUrl(product.image_url, useS3, s3Url),
    }));
    const cartCount = req.session.cartCount || 0;
    res.render('cakes', {
      products: productsWithNumbers,
      categories,
      selected: chosenCategory,
      cartCount,
      page: 'cakes',
    });
  } catch (err) {
    console.error(err);
    res.status(500).send('Error loading cakes page');
  }
});

// Product Detail
router.get('/product/:id', async (req, res) => {
  try {
    const [product] = await db.query('SELECT * FROM products WHERE id = ?', [req.params.id]);
    const [relatedProducts] = await db.query(
      'SELECT * FROM products WHERE category = ? AND id != ? LIMIT 3',
      [product[0].category, req.params.id]
    );
    const useS3 = process.env.USE_S3 === 'true';
    const s3Url = process.env.S3_BUCKET_URL || '';
    const productWithNumbers = {
      ...product[0],
      price: parseFloat(product[0].price),
      image_url: transformImageUrl(product[0].image_url, useS3, s3Url),
    };
    const relatedProductsWithNumbers = relatedProducts.map(p => ({
      ...p,
      price: parseFloat(p.price),
      image_url: transformImageUrl(p.image_url, useS3, s3Url),
    }));
    const cartCount = req.session.cartCount || 0;
    res.render('product-detail', {
      product: productWithNumbers,
      relatedProducts: relatedProductsWithNumbers,
      cartCount,
      page: 'product',
    });
  } catch (err) {
    console.error(err);
    res.status(500).send('Error loading product');
  }
});

router.get('/about', (req, res) => {
  const cartCount = req.session.cartCount || 0;
  res.render('about', { cartCount, page: 'about' });
});

router.get('/contact', (req, res) => {
  const cartCount = req.session.cartCount || 0;
  res.render('contact', { cartCount, page: 'contact' });
});

module.exports = router;

const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Conditionally serve static files locally if not using S3
if (process.env.USE_S3 !== 'true') {
    app.use(express.static('public'));
}

// Session middleware
app.use(session({
    secret: process.env.SESSION_SECRET || 'cakeshop_secret_key',
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 24 * 60 * 60 * 1000 }
}));

// CRITICAL: Make S3 config available to ALL views
app.use((req, res, next) => {
    const useS3 = process.env.USE_S3 === 'true';
    const s3Url = process.env.S3_BUCKET_URL || '';
    
    res.locals.useS3 = useS3;
    res.locals.s3Url = s3Url;
    res.locals.cartCount = req.session.cartCount || 0;
    
    // Debug logging to verify S3 config
    console.log(`[S3 CONFIG] USE_S3=${useS3}, S3_URL=${s3Url}`);
    
    next();
});

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Routes
const productRoutes = require('./routes/products');
const cartRoutes = require('./routes/cart');
const orderRoutes = require('./routes/orders');

app.use('/', productRoutes);
app.use('/cart', cartRoutes);
app.use('/orders', orderRoutes);

// Start server
app.listen(PORT, () => {
    console.log(`🎂 Cake Shop Server running on http://localhost:${PORT}`);
    console.log(`📦 Static assets: ${process.env.USE_S3 === 'true' ? 'S3 (' + process.env.S3_BUCKET_URL + ')' : 'Local (public folder)'}`);
});

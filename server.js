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

// Make S3 config available to all views
app.use((req, res, next) => {
    res.locals.useS3 = process.env.USE_S3 === 'true';
    res.locals.s3Url = process.env.S3_BUCKET_URL || '';
    res.locals.assetUrl = process.env.USE_S3 === 'true' ? process.env.S3_BUCKET_URL : '';
    next();
});

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Routes
const productRoutes = require('./routes/products');
const cakesRoutes = require('./routes/cakes');  // ADD THIS LINE
const cartRoutes = require('./routes/cart');
const orderRoutes = require('./routes/orders');

app.use('/', productRoutes);
app.use('/cakes', cakesRoutes);  // ADD THIS LINE
app.use('/cart', cartRoutes);
app.use('/orders', orderRoutes);

// Start server
app.listen(PORT, () => {
    console.log(`🎂 Cake Shop Server running on http://localhost:${PORT}`);
    console.log(`📦 Static assets: ${process.env.USE_S3 === 'true' ? 'S3 (' + process.env.S3_BUCKET_URL + ')' : 'Local (public folder)'}`);
});

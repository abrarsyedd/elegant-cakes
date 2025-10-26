-- Create database
CREATE DATABASE IF NOT EXISTS cakeshop_db;
USE cakeshop_db;

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100),
    image_url VARCHAR(255),
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cart table
CREATE TABLE IF NOT EXISTS cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    product_id INT,
    quantity INT DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    customer_address TEXT,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    order_status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    product_name VARCHAR(255),
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Insert ALL 10 products with S3 URLs
INSERT INTO products (name, description, price, category, image_url, stock_quantity) VALUES
('Chocolate Delight Cake', 'Rich chocolate layer cake with velvety ganache frosting. Perfect for chocolate lovers, this decadent dessert features three layers of moist chocolate sponge with smooth chocolate ganache between each layer.', 45.99, 'Chocolate Cakes', '/images/cake1.png', 15),
('Elegant Wedding Cake', 'Three-tier white wedding cake with fondant roses. Beautifully crafted with delicate sugar flowers and smooth fondant finish. Customizable for your special day.', 299.99, 'Wedding Cakes', '/images/cake2.png', 5),
('Fresh Strawberry Shortcake', 'Light and fluffy sponge cake layered with fresh strawberries and whipped cream. A classic favorite that combines sweet berries with airy cream for a refreshing dessert.', 38.50, 'Fruit Cakes', '/images/cake3.png', 12),
('Red Velvet Cupcakes', 'Dozen red velvet cupcakes with cream cheese frosting. Moist and tender with the perfect balance of cocoa and vanilla, topped with our signature cream cheese frosting.', 32.00, 'Cupcakes', '/images/cake4.png', 25),
('Birthday Celebration Cake', 'Colorful vanilla birthday cake with buttercream frosting and sprinkles. Customizable message and decorations available. Perfect for making celebrations extra special.', 42.99, 'Birthday Cakes', '/images/cake5.png', 18),
('Classic Tiramisu Cake', 'Italian-inspired tiramisu cake with coffee and cocoa. Layers of espresso-soaked sponge with mascarpone cream and a dusting of premium cocoa powder.', 48.75, 'Specialty Cakes', '/images/cake6.png', 10),
('Blueberry Cheesecake', 'Creamy New York-style cheesecake topped with fresh blueberries and blueberry compote. Rich and smooth with a buttery graham cracker crust. A berry lover''s dream dessert.', 46.50, 'Specialty Cakes', '/images/cake7.png', 14),
('Matcha Green Tea Cake', 'Delicate Japanese-inspired matcha cake with white cream frosting. Made with premium matcha powder for an authentic flavor. Light, fluffy, and perfectly balanced sweetness.', 52.99, 'Specialty Cakes', '/images/cake8.png', 11),
('Coconut Dream Cake', 'Moist coconut cake covered with shredded coconut and white frosting. Tropical paradise in every bite with layers of coconut cream filling. Perfect for coconut enthusiasts.', 44.75, 'Specialty Cakes', '/images/cake9.png', 13),
('Raspberry Chocolate Tart', 'Decadent chocolate ganache tart topped with fresh raspberries. Rich dark chocolate filling in a buttery tart shell. An elegant dessert for special occasions.', 54.99, 'Specialty Cakes', '/images/cake10.png', 9),
('Vanilla Celebration Cake', 'Smooth vanilla layered cake with buttercream and colorful sprinkles.', 40.50, 'Birthday Cakes', '/images/cake11.png', 20),
('Confetti Party Cake', 'Funfetti cake loaded with chocolate chips and a creamy frosting.', 44.99, 'Birthday Cakes', '/images/cake12.png', 15),
('Chocolate Birthday Blast', 'Rich chocolate cake with birthday message, topped with candles.', 49.99, 'Birthday Cakes', '/images/cake13.png', 12),
('Rainbow Layers Cake', 'Multi-layer cake with vibrant colors and whipped cream frosting.', 53.50, 'Birthday Cakes', '/images/cake14.png', 10),
('Mixed Berry Fruit Cake', 'Light sponge cake layered with strawberries, blueberries, and cream.', 45.99, 'Fruit Cakes', '/images/cake15.png', 18),
('Tropical Mango Cake', 'Mango-flavored cake with fresh mango slices and cream topping.', 48.75, 'Fruit Cakes', '/images/cake16.png', 15),
('Peach Perfection Cake', 'Moist peach cake with whipped cream and candied peach topping.', 44.50, 'Fruit Cakes', '/images/cake17.png', 12),
('Citrus Sunshine Cake', 'Orange and lemon zest infused cake with citrus glaze.', 47.00, 'Fruit Cakes', '/images/cake18.png', 15),
('Dark Chocolate Elegance', 'Decadent dark chocolate cake with white chocolate drizzle and fresh berries on top. A sophisticated choice for chocolate connoisseurs.', 59.99, 'Chocolate Cakes', '/images/cake19.png', 16),
('Luxury Gold Chocolate', 'Premium chocolate cake decorated with edible gold leaf and chocolate pearls. An elegant choice for special occasions.', 65.50, 'Chocolate Cakes', '/images/cake20.png', 12),
('Chocolate Mint Fusion', 'Rich chocolate cake infused with refreshing mint, topped with mint leaves and chocolate shavings. Perfect balance of flavors.', 56.75, 'Chocolate Cakes', '/images/cake21.png', 14),
('Strawberry Cheesecake Cupcakes', 'Delicate cupcakes combining strawberry and cheesecake flavors, topped with fresh strawberry and creamy frosting.', 31.50, 'Cupcakes', '/images/cake22.png', 28),
('Salted Caramel Cupcakes', 'Indulgent salted caramel cupcakes with caramel drizzle and sea salt crystals for a sweet and savory experience.', 33.00, 'Cupcakes', '/images/cake23.png', 26),
('Pistachio Dream Cupcakes', 'Unique pistachio-flavored cupcakes with green frosting and pistachio crumbs. A subtle and sophisticated treat.', 34.99, 'Cupcakes', '/images/cake24.png', 24),
('Romantic Floral Wedding Cake', 'Stunning three-tier white wedding cake with cascading fresh flowers and delicate pearl decorations. Perfect for romantic spring or garden weddings. Customizable for your special day.', 349.99, 'Wedding Cakes', '/images/cake25.png', 10);


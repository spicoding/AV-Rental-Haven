-- Recreate the database structure with absolute file paths
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    category VARCHAR(100),
    unit_price DECIMAL(10, 2) NOT NULL,
    image VARCHAR(500)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    payment_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    image VARCHAR(500),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products (product_name, product_description, category, unit_price, image) VALUES
('Yamaha DM7 Digital Mixer', 'Professional Digital Mixer.', 'Audio', 124999.00, 'assets/yamaha dm7.jpg'),
('Epson 4K Projector', 'Ultra-bright 4K projection.', 'Visual', 9999.00, 'assets/epson projector.jpg'),
('Shure SLXD Wireless Microphone System', 'Digital wireless audio system.', 'Audio', 6499.00, 'assets/slxd+.jpg'),
('LED Stage Lights Package', 'Complete lighting solution.', 'Lighting', 5999.00, 'assets/led stage lights.jpg'),
('Pioneer CDJ 3000 Controller', 'The industry standard DJ multi-player.', 'Audio', 20499.00, 'assets/CDJ-3000_angle.jpeg'),
('120" Projection Screen', 'High-gain projection screen.', 'Visual', 29999.00, 'assets/120 projectorscreen.jpg'),
('Allen & Heath dLive S7000 Surface', 'Flagship digital mixing surface.', 'Audio', 150000.00, 'assets/xAllen-Heath-dLive-S7000-and-CDM32-Package-768x768.jpg.pagespeed.ic.E-4kLBWTUA.jpg'),
('DiGiCo Quantum 338 Console', 'Powerhouse console for massive shows.', 'Audio', 250000.00, 'assets/Q338-Pulse-Angle-for-Web1-1200x750.jpg'),
('d&b audiotechnik J-Series Line Array', 'Industry standard line array system.', 'Audio', 350000.00, 'assets/d&b audiotechnik.jpg'),
('dBTechnologies VIO L212', 'Active 3-way line array module.', 'Audio', 180000.00, 'assets/d&b audiotechnik.jpg'),
('Allen & Heath DX168 Stage Box', 'Portable DX expander.', 'Accessories', 15000.00, 'assets/DX168-Hero-1.jpg'),
('DiGiCo SD-Rack (32 In / 16 Out)', 'High-resolution stage rack.', 'Accessories', 95000.00, 'assets/SD_Mini_Rack_1-1-1200x750-1.png'),
('Premium XLR Cable Bundle (50m)', 'Professional balanced audio cables.', 'Accessories', 3500.00, 'assets/XLR.png'),
('Sennheiser EW-DX Wireless System', 'Next-gen digital UHF wireless.', 'Audio', 8000.00, 'assets/EWE-DX Mics Dante.png'),
('Shure PSM1000 In-Ear Monitor System', 'Dual-channel personal monitoring.', 'Audio', 12000.00, 'assets/PSM 1000.jpg'),
('MA Lighting grandMA3 compact Console', 'Compact pro lighting control.', 'Lighting', 65000.00, 'assets/GrandMA3.png'),
('Absen 2.9mm SA-C Flexible Displays', 'High-res LED video panels.', 'Visual', 15000.00, 'assets/sa-series-1920X900-sa-series-1920X900LED panels.jpg'),
('Blackmagic ATEM Television Studio 4K8', 'Live production switcher.', 'Visual', 19999.00, 'assets/ATEM Television studio 4K8.jpg'),
('Sony FX6 Cinema Camera', 'Professional cinema line camera.', 'Visual', 25000.00, 'assets/Sony FX6.jpg'),
('Hollyland Solidcom M1 Pro Wireless Intercom', 'Professional wireless intercom.', 'Accessories', 29999.00, 'assets/Hollylans Solidcom M1 Pro.png');
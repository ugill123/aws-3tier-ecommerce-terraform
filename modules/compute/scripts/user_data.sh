#!/bin/bash
# =========================================================================
# AUTOMATED DEPLOYMENT SCRIPT (FIXED FOR TERRAFORM INTERPOLATION)
# =========================================================================

# 1. Update OS and install prerequisites
sudo yum update -y
sudo yum install -y curl git jq awscli

# 2. Install Node.js (v20)
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# 3. Install PM2
sudo npm install -g pm2

# 4. Set up application directory
sudo mkdir -p /var/www/ecommerce
cd /var/www/ecommerce

# 5. Create the server.js file directly on the EC2 instance
# We use 'EOF' (quoted) to prevent the shell from expanding variables
cat << 'EOF' > server.js
const express = require('express');
const cors = require('cors');
const redis = require('redis');
const mysql = require('mysql2/promise');

const app = express();
app.use(cors());
app.use(express.json());

// ALB Health Check
app.get('/health', (req, res) => res.status(200).send('OK'));

const redisClient = redis.createClient({ url: process.env.REDIS_URL });
redisClient.connect().catch(console.error);

async function initDB() {
    try {
        // Step A: Connect to server without a DB name to create the schema
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD
        });
        
        console.log('🛠️ Creating database if missing...');
        // String concatenation used here to avoid Terraform interpolation issues
        await connection.query("CREATE DATABASE IF NOT EXISTS " + process.env.DB_NAME);
        await connection.end();

        // Step B: Reconnect to the specific database
        const db = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        console.log('🛠️ Creating tables if missing...');
        await db.query(`
            CREATE TABLE IF NOT EXISTS products (
                id INT AUTO_INCREMENT PRIMARY KEY, 
                name VARCHAR(255), 
                description TEXT, 
                price DECIMAL(10,2), 
                image_url VARCHAR(255)
            )
        `);

        const [rows] = await db.query('SELECT COUNT(*) as count FROM products');
        if (rows[0].count === 0) {
            console.log('🌱 Seeding initial products...');
            await db.query(`
                INSERT INTO products (name, description, price, image_url) VALUES 
                ('Cloud Architect Hoodie', 'Premium AWS Navy hoodie.', 59.99, 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=300&q=80'),
                ('DevOps Coffee Mug', 'Keeps coffee hot during Terraform applies.', 19.99, 'https://images.unsplash.com/photo-1517256673644-36ad3623f6b7?auto=format&fit=crop&w=300&q=80'),
                ('Mechanical Keyboard', 'Clicky switches for writing IaC.', 129.99, 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?auto=format&fit=crop&w=300&q=80')
            `);
        }
        console.log('✅ Database is fully ready!');
        await db.end();
    } catch (e) { 
        console.error('❌ DB Init Critical Error:', e.message); 
    }
}

// Start DB check
initDB();

app.get('/api/products', async (req, res) => {
    try {
        const db = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });
        const [rows] = await db.query('SELECT * FROM products');
        res.json(rows);
        await db.end();
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.listen(80, () => console.log('🚀 API running on port 80'));
EOF

# 6. Initialize NPM and install dependencies
sudo npm init -y
sudo npm install express cors redis mysql2

# 7. Inject Environment Variables (Single $ for Terraform interpolation)
export AWS_DEFAULT_REGION="us-east-1"

# Terraform will replace these:
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "${db_secret_arn}" --query SecretString --output text)
ACTUAL_PASSWORD=$(echo $SECRET_JSON | jq -r .password)

RAW_ENDPOINT="${db_endpoint}"
CLEAN_DB_HOST=$(echo $RAW_ENDPOINT | cut -d':' -f1)

export DB_HOST="$CLEAN_DB_HOST"
export DB_USER="admin"
export DB_PASSWORD="$ACTUAL_PASSWORD"
export DB_NAME="ecommerce"
export REDIS_URL="redis://${redis_endpoint}:6379"
export PORT=80

# 8. Start the Application
sudo -E pm2 start server.js --name "ecommerce-api"

# 9. Ensure the app restarts if the EC2 instance is rebooted
sudo pm2 startup systemd -u root --hp /root
sudo pm2 save
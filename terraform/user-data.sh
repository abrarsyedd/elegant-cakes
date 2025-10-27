#!/bin/bash

set -xe

apt-get update -y
apt-get install -y curl git

curl-fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

npm install -g pm2

cd /home/ubuntu
git clone https://github.com/abrarsyedd/elegant-cakeshop.git
cd elegant-cakeshop

rm -rf public

cat<<EOF > .env
DB_HOST=${rds_endpoint}
DB_USER=admin
DB_PASSWORD=admin12345
DB_NAME=cakeshop_db
PORT=3000
SESSION_SECRET=your_session_secret
USE_S3=true
S3_BUCKET_NAME=${s3_url}
EOF


# --- 🕐 Wait until RDS is accepting connections ---
echo "Waiting for RDS to accept connections..."
for i in {1..20}; do
  nc -zv ${rds_endpoint} 3306 && break
  echo "RDS not ready yet... retrying in 10s"
  sleep 10
done

# --- 🧩 Import schema if available ---
if [ -f "./schema.sql" ]; then
  echo "Importing schema into RDS..."
  mysql -h ${rds_endpoint} -u admin -padmin12345 cakeshop_db < config/schema.sql
else
  echo "schema.sql not found, skipping import."
fi

# --- 🚀 Start Node.js app ---


npm install
pm2 start server.js --name elegant-cakeshop
pm2 startup systemd
pm2 save
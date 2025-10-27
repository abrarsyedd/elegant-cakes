#!/bin/bash
set -xe

apt-get update -y
apt-get install -y curl git netcat mysql-client

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

npm install -g pm2

cd /home/ubuntu
git clone https://${github_token}@github.com/abrarsyedd/elegant-cakes.git
cd elegant-cakes

rm -rf public

cat <<EOF > .env
DB_HOST=${rds_endpoint}
DB_USER=admin
DB_PASSWORD=admin12345
DB_NAME=cakeshop_db
PORT=3000
SESSION_SECRET=your_session_secret
USE_S3=true
S3_BUCKET_URL=${s3_bucket_url}
EOF

echo "Waiting for RDS to accept connections..."
for i in {1..20}; do
  nc -zv ${rds_endpoint} 3306 && break
  echo "RDS not ready yet... retrying in 10s"
  sleep 10
done

if [ -f "./config/schema.sql" ]; then
  echo "Importing schema into RDS..."
  mysql -h ${rds_endpoint} -u admin -padmin12345 cakeshop_db < config/schema.sql
else
  echo "config/schema.sql not found, skipping import."
fi

npm install
pm2 start server.js --name elegant-cakeshop
pm2 startup systemd
pm2 save

# #!/bin/bash

# # Function to check if a command exists
# check_command() {
#   command -v "$1" &> /dev/null
# }

# # Function to verify if NVM is properly loaded
# verify_nvm() {
#   if check_command nvm; then
#     echo "NVM is loaded."
#   else
#     echo "NVM is not loaded. Trying to load manually..."
#     export NVM_DIR="$HOME/.nvm"
#     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
#     if check_command nvm; then
#       echo "NVM successfully loaded."
#     else
#       echo "Failed to load NVM. Exiting."
#       exit 1
#     fi
#   fi
# }

# # Update package index and install dependencies
# echo "Installing dependencies..."
# sudo apt update
# sudo apt install -y nginx git curl 

# #Postgres Setup
# sudo apt install -y postgresql postgresql-contrib

# # Set up SSH directory
# echo "Setting up SSH directory..."
# mkdir -p ~/.ssh
# chmod 700 ~/.ssh

# # Add GitHub to known hosts
# echo "Adding GitHub to known hosts..."
# ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# # Set up SSH key for Git
# echo "Setting up SSH key for Git..."
# # Write the SSH private key to the file
# echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
# chmod 600 ~/.ssh/id_rsa

# # Clone or update private git repository
# echo "Cloning/updating private Git repository..."
# git clone "${GITHUB_REPO}" /var/www/app || (cd /var/www/app && git pull)

# # Install NVM
# echo "Installing NVM..."
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# # Ensure .bashrc exists for root user
# if [ ! -f ~/.bashrc ]; then
#     echo "Creating .bashrc..."
#     touch ~/.bashrc
# fi

# # Add NVM and npm paths to .bashrc
# echo "Adding NVM and npm paths to .bashrc..."
# {
#     echo 'export NVM_DIR="$HOME/.nvm"'
#     echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm'
#     echo 'export PATH="$PATH:$HOME/.npm-global/bin:$NVM_DIR/versions/node/$(nvm version)/bin"'
# } >> ~/.bashrc

# # Source the updated .bashrc
# echo "Sourcing .bashrc..."
# source ~/.bashrc

# # Verify that NVM is loaded
# verify_nvm

# #Postgress ROLE, DATABASE SETUP
# #Postgre Databse & Super User
# sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' SUPERUSER;"
# # Create a PostgreSQL database
# sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
# # Grant all privileges on the new database to the new superuser (this step is optional for a superuser)
# sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# # change  Auth peer to md5
# PG_HBA_CONF="/etc/postgresql/16/main/pg_hba.conf"
# # Replace 'peer' with 'md5' in the pg_hba.conf file
# sudo sed -i "s/local   all             all                                     peer/local   all             all                                     md5/" $PG_HBA_CONF
# # Restart PostgreSQL service
# sudo systemctl restart postgresql

# # Install Node.js
# echo "Installing Node.js..."
# nvm install "${NODE_VERSION}"

# # Install Yarn and PM2
# echo "Installing Yarn and PM2..."
# npm install -g yarn pm2

# # Install project dependencies
# echo "Installing project dependencies..."
# cd /var/www/app
# yarn install

# # Build project
# echo "Building project..."
# yarn build

# # Stop and start PM2 for the project
# pm2 stop "nestjs-app" || echo "PM2 service not running"
# pm2 delete "nestjs-app" || echo "No PM2 process to delete"
# pm2 start /var/www/app/dist/main.js --name "nestjs-app" -i 1 || { echo "PM2 start failed"; exit 1; }
# pm2 save || { echo "PM2 save failed"; exit 1; }


# # Source .bashrc again to ensure paths are set
# echo "Sourcing .bashrc again..."
# source ~/.bashrc

# # Check NVM and PM2 one more time to confirm they are working
# verify_nvm
# check_command pm2 && echo "PM2 is available." || { echo "PM2 is not available. Exiting."; exit 1; }

# echo "Setup completed successfully!"

#!/bin/bash

# Function to check if a command exists
check_command() {
  command -v "$1" &> /dev/null
}

# Function to verify if NVM is properly loaded
verify_nvm() {
  if check_command nvm; then
    echo "NVM is loaded."
  else
    echo "NVM is not loaded. Trying to load manually..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if check_command nvm; then
      echo "NVM successfully loaded."
    else
      echo "Failed to load NVM. Exiting."
      exit 1
    fi
  fi
}

# Load .tfvars to extract DOMAIN_NAME
if [ -f "terraform.tfvars" ]; then
  echo "Loading domain name from terraform.tfvars..."
  source <(grep -E "^DOMAIN_NAME" terraform.tfvars | sed 's/ *= */=/g')
else
  echo "terraform.tfvars file not found. Exiting."
  exit 1
fi

if [ -z "$DOMAIN_NAME" ]; then
  echo "DOMAIN_NAME not set. Exiting."
  exit 1
fi

# Update package index and install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y nginx git curl

# # Install Let's Encrypt and Certbot for SSL
# sudo apt install -y certbot python3-certbot-nginx

#Postgres Setup
sudo apt install -y postgresql postgresql-contrib

# Set up SSH directory
echo "Setting up SSH directory..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add GitHub to known hosts
echo "Adding GitHub to known hosts..."
ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Set up SSH key for Git
echo "Setting up SSH key for Git..."
echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Clone or update private git repository
echo "Cloning/updating private Git repository..."
git clone "${GITHUB_REPO}" /var/www/app || (cd /var/www/app && git pull)

# Install NVM
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Ensure .bashrc exists for root user
if [ ! -f ~/.bashrc ]; then
    echo "Creating .bashrc..."
    touch ~/.bashrc
fi

# Add NVM and npm paths to .bashrc
echo "Adding NVM and npm paths to .bashrc..."
{
    echo 'export NVM_DIR="$HOME/.nvm"'
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm'
    echo 'export PATH="$PATH:$HOME/.npm-global/bin:$NVM_DIR/versions/node/$(nvm version)/bin"'
} >> ~/.bashrc

# Source the updated .bashrc
echo "Sourcing .bashrc..."
source ~/.bashrc

# Verify that NVM is loaded
verify_nvm

#Postgres ROLE, DATABASE SETUP
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' SUPERUSER;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# change  Auth peer to md5
PG_HBA_CONF="/etc/postgresql/16/main/pg_hba.conf"
sudo sed -i "s/local   all             all                                     peer/local   all             all                                     md5/" $PG_HBA_CONF
sudo systemctl restart postgresql

# Install Node.js
echo "Installing Node.js..."
nvm install "${NODE_VERSION}"

# Install Yarn and PM2
echo "Installing Yarn and PM2..."
npm install -g yarn pm2

# Install project dependencies
echo "Installing project dependencies..."
cd /var/www/app
yarn install

# Build project
echo "Building project..."
yarn build

# Stop and start PM2 for the project
pm2 stop "nestjs-app" || echo "PM2 service not running"
pm2 delete "nestjs-app" || echo "No PM2 process to delete"
pm2 start /var/www/app/dist/main.js --name "nestjs-app" -i 1 || { echo "PM2 start failed"; exit 1; }
pm2 save || { echo "PM2 save failed"; exit 1; }

# Set up Nginx configuration for the domain
echo "Setting up Nginx for domain: $DOMAIN_NAME..."

NGINX_CONF="/etc/nginx/sites-available/$DOMAIN_NAME"
sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the site and reload Nginx
sudo ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Source .bashrc again to ensure paths are set
echo "Sourcing .bashrc again..."
source ~/.bashrc

# Check NVM and PM2 one more time to confirm they are working
verify_nvm
check_command pm2 && echo "PM2 is available." || { echo "PM2 is not available. Exiting."; exit 1; }

echo "Setup completed successfully!"

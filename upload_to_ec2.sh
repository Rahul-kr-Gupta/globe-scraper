#!/bin/bash

###############################################################################
# Upload Scraper Files to EC2 Instance
# 
# Usage: ./upload_to_ec2.sh <ec2-ip-address> <path-to-key.pem>
# Example: ./upload_to_ec2.sh 54.123.45.67 ~/.ssh/my-key.pem
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check arguments
if [ "$#" -ne 2 ]; then
    echo -e "${RED}Usage: $0 <ec2-ip-address> <path-to-key.pem>${NC}"
    echo "Example: $0 54.123.45.67 ~/.ssh/my-key.pem"
    exit 1
fi

EC2_IP="$1"
KEY_PATH="$2"
EC2_USER="ubuntu"
REMOTE_DIR="~/globe-scraper"

# Verify key file exists
if [ ! -f "$KEY_PATH" ]; then
    echo -e "${RED}Error: Key file not found: $KEY_PATH${NC}"
    exit 1
fi

# Verify key permissions
KEY_PERMS=$(stat -c %a "$KEY_PATH" 2>/dev/null || stat -f %A "$KEY_PATH" 2>/dev/null)
if [ "$KEY_PERMS" != "400" ] && [ "$KEY_PERMS" != "600" ]; then
    echo -e "${YELLOW}Warning: Key file should have 400 or 600 permissions${NC}"
    echo "Fixing permissions..."
    chmod 400 "$KEY_PATH"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Uploading Files to EC2 Instance${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "EC2 IP: $EC2_IP"
echo "Key: $KEY_PATH"
echo "Remote Dir: $REMOTE_DIR"
echo ""

# Test SSH connection
echo -e "${YELLOW}Testing SSH connection...${NC}"
if ! ssh -i "$KEY_PATH" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'Connection successful'" 2>/dev/null; then
    echo -e "${RED}Error: Cannot connect to EC2 instance${NC}"
    echo "Please check:"
    echo "  1. EC2 instance is running"
    echo "  2. Security group allows SSH (port 22)"
    echo "  3. IP address is correct"
    exit 1
fi
echo -e "${GREEN}✓ SSH connection successful${NC}"
echo ""

# Upload main scraper file
echo -e "${YELLOW}Uploading main.py...${NC}"
if scp -i "$KEY_PATH" main.py "$EC2_USER@$EC2_IP:$REMOTE_DIR/" 2>/dev/null; then
    echo -e "${GREEN}✓ main.py uploaded${NC}"
else
    echo -e "${RED}✗ Failed to upload main.py${NC}"
fi

# Upload CSV files
echo -e "${YELLOW}Uploading CSV files...${NC}"
CSV_COUNT=$(find attached_assets -name "*.csv" 2>/dev/null | wc -l)
if [ "$CSV_COUNT" -gt 0 ]; then
    if scp -i "$KEY_PATH" attached_assets/*.csv "$EC2_USER@$EC2_IP:$REMOTE_DIR/attached_assets/" 2>/dev/null; then
        echo -e "${GREEN}✓ $CSV_COUNT CSV file(s) uploaded${NC}"
    else
        echo -e "${RED}✗ Failed to upload CSV files${NC}"
    fi
else
    echo -e "${YELLOW}No CSV files found in attached_assets/${NC}"
fi

# Optional: Upload setup script
echo -e "${YELLOW}Uploading setup script...${NC}"
if scp -i "$KEY_PATH" setup_ubuntu.sh "$EC2_USER@$EC2_IP:~/" 2>/dev/null; then
    echo -e "${GREEN}✓ setup_ubuntu.sh uploaded${NC}"
else
    echo -e "${YELLOW}setup_ubuntu.sh not uploaded (may not exist)${NC}"
fi

# Optional: Upload requirements.txt
if [ -f "requirements.txt" ]; then
    echo -e "${YELLOW}Uploading requirements.txt...${NC}"
    if scp -i "$KEY_PATH" requirements.txt "$EC2_USER@$EC2_IP:$REMOTE_DIR/" 2>/dev/null; then
        echo -e "${GREEN}✓ requirements.txt uploaded${NC}"
    fi
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Upload Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "1. SSH into your EC2 instance:"
echo -e "   ${GREEN}ssh -i $KEY_PATH $EC2_USER@$EC2_IP${NC}"
echo ""
echo "2. Run the setup script:"
echo -e "   ${GREEN}chmod +x ~/setup_ubuntu.sh${NC}"
echo -e "   ${GREEN}./setup_ubuntu.sh${NC}"
echo ""
echo "3. Configure environment variables:"
echo -e "   ${GREEN}nano ~/globe-scraper/.env${NC}"
echo ""
echo "4. Test the scraper:"
echo -e "   ${GREEN}cd ~/globe-scraper${NC}"
echo -e "   ${GREEN}source .env && source venv/bin/activate${NC}"
echo -e "   ${GREEN}python main.py${NC}"
echo ""

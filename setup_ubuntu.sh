#!/bin/bash

###############################################################################
# Globe Pest Solutions Scraper - Ubuntu EC2 Setup Script
# 
# This script automatically sets up the web scraper on Ubuntu EC2
# 
# Usage: ./setup_ubuntu.sh
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$HOME/globe-scraper"
PYTHON_VERSION="3.8"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Globe Scraper - Ubuntu Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running on Ubuntu
if [ ! -f /etc/lsb-release ]; then
    echo -e "${RED}Error: This script is designed for Ubuntu.${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1/8: Updating system packages...${NC}"
sudo apt update -qq
echo -e "${GREEN}✓ System packages updated${NC}"
echo ""

echo -e "${YELLOW}Step 2/8: Installing Python and dependencies...${NC}"
sudo apt install -y python3 python3-pip python3-venv git curl build-essential libssl-dev libffi-dev python3-dev > /dev/null 2>&1
echo -e "${GREEN}✓ Python and dependencies installed${NC}"
echo ""

echo -e "${YELLOW}Step 3/8: Creating project directory...${NC}"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
echo -e "${GREEN}✓ Project directory created: $PROJECT_DIR${NC}"
echo ""

echo -e "${YELLOW}Step 4/8: Setting up Python virtual environment...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
echo -e "${GREEN}✓ Virtual environment created${NC}"
echo ""

echo -e "${YELLOW}Step 5/8: Installing Python packages...${NC}"
pip install requests beautifulsoup4 lxml pandas psycopg2-binary python-dotenv > /dev/null 2>&1
echo -e "${GREEN}✓ Python packages installed:${NC}"
pip list | grep -E "requests|beautifulsoup4|lxml|pandas|psycopg2|dotenv"
echo ""

echo -e "${YELLOW}Step 6/8: Creating directory structure...${NC}"
mkdir -p scraped_data
mkdir -p logs
mkdir -p attached_assets
echo -e "${GREEN}✓ Directories created:${NC}"
echo "  - scraped_data/  (for CSV outputs)"
echo "  - logs/          (for scraper logs)"
echo "  - attached_assets/ (for input CSV)"
echo ""

echo -e "${YELLOW}Step 7/8: Creating environment file template...${NC}"
cat > .env.template << 'EOF'
# Supabase PostgreSQL Configuration
# IMPORTANT: Copy this file to .env and fill in your actual credentials
# DO NOT commit .env to version control

SUPABASE_HOST=YOUR_SUPABASE_HOST_HERE
SUPABASE_DBNAME=postgres
SUPABASE_USER=YOUR_POSTGRES_USER_HERE
SUPABASE_PASSWORD=YOUR_POSTGRES_PASSWORD_HERE
SUPABASE_PORT=6543
SUPABASE_TABLE=globe_daily_data
EOF

if [ ! -f .env ]; then
    cp .env.template .env
    echo -e "${GREEN}✓ Environment template created: $PROJECT_DIR/.env${NC}"
    echo -e "${YELLOW}  ⚠️  IMPORTANT: Edit .env with your actual Supabase credentials${NC}"
else
    echo -e "${YELLOW}  .env already exists, not overwriting${NC}"
fi

chmod 600 .env
chmod 644 .env.template
echo ""

echo -e "${YELLOW}Step 8/8: Creating runner script...${NC}"
cat > run_scraper.sh << EOF
#!/bin/bash

###############################################################################
# Globe Pest Solutions Scraper - Runner Script for Ubuntu/EC2
# 
# This script runs the scraper with proper environment setup and logging
# Designed to be triggered manually via SSH
###############################################################################

# Configuration
PROJECT_DIR="$PROJECT_DIR"
LOG_DIR="\$PROJECT_DIR/logs"
DATE_SUFFIX=\$(date +%Y%m%d_%H%M%S)

# Create log directory if it doesn't exist
mkdir -p "\$LOG_DIR"

# Change to project directory
cd "\$PROJECT_DIR" || {
    echo "Error: Could not change to project directory: \$PROJECT_DIR"
    exit 1
}

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found in \$PROJECT_DIR"
    exit 1
fi

# Activate virtual environment
if [ -d venv ]; then
    source venv/bin/activate
else
    echo "Error: Virtual environment not found in \$PROJECT_DIR/venv"
    exit 1
fi

# Log start
echo "========================================" >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log"
echo "Scraper started at: \$(date)" >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log"
echo "========================================" >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log"

# Run scraper with logging
python main.py >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log" 2>&1

# Capture exit code
EXIT_CODE=\$?

# Log completion
echo "========================================" >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log"
echo "Scraper finished at: \$(date)" >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log"
echo "Exit code: \$EXIT_CODE" >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log"
echo "========================================" >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log"
echo "" >> "\$LOG_DIR/cron_\$(date +%Y%m%d).log"

# Deactivate virtual environment
deactivate

# Exit with the same code as the Python script
exit \$EXIT_CODE
EOF
chmod +x run_scraper.sh
echo -e "${GREEN}✓ Runner script created: $PROJECT_DIR/run_scraper.sh${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Upload your files to the project directory:"
echo -e "   ${GREEN}scp -i your-key.pem main.py ubuntu@your-ec2-ip:~/globe-scraper/${NC}"
echo -e "   ${GREEN}scp -i your-key.pem attached_assets/globe_*.csv ubuntu@your-ec2-ip:~/globe-scraper/attached_assets/${NC}"
echo ""
echo "2. Edit the environment file with your Supabase credentials:"
echo -e "   ${GREEN}nano ~/globe-scraper/.env${NC}"
echo ""
echo "3. Test the scraper:"
echo -e "   ${GREEN}cd ~/globe-scraper${NC}"
echo -e "   ${GREEN}source .env && source venv/bin/activate${NC}"
echo -e "   ${GREEN}python main.py${NC}"
echo ""
echo "4. Run the scraper anytime via SSH:"
echo -e "   ${GREEN}ssh -i your-key.pem ubuntu@your-ec2-ip '~/globe-scraper/run_scraper.sh'${NC}"
echo ""
echo "   Or login and run manually:"
echo -e "   ${GREEN}ssh -i your-key.pem ubuntu@your-ec2-ip${NC}"
echo -e "   ${GREEN}cd ~/globe-scraper && ./run_scraper.sh${NC}"
echo ""
echo -e "${YELLOW}📝 The scraper can be triggered anytime via SSH - no cron needed!${NC}"
echo ""

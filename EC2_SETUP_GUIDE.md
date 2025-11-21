# 🚀 EC2 Ubuntu Setup Guide - Globe Pest Solutions Scraper

Complete guide to deploy and run the scraper on an EC2 Ubuntu instance with daily scheduling.

---

## 📋 Prerequisites

- EC2 Ubuntu instance (20.04 or 22.04 recommended)
- SSH access to your EC2 instance
- Python 3.8+ (comes pre-installed on Ubuntu 20.04+)
- Supabase account with `globe_daily_data` table created

---

## 🚀 Quick Start (5 Minutes)

```bash
# 1. SSH into your EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# 2. Download the setup script
wget https://raw.githubusercontent.com/your-repo/setup_ubuntu.sh
chmod +x setup_ubuntu.sh

# 3. Run the automated setup
./setup_ubuntu.sh

# 4. Configure your Supabase credentials
nano ~/globe-scraper/.env

# 5. Test the scraper
cd ~/globe-scraper
./venv/bin/python main.py

# 6. Done! The cron job is already set up to run daily at 6 PM AEST
```

---

## 📦 Manual Installation Steps

### Step 1: Update System & Install Dependencies

```bash
# Update package list
sudo apt update && sudo apt upgrade -y

# Install Python3, pip, and virtual environment
sudo apt install -y python3 python3-pip python3-venv git curl

# Install system dependencies
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev
```

### Step 2: Create Project Directory

```bash
# Create project directory
mkdir -p ~/globe-scraper
cd ~/globe-scraper

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip
```

### Step 3: Install Python Dependencies

```bash
# Install required packages
pip install requests beautifulsoup4 lxml pandas supabase

# Verify installations
pip list | grep -E "requests|beautifulsoup4|pandas|supabase"
```

### Step 4: Upload Scraper Files

**Option A: Using SCP (from your local machine)**
```bash
# Upload files from your local machine
scp -i your-key.pem main.py ubuntu@your-ec2-ip:~/globe-scraper/
scp -i your-key.pem attached_assets/globe_sku_rows_*.csv ubuntu@your-ec2-ip:~/globe-scraper/
```

**Option B: Using Git**
```bash
cd ~/globe-scraper
git clone https://github.com/your-repo/globe-scraper.git .
```

**Option C: Manually create files**
```bash
# Copy main.py and CSV file contents to the server
nano ~/globe-scraper/main.py
# Paste the content

mkdir -p ~/globe-scraper/attached_assets
nano ~/globe-scraper/attached_assets/globe_sku_rows_*.csv
# Paste the CSV content
```

### Step 5: Create Environment Variables File

```bash
# Create .env file
nano ~/globe-scraper/.env
```

**Add the following (replace with your actual credentials):**
```bash
export SUPABASE_URL="https://odpysbkgdzwcnwkrwrsw.supabase.co"
export SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kcHlzYmtnZHp3Y253a3J3cnN3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MTI4MTQwMywiZXhwIjoyMDc2ODU3NDAzfQ.fvgtK9ih3y450Avhi9nvkPz9un-k70_u1zN5x8IkB-s"
export SUPABASE_SCHEMA="public"
export SUPABASE_TABLE="globe_daily_data"
```

**Secure the file:**
```bash
chmod 600 ~/globe-scraper/.env
```

### Step 6: Create Scraper Directory Structure

```bash
cd ~/globe-scraper

# Create output directory
mkdir -p scraped_data

# Create logs directory
mkdir -p logs

# Verify structure
tree -L 2
# Should show:
# .
# ├── attached_assets/
# │   └── globe_sku_rows_*.csv
# ├── scraped_data/
# ├── logs/
# ├── main.py
# ├── .env
# └── venv/
```

### Step 7: Test the Scraper

```bash
cd ~/globe-scraper

# Load environment variables
source .env

# Activate virtual environment
source venv/bin/activate

# Run scraper
python main.py

# Check output
ls -lh scraped_data/

# Verify Supabase upload (check your Supabase dashboard)
```

---

## ⏰ Setting Up Daily Schedule (6 PM AEST)

### Method 1: Using Cron (Recommended)

**Create wrapper script:**
```bash
nano ~/globe-scraper/run_scraper.sh
```

**Add this content:**
```bash
#!/bin/bash

# Change to project directory
cd /home/ubuntu/globe-scraper

# Load environment variables
source .env

# Activate virtual environment
source venv/bin/activate

# Run scraper with logging
python main.py >> logs/cron_$(date +\%Y\%m\%d).log 2>&1

# Deactivate virtual environment
deactivate
```

**Make it executable:**
```bash
chmod +x ~/globe-scraper/run_scraper.sh
```

**Set up cron job:**
```bash
# Edit crontab
crontab -e

# Add this line for 6 PM AEST (8 AM UTC during standard time)
# Note: Adjust for daylight saving time (7 AM UTC when AEDT)
0 8 * * * /home/ubuntu/globe-scraper/run_scraper.sh
```

**Cron schedule reference:**
```bash
# 6 PM AEST (UTC+10) - Standard Time
0 8 * * * /home/ubuntu/globe-scraper/run_scraper.sh

# 6 PM AEDT (UTC+11) - Daylight Saving Time
0 7 * * * /home/ubuntu/globe-scraper/run_scraper.sh
```

**Verify cron job:**
```bash
# List current cron jobs
crontab -l

# Check cron service is running
sudo systemctl status cron
```

### Method 2: Using Systemd Timer (Advanced)

**Create service file:**
```bash
sudo nano /etc/systemd/system/globe-scraper.service
```

**Add:**
```ini
[Unit]
Description=Globe Pest Solutions Web Scraper
After=network.target

[Service]
Type=oneshot
User=ubuntu
WorkingDirectory=/home/ubuntu/globe-scraper
EnvironmentFile=/home/ubuntu/globe-scraper/.env
ExecStart=/home/ubuntu/globe-scraper/venv/bin/python /home/ubuntu/globe-scraper/main.py
StandardOutput=append:/home/ubuntu/globe-scraper/logs/scraper.log
StandardError=append:/home/ubuntu/globe-scraper/logs/scraper_error.log

[Install]
WantedBy=multi-user.target
```

**Create timer file:**
```bash
sudo nano /etc/systemd/system/globe-scraper.timer
```

**Add:**
```ini
[Unit]
Description=Run Globe Scraper daily at 6 PM AEST
Requires=globe-scraper.service

[Timer]
OnCalendar=*-*-* 18:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable and start timer:**
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable timer
sudo systemctl enable globe-scraper.timer

# Start timer
sudo systemctl start globe-scraper.timer

# Check status
sudo systemctl status globe-scraper.timer

# List all timers
sudo systemctl list-timers
```

**Manual run:**
```bash
# Test the service
sudo systemctl start globe-scraper.service

# Check logs
journalctl -u globe-scraper.service -f
```

---

## 🔍 Monitoring & Logs

### View Logs

**Cron logs:**
```bash
# View today's log
cat ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# View recent logs
ls -lth ~/globe-scraper/logs/ | head -5

# Tail live logs (during cron run)
tail -f ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# Search for errors
grep -i error ~/globe-scraper/logs/*.log
```

**System cron logs:**
```bash
# Ubuntu cron logs
grep CRON /var/log/syslog | tail -20

# Check if cron ran
grep globe-scraper /var/log/syslog
```

**Systemd logs:**
```bash
# View service logs
journalctl -u globe-scraper.service

# Follow logs in real-time
journalctl -u globe-scraper.service -f

# Logs from last hour
journalctl -u globe-scraper.service --since "1 hour ago"
```

### Check Scraped Data

```bash
# List scraped files
ls -lht ~/globe-scraper/scraped_data/

# View latest CSV
cat ~/globe-scraper/scraped_data/scraped_products_*.csv | head -20

# Count products scraped
wc -l ~/globe-scraper/scraped_data/scraped_products_*.csv
```

---

## 🔐 Security Best Practices

### 1. Secure Environment File

```bash
# Ensure .env is not readable by others
chmod 600 ~/globe-scraper/.env

# Verify permissions
ls -l ~/globe-scraper/.env
# Should show: -rw------- (600)
```

### 2. Use AWS Secrets Manager (Recommended for Production)

**Install AWS CLI:**
```bash
sudo apt install -y awscli

# Configure AWS credentials (if using IAM role, this is automatic)
aws configure
```

**Store secrets in AWS Secrets Manager:**
```bash
# Store Supabase credentials
aws secretsmanager create-secret \
  --name globe-scraper/supabase-url \
  --secret-string "https://odpysbkgdzwcnwkrwrsw.supabase.co"

aws secretsmanager create-secret \
  --name globe-scraper/supabase-key \
  --secret-string "your-supabase-service-role-key"
```

**Update main.py to fetch from Secrets Manager:**
```python
import boto3
import json

def get_secret(secret_name):
    client = boto3.client('secretsmanager', region_name='us-east-1')
    response = client.get_secret_value(SecretId=secret_name)
    return response['SecretString']

# In your upload_to_supabase function:
supabase_url = get_secret('globe-scraper/supabase-url')
supabase_key = get_secret('globe-scraper/supabase-key')
```

### 3. Restrict File Permissions

```bash
# Ensure only ubuntu user can access
chmod 700 ~/globe-scraper
chmod 600 ~/globe-scraper/.env
chmod 644 ~/globe-scraper/main.py
chmod 755 ~/globe-scraper/run_scraper.sh
```

### 4. Regular Updates

```bash
# Update system regularly
sudo apt update && sudo apt upgrade -y

# Update Python packages
cd ~/globe-scraper
source venv/bin/activate
pip list --outdated
pip install --upgrade requests beautifulsoup4 lxml pandas supabase
```

---

## 🛠️ Troubleshooting

### Scraper Not Running

**Check cron:**
```bash
# Verify cron is running
sudo systemctl status cron

# Check crontab
crontab -l

# Test manually
/home/ubuntu/globe-scraper/run_scraper.sh
```

**Check logs:**
```bash
# View recent logs
tail -50 ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# Check system logs
grep globe-scraper /var/log/syslog
```

### Import Errors

```bash
# Activate venv and check imports
cd ~/globe-scraper
source venv/bin/activate
python -c "import requests, bs4, pandas, supabase; print('All imports OK')"
```

### Permission Denied

```bash
# Fix permissions
chmod +x ~/globe-scraper/run_scraper.sh
chmod 600 ~/globe-scraper/.env
```

### Supabase Upload Fails

```bash
# Test connection
cd ~/globe-scraper
source .env
source venv/bin/activate

python3 -c "
from supabase import create_client
import os
client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_KEY'))
print('Connection successful!')
"
```

### Wrong Timezone

```bash
# Check current timezone
timedatectl

# Set to AEST (Australia/Sydney)
sudo timedatectl set-timezone Australia/Sydney

# Verify
date
```

---

## 📊 Log Rotation (Prevent Disk Fill-up)

**Create logrotate configuration:**
```bash
sudo nano /etc/logrotate.d/globe-scraper
```

**Add:**
```
/home/ubuntu/globe-scraper/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 ubuntu ubuntu
}
```

**Test logrotate:**
```bash
sudo logrotate -f /etc/logrotate.d/globe-scraper
```

---

## 🔄 Updating the Scraper

```bash
# Navigate to project
cd ~/globe-scraper

# Activate virtual environment
source venv/bin/activate

# Pull latest changes (if using Git)
git pull

# Or update main.py manually
nano main.py

# Test changes
python main.py

# No need to restart cron - it will use the updated file on next run
```

---

## 📞 Support & Maintenance

### Check System Resources

```bash
# Disk usage
df -h

# Memory usage
free -h

# CPU usage
top
```

### Backup Data

```bash
# Backup scraped data
tar -czf globe-scraper-backup-$(date +%Y%m%d).tar.gz ~/globe-scraper/scraped_data/

# Download to local machine
scp -i your-key.pem ubuntu@your-ec2-ip:~/globe-scraper-backup-*.tar.gz .
```

---

## ✅ Quick Checklist

- [ ] Python 3.8+ installed
- [ ] Virtual environment created
- [ ] Dependencies installed (requests, beautifulsoup4, lxml, pandas, supabase)
- [ ] `.env` file created with Supabase credentials
- [ ] `.env` file secured (chmod 600)
- [ ] `main.py` uploaded
- [ ] CSV file with product URLs uploaded
- [ ] `scraped_data/` directory created
- [ ] Scraper tested manually
- [ ] Cron job configured for 6 PM AEST
- [ ] Logs directory created
- [ ] Log rotation configured
- [ ] Supabase table `globe_daily_data` created

---

**Setup Complete!** Your scraper will now run daily at 6 PM AEST. 🎉

**Next Steps:**
1. Monitor first automated run
2. Check logs for any issues
3. Verify data in Supabase dashboard
4. Set up alerts (optional)

---

*Last Updated: November 11, 2025*  
*Compatible with: Ubuntu 20.04, 22.04, 24.04*

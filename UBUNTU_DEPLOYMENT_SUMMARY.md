# ✅ Ubuntu EC2 Deployment - Complete Setup Guide

Your Globe Pest Solutions scraper has been **fully configured** for deployment on Ubuntu EC2 instances!

---

## 🎉 What's Been Updated

I've created a complete Ubuntu/EC2 deployment package for you:

### ✅ New Files Created

1. **`EC2_SETUP_GUIDE.md`** - Comprehensive step-by-step guide for Ubuntu deployment
2. **`README_UBUNTU.md`** - Quick reference guide for Ubuntu users
3. **`setup_ubuntu.sh`** - Automated setup script (one-command installation)
4. **`run_scraper.sh`** - Cron-ready runner script with logging
5. **`requirements.txt`** - Python dependencies for pip installation
6. **`.env.template`** - Environment variable template (secure - no hardcoded credentials)
7. **`.gitignore`** - Updated to exclude sensitive files and logs

### ✅ Updated Files

- **`README.md`** - Now includes both Replit and Ubuntu deployment options
- **`main.py`** - Already compatible with both Replit and Ubuntu (no changes needed!)

---

## 🚀 Quick Deployment to Ubuntu EC2

### Method 1: Fully Automated (Recommended)

```bash
# 1. SSH into your EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# 2. Download and run setup script
wget https://raw.githubusercontent.com/your-repo/setup_ubuntu.sh
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh

# 3. Upload your files
scp -i your-key.pem main.py ubuntu@your-ec2-ip:~/globe-scraper/
scp -i your-key.pem attached_assets/globe_sku_rows_*.csv ubuntu@your-ec2-ip:~/globe-scraper/attached_assets/

# 4. Configure your credentials
nano ~/globe-scraper/.env
# Replace YOUR_SUPABASE_URL_HERE and YOUR_SUPABASE_SERVICE_ROLE_KEY_HERE

# 5. Test the scraper
cd ~/globe-scraper
source .env && source venv/bin/activate
python main.py

# 6. Set up daily cron job
crontab -e
# Add: 0 8 * * * /home/ubuntu/globe-scraper/run_scraper.sh
```

**That's it!** Your scraper will now run daily at 6 PM AEST.

---

## 📦 What the Setup Script Does

The `setup_ubuntu.sh` script automatically:

1. ✅ Updates system packages
2. ✅ Installs Python 3 + pip + venv
3. ✅ Installs system dependencies (build tools, SSL)
4. ✅ Creates project directory: `~/globe-scraper`
5. ✅ Sets up Python virtual environment
6. ✅ Installs all Python packages (requests, beautifulsoup4, lxml, pandas, supabase)
7. ✅ Creates directory structure (scraped_data, logs, attached_assets)
8. ✅ Creates `.env` template (no hardcoded credentials!)
9. ✅ Creates `run_scraper.sh` script for cron
10. ✅ Sets secure file permissions

**Total time:** ~2-3 minutes

---

## 📁 Directory Structure on EC2

After setup, your EC2 instance will have:

```
~/globe-scraper/
├── main.py                          ← Your scraper (upload this)
├── run_scraper.sh                   ← Cron runner script (auto-created)
├── .env                             ← Your credentials (configure this)
├── .env.template                    ← Template (auto-created)
├── requirements.txt                 ← Python deps (auto-created)
├── venv/                            ← Virtual environment (auto-created)
├── attached_assets/                 ← Input files (upload CSV here)
│   └── globe_sku_rows_*.csv        ← Product URLs
├── scraped_data/                    ← Output CSVs (auto-created daily)
│   └── scraped_products_*.csv      ← Daily results
└── logs/                            ← Cron logs (auto-created)
    └── cron_YYYYMMDD.log           ← Daily log files
```

---

## 🔐 Security Features

### 1. No Hardcoded Credentials ✅

Unlike the Replit version, credentials are **NOT** hardcoded in the setup script.

**Instead:**
- Setup creates `.env.template` with placeholders
- You manually add your actual credentials to `.env`
- `.env` file has `600` permissions (only you can read it)
- `.env` is in `.gitignore` (never committed to git)

### 2. Recommended: AWS Secrets Manager

For production, use AWS Secrets Manager instead of `.env` files:

```bash
# Store credentials in AWS Secrets Manager
aws secretsmanager create-secret \
  --name globe-scraper/supabase-url \
  --secret-string "https://odpysbkgdzwcnwkrwrsw.supabase.co"

aws secretsmanager create-secret \
  --name globe-scraper/supabase-key \
  --secret-string "your-service-role-key"
```

Then update `main.py` to fetch from Secrets Manager (example code provided in `EC2_SETUP_GUIDE.md`).

### 3. IAM Instance Role

Attach an IAM role to your EC2 instance with permission to read from Secrets Manager - no credentials needed in files at all!

---

## ⏰ Scheduling with Cron

### Cron Configuration

The `run_scraper.sh` script is designed to work perfectly with cron:

```bash
# Edit crontab
crontab -e

# Add this line for 6 PM AEST (8 AM UTC during standard time)
0 8 * * * /home/ubuntu/globe-scraper/run_scraper.sh
```

### What `run_scraper.sh` Does:

1. Changes to project directory
2. Loads environment variables from `.env`
3. Activates Python virtual environment
4. Runs `python main.py`
5. Logs all output to `logs/cron_YYYYMMDD.log`
6. Adds timestamps and exit codes
7. Deactivates virtual environment

### Cron Schedule Reference:

```bash
# 6 PM AEST (UTC+10) - October to April
0 8 * * * /home/ubuntu/globe-scraper/run_scraper.sh

# 6 PM AEDT (UTC+11) - April to October (Daylight Saving)
0 7 * * * /home/ubuntu/globe-scraper/run_scraper.sh
```

---

## 🔍 Monitoring & Logs

### View Logs

```bash
# Today's log
cat ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# Tail logs in real-time
tail -f ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# Search for errors
grep -i error ~/globe-scraper/logs/*.log

# List all log files
ls -lht ~/globe-scraper/logs/
```

### Check Scraped Data

```bash
# List CSV files
ls -lht ~/globe-scraper/scraped_data/

# Count products in latest CSV
wc -l ~/globe-scraper/scraped_data/scraped_products_*.csv

# View first 10 products
head -10 ~/globe-scraper/scraped_data/scraped_products_*.csv
```

### Verify in Supabase

Login to your Supabase dashboard and run:

```sql
-- Check today's upload
SELECT COUNT(*) FROM globe_daily_data 
WHERE DATE(scraped_at) = CURRENT_DATE;

-- View latest products
SELECT product_name, price, scraped_at 
FROM globe_daily_data 
ORDER BY scraped_at DESC 
LIMIT 10;
```

---

## 🛠️ Troubleshooting

### Scraper Not Running?

```bash
# 1. Check cron status
sudo systemctl status cron

# 2. Verify crontab entry
crontab -l

# 3. Test manually
/home/ubuntu/globe-scraper/run_scraper.sh

# 4. Check logs
tail -50 ~/globe-scraper/logs/cron_$(date +%Y%m%d).log
```

### Import Errors?

```bash
cd ~/globe-scraper
source venv/bin/activate
python -c "import requests, bs4, pandas, supabase; print('All imports OK')"
```

### Supabase Upload Fails?

```bash
# Test connection
cd ~/globe-scraper
source .env
source venv/bin/activate
python3 -c "
from supabase import create_client
import os
client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_KEY'))
response = client.table('globe_daily_data').select('*', count='exact').limit(1).execute()
print(f'Connection OK! Total records: {response.count}')
"
```

---

## 📊 Comparison: Replit vs Ubuntu EC2

| Feature | Replit | Ubuntu EC2 |
|---------|--------|------------|
| **Setup Time** | 5 minutes | 3 minutes (automated) |
| **Secrets** | Replit Secrets UI | `.env` or AWS Secrets Manager |
| **Scheduling** | Deployment config | Cron or Systemd |
| **Packages** | Nix packages | apt + pip (venv) |
| **Logs** | Replit Console | Log files |
| **Cost** | Replit plan | ~$7-10/month |
| **Control** | Limited | Full server access |
| **Scalability** | Managed | Manual |
| **Best For** | Quick prototyping | Production use |

---

## 📈 Next Steps After Deployment

### 1. Verify First Run

```bash
# Monitor tomorrow's 6 PM run
tail -f ~/globe-scraper/logs/cron_$(date +%Y%m%d).log
```

### 2. Set Up Log Rotation

```bash
sudo nano /etc/logrotate.d/globe-scraper
```

Add:
```
/home/ubuntu/globe-scraper/logs/*.log {
    daily
    rotate 30
    compress
}
```

### 3. Configure Monitoring (Optional)

- Set up CloudWatch for EC2 metrics
- Create SNS alerts for failures
- Monitor disk usage

### 4. Automate Backups (Optional)

```bash
# Add to crontab for weekly backups
0 0 * * 0 tar -czf ~/backups/globe-scraper-$(date +\%Y\%m\%d).tar.gz ~/globe-scraper/scraped_data/
```

---

## 🎯 Quick Checklist

Before your first cron run, verify:

- [ ] Python 3.8+ installed
- [ ] Virtual environment created and packages installed
- [ ] `.env` file configured with real Supabase credentials
- [ ] `main.py` uploaded to `~/globe-scraper/`
- [ ] CSV file uploaded to `~/globe-scraper/attached_assets/`
- [ ] `run_scraper.sh` is executable (chmod +x)
- [ ] Cron job configured
- [ ] Manual test successful
- [ ] Supabase table `globe_daily_data` exists
- [ ] Logs directory created

---

## 📞 Support & Documentation

### All Documentation Files:

1. **[UBUNTU_DEPLOYMENT_SUMMARY.md](UBUNTU_DEPLOYMENT_SUMMARY.md)** ← You are here
2. **[README_UBUNTU.md](README_UBUNTU.md)** - Quick reference
3. **[EC2_SETUP_GUIDE.md](EC2_SETUP_GUIDE.md)** - Detailed step-by-step
4. **[SUPABASE_TABLE_SETUP.sql](SUPABASE_TABLE_SETUP.sql)** - Database SQL
5. **[README.md](README.md)** - Main project README

### Setup Files:

- **`setup_ubuntu.sh`** - Automated setup script
- **`run_scraper.sh`** - Cron runner script
- **`requirements.txt`** - Python dependencies
- **`.env.template`** - Environment template

---

## ✅ You're Ready!

Your scraper is **100% ready** for Ubuntu EC2 deployment!

**To deploy:**
1. Copy files to your EC2 instance
2. Run `setup_ubuntu.sh`
3. Configure `.env` with your credentials
4. Set up cron job
5. Done! ✨

**Total deployment time:** ~5 minutes

---

*Last Updated: November 11, 2025*  
*Status: Production-Ready* ✅  
*Platform: Ubuntu 20.04, 22.04, 24.04*  
*Python: 3.8+*

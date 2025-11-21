# Globe Pest Solutions Scraper - Ubuntu/EC2 Deployment

Automated web scraper that runs daily on Ubuntu EC2 to extract product data from Globe Pest Solutions and upload to Supabase.

---

## 🚀 Quick Start (5 Minutes)

### Option 1: Automated Setup

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Download and run setup script
curl -O https://raw.githubusercontent.com/your-repo/setup_ubuntu.sh
chmod +x setup_ubuntu.sh
./setup_ubuntu.sh

# Upload your files
scp -i your-key.pem main.py ubuntu@your-ec2-ip:~/globe-scraper/
scp -i your-key.pem attached_assets/globe_sku_rows_*.csv ubuntu@your-ec2-ip:~/globe-scraper/attached_assets/

# Configure credentials
nano ~/globe-scraper/.env
# Add your Supabase URL and Key

# Test it
cd ~/globe-scraper
source .env && source venv/bin/activate
python main.py
```

### Option 2: Manual Setup

See **[EC2_SETUP_GUIDE.md](EC2_SETUP_GUIDE.md)** for detailed step-by-step instructions.

---

## 📦 What Gets Installed

- Python 3.8+ with pip and venv
- Required system libraries (build tools, SSL, etc.)
- Python packages:
  - `requests` - HTTP requests
  - `beautifulsoup4` - HTML parsing
  - `lxml` - XML/HTML parser
  - `pandas` - Data manipulation
  - `supabase` - Database client

---

## 📁 Directory Structure

```
~/globe-scraper/
├── main.py                          # Main scraper script
├── run_scraper.sh                   # Runner script for cron
├── .env                             # Environment variables (SECRETS)
├── .env.template                    # Template for .env
├── requirements.txt                 # Python dependencies
├── venv/                            # Python virtual environment
├── attached_assets/                 # Input files
│   └── globe_sku_rows_*.csv        # Product URLs
├── scraped_data/                    # Output CSVs
│   └── scraped_products_*.csv      # Daily scrape results
└── logs/                            # Cron job logs
    └── cron_YYYYMMDD.log           # Daily log files
```

---

## ⚙️ Configuration

### Environment Variables (.env file)

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_KEY="your-service-role-key"
export SUPABASE_SCHEMA="public"
export SUPABASE_TABLE="globe_daily_data"
```

**Security:** The `.env` file has `600` permissions (only owner can read/write).

---

## ⏰ Daily Schedule Setup

### Using Cron (Recommended)

```bash
# Open crontab editor
crontab -e

# Add this line for 6 PM AEST (8 AM UTC standard time)
0 8 * * * /home/ubuntu/globe-scraper/run_scraper.sh

# For daylight saving time (6 PM AEDT = 7 AM UTC)
0 7 * * * /home/ubuntu/globe-scraper/run_scraper.sh
```

**Verify cron job:**
```bash
crontab -l
```

### Using Systemd Timer (Advanced)

See [EC2_SETUP_GUIDE.md](EC2_SETUP_GUIDE.md#method-2-using-systemd-timer-advanced) for systemd setup.

---

## 🔍 Monitoring

### View Logs

```bash
# Today's log
cat ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# Latest log file
ls -lt ~/globe-scraper/logs/ | head -2

# Follow logs in real-time
tail -f ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# Search for errors
grep -i error ~/globe-scraper/logs/*.log
```

### Check Scraped Data

```bash
# List all CSV files
ls -lh ~/globe-scraper/scraped_data/

# View latest CSV
cat ~/globe-scraper/scraped_data/scraped_products_*.csv | tail -20

# Count products
wc -l ~/globe-scraper/scraped_data/scraped_products_*.csv
```

### Verify Supabase Upload

Login to your Supabase dashboard and run:

```sql
SELECT COUNT(*) FROM globe_daily_data 
WHERE DATE(scraped_at) = CURRENT_DATE;
```

---

## 🧪 Testing

### Manual Test Run

```bash
cd ~/globe-scraper
source .env
source venv/bin/activate
python main.py
deactivate
```

### Test Cron Job

```bash
# Run the cron script manually
/home/ubuntu/globe-scraper/run_scraper.sh

# Check output
cat ~/globe-scraper/logs/cron_$(date +%Y%m%d).log
```

---

## 🔐 Security Best Practices

### 1. Protect Environment File

```bash
# Ensure .env is not readable by others
chmod 600 ~/globe-scraper/.env

# Never commit .env to git
echo ".env" >> ~/globe-scraper/.gitignore
```

### 2. Use AWS Secrets Manager (Recommended for Production)

Instead of storing credentials in `.env`, use AWS Secrets Manager:

```bash
# Install AWS CLI
sudo apt install -y awscli

# Store secret
aws secretsmanager create-secret \
  --name globe-scraper/supabase-credentials \
  --secret-string '{"url":"your-url","key":"your-key"}'
```

Update `main.py` to fetch from Secrets Manager:

```python
import boto3

def get_secret():
    client = boto3.client('secretsmanager', region_name='us-east-1')
    response = client.get_secret_value(SecretId='globe-scraper/supabase-credentials')
    return json.loads(response['SecretString'])

# In upload_to_supabase():
creds = get_secret()
supabase_url = creds['url']
supabase_key = creds['key']
```

### 3. Use IAM Instance Role

Create an IAM role with permission to access Secrets Manager:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "secretsmanager:GetSecretValue",
    "Resource": "arn:aws:secretsmanager:region:account:secret:globe-scraper/*"
  }]
}
```

Attach this role to your EC2 instance - no AWS credentials needed in files!

---

## 🔄 Updates & Maintenance

### Update Scraper Code

```bash
cd ~/globe-scraper
source venv/bin/activate

# Pull latest changes (if using Git)
git pull

# Or edit directly
nano main.py

# Test changes
python main.py
```

### Update Python Packages

```bash
cd ~/globe-scraper
source venv/bin/activate
pip install --upgrade requests beautifulsoup4 lxml pandas supabase
```

### Update System

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 📊 Log Rotation

Prevent logs from filling up disk:

```bash
# Create logrotate config
sudo nano /etc/logrotate.d/globe-scraper
```

Add:
```
/home/ubuntu/globe-scraper/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
}
```

---

## 🛠️ Troubleshooting

### Scraper Not Running

```bash
# Check cron status
sudo systemctl status cron

# View cron logs
grep globe-scraper /var/log/syslog

# Test manually
/home/ubuntu/globe-scraper/run_scraper.sh
```

### Import Errors

```bash
# Verify packages
cd ~/globe-scraper
source venv/bin/activate
python -c "import requests, bs4, pandas, supabase; print('OK')"
```

### Permission Denied

```bash
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
print('Connection OK!')
"
```

---

## 📈 Performance & Cost

### Expected Resource Usage

- **CPU**: ~10-15% during scraping
- **Memory**: ~200-300 MB
- **Disk**: ~1 MB per day (CSV files)
- **Network**: ~10-20 MB per run
- **Runtime**: ~2-3 minutes

### EC2 Instance Recommendation

- **Minimum**: t2.micro (1 vCPU, 1 GB RAM)
- **Recommended**: t3.micro (2 vCPU, 1 GB RAM)
- **Cost**: ~$7-10/month

### Storage Requirements

- Logs: ~365 MB/year (1 MB per day)
- CSV files: ~365 MB/year (1 MB per day)
- **Total**: ~1 GB/year

---

## 🎯 Next Steps

1. ✅ Complete setup using `setup_ubuntu.sh`
2. ✅ Configure `.env` with your Supabase credentials
3. ✅ Upload `main.py` and CSV file
4. ✅ Test scraper manually
5. ✅ Set up cron job for daily runs
6. ✅ Monitor first automated run
7. ✅ Verify data in Supabase
8. ⭐ (Optional) Migrate to AWS Secrets Manager
9. ⭐ (Optional) Set up CloudWatch monitoring
10. ⭐ (Optional) Configure email alerts

---

## 📞 Support

### Documentation Files

- **[EC2_SETUP_GUIDE.md](EC2_SETUP_GUIDE.md)** - Complete setup guide
- **[README_UBUNTU.md](README_UBUNTU.md)** - This file
- **[SUPABASE_TABLE_SETUP.sql](SUPABASE_TABLE_SETUP.sql)** - Database table SQL

### Common Issues

Most issues are resolved by:
1. Checking `.env` file has correct credentials
2. Verifying virtual environment is activated
3. Reviewing logs in `~/globe-scraper/logs/`
4. Testing Supabase connection manually

---

## ✅ Differences from Replit Version

| Feature | Replit | Ubuntu EC2 |
|---------|--------|------------|
| **Secrets** | Replit Secrets | `.env` file or AWS Secrets Manager |
| **Scheduling** | Replit Deployment | Cron or Systemd Timer |
| **Packages** | Nix packages | apt + pip (virtual environment) |
| **Logs** | Replit Console | Log files in `logs/` directory |
| **Restart** | Automatic | Manual or cron-based |

---

**Ready to deploy!** Follow the Quick Start above to get running in 5 minutes. 🚀

---

*Last Updated: November 11, 2025*  
*Compatible with: Ubuntu 20.04, 22.04, 24.04*  
*Python: 3.8+*

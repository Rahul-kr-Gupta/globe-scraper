# SSH Trigger Guide - Run Scraper Remotely

This guide shows you how to trigger the scraper on your EC2 instance via SSH.

---

## 🚀 Quick Run Commands

### Option 1: Run Directly via SSH (One Command)

From your local machine, run this single command:

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip '~/globe-scraper/run_scraper.sh'
```

**Replace:**
- `your-key.pem` with your actual SSH key path
- `your-ec2-ip` with your EC2 instance IP address

**Example:**
```bash
ssh -i ~/.ssh/my-key.pem ubuntu@54.123.45.67 '~/globe-scraper/run_scraper.sh'
```

This will:
- ✅ Connect to your EC2 instance
- ✅ Run the scraper
- ✅ Save logs to `~/globe-scraper/logs/cron_YYYYMMDD.log`
- ✅ Disconnect automatically when done

---

### Option 2: Login First, Then Run

```bash
# Step 1: SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Step 2: Navigate to project
cd ~/globe-scraper

# Step 3: Run scraper
./run_scraper.sh
```

---

### Option 3: Run in Background (Returns Immediately)

If you want to trigger it and not wait for completion:

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip 'nohup ~/globe-scraper/run_scraper.sh > /dev/null 2>&1 &'
```

This runs the scraper in the background and returns control to you immediately.

---

## 📊 Check Logs

### View Latest Log File

```bash
# From local machine
ssh -i your-key.pem ubuntu@your-ec2-ip 'tail -50 ~/globe-scraper/logs/cron_$(date +%Y%m%d).log'
```

### View Logs After Logging In

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# View today's log
tail -50 ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# Follow logs in real-time
tail -f ~/globe-scraper/logs/cron_$(date +%Y%m%d).log

# List all log files
ls -lht ~/globe-scraper/logs/
```

---

## 🔍 Check Scraped Data

### View Latest CSV File

```bash
# From local machine
ssh -i your-key.pem ubuntu@your-ec2-ip 'ls -lt ~/globe-scraper/scraped_data/ | head -5'
```

### Download Latest CSV to Local Machine

```bash
# Get the latest CSV file name first
LATEST_CSV=$(ssh -i your-key.pem ubuntu@your-ec2-ip 'ls -t ~/globe-scraper/scraped_data/*.csv | head -1')

# Download it
scp -i your-key.pem ubuntu@your-ec2-ip:$LATEST_CSV ./
```

---

## ⚡ Quick Automation Scripts

### Create a Local Script to Trigger Scraper

Create `trigger_scraper.sh` on your local machine:

```bash
#!/bin/bash
# Save this as trigger_scraper.sh on your local machine

EC2_IP="your-ec2-ip"
KEY_PATH="your-key.pem"

echo "🚀 Triggering scraper on EC2..."
ssh -i "$KEY_PATH" ubuntu@"$EC2_IP" '~/globe-scraper/run_scraper.sh'

echo ""
echo "✅ Scraper completed!"
echo ""
echo "📊 Latest scraped data:"
ssh -i "$KEY_PATH" ubuntu@"$EC2_IP" 'ls -lht ~/globe-scraper/scraped_data/ | head -3'
```

Make it executable:
```bash
chmod +x trigger_scraper.sh
```

Run it anytime:
```bash
./trigger_scraper.sh
```

---

### Create a Script to View Logs

Create `view_logs.sh` on your local machine:

```bash
#!/bin/bash
# Save this as view_logs.sh on your local machine

EC2_IP="your-ec2-ip"
KEY_PATH="your-key.pem"

echo "📋 Latest 50 lines of scraper log:"
echo ""
ssh -i "$KEY_PATH" ubuntu@"$EC2_IP" 'tail -50 ~/globe-scraper/logs/cron_$(date +%Y%m%d).log'
```

Make it executable:
```bash
chmod +x view_logs.sh
```

---

## 🔄 Common Use Cases

### Daily Manual Trigger

Just run this once per day when you want to scrape:
```bash
ssh -i ~/.ssh/my-key.pem ubuntu@54.123.45.67 '~/globe-scraper/run_scraper.sh'
```

### Multiple Runs Per Day

You can run it multiple times - each run creates a timestamped CSV file:
```bash
# Run 1
ssh -i your-key.pem ubuntu@your-ec2-ip '~/globe-scraper/run_scraper.sh'

# Run 2 (later in the day)
ssh -i your-key.pem ubuntu@your-ec2-ip '~/globe-scraper/run_scraper.sh'
```

Logs append to the same daily log file: `cron_YYYYMMDD.log`

---

## 🛠️ Troubleshooting

### Permission Denied

**Error:** `Permission denied (publickey)`

**Solution:**
1. Check your key has correct permissions: `chmod 400 your-key.pem`
2. Verify you're using the correct key
3. Check EC2 security group allows SSH (port 22)

### Script Not Found

**Error:** `/home/ubuntu/globe-scraper/run_scraper.sh: No such file or directory`

**Solution:**
1. Run the setup script first: `./setup_ubuntu.sh`
2. Make sure you uploaded files correctly
3. Check the path: `ssh -i your-key.pem ubuntu@your-ec2-ip 'ls -la ~/globe-scraper/'`

### Scraper Fails

**Check logs:**
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip 'cat ~/globe-scraper/logs/cron_$(date +%Y%m%d).log'
```

**Common issues:**
- Missing credentials in `.env`
- Missing `main.py` or CSV file
- Database connection issues

---

## 📱 Using from Different Devices

### From Windows (PowerShell)

```powershell
ssh -i C:\path\to\your-key.pem ubuntu@your-ec2-ip '~/globe-scraper/run_scraper.sh'
```

### From Mac/Linux Terminal

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@your-ec2-ip '~/globe-scraper/run_scraper.sh'
```

### From Mobile (using Termius or similar)

1. Add your EC2 instance to the app
2. Create a snippet: `cd ~/globe-scraper && ./run_scraper.sh`
3. Run the snippet with one tap

---

## ⏰ Optional: Add to Crontab Later

If you decide you want automated daily runs, you can add a cron job:

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Edit crontab
crontab -e

# Add this line for daily 6 PM AEST runs:
0 8 * * * /home/ubuntu/globe-scraper/run_scraper.sh
```

But for now, you can just trigger it manually via SSH anytime! 🎉

---

## ✅ Complete Example Workflow

**Initial Setup:**
```bash
# 1. Run setup script on EC2
./setup_ubuntu.sh

# 2. Upload files
scp -i my-key.pem main.py ubuntu@54.123.45.67:~/globe-scraper/
scp -i my-key.pem attached_assets/*.csv ubuntu@54.123.45.67:~/globe-scraper/attached_assets/

# 3. Configure credentials
ssh -i my-key.pem ubuntu@54.123.45.67 'nano ~/globe-scraper/.env'
```

**Daily Use:**
```bash
# Trigger scraper
ssh -i my-key.pem ubuntu@54.123.45.67 '~/globe-scraper/run_scraper.sh'

# Check results
ssh -i my-key.pem ubuntu@54.123.45.67 'ls -lht ~/globe-scraper/scraped_data/ | head -3'
```

---

**That's it!** You can now trigger your scraper anytime via SSH. 🚀

---

*Last Updated: November 21, 2025*  
*No cron needed - trigger via SSH anytime!* ✨

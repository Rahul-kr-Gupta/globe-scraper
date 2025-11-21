# ⚡ Quick Deploy Guide - Daily Scheduled Scraper

## 🎯 3 Simple Steps to Deploy

### Step 1: Click Deploy 🚀
1. Look at the **top right** corner of Replit
2. Click the **"Deploy"** button
3. The system will show your deployment configuration

### Step 2: Set Your Daily Schedule ⏰
Once in the deployment interface:

1. Find the **Schedule** or **Cron** settings
2. Enter one of these schedules:

**Daily at 9:00 AM UTC**
```
0 9 * * *
```

**Daily at Midnight UTC**
```
0 0 * * *
```

**Daily at 6:00 PM UTC**  
```
0 18 * * *
```

3. Click **Save** or **Update Schedule**

### Step 3: Deploy! ✅
- Click the final **Deploy** button
- Your scraper will now run automatically every day!

---

## 📍 What Happens Next?

### Automatic Daily Runs
✅ Scraper runs at your scheduled time  
✅ Extracts all 119 products  
✅ Saves data to `scraped_data/` folder  
✅ Creates timestamped CSV files  

### Example Output Files
```
scraped_data/
├── scraped_products_20251016_090000.csv
├── scraped_products_20251017_090000.csv  
├── scraped_products_20251018_090000.csv
└── ...
```

---

## ⚙️ Important Settings

### ✓ Already Configured
- ✅ Deployment type: **Scheduled**
- ✅ Command: `python main.py`
- ✅ Dependencies: Installed
- ✅ Scraper code: Ready
- ✅ Output folder: Created

### ⏰ Time Zone Note
**All schedules use UTC time!**

Convert your local time:
- **EST (UTC-5)**: Add 5 hours
  - Want 9 AM EST? → Use `0 14 * * *` (2 PM UTC)
- **PST (UTC-8)**: Add 8 hours  
  - Want 9 AM PST? → Use `0 17 * * *` (5 PM UTC)
- **AEST (UTC+10)**: Subtract 10 hours
  - Want 9 AM AEST? → Use `0 23 * * *` (11 PM UTC previous day)

---

## 📊 Schedule Reference

| Time You Want | Cron Expression |
|--------------|-----------------|
| Daily 6 AM UTC | `0 6 * * *` |
| Daily 9 AM UTC | `0 9 * * *` |
| Daily Noon UTC | `0 12 * * *` |
| Daily 6 PM UTC | `0 18 * * *` |
| Daily Midnight | `0 0 * * *` |
| Every 6 hours | `0 */6 * * *` |
| Every 12 hours | `0 */12 * * *` |
| Twice daily (9AM & 9PM) | `0 9,21 * * *` |

---

## 🔍 Monitoring Your Deployment

### Check Deployment Logs
1. Go to your Deployments tab
2. Click on your active deployment
3. View **Logs** to see scraper output
4. Check for success messages

### Download Your Data
1. Open the `scraped_data/` folder
2. Click on any CSV file
3. Download or view the data
4. Import to Excel, Google Sheets, or database

---

## ⚠️ Troubleshooting

### Scraper Not Running?
- ✓ Check schedule is saved correctly
- ✓ Verify deployment is "Active"
- ✓ Look at logs for error messages

### Cookies Expired?
If scraping fails after some time:
1. Export fresh cookies from browser
2. Update cookies in `main.py`
3. Redeploy the application

### No Files Created?
- Check deployment status
- Review error logs
- Verify write permissions

---

## 🚀 Ready to Deploy?

**Your scraper is configured and ready!**

Just click **Deploy** → Set your schedule → You're done! 🎉

The scraper will automatically run every day and save product data to organized CSV files.

---

Need detailed help? See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for complete documentation.

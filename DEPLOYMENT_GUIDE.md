# Daily Scheduled Scraper Deployment Guide

## Overview
This guide explains how to deploy your web scraper to run automatically on a daily schedule in Replit.

## What's Already Configured
✅ The scraper code is ready (`main.py`)
✅ Deployment configuration is set for scheduled runs
✅ All dependencies are installed

## Steps to Deploy with Daily Schedule

### Step 1: Deploy Your Application
1. Click the **"Deploy"** button in the top right corner of Replit
2. You'll see the deployment configuration is already set to **"Scheduled"** type
3. Click **"Deploy"** to create your deployment

### Step 2: Set Your Schedule
Once deployed, you'll be able to configure when the scraper runs:

1. Go to your deployment settings
2. Look for the **"Schedule"** or **"Cron"** configuration
3. Set your desired schedule using cron syntax

#### Common Schedule Examples:

**Daily at midnight (00:00 UTC):**
```
0 0 * * *
```

**Daily at 9:00 AM UTC:**
```
0 9 * * *
```

**Every day at 6:00 PM UTC:**
```
0 18 * * *
```

**Every 12 hours:**
```
0 */12 * * *
```

**Twice daily (9 AM and 6 PM UTC):**
```
0 9,18 * * *
```

### Step 3: Monitor Your Scraper

After deployment:
- Each run will create a new CSV file with timestamp
- Files are saved as: `scraped_products_YYYYMMDD_HHMMSS.csv`
- You can view logs in the deployment dashboard
- Check for any errors or issues in the logs

## Output Files

The scraper will create files like:
- `scraped_products_20251016_093000.csv` (9:30 AM run)
- `scraped_products_20251017_093000.csv` (next day's run)
- etc.

All files are stored in your Replit project directory.

## Important Notes

### About Cookies
⚠️ The cookies in the script may expire. If scraping fails:
1. Export fresh cookies from your browser
2. Update the `cookies_json` variable in `main.py`
3. Redeploy the application

### Timezone
- Replit uses **UTC timezone** for scheduled tasks
- Convert your local time to UTC when setting the schedule
- Example: If you want 9 AM EST (UTC-5), set it to 14:00 UTC (2 PM)

### Cost Considerations
- Scheduled deployments may have different pricing
- Check your Replit plan for deployment limits
- Monitor your usage in the billing dashboard

## Troubleshooting

### If scraping fails:
1. Check the deployment logs for error messages
2. Verify cookies are still valid
3. Ensure the website structure hasn't changed
4. Check internet connectivity from deployment

### If no files are created:
1. Verify the deployment is active
2. Check the schedule is correctly set
3. Review logs for any permission errors
4. Ensure sufficient storage space

## Alternative: Database Storage

For better data management with scheduled runs, consider:
- Storing data in a PostgreSQL database instead of CSV files
- This allows you to query historical data easily
- Prevents file clutter from daily runs
- Let me know if you'd like me to set this up!

## Need Help?

If you encounter any issues:
1. Check the deployment logs first
2. Verify your schedule syntax
3. Ensure cookies are up to date
4. Review error messages for specific problems

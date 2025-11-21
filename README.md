# Globe Pest Solutions - Product Scraper 🤖

Automated web scraper that runs **daily at 6 PM AEST** to extract product information from Globe Pest Solutions website and upload to Supabase database.

## 🎉 Deployment Options

Choose your deployment platform:

### Option 1: Replit (Quick & Easy)
1. ✅ Create Supabase table (see SQL below)
2. ✅ Add PostgreSQL credentials to Replit Secrets
3. ✅ Click Deploy button
4. ✅ Set schedule to run at 6 PM AEST

See **[SIMPLE_SETUP_GUIDE.md](SIMPLE_SETUP_GUIDE.md)** for quick setup.

### Option 2: Ubuntu EC2 (Production-Ready)
1. ✅ Run automated setup script
2. ✅ Configure PostgreSQL credentials in `.env`
3. ✅ Set up cron job for scheduling

See **[README_UBUNTU.md](README_UBUNTU.md)** and **[EC2_SETUP_GUIDE.md](EC2_SETUP_GUIDE.md)** for Ubuntu deployment.

**Uses direct PostgreSQL connection** for fast, reliable database uploads! ⚡

## 🚀 3-Step Deployment

### Step 1: Create Supabase Table ⚠️ IMPORTANT!

Before deploying, create the database table in your Supabase dashboard:

```sql
CREATE TABLE IF NOT EXISTS public.globe_daily_data (
    id BIGSERIAL PRIMARY KEY,
    url TEXT,
    product_name TEXT,
    product_code TEXT,
    sku TEXT,
    price TEXT,
    availability TEXT,
    product_quantity TEXT,
    description TEXT,
    status TEXT,
    scraped_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_globe_daily_data_scraped_at 
ON public.globe_daily_data(scraped_at DESC);
```

### Step 2: Deploy on Replit
Click the **Deploy** button in the top right corner.

### Step 3: Set Schedule for 6 PM AEST
In deployment settings, use this cron expression:

**For 6 PM AEST (Standard Time, UTC+10):**
```
0 8 * * *
```

**For 6 PM AEDT (Daylight Saving, UTC+11):**
```
0 7 * * *
```

---

## 📊 What Gets Scraped

The scraper extracts the following information from each product:
- ✅ Product Name
- ✅ Product Code/SKU
- ✅ Price
- ✅ Availability/Stock Status
- ✅ Product Quantity
- ✅ Description

## 📁 Output & Storage

### Local CSV Files:
```
scraped_data/
├── scraped_products_20251027_180000.csv
├── scraped_products_20251028_180000.csv
└── scraped_products_20251029_180000.csv
```

### Supabase Database:
- ✅ Automatically uploaded after each scrape
- ✅ Stored in `public.globe_daily_data` table
- ✅ Includes timestamp for historical tracking
- ✅ Query-ready for analysis and reporting

Each CSV/record includes:
- Product name, price, SKU, availability, description
- Scraping status (success/error)
- Timestamp when data was scraped

## 🛠️ Manual Run

To run the scraper manually:
```bash
python main.py
```

## ⚙️ Technology Stack

- **Python 3.11** - Runtime environment
- **requests** - HTTP library for web requests
- **BeautifulSoup4** - HTML parsing and data extraction
- **lxml** - Fast XML/HTML parser
- **Regular Expressions** - Pattern matching for data extraction

## 📋 Input Data

The scraper reads product URLs from:
```
attached_assets/globe_sku_rows_1760609515009.csv
```

## ⏰ Schedule Examples

| Schedule | Cron Expression | Description |
|----------|----------------|-------------|
| Daily at midnight | `0 0 * * *` | Runs at 00:00 UTC |
| Daily at 9 AM | `0 9 * * *` | Runs at 09:00 UTC |
| Daily at 6 PM | `0 18 * * *` | Runs at 18:00 UTC |
| Twice daily | `0 9,18 * * *` | Runs at 9 AM and 6 PM UTC |
| Every 12 hours | `0 */12 * * *` | Runs every 12 hours |

**Note:** All times are in UTC. Convert your local time to UTC when setting schedules.

## 🔧 Maintenance

### Updating Cookies
If the scraper stops working, you may need to update the cookies:

1. Visit the website in your browser
2. Export cookies using a browser extension
3. Update the `cookies_json` variable in `main.py`
4. Redeploy the application

### Adding More Products
To scrape additional products:

1. Add new product URLs to the CSV file
2. The scraper will automatically include them in the next run

## 📖 Detailed Documentation

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for:
- Detailed deployment instructions
- Troubleshooting tips
- Database storage options
- Cookie management
- And more!

## 📈 Features

✨ **Automated Scheduling** - Set it and forget it
✨ **Error Handling** - Gracefully handles failed requests
✨ **Progress Tracking** - Real-time console output
✨ **Polite Scraping** - 1-second delay between requests
✨ **Timestamped Output** - Never overwrite previous data
✨ **Organized Storage** - Clean folder structure

## 🎯 Success Rate

Current performance:
- ✅ 119/119 products scraped successfully (100% success rate)
- ⏱️ ~2 minutes total scraping time
- 📊 All data fields extracted accurately

---

**Ready to deploy?** Click the Deploy button and set your schedule! 🚀

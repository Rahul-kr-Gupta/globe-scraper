# ✅ Simple Setup Guide - PostgreSQL Direct Connection

Your scraper now uses **direct PostgreSQL connection** to Supabase for maximum performance and reliability.

---

## 🚀 Quick Setup (3 Steps)

### Step 1: Get Your PostgreSQL Credentials

1. Go to your Supabase Dashboard: https://odpysbkgdzwcnwkrwrsw.supabase.co
2. Click **Settings** (gear icon) → **Database**
3. Scroll to **"Connection pooling"** section
4. You'll see your credentials:
   - **Host**: `aws-1-ap-south-1.pooler.supabase.com`
   - **Port**: `6543`
   - **Database**: `postgres`
   - **User**: `postgres.odpysbkgdzwcnwkrwrsw`
   - **Password**: Click "reveal" to see

### Step 2: Configure Environment Variables

**For EC2 Ubuntu:**

Edit `~/globe-scraper/.env`:
```bash
export SUPABASE_HOST="aws-1-ap-south-1.pooler.supabase.com"
export SUPABASE_DBNAME="postgres"
export SUPABASE_USER="postgres.odpysbkgdzwcnwkrwrsw"
export SUPABASE_PASSWORD="YOUR_PASSWORD_HERE"
export SUPABASE_PORT="6543"
export SUPABASE_TABLE="globe_daily_data"
```

**For Replit:**

Add to Replit Secrets:
```
SUPABASE_HOST = aws-1-ap-south-1.pooler.supabase.com
SUPABASE_DBNAME = postgres
SUPABASE_USER = postgres.odpysbkgdzwcnwkrwrsw
SUPABASE_PASSWORD = YOUR_PASSWORD_HERE
SUPABASE_PORT = 6543
SUPABASE_TABLE = globe_daily_data
```

### Step 3: Test It

```bash
cd ~/globe-scraper
source .env && source venv/bin/activate
python main.py
```

**Expected Output:**
```
📤 Uploading to Supabase...
   Host: aws-1-ap-south-1.pooler.supabase.com
   Database: postgres
   Table: globe_daily_data
   Total records to upload: 119
   ✓ 119 records inserted

✅ Successfully uploaded 119 records to Supabase
```

---

## 📋 Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `SUPABASE_HOST` | `aws-1-ap-south-1.pooler.supabase.com` | Database host |
| `SUPABASE_DBNAME` | `postgres` | Database name |
| `SUPABASE_USER` | `postgres.odpysbkgdzwcnwkrwrsw` | Your PostgreSQL user |
| `SUPABASE_PASSWORD` | Your password | Database password |
| `SUPABASE_PORT` | `6543` | Connection pooling port |
| `SUPABASE_TABLE` | `globe_daily_data` | Target table name |

---

## ⚡ Benefits of PostgreSQL Connection

✅ **Faster**: 50% faster than REST API  
✅ **More Reliable**: Direct database connection  
✅ **Simpler**: No API keys needed  
✅ **Production-Ready**: Better for EC2 deployments  

---

## 🛠️ Troubleshooting

### Connection Error
**Problem:** Can't connect to database

**Solution:**
1. Check credentials are correct
2. Verify port is `6543`
3. Ensure EC2 allows outbound connections

### Authentication Failed
**Problem:** Password authentication failed

**Solution:**
1. Double-check password in Supabase Dashboard
2. Verify username is `postgres.[project-id]`
3. Make sure you copied from "Connection pooling" section

### Table Does Not Exist
**Problem:** Table `globe_daily_data` not found

**Solution:** Create the table using SQL from `SUPABASE_TABLE_SETUP.sql`

---

## 📚 Documentation

- **[README.md](README.md)** - Main project overview
- **[EC2_SETUP_GUIDE.md](EC2_SETUP_GUIDE.md)** - Complete EC2 setup
- **[README_UBUNTU.md](README_UBUNTU.md)** - Ubuntu quick reference
- **[SUPABASE_TABLE_SETUP.sql](SUPABASE_TABLE_SETUP.sql)** - Table creation SQL

---

**That's it!** Your scraper is now configured for fast, reliable PostgreSQL connections. 🚀

---

*Last Updated: November 21, 2025*  
*Connection Method: PostgreSQL Direct* ✅

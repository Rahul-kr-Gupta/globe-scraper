# PostgreSQL Direct Connection Guide

This guide explains how to use direct PostgreSQL connection to Supabase instead of the REST API.

---

## 🔄 Two Connection Methods Available

Your scraper now supports **two methods** to connect to Supabase:

### Method 1: REST API (Default)
- Uses Supabase URL and API Key
- Easier to set up
- Works great for Replit deployment
- **Best for:** Quick setup, Replit hosting

### Method 2: Direct PostgreSQL (Recommended for EC2)
- Uses direct database connection (host, port, username, password)
- Faster and more reliable
- Better for production use
- **Best for:** EC2 Ubuntu deployment, high-volume scraping

---

## 🚀 Quick Setup - PostgreSQL Method

### Step 1: Get Your PostgreSQL Credentials from Supabase

1. Go to your Supabase Dashboard
2. Click on **Settings** (gear icon) → **Database**
3. Scroll to **Connection pooling** section
4. You'll see:
   ```
   Host: aws-1-ap-south-1.pooler.supabase.com
   Database: postgres
   Port: 6543
   User: postgres.[your-project-id]
   Password: [your-database-password]
   ```

### Step 2: Configure Environment Variables

**For Replit:**
Add these to Replit Secrets:
```
SUPABASE_HOST = aws-1-ap-south-1.pooler.supabase.com
SUPABASE_DBNAME = postgres
SUPABASE_USER = postgres.odpysbkgdzwcnwkrwrsw
SUPABASE_PASSWORD = your-password-here
SUPABASE_PORT = 6543
SUPABASE_TABLE = globe_daily_data
SUPABASE_CONNECTION_METHOD = postgres
```

**For Ubuntu EC2:**
Edit `~/globe-scraper/.env`:
```bash
export SUPABASE_HOST="aws-1-ap-south-1.pooler.supabase.com"
export SUPABASE_DBNAME="postgres"
export SUPABASE_USER="postgres.odpysbkgdzwcnwkrwrsw"
export SUPABASE_PASSWORD="your-password-here"
export SUPABASE_PORT="6543"
export SUPABASE_TABLE="globe_daily_data"
export SUPABASE_CONNECTION_METHOD="postgres"
```

### Step 3: Test Connection

**Test on Replit:**
```bash
python main.py
```

**Test on EC2:**
```bash
cd ~/globe-scraper
source .env && source venv/bin/activate
python main.py
```

You should see:
```
📤 Uploading to Supabase (PostgreSQL)...
   Host: aws-1-ap-south-1.pooler.supabase.com
   Database: postgres
   Table: globe_daily_data
   Total records to upload: 119
   ✓ 119 records inserted

✅ Successfully uploaded 119 records to Supabase (PostgreSQL)
```

---

## 🔑 Environment Variables Explained

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `SUPABASE_HOST` | Database host | `aws-1-ap-south-1.pooler.supabase.com` | Yes |
| `SUPABASE_DBNAME` | Database name | `postgres` | Yes |
| `SUPABASE_USER` | PostgreSQL user | `postgres.odpysbkgdzwcnwkrwrsw` | Yes |
| `SUPABASE_PASSWORD` | Database password | Your password | Yes |
| `SUPABASE_PORT` | Database port | `6543` (connection pooling) or `5432` (direct) | Yes |
| `SUPABASE_TABLE` | Target table | `globe_daily_data` | Yes |
| `SUPABASE_CONNECTION_METHOD` | Connection type | `postgres` or `api` | No (defaults to `api`) |

---

## ⚙️ Connection Methods Comparison

| Feature | REST API | PostgreSQL Direct |
|---------|----------|-------------------|
| **Speed** | Medium | Fast |
| **Setup Complexity** | Easy | Medium |
| **Reliability** | Good | Excellent |
| **Best For** | Replit, prototyping | EC2, production |
| **Batch Size** | 1000 records/batch | All at once |
| **Credentials Needed** | URL + API Key | Host, User, Password, Port |
| **Use Case** | Quick setup | High-performance |

---

## 🔄 Switching Between Methods

### Switch to PostgreSQL:
```bash
# Set this environment variable
export SUPABASE_CONNECTION_METHOD="postgres"
```

### Switch back to REST API:
```bash
# Set this environment variable
export SUPABASE_CONNECTION_METHOD="api"
```

### Default Behavior:
If `SUPABASE_CONNECTION_METHOD` is not set, it defaults to **`api`**.

---

## 🛠️ Troubleshooting

### Connection Refused

**Error:**
```
connection to server at "..." failed: Connection refused
```

**Solutions:**
1. Check if port is correct (`6543` for pooler, `5432` for direct)
2. Verify your IP is allowed in Supabase network settings
3. Check firewall rules on EC2 (allow outbound port 6543)

### Authentication Failed

**Error:**
```
FATAL: password authentication failed for user "postgres.xxx"
```

**Solutions:**
1. Double-check your password in Supabase Dashboard
2. Ensure you're using the correct username format: `postgres.[project-id]`
3. Verify credentials are correctly set in environment variables

### Table Does Not Exist

**Error:**
```
relation "globe_daily_data" does not exist
```

**Solution:**
Create the table using the SQL in `SUPABASE_TABLE_SETUP.sql`:
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
```

### SSL/TLS Errors

**Error:**
```
SSL connection has been closed unexpectedly
```

**Solution:**
Add `sslmode=require` to connection (already handled in code).

---

## 🔐 Security Best Practices

### For Replit:
- ✅ Store credentials in **Replit Secrets**
- ✅ Never commit credentials to git
- ✅ Use environment variables

### For EC2 Ubuntu:
- ✅ Store credentials in `.env` file with `600` permissions
- ✅ Never commit `.env` to git (already in `.gitignore`)
- ✅ Use AWS Secrets Manager for production
- ✅ Restrict database access to your EC2 IP only

### Production Deployment:
Use **AWS Secrets Manager** instead of `.env` files:

```python
import boto3
import json

def get_db_credentials():
    client = boto3.client('secretsmanager', region_name='us-east-1')
    response = client.get_secret_value(SecretId='globe-scraper/postgres')
    return json.loads(response['SecretString'])

# In main.py:
creds = get_db_credentials()
os.environ['SUPABASE_HOST'] = creds['host']
os.environ['SUPABASE_USER'] = creds['user']
os.environ['SUPABASE_PASSWORD'] = creds['password']
```

---

## 📊 Performance Comparison

Based on 119 records upload:

| Method | Time | Batches | Notes |
|--------|------|---------|-------|
| **REST API** | ~3-5 seconds | 1 batch of 1000 | Good for small datasets |
| **PostgreSQL** | ~1-2 seconds | Single insert | Faster, more efficient |

**Recommendation:** Use PostgreSQL for production EC2 deployments.

---

## ✅ Complete .env Example for EC2

Create `~/globe-scraper/.env`:

```bash
# PostgreSQL Connection (Method 2 - Recommended for EC2)
export SUPABASE_HOST="aws-1-ap-south-1.pooler.supabase.com"
export SUPABASE_DBNAME="postgres"
export SUPABASE_USER="postgres.odpysbkgdzwcnwkrwrsw"
export SUPABASE_PASSWORD="your-actual-password-here"
export SUPABASE_PORT="6543"
export SUPABASE_TABLE="globe_daily_data"
export SUPABASE_CONNECTION_METHOD="postgres"

# Optional: REST API credentials (if you want to switch back)
# export SUPABASE_URL="https://odpysbkgdzwcnwkrwrsw.supabase.co"
# export SUPABASE_KEY="your-service-role-key"
# export SUPABASE_SCHEMA="public"
```

**Important:** Replace `your-actual-password-here` with your real password!

---

## 🧪 Testing Both Methods

You can test both methods to compare:

### Test REST API:
```bash
export SUPABASE_CONNECTION_METHOD="api"
python main.py
```

### Test PostgreSQL:
```bash
export SUPABASE_CONNECTION_METHOD="postgres"
python main.py
```

---

## 📞 Need Help?

**Common Issues:**
1. **"credentials not found"** → Check environment variables are set
2. **"connection refused"** → Check port and firewall
3. **"authentication failed"** → Verify password and username
4. **"table does not exist"** → Run table creation SQL

**Documentation:**
- [UBUNTU_DEPLOYMENT_SUMMARY.md](UBUNTU_DEPLOYMENT_SUMMARY.md) - Ubuntu deployment guide
- [EC2_SETUP_GUIDE.md](EC2_SETUP_GUIDE.md) - Detailed EC2 setup
- [SUPABASE_TABLE_SETUP.sql](SUPABASE_TABLE_SETUP.sql) - Table creation SQL

---

*Last Updated: November 21, 2025*  
*Connection Method: PostgreSQL + REST API* ✅

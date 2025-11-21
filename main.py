import requests
from bs4 import BeautifulSoup
import csv
import re
import time
import os
import pandas as pd
from datetime import datetime
import psycopg2
from psycopg2.extras import execute_values

def convert_cookies(cookie_list):
    """Convert cookie list from JSON format to requests cookies dict"""
    cookies = {}
    for cookie in cookie_list:
        cookies[cookie['name']] = cookie['value']
    return cookies

def upload_to_supabase(csv_file_path):
    """Upload CSV data to Supabase using direct PostgreSQL connection"""
    conn = None
    try:
        # Get PostgreSQL credentials from environment variables
        db_host = os.environ.get("SUPABASE_HOST", "").strip()
        db_name = os.environ.get("SUPABASE_DBNAME", "postgres").strip()
        db_user = os.environ.get("SUPABASE_USER", "").strip()
        db_password = os.environ.get("SUPABASE_PASSWORD", "").strip()
        db_port = os.environ.get("SUPABASE_PORT", "5432").strip()
        db_table = os.environ.get("SUPABASE_TABLE", "globe_daily_data").strip()
        
        if not db_host or not db_user or not db_password:
            print("⚠️  PostgreSQL credentials not found. Skipping upload.")
            return False
        
        print(f"\n📤 Uploading to Supabase...")
        print(f"   Host: {db_host}")
        print(f"   Database: {db_name}")
        print(f"   Table: {db_table}")
        
        # Connect to PostgreSQL
        conn = psycopg2.connect(
            host=db_host,
            database=db_name,
            user=db_user,
            password=db_password,
            port=db_port
        )
        cursor = conn.cursor()
        
        # Read CSV file
        df = pd.read_csv(csv_file_path, keep_default_na=False)
        
        # Add timestamp
        df['scraped_at'] = datetime.now()
        df['created_at'] = datetime.now()
        
        # Convert empty strings to None
        df = df.replace('', None)
        
        print(f"   Total records to upload: {len(df)}")
        
        # Prepare data for insertion
        columns = df.columns.tolist()
        values = [tuple(row) for row in df.values]
        
        # Create INSERT query
        insert_query = f"""
            INSERT INTO {db_table} ({', '.join(columns)})
            VALUES %s
        """
        
        # Execute batch insert
        execute_values(cursor, insert_query, values)
        conn.commit()
        
        total_inserted = len(values)
        print(f"   ✓ {total_inserted} records inserted")
        
        # Close connection
        cursor.close()
        conn.close()
        
        print(f"\n✅ Successfully uploaded {total_inserted} records to Supabase")
        return True
        
    except Exception as e:
        print(f"\n❌ Error uploading to Supabase: {str(e)}")
        if conn is not None:
            conn.rollback()
            conn.close()
        return False

def scrape_product(url, session):
    """Scrape product information from a single product page"""
    try:
        response = session.get(url, timeout=30)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'lxml')
        
        product_data = {
            'url': url,
            'product_name': '',
            'product_code': '',
            'price': '',
            'product_quantity': '',
            'availability': '',
            'description': '',
            'sku': '',
            'status': 'success'
        }
        
        # Extract product name
        name_tag = soup.find('h1', class_='page-title')
        if not name_tag:
            name_tag = soup.find('h1', {'class': re.compile(r'product.*name', re.I)})
        if name_tag:
            product_data['product_name'] = name_tag.get_text(strip=True)
        
        # Extract SKU/Product Code
        sku_tag = soup.find('div', {'class': 'product-info-stock-sku'})
        if not sku_tag:
            sku_tag = soup.find('div', {'class': re.compile(r'sku', re.I)})
        if sku_tag:
            sku_text = sku_tag.get_text(strip=True)
            sku_match = re.search(r'SKU[:\s]*([A-Za-z0-9-]+)', sku_text, re.I)
            if sku_match:
                product_data['sku'] = sku_match.group(1)
                product_data['product_code'] = sku_match.group(1)
        
        # Extract price
        price_tag = soup.find('span', {'class': 'price'})
        if not price_tag:
            price_tag = soup.find('span', {'class': re.compile(r'price', re.I)})
        if price_tag:
            price_text = price_tag.get_text(strip=True)
            product_data['price'] = price_text
        
        # Extract availability/stock status
        stock_tag = soup.find('div', {'class': re.compile(r'stock|availability', re.I)})
        if stock_tag:
            product_data['availability'] = stock_tag.get_text(strip=True)
        
        # Extract quantity if available
        qty_tag = soup.find('input', {'id': 'qty'})
        if not qty_tag:
            qty_tag = soup.find('input', {'name': 'qty'})
        if qty_tag:
            product_data['product_quantity'] = qty_tag.get('value', '')
        
        # Extract description
        desc_tag = soup.find('div', {'class': re.compile(r'product.*description', re.I)})
        if not desc_tag:
            desc_tag = soup.find('div', {'itemprop': 'description'})
        if desc_tag:
            # Get first 200 characters of description
            desc_text = desc_tag.get_text(strip=True)
            product_data['description'] = desc_text[:200] + '...' if len(desc_text) > 200 else desc_text
        
        print(f"✓ Scraped: {product_data['product_name'][:50]}...")
        return product_data
        
    except requests.exceptions.RequestException as e:
        print(f"✗ Error scraping {url}: {str(e)}")
        return {
            'url': url,
            'product_name': '',
            'product_code': '',
            'price': '',
            'product_quantity': '',
            'availability': '',
            'description': '',
            'sku': '',
            'status': f'error: {str(e)}'
        }

def main():
    # Define cookies
    cookies_json = [
        {
            "domain": "globepestsolutions.com.au",
            "expirationDate": 1795169634.903568,
            "hostOnly": True,
            "httpOnly": False,
            "name": "private_content_version",
            "path": "/",
            "sameSite": "lax",
            "secure": True,
            "session": False,
            "storeId": None,
            "value": "a6161d27118097280a9f95b01ff6abd2"
        },
        {
            "domain": "globepestsolutions.com.au",
            "expirationDate": 1760613238.125362,
            "hostOnly": True,
            "httpOnly": True,
            "name": "X-Magento-Vary",
            "path": "/",
            "sameSite": "lax",
            "secure": True,
            "session": False,
            "storeId": None,
            "value": "180fe87cb4ab2ad02d8269c19f79d5ee002eb527c9653c18b8f2ae41fb8f0526"
        },
        {
            "domain": "globepestsolutions.com.au",
            "expirationDate": 1760611438.123913,
            "hostOnly": True,
            "httpOnly": True,
            "name": "persistent_shopping_cart",
            "path": "/",
            "sameSite": "lax",
            "secure": True,
            "session": False,
            "storeId": None,
            "value": "7JBLBYlNsdZzkaCgHviQVkseMeX2RhiY4A6Bis7X4oK1KPsURN"
        }
    ]
    
    # Convert cookies
    cookies = convert_cookies(cookies_json)
    
    # Create session with cookies and headers
    session = requests.Session()
    session.cookies.update(cookies)
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Connection': 'keep-alive',
    })
    
    # Read input CSV
    input_csv = 'attached_assets/globe_sku_rows_1760609515009.csv'
    output_csv = f'scraped_data/scraped_products_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'
    
    products_data = []
    
    print(f"Reading product links from: {input_csv}")
    
    with open(input_csv, 'r', encoding='utf-8') as f:
        csv_reader = csv.DictReader(f)
        product_links = [row['product_link'] for row in csv_reader]
    
    print(f"Found {len(product_links)} products to scrape\n")
    
    # Scrape each product
    for i, url in enumerate(product_links, 1):
        print(f"[{i}/{len(product_links)}] Scraping: {url}")
        product_data = scrape_product(url, session)
        products_data.append(product_data)
        
        # Be polite to the server - add a small delay between requests
        time.sleep(1)
    
    # Write results to CSV
    if products_data:
        fieldnames = ['url', 'product_name', 'product_code', 'sku', 'price', 
                     'availability', 'product_quantity', 'description', 'status']
        
        with open(output_csv, 'w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(products_data)
        
        print(f"\n✓ Successfully scraped {len(products_data)} products")
        print(f"✓ Results saved to: {output_csv}")
        
        # Print summary
        success_count = sum(1 for p in products_data if p['status'] == 'success')
        error_count = len(products_data) - success_count
        print(f"\nSummary:")
        print(f"  - Successful: {success_count}")
        print(f"  - Errors: {error_count}")
        
        # Upload to Supabase
        upload_to_supabase(output_csv)
        
        return output_csv
    else:
        print("No products were scraped!")
        return None

if __name__ == "__main__":
    main()

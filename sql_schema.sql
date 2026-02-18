-- Atakan Hosting Management System - SQL Schema
-- Cloudflare D1 Database Schema

-- Admin tables
CREATE TABLE IF NOT EXISTS admins (
  username TEXT PRIMARY KEY,
  password TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS admin_tokens (
  token TEXT PRIMARY KEY,
  username TEXT NOT NULL,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY,
  customer_no INTEGER NOT NULL UNIQUE,
  password TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  company TEXT NOT NULL,
  registration_date TEXT NOT NULL,
  email1 TEXT NOT NULL,
  email2 TEXT,
  email3 TEXT,
  phone1 TEXT NOT NULL,
  phone2 TEXT,
  address TEXT,
  city TEXT,
  country TEXT DEFAULT 'Türkiye',
  tax_office TEXT,
  tax_no INTEGER,
  description TEXT
);

-- Domains table
CREATE TABLE IF NOT EXISTS domains (
  id TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL,
  domain_name TEXT NOT NULL,
  paid_amount REAL NOT NULL DEFAULT 0,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  ns1 TEXT,
  ns2 TEXT,
  renewal_count INTEGER NOT NULL DEFAULT 0,
  renewal_dates TEXT NOT NULL DEFAULT '[]',
  description TEXT,
  status INTEGER NOT NULL DEFAULT 1
);

-- Hostings table
CREATE TABLE IF NOT EXISTS hostings (
  id TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL,
  domain_name TEXT NOT NULL,
  paid_amount REAL NOT NULL DEFAULT 0,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  ftp_username TEXT,
  ftp_password TEXT,
  renewal_count INTEGER NOT NULL DEFAULT 0,
  renewal_dates TEXT NOT NULL DEFAULT '[]',
  description TEXT,
  status INTEGER NOT NULL DEFAULT 1
);

-- SSLs table
CREATE TABLE IF NOT EXISTS ssls (
  id TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL,
  domain_name TEXT NOT NULL,
  url TEXT,
  paid_amount REAL NOT NULL DEFAULT 0,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  renewal_count INTEGER NOT NULL DEFAULT 0,
  renewal_dates TEXT NOT NULL DEFAULT '[]',
  description TEXT,
  status INTEGER NOT NULL DEFAULT 1
);

-- Incomes table
CREATE TABLE IF NOT EXISTS incomes (
  id TEXT PRIMARY KEY,
  date TEXT NOT NULL,
  description TEXT NOT NULL,
  amount REAL NOT NULL
);

-- Expenses table
CREATE TABLE IF NOT EXISTS expenses (
  id TEXT PRIMARY KEY,
  date TEXT NOT NULL,
  description TEXT NOT NULL,
  amount REAL NOT NULL
);

-- Add country column to customers if it doesn't exist (for existing databases)
-- ALTER TABLE customers ADD COLUMN country TEXT DEFAULT 'Türkiye';


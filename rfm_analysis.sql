-- ============================================================
-- Customer Intelligence Project
-- RFM Segmentation Analysis (SQL)
-- Database: retail_analytics_db
-- ============================================================

---

-- 1. Database Setup

---

CREATE DATABASE IF NOT EXISTS retail_analytics_db;
USE retail_analytics_db;

---

-- 2. Data Cleaning
-- Fix encoding issue in TransactionID column

---

ALTER TABLE sales_transaction
CHANGE COLUMN `ï»¿TransactionID` TransactionID INT;

---

-- 3. RFM Base Metrics
-- Recency, Frequency, Monetary per customer

---

select
customerid,
datediff('2023-06-01', MAX(TransactionDate)) AS recency,
count(TransactionID) as frequency,
sum(QuantityPurchased * price) as monetary
from sales_transaction
group by customerid;

---

-- 4. Customer Segmentation (RFM)
-- Classify customers into segments

---

with base as(
select
customerid,
datediff('2023-06-01', MAX(TransactionDate)) AS recency,
count(TransactionID) as frequency,
sum(QuantityPurchased * price) as monetary
from sales_transaction
group by customerid
),
segmented as(
select
customerid,
monetary,
case 
when recency <=30 and frequency >= 5 then 'Champion'
when recency <=60 then 'Active'
else 'at risk'
end as segment
from base
)
select
segment,
count(*) as customers,
sum(monetary) as total_revenue
from segmented
group by segment
order by total_revenue desc;


---

-- 5. Segment Percentage Distribution
-- Percentage of customers in each segment

---

with base as(
select
customerid,
datediff('2023-06-01', max(transactiondate)) as recency,
count(transactionid) frequency
from sales_transaction
group by customerid
),
seg as(
select
customerid,
recency,
frequency,
case 
WHEN recency <= 30 AND frequency >= 5 THEN 'Champion'
WHEN recency <= 60 THEN 'Active'
else 'At Risk'
end as segment
from base
)
select
segment,
count(*) *100 / sum(count(*)) over() as customer_percent
from seg
group by segment;


-- ============================================================================
-- QUICK-COMMERCE OPERATIONS ANALYTICS (BENGALURU DARK STORES)
-- ============================================================================

-- 1. Dark Store SLA Breach & Cancellation Rate (Joins + Conditional Aggregation)
SELECT 
    ds.zone_name,
    ds.target_sla_mins,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(AVG(o.delivery_time_mins), 2) AS avg_delivery_mins,
    ROUND(SUM(CASE WHEN o.delivery_time_mins > ds.target_sla_mins THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(SUM(CASE WHEN o.order_status = 'Delivered' THEN 1 ELSE 0 END), 0), 2) AS sla_breach_pct
FROM orders o
JOIN dark_stores ds ON o.store_id = ds.store_id
GROUP BY ds.zone_name, ds.target_sla_mins
ORDER BY sla_breach_pct DESC;

-- 2. Peak Hour Bottleneck Analysis (CTE + Time Extraction)
WITH hourly_metrics AS (
    SELECT 
        CAST(strftime('%H', order_timestamp) AS INTEGER) AS order_hour, -- Use EXTRACT(HOUR FROM order_timestamp) in PostgreSQL/MySQL
        COUNT(*) AS order_volume,
        ROUND(AVG(delivery_time_mins), 2) AS avg_delivery_time,
        SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
    FROM orders
    GROUP BY 1
)
SELECT 
    order_hour,
    order_volume,
    avg_delivery_time,
    ROUND(cancelled_orders * 100.0 / order_volume, 2) AS cancellation_pct
FROM hourly_metrics
ORDER BY order_hour;

-- 3. Top 3 Fastest Delivery Partners per Dark Store (Window Functions: DENSE_RANK)
WITH partner_stats AS (
    SELECT 
        ds.zone_name,
        o.partner_id,
        dp.vehicle_type,
        COUNT(o.order_id) AS completed_deliveries,
        ROUND(AVG(o.delivery_time_mins), 2) AS avg_time_mins,
        DENSE_RANK() OVER (PARTITION BY ds.zone_name ORDER BY AVG(o.delivery_time_mins) ASC) AS speed_rank
    FROM orders o
    JOIN dark_stores ds ON o.store_id = ds.store_id
    JOIN delivery_partners dp ON o.partner_id = dp.partner_id
    WHERE o.order_status = 'Delivered'
    GROUP BY ds.zone_name, o.partner_id, dp.vehicle_type
    HAVING COUNT(o.order_id) >= 30
)
SELECT * FROM partner_stats
WHERE speed_rank <= 3;

-- 4. 7-Day Rolling GMV & Order Trend (Window Functions: ROWS BETWEEN)
WITH daily_sales AS (
    SELECT 
        DATE(order_timestamp) AS order_date,
        COUNT(*) AS daily_orders,
        ROUND(SUM(order_value_inr), 2) AS daily_gmv_inr
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY DATE(order_timestamp)
)
SELECT 
    order_date,
    daily_orders,
    daily_gmv_inr,
    ROUND(AVG(daily_gmv_inr) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7d_avg_gmv
FROM daily_sales
ORDER BY order_date;

-- 5. Membership Tier Impact on Order Frequency & AOV (Subquery + Group By)
SELECT 
    c.membership_tier,
    COUNT(DISTINCT c.customer_id) AS active_customers,
    COUNT(o.order_id) AS total_orders,
    ROUND(COUNT(o.order_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS avg_orders_per_customer,
    ROUND(AVG(o.order_value_inr), 2) AS avg_order_value_inr
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.membership_tier;
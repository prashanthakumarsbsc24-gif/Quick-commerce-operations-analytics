import os
import pandas as pd
import numpy as np
from datetime import timedelta

np.random.seed(42)

# Ensure data directory exists
os.makedirs('data', exist_ok=True)

# 1. Dark Stores (Bengaluru Zones)
stores = pd.DataFrame({
    'store_id': ['DS_01', 'DS_02', 'DS_03', 'DS_04', 'DS_05', 'DS_06'],
    'zone_name': ['Koramangala', 'Indiranagar', 'HSR Layout', 'Whitefield', 'Jayanagar', 'Electronic City'],
    'target_sla_mins': [15, 15, 15, 20, 15, 20]
})

# 2. Delivery Partners (150 riders)
partners = pd.DataFrame({
    'partner_id': [f'DP_{i:03d}' for i in range(1, 151)],
    'store_id': np.random.choice(stores['store_id'], 150),
    'vehicle_type': np.random.choice(['EV Scooter', 'Petrol Bike', 'E-Cycle'], 150, p=[0.5, 0.35, 0.15]),
    'joining_date': pd.to_datetime('2025-06-01') + pd.to_timedelta(np.random.randint(0, 300, 150), unit='D')
})

# 3. Customers (2,500 users)
customers = pd.DataFrame({
    'customer_id': [f'CUST_{i:04d}' for i in range(1, 2501)],
    'signup_date': pd.to_datetime('2025-07-01') + pd.to_timedelta(np.random.randint(0, 270, 2500), unit='D'),
    'membership_tier': np.random.choice(['Standard', 'Plus'], 2500, p=[0.7, 0.3])
})

# 4. Orders (10,000 orders)
n_orders = 10000
order_dates = pd.to_datetime('2026-01-01') + pd.to_timedelta(np.random.randint(0, 90, n_orders), unit='D')
order_hours = np.random.choice(range(7, 24), n_orders, p=[
    0.03, 0.05, 0.07, 0.06, 0.05, 0.05, 0.06, 0.05, 0.04, 0.05, 0.07, 0.09, 0.10, 0.09, 0.06, 0.04, 0.03
])
timestamps = [d + timedelta(hours=int(h), minutes=int(np.random.randint(0, 60))) for d, h in zip(order_dates, order_hours)]

store_choices = np.random.choice(stores['store_id'], n_orders)
partner_choices = [np.random.choice(partners[partners['store_id'] == s]['partner_id']) for s in store_choices]

# Simulate peak-hour congestion & Whitefield/Electronic City delays
base_time = np.random.normal(13, 3.5, n_orders)
peak_penalty = np.where(np.isin(order_hours, [18, 19, 20, 21]), np.random.uniform(4, 10, n_orders), 0)
zone_penalty = np.where(np.isin(store_choices, ['DS_04', 'DS_06']), np.random.uniform(3, 7, n_orders), 0)
delivery_mins = np.clip(np.round(base_time + peak_penalty + zone_penalty, 1), 6, 45)

statuses = np.where(
    delivery_mins > 32,
    np.random.choice(['Delivered', 'Cancelled'], n_orders, p=[0.6, 0.4]),
    np.random.choice(['Delivered', 'Cancelled'], n_orders, p=[0.96, 0.04])
)

orders = pd.DataFrame({
    'order_id': [f'ORD_{i:05d}' for i in range(1, n_orders + 1)],
    'customer_id': np.random.choice(customers['customer_id'], n_orders),
    'store_id': store_choices,
    'partner_id': partner_choices,
    'order_timestamp': timestamps,
    'order_value_inr': np.round(np.random.lognormal(mean=5.8, sigma=0.5, size=n_orders), 2),
    'delivery_time_mins': np.where(statuses == 'Cancelled', np.nan, delivery_mins),
    'order_status': statuses
})

# Save directly inside the data/ folder
stores.to_csv('data/dark_stores.csv', index=False)
partners.to_csv('data/delivery_partners.csv', index=False)
customers.to_csv('data/customers.csv', index=False)
orders.to_csv('data/orders.csv', index=False)

print("Success! 4 CSV files created inside data/:")
print(" - data/dark_stores.csv")
print(" - data/delivery_partners.csv")
print(" - data/customers.csv")
print(" - data/orders.csv")
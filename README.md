# \# Quick-Commerce Operations \& SLA Analytics (Bengaluru Dark Stores)

# 

# An end-to-end data analytics portfolio project simulating hyperlocal 10-minute grocery delivery operations across Bengaluru's high-density zones. Built to diagnose last-mile SLA bottlenecks, peak-hour fleet strain, and customer membership unit economics using \*\*Python\*\*, \*\*SQL\*\*, and \*\*Power BI\*\*.

# 

# !\[Executive Dashboard Preview](dashboard/dashboard\_preview.png)

# 

# \---

# 

# \## Business Problem \& Objectives

# Hyperlocal quick-commerce platforms rely on strict sub-15-minute Service Level Agreements (SLAs) to retain high-frequency urban customers. However, traffic congestion in tech corridors and evening order surges often degrade delivery times and spike cancellation rates. This project answers four core operational questions:

# 1\. \*\*Zone Bottlenecks:\*\* Which Bengaluru dark stores experience the highest SLA breaches and average delivery times?

# 2\. \*\*Peak-Hour Strain:\*\* How severely do evening order spikes (6:00 PM – 9:00 PM) impact delivery velocity?

# 3\. \*\*Fleet Efficiency:\*\* How do Electric Vehicles (EVs), petrol bikes, and bicycles compare on delivery speed and order volume?

# 4\. \*\*Customer Unit Economics:\*\* How much GMV and order frequency do paid membership tiers drive compared to standard users?

# 

# \---

# 

# \## Star-Schema Data Architecture

# Generated a synthetic, relationally consistent dataset using Python (`pandas`, `numpy`) structured into a clean star schema:

# 

# \* \*\*`orders` (Fact Table):\*\* Order timestamps, order value (`INR`), delivery duration (`mins`), and order status (`Delivered`, `Cancelled`, `Delayed`).

# \* \*\*`dark\_stores` (Dimension):\*\* Bengaluru dark store locations (`Koramangala`, `Indiranagar`, `HSR Layout`, `Whitefield`, `Electronic City`, `Jayanagar`) and target SLA thresholds.

# \* \*\*`delivery\_partners` (Dimension):\*\* Rider assignments, home dark store, onboarding date, and fleet vehicle type (`EV`, `Petrol Bike`, `Bicycle`).

# \* \*\*`customers` (Dimension):\*\* Customer profiles, residential zones, and subscription tiers (`Standard`, `Plus`, `Pro`).

# 

# \---

# 

# \## Tech Stack \& Repository Structure

# \* \*\*Data Engineering \& Simulation:\*\* Python (`Pandas`, `NumPy`)

# \* \*\*Relational Analysis:\*\* SQL (`SQLite` / window functions, CTEs, aggregations)

# \* \*\*BI \& Data Modeling:\*\* Power BI Desktop (Star-Schema Modeling, DAX Measures \& Calculated Columns)

# 

# ```text

# quick-commerce-operations-analytics/

# ├── data/

# │   ├── customers.csv

# │   ├── dark\_stores.csv

# │   ├── delivery\_partners.csv

# │   └── orders.csv

# ├── sql/

# │   └── analysis.sql

# ├── dashboard/

# │   ├── quick\_commerce\_dashboard.pbix

# │   └── dashboard\_preview.png

# └── README.md


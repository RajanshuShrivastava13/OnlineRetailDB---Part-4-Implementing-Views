# OnlineRetailDB - Part 4: Data Abstraction & Analytical Views
This module focuses on creating secure database abstractions using **SQL Views** to simplify reporting architecture and enforce row-and-column level encapsulation.
## Implemented Virtual Layers (Views)
Following the tactical roadmap in `image_d9c6f9.png`, three dynamic production views were engineered:
1. `vw_ProductDetails`: Flattens normalization between catalog units and categories.
2. `vw_CustomerOrders`: Aggregates customer checkout frequencies and lifetime monetary metrics.
3. `vw_RecentOrders`: Implements a rolling time-window layer filtering operations inside a tight 30-day index trail.
---
## Covered Analytical Benchmarks (Queries 31 - 44)
This script features precise logical solutions mapped to the requirements specified in `image_d9c6f9.png`:
* **Catalog Diagnostics:** Multi-category inventory metrics, price-range evaluations, and low-stock threshold triggers (Queries 31, 32, 33, 38, 42).
* **Customer CRM Insights:** Lifetime values (LTV), high-volume tier tracking (Customers with >5 orders), and top spending ranking systems (Queries 34, 35, 41).
* **Time-Series Operations:** 7-day velocity check, historical monthly product sales tracking, and dynamic high-value transactional filtration (Queries 36, 37, 39, 40, 43, 44).
---
## How to Run Legacies
Execute the main file inside SSMS or your web compiler sandboxes. The queries use standard optimized cross-joins between isolated views to compute production-ready management information reports (MIS).
** https://onecompiler.com/sqlserver/44rarahbv **

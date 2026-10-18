# Apache Superset implementation: Salem Smart City

The same smart-city report as the Power BI project, rebuilt in **Apache Superset 6.1.0 (Docker)** on the same data, with the same two security designs. Thirteen dashboards, six domains, managers see everything and each operator sees only their domain.

> The data is the same synthetic sample data as the Power BI projects. Zone names are the real Salem Corporation zones; the numbers are not real.

## What was built

| Item | Count / detail |
|---|---|
| Dashboards | 13: **Salem Smart City** (Overview) + Summary and Analysis for each of Air Quality, Solid Waste, Water, Energy, Smart Irrigation, City Surveillance |
| Datasets | 8 (one per reporting view), with saved metrics that match the Power BI measures |
| Charts | about 130: KPIs (big number), line, area, bar, donut, treemap, table (the Overview has 20) |
| RLS rules | 7: six static (one per operator role) + one dynamic |
| Roles | `salem_manager`, six `salem_op_*` operator roles, `salem_dynamic` |
| Navigation | Overview cards link to each domain's Summary; every domain dashboard has Home / Summary / Analysis links |

## Screenshots

Manager: the Overview, six domain cards (two KPIs and a different chart type in each) plus open alarms and open incidents by domain.

![Overview, manager](screenshots/01-overview-manager.jpg)

A domain dashboard (Air Quality, Summary and Analysis):

![Air Quality summary](screenshots/02-aq-summary-manager.jpg)

![Air Quality analysis](screenshots/03-aq-analysis-manager.jpg)

**Static RLS:** the irrigation operator sees Smart Irrigation data...

![Irrigation operator, irrigation dashboard](screenshots/04-irrigation-summary-irrigation-operator.jpg)

...but on the Air Quality dashboard every chart and filter is empty:

![Irrigation operator, Air Quality dashboard](screenshots/05-aq-summary-irrigation-operator-no-data.jpg)

On the Overview, the same operator gets data only on the Smart Irrigation card, and the by-domain charts show only that domain:

![Overview, irrigation operator](screenshots/06-overview-irrigation-operator.jpg)

**Dynamic RLS:** a shift supervisor mapped to Air Quality and Energy sees exactly those two cards:

![Overview, dynamic supervisor](screenshots/07-overview-dynamic-supervisor.jpg)

## How the data is organised

PostgreSQL holds the dimension and fact tables from the Power BI model plus the `security_user_access` mapping. Eight **views** join each fact to its dimensions and expose `domain_code`, `tenant_name`, `month_year` and the alarm/incident status text. Superset datasets are built on those views, and **`domain_code` is the column every RLS rule filters on**.

- Schema and views: [`sql/00_schema_and_views.sql`](sql/00_schema_and_views.sql)
- Loading the CSVs: [`sql/01_load_data.md`](sql/01_load_data.md)
- RLS clauses: [`sql/02_rls_rules.sql`](sql/02_rls_rules.sql)

## The two RLS designs in Superset

Superset RLS lives in **Security > Row Level Security**. A rule has a filter type, the datasets, the roles it applies to, and a SQL clause appended to the query's `WHERE`.

| | Static | Dynamic |
|---|---|---|
| Rules | 6 Regular rules, one per operator role | 1 Regular rule for the `salem_dynamic` role |
| Clause | `domain_code = 'IRR'` | looks the user up in `security_user_access` using the Jinja macro `current_user_email()` |
| Add or move an operator | change their role | change a row in the mapping table |
| Needs | nothing special | the `ENABLE_TEMPLATE_PROCESSING` feature flag |

The manager role has no rule, so it sees every domain.

## Test results

Each test user was checked two ways: through the chart data API (which domains come back) and by signing in and opening the dashboards.

| User | Role | Domains visible |
|---|---|---|
| salem_manager | `salem_manager` (no rule) | 6 |
| salem_op_irrigation | `salem_op_irrigation` | 1 (IRR) |
| salem_op_air | `salem_op_air` | 1 (AQ) |
| salem_dyn_manager (manager@...) | `salem_dynamic` | 6 |
| salem_dyn_irrigation (irrigation.operator@...) | `salem_dynamic` | 1 (IRR) |
| salem_dyn_supervisor (shift.supervisor@...) | `salem_dynamic` | 2 (AQ, ENG) |
| salem_dyn_unknown (not in the table) | `salem_dynamic` | 0 |

These match the Power BI results. Irrigation water used for the irrigation operator is 66,834 KL, the same figure the Power BI report shows.

## How Superset differs from Power BI here

- **The Overview is not blank for operators.** Each Overview card is a separate chart on its own dataset, so an operator still sees their own domain's card and "No data" on the rest. In Power BI the Overview measures were wrapped to blank everything for non-managers.
- **RLS applies to datasets, not to people directly.** You attach each rule to datasets and roles. A new dataset needs the rule added or it is unprotected.
- **Admins are not filtered.** Users with the Admin role are not covered by the rules above. Test with a plain role.
- **Hiding a dashboard needs a feature flag.** Per-dashboard role access (`DASHBOARD_RBAC`) was not enabled here, so, as in Power BI, security restricts the data, not which dashboards open.
- **Users need access to the datasets.** Operator roles get the datasource permissions for the Salem datasets only; RLS then narrows the rows.

## Dark theme

The Salem dashboards use Superset's built-in **dark** theme so they stay black whatever the viewer's Light/Dark setting is (the Power BI report is black too). The theme is stored on the dashboard (`theme_id`), and an export zip does not carry it. After importing, set it again: in the dashboard's properties choose the dark theme if your instance has theme administration on, or point the dashboards at the system dark theme in the metadata database:

```sql
UPDATE dashboards
SET theme_id = (SELECT id FROM themes WHERE theme_name = 'THEME_DARK')
WHERE slug LIKE 'salem-%';
```

## Reusing the dashboards

[`dashboards/salem_dashboards_export.zip`](dashboards/salem_dashboards_export.zip) is a Superset export of the 13 dashboards, their charts and datasets, and the database connection (password masked). To import it: create a PostgreSQL database with the schema and data above, then **Settings > Import dashboards**, upload the zip, and enter the database password when asked. Roles, users and RLS rules are not part of an export, so recreate them from `sql/02_rls_rules.sql`.

The dashboards were built on a Superset build with free-form dashboard layout. On stock Superset the six Overview cards stack vertically instead of sitting three across.

## What is verified

- Superset 6.1.0 in Docker: tables and views load, all 13 dashboards render with data, the static and dynamic rules return the results in the table above, and the screenshots come from the running dashboards.
- Not verified: embedding, guest tokens, scheduled reports, other Superset versions, large data volumes.

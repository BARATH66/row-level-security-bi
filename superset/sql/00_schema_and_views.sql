-- Salem smart city: schema, dimension/fact tables and reporting views (PostgreSQL).
-- Load order: this file, then the CSVs in powerbi/model/data and data/security_user_access.csv (see 01_load_data.md).

CREATE TABLE dim_tenant (
    tenant_id integer,
    tenant_name text,
    zone_number integer,
    city text,
    district text,
    state text,
    wards integer,
    population integer,
    area_sq_km double precision
);

CREATE TABLE dim_category (
    category_key integer,
    domain_code text,
    domain_name text,
    sort_order integer,
    department text,
    description text,
    theme_color text
);

CREATE TABLE dim_alarm (
    alarm_status_id integer,
    alarm_status text,
    meaning text
);

CREATE TABLE dim_incident (
    incident_status_id integer,
    incident_status text,
    meaning text
);

CREATE TABLE fact_air_quality (
    event_date date,
    tenant_id integer,
    category_key integer,
    station_name text,
    pm25 double precision,
    pm10 double precision,
    no2 double precision,
    so2 double precision,
    co double precision,
    aqi integer,
    aqi_band text,
    temperature double precision,
    humidity double precision
);

CREATE TABLE fact_swm (
    event_date date,
    tenant_id integer,
    category_key integer,
    waste_type text,
    vehicles_deployed integer,
    planned_pickups integer,
    completed_pickups integer,
    waste_tonnes double precision,
    processed_tonnes double precision,
    avg_bin_fill_pct double precision,
    segregation_pct double precision
);

CREATE TABLE fact_water (
    event_date date,
    tenant_id integer,
    category_key integer,
    supply_source text,
    supply_kl double precision,
    consumption_kl double precision,
    leakage_kl double precision,
    pressure_bar double precision,
    chlorine_mg_l double precision,
    turbidity_ntu double precision,
    reservoir_level_pct double precision,
    quality_tests_done integer,
    quality_tests_passed integer
);

CREATE TABLE fact_energy (
    event_date date,
    tenant_id integer,
    category_key integer,
    consumer_class text,
    consumption_k_wh double precision,
    solar_k_wh double precision,
    peak_demand_kw double precision,
    power_factor double precision,
    energy_cost_inr double precision,
    lights_on integer,
    lights_total integer
);

CREATE TABLE fact_irrigation (
    event_date date,
    tenant_id integer,
    category_key integer,
    zone_type text,
    soil_moisture_pct double precision,
    water_used_kl double precision,
    scheduled_kl double precision,
    rainfall_mm double precision,
    valve_runtime_min integer,
    valves_active integer,
    valves_total integer
);

CREATE TABLE fact_surveillance (
    event_date date,
    tenant_id integer,
    category_key integer,
    camera_type text,
    cameras_total integer,
    cameras_online integer,
    events_detected integer,
    violations integer,
    alerts_raised integer,
    avg_response_min double precision
);

CREATE TABLE fact_alarm (
    event_date date,
    tenant_id integer,
    category_key integer,
    alarm_id text,
    alarm_status_id integer,
    severity text,
    alarm_type text,
    device_id text,
    raised_at timestamp
);

CREATE TABLE fact_incident (
    event_date date,
    tenant_id integer,
    category_key integer,
    incident_id text,
    incident_status_id integer,
    priority text,
    incident_type text,
    resolution_hours double precision
);

CREATE TABLE security_user_access (
    user_email   text NOT NULL,
    display_name text,
    domain_code  text NOT NULL,
    access_level text
);

CREATE TABLE dim_date AS
SELECT d::date AS date,
       extract(year FROM d)::int AS year,
       extract(month FROM d)::int AS month_num,
       to_char(d, 'Mon') AS month_name,
       to_char(d, 'Mon YYYY') AS month_year,
       (extract(year FROM d) * 100 + extract(month FROM d))::int AS year_month
FROM generate_series('2026-01-01'::date, '2026-12-31'::date, interval '1 day') AS d;

CREATE VIEW v_air_quality AS
SELECT f.*, c.domain_code, c.domain_name, t.tenant_name, d.month_year, d.year_month
  FROM fact_air_quality f
  JOIN dim_category c ON c.category_key = f.category_key
  JOIN dim_tenant t ON t.tenant_id = f.tenant_id
  JOIN dim_date d ON d.date = f.event_date;

CREATE VIEW v_swm AS
SELECT f.*, c.domain_code, c.domain_name, t.tenant_name, d.month_year, d.year_month
  FROM fact_swm f
  JOIN dim_category c ON c.category_key = f.category_key
  JOIN dim_tenant t ON t.tenant_id = f.tenant_id
  JOIN dim_date d ON d.date = f.event_date;

CREATE VIEW v_water AS
SELECT f.*, c.domain_code, c.domain_name, t.tenant_name, d.month_year, d.year_month
  FROM fact_water f
  JOIN dim_category c ON c.category_key = f.category_key
  JOIN dim_tenant t ON t.tenant_id = f.tenant_id
  JOIN dim_date d ON d.date = f.event_date;

CREATE VIEW v_energy AS
SELECT f.*, c.domain_code, c.domain_name, t.tenant_name, d.month_year, d.year_month
  FROM fact_energy f
  JOIN dim_category c ON c.category_key = f.category_key
  JOIN dim_tenant t ON t.tenant_id = f.tenant_id
  JOIN dim_date d ON d.date = f.event_date;

CREATE VIEW v_irrigation AS
SELECT f.*, c.domain_code, c.domain_name, t.tenant_name, d.month_year, d.year_month
  FROM fact_irrigation f
  JOIN dim_category c ON c.category_key = f.category_key
  JOIN dim_tenant t ON t.tenant_id = f.tenant_id
  JOIN dim_date d ON d.date = f.event_date;

CREATE VIEW v_surveillance AS
SELECT f.*, c.domain_code, c.domain_name, t.tenant_name, d.month_year, d.year_month
  FROM fact_surveillance f
  JOIN dim_category c ON c.category_key = f.category_key
  JOIN dim_tenant t ON t.tenant_id = f.tenant_id
  JOIN dim_date d ON d.date = f.event_date;

CREATE VIEW v_alarm AS
SELECT f.*, c.domain_code, c.domain_name, t.tenant_name, d.month_year, d.year_month, a.alarm_status
  FROM fact_alarm f
  JOIN dim_category c ON c.category_key = f.category_key
  JOIN dim_tenant t ON t.tenant_id = f.tenant_id
  JOIN dim_date d ON d.date = f.event_date
  JOIN dim_alarm a ON a.alarm_status_id = f.alarm_status_id;

CREATE VIEW v_incident AS
SELECT f.*, c.domain_code, c.domain_name, t.tenant_name, d.month_year, d.year_month, i.incident_status
  FROM fact_incident f
  JOIN dim_category c ON c.category_key = f.category_key
  JOIN dim_tenant t ON t.tenant_id = f.tenant_id
  JOIN dim_date d ON d.date = f.event_date
  JOIN dim_incident i ON i.incident_status_id = f.incident_status_id;

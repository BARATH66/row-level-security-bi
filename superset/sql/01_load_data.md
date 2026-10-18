# Loading the data

Run `00_schema_and_views.sql` first (creates the tables and the eight reporting views), then load the CSVs with `psql`'s `\copy`.
The CSVs are the same files used by the Power BI projects (`powerbi/model/data/`, plus `data/security_user_access.csv`).
Column order in each CSV matches the table, so a header row with a plain column list works:

```sql
\copy dim_tenant            FROM 'powerbi/model/data/DimTenant.csv'        WITH (FORMAT csv, HEADER true)
\copy dim_category          FROM 'powerbi/model/data/DimCategory.csv'      WITH (FORMAT csv, HEADER true)
\copy dim_alarm             FROM 'powerbi/model/data/DimAlarm.csv'         WITH (FORMAT csv, HEADER true)
\copy dim_incident          FROM 'powerbi/model/data/DimIncident.csv'      WITH (FORMAT csv, HEADER true)
\copy fact_air_quality      FROM 'powerbi/model/data/FactAirQuality.csv'   WITH (FORMAT csv, HEADER true)
\copy fact_swm              FROM 'powerbi/model/data/FactSWM.csv'          WITH (FORMAT csv, HEADER true)
\copy fact_water            FROM 'powerbi/model/data/FactWater.csv'        WITH (FORMAT csv, HEADER true)
\copy fact_energy           FROM 'powerbi/model/data/FactEnergy.csv'       WITH (FORMAT csv, HEADER true)
\copy fact_irrigation       FROM 'powerbi/model/data/FactIrrigation.csv'   WITH (FORMAT csv, HEADER true)
\copy fact_surveillance     FROM 'powerbi/model/data/FactSurveillance.csv' WITH (FORMAT csv, HEADER true)
\copy fact_alarm            FROM 'powerbi/model/data/FactAlarm.csv'        WITH (FORMAT csv, HEADER true)
\copy fact_incident         FROM 'powerbi/model/data/FactIncident.csv'     WITH (FORMAT csv, HEADER true)
\copy security_user_access  FROM 'data/security_user_access.csv'           WITH (FORMAT csv, HEADER true)
```

Expected row counts: dim_tenant 4, dim_category 6, dim_alarm 2, dim_incident 3, fact_air_quality 1464, fact_swm 2196, fact_water 2196,
fact_energy 2928, fact_irrigation 2928, fact_surveillance 2928, fact_alarm 2425, fact_incident 1298, security_user_access 10.
`dim_date` is created inside `00_schema_and_views.sql`.

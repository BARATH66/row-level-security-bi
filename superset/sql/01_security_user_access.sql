-- PostgreSQL. Shared entitlement table used by the dynamic RLS rule.
-- Source: data/security_user_access.csv  (columns: UserEmail, DisplayName, DomainCode, AccessLevel)

CREATE TABLE IF NOT EXISTS security_user_access (
    user_email    text NOT NULL,
    display_name  text,
    domain_code   text NOT NULL,      -- AQ, SWM, WTR, ENG, IRR, SUR or ALL
    access_level  text,
    PRIMARY KEY (user_email, domain_code)
);

-- Load the CSV (run from psql; adjust the path):
-- \copy security_user_access (user_email, display_name, domain_code, access_level)
--   FROM 'data/security_user_access.csv' WITH (FORMAT csv, HEADER true);

-- Domain dimension (same codes as the Power BI DimCategory).
CREATE TABLE IF NOT EXISTS dim_category (
    category_key  int PRIMARY KEY,
    domain_code   text NOT NULL UNIQUE,
    domain_name   text NOT NULL
);

INSERT INTO dim_category (category_key, domain_code, domain_name) VALUES
    (1, 'AQ',  'Air Quality'),
    (2, 'SWM', 'Solid Waste Management'),
    (3, 'WTR', 'Water Management'),
    (4, 'ENG', 'Energy Management'),
    (5, 'IRR', 'Smart Irrigation'),
    (6, 'SUR', 'City Surveillance')
ON CONFLICT DO NOTHING;

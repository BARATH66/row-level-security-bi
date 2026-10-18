-- Clauses to paste into Superset > Security > Row Level Security. (Untested draft: verify on your version.)
-- The clause is appended to the WHERE of every query on the selected datasets.

-- ---------------------------------------------------------------
-- STATIC: one Regular rule per domain role
-- Filter type: Regular | Roles: operator_irrigation | Datasets: all virtual datasets
-- ---------------------------------------------------------------
-- Rule "RLS static IRR":
domain_code = 'IRR'
-- Repeat with 'AQ', 'SWM', 'WTR', 'ENG', 'SUR' for the other operator roles.
-- Role `manager` gets no rule, so it sees every domain.

-- ---------------------------------------------------------------
-- DYNAMIC: one Base rule driven by security_user_access
-- Filter type: Base | Excluded roles: Admin | Datasets: all virtual datasets
-- Jinja macro name varies by version: current_username() / current_user_email().
-- ---------------------------------------------------------------
-- Rule "RLS dynamic":
(
    domain_code IN (
        SELECT sua.domain_code
        FROM security_user_access sua
        WHERE lower(sua.user_email) = lower('{{ current_username() }}')
    )
    OR EXISTS (
        SELECT 1
        FROM security_user_access sua
        WHERE lower(sua.user_email) = lower('{{ current_username() }}')
          AND sua.domain_code = 'ALL'
    )
)

-- Expected (same as the Power BI dynamic role):
--   manager@...             -> {ALL}      -> all rows
--   irrigation.operator@... -> {IRR}      -> irrigation rows only
--   shift.supervisor@...    -> {AQ, ENG}  -> two domains
--   unknown user            -> {}         -> no rows

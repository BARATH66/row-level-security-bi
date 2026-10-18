-- Row Level Security rules used in the Superset implementation (Superset 6.1.0).
-- Each rule is created in Security > Row Level Security and attached to the 8 Salem datasets
-- (v_air_quality, v_swm, v_water, v_energy, v_irrigation, v_surveillance, v_alarm, v_incident).
-- Every view exposes domain_code, which is what the clauses filter on.
-- The clause is plain SQL appended to the WHERE of every query on those datasets.

-- ---------------------------------------------------------------
-- STATIC: one Regular rule per operator role
-- Filter type: Regular | Roles: the matching operator role | Datasets: all 8
-- ---------------------------------------------------------------
-- Rule salem_rls_static_IRR  (role: salem_op_irrigation)
domain_code = 'IRR'

-- Same pattern for the other five:
--   salem_rls_static_AQ   (salem_op_air)           domain_code = 'AQ'
--   salem_rls_static_SWM  (salem_op_swm)           domain_code = 'SWM'
--   salem_rls_static_WTR  (salem_op_water)         domain_code = 'WTR'
--   salem_rls_static_ENG  (salem_op_energy)        domain_code = 'ENG'
--   salem_rls_static_SUR  (salem_op_surveillance)  domain_code = 'SUR'
-- The manager role (salem_manager) has no rule, so it sees every domain.

-- ---------------------------------------------------------------
-- DYNAMIC: one Regular rule for one role, driven by security_user_access
-- Filter type: Regular | Role: salem_dynamic | Datasets: all 8
-- Requires the ENABLE_TEMPLATE_PROCESSING feature flag. The Jinja macro current_user_email()
-- returns the signed-in user's email, which must match security_user_access.user_email.
-- ---------------------------------------------------------------
-- Rule salem_rls_dynamic
(
    domain_code IN (
        SELECT sua.domain_code
        FROM security_user_access sua
        WHERE lower(sua.user_email) = lower('{{ current_user_email() }}')
    )
    OR EXISTS (
        SELECT 1
        FROM security_user_access sua
        WHERE lower(sua.user_email) = lower('{{ current_user_email() }}')
          AND sua.domain_code = 'ALL'
    )
)

-- Results observed (same as the Power BI dynamic role):
--   manager@...              -> {ALL}      -> 6 domains
--   irrigation.operator@...  -> {IRR}      -> 1 domain
--   shift.supervisor@...     -> {AQ, ENG}  -> 2 domains
--   unknown.user@...         -> {}         -> 0 domains (no rows)

# Apache Superset implementation (draft, not yet tested)

> **Status: untested design.** The SQL and settings below follow Superset's documented Row Level Security feature, but they have not been run against a live instance yet. Version differences (for example which Jinja macros are available in an RLS clause) must be checked on your installation. Treat this folder as a starting point and update it once verified.

## How Superset does RLS

Superset RLS lives in **Security > Row Level Security**. Each rule has:

| Field | Meaning |
|---|---|
| Filter type | **Regular**: applies to the listed roles. **Base**: applies to everyone *except* the listed roles |
| Datasets | The tables or virtual datasets the rule is added to |
| Roles | Who the rule applies to (Regular) or who is excluded (Base) |
| Clause | A SQL `WHERE` fragment appended to every query on those datasets |
| Group key | Rules sharing a key are OR-ed; different keys are AND-ed |

The clause is plain SQL, so the same two designs map directly:

| Design | Superset form |
|---|---|
| Static | One **Regular** rule per domain role, clause `domain_code = 'IRR'` |
| Dynamic | One **Base** rule whose clause looks the user up in `security_user_access` using a Jinja macro for the current user |

## Plan

1. Load the shared mapping into the database: [`sql/01_security_user_access.sql`](sql/01_security_user_access.sql) with [`../data/security_user_access.csv`](../data/security_user_access.csv).
2. Expose `domain_code` on each dataset. Facts here carry `CategoryKey`, so use virtual datasets that join `dim_category`: [`sql/02_virtual_datasets.sql`](sql/02_virtual_datasets.sql).
3. Create the rules: [`sql/03_rls_rules.sql`](sql/03_rls_rules.sql) holds the clauses to paste into the UI.
4. Create Superset roles (`manager`, `operator_irrigation`, ...) and assign test users.
5. Test with the checklist in [`../docs/testing-checklist.md`](../docs/testing-checklist.md).

## Things to verify before publishing results

- [ ] Jinja in the RLS clause resolves `current_username()` / `current_user_email()` on your version.
- [ ] Superset's username equals the value stored in `security_user_access.user_email` (it may be a login name, not an email).
- [ ] Base rule excludes only the roles you intend (typically `Admin`). Admins bypass RLS by design.
- [ ] SQL Lab and chart exports honour the rule.
- [ ] A user with no mapping row sees zero rows.

## Role mapping (target)

| Superset role | Equivalent in Power BI | Domain |
|---|---|---|
| `manager` | `Manager` / `ALL` row | all |
| `operator_air_quality` | `Operator_AirQuality` | AQ |
| `operator_swm` | `Operator_SolidWasteManagement` | SWM |
| `operator_water` | `Operator_WaterManagement` | WTR |
| `operator_energy` | `Operator_EnergyManagement` | ENG |
| `operator_irrigation` | `Operator_SmartIrrigation` | IRR |
| `operator_surveillance` | `Operator_CitySurveillance` | SUR |

Add screenshots of the configured rules and a before/after chart here once tested.

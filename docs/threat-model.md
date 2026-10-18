# Threat model for RLS

Scope: a multi-user BI deployment where users share one dataset but must not see each other's rows (multi-tenant or multi-department).

## Principles

1. **Deny by default.** A user with no mapping sees nothing. Dynamic designs get this for free when the filter is an `IN` against the user's own rows.
2. **Enforce server-side.** Filters in dashboard widgets, bookmarks or hidden pages are cosmetic. The rule must live in the model or query layer.
3. **Least privilege.** Operators get their domain only; "see everything" is a named, small group.
4. **One source of truth for identity.** Use the sign-in identity the platform reports, not a value the user can type.
5. **The mapping table is sensitive.** Whoever edits it controls access. Restrict write access and keep it in version control.

## Threats and mitigations

| Threat | Example | Mitigation |
|---|---|---|
| Wrong role assignment | Operator added to `Manager` | Review membership regularly; prefer groups over individuals; dynamic mapping makes access visible in one table |
| Union of roles | User in two roles sees both sets | Keep roles disjoint, document that multiple roles combine |
| Admin bypass | Workspace admin or report owner sees all rows | Give end users viewer access only; test as a viewer |
| Mapping tampering | Someone adds themselves an `ALL` row | Lock down the table's source, audit changes, alert on `ALL` rows |
| Identity mismatch | Sign-in is `user@corp.com`, table has `User@corp.co.in` | Normalise case and domain; test with real accounts, not only typed test users |
| Leaking the mapping | Users can read other people's access | Filter the mapping table to the user's own rows (done in the Power BI dynamic role) |
| Free-text identity in embedding | App lets the browser choose the role | Choose role and identity on the server only |
| Measure or visual leakage | Totals shown outside the filtered table | Test every page as each persona; check measures that use `ALL()` (RLS survives it in Power BI, other tools differ) |
| Export / API access | User downloads the underlying data | Confirm the export path applies the same filter; restrict export where it does not |
| Stale access | Leaver keeps access | Remove from identity groups; refresh mapping on a schedule |

## Not covered

Column-level and object-level security, network controls, encryption and compliance requirements. RLS is one layer, not a full security programme.

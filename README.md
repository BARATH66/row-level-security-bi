# Row-Level Security for BI

How to restrict who sees which rows in a BI tool, shown as a **concept first, tools second**. The same access rules are implemented once per tool so the approaches can be compared.

| Tool | Status | Where |
|---|---|---|
| Power BI | Built and tested in Desktop (static and dynamic) | [`powerbi/`](powerbi/README.md) |
| Apache Superset | Built and tested (static and dynamic) | [`superset/`](superset/README.md) |
| Tableau / Looker / Metabase | Not started (see roadmap) | n/a |

> Data is synthetic. The scenario is a smart-city control room for Salem, Tamil Nadu, with six domains (air quality, solid waste, water, energy, irrigation, surveillance). Managers see everything; each operator sees only their domain.

**New here?** Start with the plain-English walkthrough in [`powerbi/README.md`](powerbi/README.md), then come back for the concept and the tool comparison.

## The concept

RLS answers one question: *given who is asking, which rows may they read?* Every tool needs the same four steps:

1. **Identify** the user (login, email, user ID).
2. **Map** the user to what they may access (a role, or a row in an entitlement table).
3. **Filter** the data with that mapping, as close to the data as possible.
4. **Test** as each kind of user, including a user with no access.

## Static vs dynamic

| | Static | Dynamic |
|---|---|---|
| Rule lives in | Role definition (`domain = "IRR"`) | A mapping table (`user -> domain`) |
| Roles to maintain | One per audience (7 here) | One (`DynamicAccess`) |
| Adding or moving a user | Change role membership in the tool | Add or edit a table row, refresh |
| Auditability | Role membership in the BI tool | The mapping table can be reviewed and versioned |
| Failure mode | User in the wrong role sees the wrong data | Missing or mistyped row means no data (safe default) |
| Best when | Few stable groups | Many users, frequent changes, users covering several domains |

## Access rules used everywhere

[`data/security_user_access.csv`](data/security_user_access.csv) is the shared mapping:

| UserEmail | DomainCode |
|---|---|
| manager@... | `ALL` |
| irrigation.operator@... | `IRR` |
| shift.supervisor@... | `AQ` and `ENG` (one row each) |
| unknown user | no row, so no data |

Expected result in every tool: manager sees 6 domains, irrigation operator 1, shift supervisor 2, unknown user 0.

## Repository map

```
README.md          this guide
docs/              threat model, testing checklist, data model, DAX measures
powerbi/           Salem project: static RLS + dynamic RLS, DAX, screenshots
superset/          Superset implementation: dashboards export, SQL, RLS rules, embedded page, screenshots
data/              shared mapping table
```

## Limits worth knowing

- RLS filters **rows**, not pages, menus or whole dashboards. Hide those with the tool's own permissions.
- Admins and report owners often bypass RLS. Test with a plain viewer.
- A client-side filter is not security. Enforce it in the model or the query layer.

## License

MIT, see [LICENSE](LICENSE).

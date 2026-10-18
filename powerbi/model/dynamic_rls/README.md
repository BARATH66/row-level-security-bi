# Dynamic RLS variant

Same 13-page report and model as the parent project, but security is driven by **data** instead of seven hard-coded roles.

| | Static (parent folder) | Dynamic (this folder) |
|---|---|---|
| Roles | `Manager` + 6 `Operator_<Domain>` | one role, `DynamicAccess` |
| Who sees what | role membership | row in `SecurityUserAccess` matched to `USERPRINCIPALNAME()` |
| New operator | add to role, no republish | add a CSV/table row, refresh |

Open `salem_smart_city_report_dynamic.pbip` in Power BI Desktop. If asked for `DataFolder`, use `C:\Documents\personal\projects\salem_smart_city\dynamic_rls\data\`.

## How it works

`data/SecurityUserAccess.csv` (hidden table in the model):

| UserEmail | DomainCode |
|---|---|
| manager@salem-smartcity.example | ALL |
| irrigation.operator@salem-smartcity.example | IRR |
| shift.supervisor@salem-smartcity.example | AQ (and a second row: ENG) |

Role `DynamicAccess` filters `DimCategory` to the domain codes mapped to the signed-in user, or every domain when the user has `ALL`:

```dax
VAR u = USERPRINCIPALNAME()
VAR allowed = SELECTCOLUMNS(FILTER(SecurityUserAccess, SecurityUserAccess[UserEmail] = u), "d", SecurityUserAccess[DomainCode])
RETURN DimCategory[DomainCode] IN allowed || "ALL" IN allowed
```

The role also limits `SecurityUserAccess` to the user's own rows, so nobody can read the mapping of other people.
The Overview still uses `[Is Manager View]` (all 6 domains visible), so `ALL` users see it and everyone else gets the restricted message.
A user with no mapping row sees no data.

## Test in Desktop

1. **Modeling > View as**, tick `DynamicAccess`, tick **Other user** and type an email from the table
   (for example `irrigation.operator@salem-smartcity.example`).
2. Expect only Smart Irrigation data; Overview shows the restricted message.
3. Repeat with `manager@...` (all pages) and `shift.supervisor@...` (Air Quality + Energy).

## Replace the sample emails

Edit `data/SecurityUserAccess.csv` with real user principal names (the sign-in emails in Entra), refresh, republish.
In the service, add the **users or groups** to role `DynamicAccess` under the semantic model's Security settings:
anyone not in the role gets no access, and anyone in it is filtered by the table.
When embedding for customers, pass the email as `username` and `roles: ["DynamicAccess"]` in the token identity.
On Report Server, `USERPRINCIPALNAME()` returns the UPN; use `USERNAME()` (DOMAIN\\user) in the table instead if UPNs are not available.


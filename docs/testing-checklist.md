# RLS testing checklist

Run this in a test or staging environment, then once after release. Record the result next to each item.

## 1. Personas

Create or pick one test identity for each:

- [ ] Manager (full access)
- [ ] Operator for each domain (6 here)
- [ ] User covering two domains
- [ ] Authenticated user with **no mapping**
- [ ] Admin / owner (to confirm what bypasses RLS)

## 2. Per persona

- [ ] Row counts match expectations (compare with a direct query as the data owner)
- [ ] Totals on every page equal the sum of the rows that persona may see
- [ ] Other domains' pages are blank or empty, not an error that leaks names or counts
- [ ] Slicers and filter lists do not list values the persona cannot access
- [ ] Drill-through, tooltips and cross-filtering do not reveal other rows
- [ ] Manager-only pages show the restricted state to operators

## 3. Edge cases

- [ ] Email case and whitespace differences
- [ ] User present in two roles (union is intended and documented)
- [ ] New user added to the mapping (appears after refresh, no republish)
- [ ] Mapping row removed (access disappears after refresh)
- [ ] Measures that use `ALL`, `REMOVEFILTERS` or cross-table lookups

## 4. Channels

- [ ] Exports (CSV, Excel, PDF) honour the filter
- [ ] Subscriptions and email snapshots run as the right identity
- [ ] Embedded views: identity and roles are chosen on the server
- [ ] API or direct query access to the dataset is restricted

## 5. Evidence

Keep screenshots or a short log of: persona, page, expected, actual, pass/fail, date, tester.

### Power BI quick test

Modeling > **View as** > tick the role > for dynamic RLS also tick **Other user** and type a mapping-table email. The yellow banner shows who you are viewing as. Ticking **Other user** alone applies no role and shows everything.

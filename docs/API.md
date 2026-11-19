# Budget and planning-line API

Publisher vffice, group projectMaterials, version v1.0.
Base URL:
https://api.businesscentral.dynamics.com/v2.0/{tenant}/{environment}/api/vffice/projectMaterials/v1.0/companies({companyId})

| Entity set | Methods | Purpose |
|---|---|---|
|materialBudgets|GET POST PATCH|Write facade atomically updating real standard planning lines and history|
|materialPlanningLines|GET|Standard Item/Budget planning lines, including native lines|
|projectMaterialCosts|GET|Source actual target, allocated cost and processing status|

The write facade avoids using mutable planning line numbers as the external identity. It is not a deferred
staging queue: a write succeeds only when the actual Job Planning Line and revision history save.
POST requires externalId, existing project/task/item, positive revision and nonnegative quantity/unitCostLCY.
Cost is explicitly LCY. Responses include planningLineId and planningLineNumber.

GET by externalId before POST. If present, PATCH the returned system ID with exact ETag and a higher revision.
Duplicate externalId fails instead of duplicating a line. After timeout, compare stored revision/payload before retry.
Do not normally use wildcard ETags. Project/task/item/variant/unit and external identity are immutable.
Use a new budget identity for substitutions. Set inactive with a new revision to retire the line; native
planning quantity becomes zero, history remains. DELETE is prohibited. Actual costs are never rewritten.

Keep managed planning lines under integration ownership. Manual edits are not a supported budget-revision path.
Usage Link=false does not itself prove procurement-demand exclusion. Keep Budget Demand Validated false until
the planning test passes. No parallel native Item-type project consumption is allowed for these shipments.

Use normal BC OAuth and API permissions. No credentials are packaged.
Examples are in samples/material-budget.http.

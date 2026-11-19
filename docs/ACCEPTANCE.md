# Sandbox acceptance

Record BC version, localization, installed apps, account setup, timestamps and resulting entry IDs.
AL unit test codeunit71150 can run using the organization's BC test runner. Unit tests do not authorize activation.

1. Budget POST1000 creates exactly one Item/Budget planning line and revision1. Duplicate POST fails.
   Stale ETag/lower revision PATCH fails. Revision2 updates the same line and records history.
   A manually inserted Item/Budget planning line creates exactly one VPM budget with a generated external ID,
   Usage Link=false and revision1. A manual quantity/cost/date/description change creates revision2 without a
   second planning line. Identity changes, renumbering and deletion are blocked.
2. Budget1000, confirmed order100, no stock: required supply must be100, not1000 or1100.
   Test every used planning route. Keep Budget Demand Validated false until this passes.
3. Sync ordinary/project orders using existing Dataverse mappings/jobs. Retry creates no duplicate order/line.
   Verify all five custom fields on final Sales Line records, not only intermediate CRM buffers.
   On a VPM Sales Order line, select a project, task and item with one active matching budget: Budget Id must
   equal that budget external ID and Source Line Id must be generated and remain unchanged after quantity edits.
   Prove that no match and duplicate active matches are rejected. Prove a Return Order retains explicit IDs.
4. Normal and promotional zero-price direct sales create no custom cost allocation.
5. Project shipment60 of100: technical invoice60, one stock issue, zero material revenue.
   The Sales Order posting invokes the VPM worker after posting succeeds. An invoice-only posting invokes it
   again so the shipped source can reconcile. Preview must leave no persistent capture or cost adjustment.
   Commit-suppressed and inventory pick/put-away posting must defer the worker without losing the source link.
   Resolve all tracking entries; dry mode posts nothing.
6. FIFO receipt100 @20: project60, direct20, stock20. Project cost1200.
   Supplier invoice23, standard adjustment and inventory G/L: project delta180, direct60, stock60. Each VPM
   delta creates one balanced G/L transfer and exactly one Project Ledger Entry posted from the dedicated
   Project Journal batch. Its G/L ledger-entry link, item entry, value entry, budget ID, source-line ID and
   shipment document must match the VPM Transfer record.
7. Assigned freight200: project delta120, resulting1500. Unassigned G/L freight does not transfer.
8. Exact-cost return10 @25: project delta-250. Later cost changes reconcile both issue and return once.
9. Partial supplier/technical invoices, late zero-quantity costs and deleted order remain reconcilable.
10. Delayed inventory G/L posting leaves prior allocation intact; posting completes then source recovers.
    Aggregated G/L evidence must block, never allocate an invented ratio.
11. Repeated and concurrent workers post one net delta. Concurrent valuation cannot lose a cost change.
12. Inject Error after either the G/L or Project Journal posting in a disposable test build: both journals,
    project entry, registers and balances all roll back. Retry the normal build and prove exactly one transfer.
13. Closed period/project and invalid dimensions block visibly. Correct only through authorized setup.
14. Test warehouse posting, serial/lot splits, undo shipment and returns. Block any unsupported source chain.
15. No duplicate budget/billable planning line is created by journal usage. Reconcile G/L, project and WIP.
16. Verify permissions, disable/re-enable, mapping-reset recovery and operational logging before approval.

# Implementation scope and remaining release gates

This is not a claim that all architecture-annex requirements are implemented.

|Area|Delivered source|Remaining gate or limitation|
|---|---|---|
|Budget API|Atomic native line, registry, revision history and read API|Target-symbol compile and planning validation|
|Order transport|Native mapping extension fields and installer|Real Dataverse schema; buffer adapter if native route does not target Sales Line|
|Budget demand isolation|Setup gate; Usage Link disabled|No universal planning exclusion subscriber; prove configuration or implement target-specific exclusion|
|Technical invoice|Controlled action for shipped project-only orders|Localization, tax/output and mixed-order policies|
|Source capture|Shipment/return links and matching item-entry discovery|Preview, serial/lot, warehouse posting tests|
|Supplier cost updates|Full-source sweep after standard valuation, including closed orders|Configure standard valuation jobs; no event-coalesced request queue in this version|
|Resolver|Exact historical source-account evidence per value entry|Aggregated G/L, mixed dimensions and other source accounts are rejected|
|Journal|Balanced standard posting, project-total assertion, per-value balance|Prove commit suppression/rollback with target symbols and installed subscribers|
|Accounting rules|One source and target account; source dimensions preserved|No multi-component/versioned rule UI or dimension transformation|
|Returns|Signed linked return sources after normal credit valuation|Explicit return mapping and original item application tests|
|Corrections|No direct ledger rewriting|Automated project reassignment/reversal UI not implemented|
|Reporting|Monitor, transfers, budget history and read APIs|Full joined budget/commitment/EAC report and operational commitment app not included|
|Audit|Item/value/project entry, transfer document, amounts and accounts|No normalized G/L posting-link table; use document drill-down|
|Recovery|Per-source rollback, visible errors, retry on next sweep|Full sweep prioritizes correctness over high-volume optimization|
|Tests|Cost math/sign/retry/rounding and missing budget identity|End-to-end financial and injected-failure tests need BC sandbox|
|Build|Workspace, manifest, launch, build script|Not compiled here; no symbols/compiler or .app binary|

Initial costing scope: purchased FIFO, Average and Specific. Additional reporting currency, Standard costing,
production/assembly and site-held inventory are rejected or excluded. Finance must resolve errors before WIP close.

## Transactions
Discovery commits before processing. Each Boolean Codeunit.Run processor invocation owns one financial unit.
Setup/source locks serialize workers and the dedicated journal. After full-source preflight, standard posting
with suppression, register and balance changes commit together. An uncaught failure rolls back that unit;
the caller records its error afterward. No TryFunction catches financial writes.
All sources are revisited, so no supplier-event omission loses a later cost change.

## Posting date
Setup Posting Date is explicitly controlled by finance; native allowed-date rules still apply.
There is no silent next-open-date policy. Keep this date current through the approved close process.

# Native Dataverse sales-order synchronization

Sales orders use the existing BC Dataverse connection:
Integration Table Mappings → Integration Field Mappings → native synchronization job queues.
No alternate sales-order API or integration daemon is included.

Identify actual header/line mappings, coupling, proxy tables and synchronization handlers.
Confirm final destination Sales Header36 and Sales Line37. Preserve native master-data coupling.
Custom Dataverse schema names and generated proxy IDs were not supplied; no fabricated proxy is included.
Use supported native custom-field mapping or generate/update proxy objects from actual metadata.

| BC Sales Line field | ID | Type | Required source |
|---|---:|---|---|
| VPM Project Material |71000|Boolean|Explicit included-material mode; false for direct sales|
| VPM Project No. |71001|Code20|Existing BC project number|
| VPM Task No. |71002|Code20|Existing BC task number|
| VPM Budget Id |71003|Guid|Stable budget API externalId|
| VPM Source Line Id |71004|Guid|Stable source sales-order-line identity|

All additional mappings are inbound. Do not populate standard Sales Line Job No./Job Task No. for this flow.
Project-material prices must be zero; direct sales retain commercial prices.
Synchronize project/tasks/budgets before release of dependent material orders.

In VPM Dataverse Mappings, enter the existing line mapping name, BC field number and actual Dataverse proxy
field number; choose Install field mappings. The installer rejects wrong destination tables, type mismatches
and conflicting existing mappings. It preserves native table filters, direction, codeunits and scheduling.
Configure required value transformations explicitly; direct GUID-to-code mappings are not valid.

If the native route maps into CRM staging buffers, a target-specific final buffer-to-Sales-Line adapter is
required. Do not invent a table37 mapping or create a second order import route to bypass the native handler.
No reset-default-mappings subscriber is supplied. Export mappings and reapply after an administrator reset.

Keep header-before-line dependencies and standard coupling. Run initial synchronization deliberately, then
enable existing periodic native jobs. Inspect Integration Synchronization Errors and retry through BC.
Test duplicate sync, missing dependencies, same item on different budget lines, partial shipments and edits.

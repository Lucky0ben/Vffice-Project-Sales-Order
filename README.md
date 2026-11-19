# Vffice Project Materials

Business Central AL source package. Publisher Vffice. Version 1.1.0.0. Prepared 19 November 2026.

## Build status
**Compiled against BC 28.5 target symbols and deployed to the ProductionDemo sandbox; not production validated.**
No .app binary is supplied in source control. Default target: BC 28 / runtime 17. Confirm the actual target
and object ranges before another deployment.
Open Vffice.ProjectMaterials.code-workspace; follow docs/BUILD_AND_DEPLOY.md.

## Included
- Material budget API with stable external identity, revision history and ETags. Each successful write
  creates/updates a real standard Job Planning Line, Type Item and Line Type Budget.
- Read-only standard planning-line API and project material cost API.
- Sales Line fields and installer for existing native Dataverse integration field mappings.
  No custom sales-order REST importer, Power Automate order flow or replacement synchronization scheduler.
- Project-material posting validation, durable shipment/return links and controlled zero-dollar invoice action.
- Recurring cost reconciliation including later supplier invoice and assigned item-charge changes.
- Actual-cost delta calculation, conservative G/L evidence resolver and balanced project journal.
- Setup/monitoring/history pages, permissions, AL unit tests, build script, API samples and acceptance guide.

## Release boundaries
Read docs/IMPLEMENTATION_STATUS.md. This package implements a constrained first version, not every annex item.
Full-budget procurement-demand exclusion must be proven or extended for the target planning routes.
Budget import is gated until that happens. The source-account resolver rejects ambiguous aggregated G/L evidence.
Standard BC valuation jobs run before the custom reconciliation worker. Financial posting is disabled by default.

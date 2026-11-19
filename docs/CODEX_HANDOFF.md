# VS Code handoff

Read README.md and IMPLEMENTATION_STATUS.md. Do not deploy to production or assume the WMS sandbox is the target.
Confirm target version/environment, download symbols, compile app/tests and fix actual diagnostics.
Do not remove accounting checks to make compilation pass.

Resolve planning-demand isolation before enabling budget imports: inspect target planning events and exclude
only managed budget lines from the selected replenishment routes. Prove the demand test.
Inspect actual Dataverse mappings and proxy fields. Extend existing native synchronization. If CRM buffers
are involved, implement final field propagation to Sales Line. Do not create another sales-order importer.
Validate capture, preview, tracking, warehouse posting and returns.
Prove project journal accounting and atomic rollback; add end-to-end and injected-failure AL tests.
Resolve or explicitly retain the release exclusions in IMPLEMENTATION_STATUS.md.
Produce successful build evidence, .app hashes, test results and approved sandbox deployment settings.
Never claim financial acceptance solely because compilation succeeded.

# Build and sandbox deployment

1. Extract the ZIP and open the .code-workspace in VS Code. Install Microsoft's AL Language extension.
2. Select the Application folder. Replace the sandbox name in app/.vscode/launch.json and authenticate.
   Do not assume another project's environment is the target.
3. Confirm app/app.json application/platform/runtime and object IDs. Defaults: BC28, runtime17,
   app71000–71149 and tests71150–71199. Check object-range conflicts.
4. Run AL: Download Symbols, then AL: Package for the application.
   Alternatively run: pwsh -File scripts/Build.ps1 -IncludeTests
   Pass -CompilerPath and -SymbolsPath if needed.
5. Resolve actual compiler diagnostics against downloaded symbols; do not remove accounting checks to compile.
6. Publish only the application to the sandbox using AL publish/F5. Compile and publish tests separately.
7. Assign VPM ADMIN plus standard BC permissions for sales, projects and journal posting.
   The extension does not grant direct writes to standard financial ledger tables.
8. Open VPM Setup. Create a dedicated empty general journal template/batch, distinct source and target expense
   accounts and an authorized Posting Date. Do not allow other users/jobs to share the batch.
9. Keep Posting Enabled false. Prove budget demand isolation before setting Budget Demand Validated.
   This acknowledgment is not an implementation of demand exclusion.
10. Configure the existing native Dataverse mapping and synchronization job queues per DATAVERSE_MAPPING.md.
11. Configure standard cost adjustment and inventory cost-to-G/L jobs. Use per-entry evidence compatible with
    the conservative resolver. Confirm actual expense account/dimensions on posted transactions.
12. Create a recurring standard Job Queue Entry: Object Type Codeunit, Object ID71003 VPM Cost Worker,
    initially every five minutes. It is separate from native Dataverse synchronization jobs.
13. Enable the feature in dry mode and inspect targets/pending reasons. Execute ACCEPTANCE.md.
14. Only after sandbox accounting and rollback validation, set Sandbox Validated and enable posting.

## Production release
Requires a clean build, actual-symbol validation, finance acceptance, demand-exclusion evidence and atomic
rollback tests with installed subscribers. Upload the approved .app through the normal deployment pipeline.
Do not publish the test app to production. No production deployment has been performed.

## Disable and upgrade
Disabling Enabled or Posting Enabled stops future processing and preserves history. Uninstallation does not
reverse financial entries. Future schema releases require explicit upgrade code; this is the first schema.

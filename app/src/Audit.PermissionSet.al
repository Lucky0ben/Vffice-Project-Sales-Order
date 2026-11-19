permissionset 71002 "VPM AUDIT"
{
    Assignable = true;
    Permissions = tabledata "VPM Cost Source" = R, tabledata "VPM Transfer" = R,
        tabledata "VPM Budget" = R, tabledata "VPM Budget Revision" = R, tabledata "VPM Shipment Link" = R,
        page "VPM Cost Monitor" = X, page "VPM Transfers" = X, page "VPM Material Budgets" = X,
        page "VPM Budget History" = X, page "VPM Shipment Links" = X, page "VPM Cost Sources API" = X;
}

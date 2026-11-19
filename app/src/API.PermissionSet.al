permissionset 71001 "VPM BUDGET API"
{
    Assignable = true;
    Permissions = tabledata "VPM Budget" = RIM,
        tabledata "VPM Budget Revision" = RI,
        tabledata "VPM Setup" = R,
        tabledata "Job Planning Line" = RIM,
        tabledata Job = R, tabledata "Job Task" = R, tabledata Item = R,
        page "VPM Material Budget API" = X, page "VPM Planning Lines API" = X,
        codeunit "VPM Budget Mgt." = X;
}

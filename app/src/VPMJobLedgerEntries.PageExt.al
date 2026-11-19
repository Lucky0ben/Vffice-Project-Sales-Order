pageextension 71004 "VPM Job Ledger Entries" extends "Job Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("VPM Item Entry No."; Rec."VPM Item Entry No.") { ApplicationArea = All; ToolTip = 'Specifies the originating item ledger entry for this VPM project cost.'; }
            field("VPM Value Entry No."; Rec."VPM Value Entry No.") { ApplicationArea = All; ToolTip = 'Specifies the value entry whose cost produced this VPM project entry.'; }
            field("VPM Budget Id"; Rec."VPM Budget Id") { ApplicationArea = All; ToolTip = 'Specifies the VPM material budget identifier.'; }
            field("VPM Source Line Id"; Rec."VPM Source Line Id") { ApplicationArea = All; ToolTip = 'Specifies the stable source sales-line identifier.'; }
            field("VPM Source Document No."; Rec."VPM Source Document No.") { ApplicationArea = All; ToolTip = 'Specifies the posted shipment or return receipt that originated the cost.'; }
        }
    }
}

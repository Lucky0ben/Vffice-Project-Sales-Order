pageextension 71001 "VPM Sales Order Lines" extends "Sales Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("VPM Project Material"; Rec."VPM Project Material") { ApplicationArea = All; }
            field("VPM Project No."; Rec."VPM Project No.") { ApplicationArea = All; }
            field("VPM Task No."; Rec."VPM Task No.") { ApplicationArea = All; }
            field("VPM Budget Id"; Rec."VPM Budget Id") { ApplicationArea = All; Editable = false; }
            field("VPM Source Line Id"; Rec."VPM Source Line Id") { ApplicationArea = All; Editable = false; }
        }
    }
}

page 71004 "VPM Budget History"
{
    PageType = List; SourceTable = "VPM Budget Revision"; ApplicationArea = All; UsageCategory = Lists;
    Editable = false; InsertAllowed = false; DeleteAllowed = false;
    layout { area(Content) { repeater(Lines) {
        field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
        field("Budget Id"; Rec."Budget Id") { ApplicationArea = All; }
        field("Revision"; Rec."Revision") { ApplicationArea = All; }
        field("Quantity"; Rec."Quantity") { ApplicationArea = All; }
        field("Unit Cost LCY"; Rec."Unit Cost LCY") { ApplicationArea = All; }
        field("Inactive"; Rec."Inactive") { ApplicationArea = All; }
        field("Changed At"; Rec."Changed At") { ApplicationArea = All; }
        field("Changed By"; Rec."Changed By") { ApplicationArea = All; }
    } } }


}

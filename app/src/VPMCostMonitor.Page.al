page 71001 "VPM Cost Monitor"
{
    PageType = List; SourceTable = "VPM Cost Source"; ApplicationArea = All; UsageCategory = Lists;
    Editable = false; InsertAllowed = false; DeleteAllowed = false;
    layout { area(Content) { repeater(Lines) {
        field("Item Entry No."; Rec."Item Entry No.") { ApplicationArea = All; }
        field("Project No."; Rec."Project No.") { ApplicationArea = All; }
        field("Task No."; Rec."Task No.") { ApplicationArea = All; }
        field("Budget Id"; Rec."Budget Id") { ApplicationArea = All; }
        field("Document No."; Rec."Document No.") { ApplicationArea = All; }
        field("Target LCY"; Rec."Target LCY") { ApplicationArea = All; }
        field("Transferred LCY"; Rec."Transferred LCY") { ApplicationArea = All; }
        field("Last Checked"; Rec."Last Checked") { ApplicationArea = All; }
        field("Status"; Rec."Status") { ApplicationArea = All; }
    } } }


}

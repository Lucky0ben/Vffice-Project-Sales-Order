page 71002 "VPM Transfers"
{
    PageType = List; SourceTable = "VPM Transfer"; ApplicationArea = All; UsageCategory = Lists;
    Editable = false; InsertAllowed = false; DeleteAllowed = false;
    layout { area(Content) { repeater(Lines) {
        field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
        field("Item Entry No."; Rec."Item Entry No.") { ApplicationArea = All; }
        field("Value Entry No."; Rec."Value Entry No.") { ApplicationArea = All; }
        field("Project No."; Rec."Project No.") { ApplicationArea = All; }
        field("Task No."; Rec."Task No.") { ApplicationArea = All; }
        field("Budget Id"; Rec."Budget Id") { ApplicationArea = All; }
        field("Amount LCY"; Rec."Amount LCY") { ApplicationArea = All; }
        field("Document No."; Rec."Document No.") { ApplicationArea = All; }
        field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
        field("Source Account"; Rec."Source Account") { ApplicationArea = All; }
        field("Target Account"; Rec."Target Account") { ApplicationArea = All; }
        field("Dimension Set ID"; Rec."Dimension Set ID") { ApplicationArea = All; }
        field("Project Entry No."; Rec."Project Entry No.") { ApplicationArea = All; }
    } } }


}

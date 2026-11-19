page 71003 "VPM Material Budgets"
{
    PageType = List; SourceTable = "VPM Budget"; ApplicationArea = All; UsageCategory = Lists;
    Editable = false; InsertAllowed = false; DeleteAllowed = false;
    layout { area(Content) { repeater(Lines) {
        field("External Id"; Rec."External Id") { ApplicationArea = All; }
        field("Project No."; Rec."Project No.") { ApplicationArea = All; }
        field("Task No."; Rec."Task No.") { ApplicationArea = All; }
        field("Item No."; Rec."Item No.") { ApplicationArea = All; }
        field("Quantity"; Rec."Quantity") { ApplicationArea = All; }
        field("Unit Cost LCY"; Rec."Unit Cost LCY") { ApplicationArea = All; }
        field("Revision"; Rec."Revision") { ApplicationArea = All; }
        field("Planning Line No."; Rec."Planning Line No.") { ApplicationArea = All; }
        field("Planning Line Id"; Rec."Planning Line Id") { ApplicationArea = All; }
        field("Inactive"; Rec."Inactive") { ApplicationArea = All; }
    } } }


}

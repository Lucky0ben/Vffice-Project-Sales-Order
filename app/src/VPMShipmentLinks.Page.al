page 71006 "VPM Shipment Links"
{
    PageType = List; SourceTable = "VPM Shipment Link"; ApplicationArea = All; UsageCategory = Lists;
    Editable = false; InsertAllowed = false; DeleteAllowed = false;
    layout { area(Content) { repeater(Lines) {
        field("Document No."; Rec."Document No.") { ApplicationArea = All; }
        field("Document Line No."; Rec."Document Line No.") { ApplicationArea = All; }
        field("Project No."; Rec."Project No.") { ApplicationArea = All; }
        field("Task No."; Rec."Task No.") { ApplicationArea = All; }
        field("Budget Id"; Rec."Budget Id") { ApplicationArea = All; }
        field("Source Line Id"; Rec."Source Line Id") { ApplicationArea = All; }
        field("Item No."; Rec."Item No.") { ApplicationArea = All; }
        field("Is Return"; Rec."Is Return") { ApplicationArea = All; }
        field("Quantity Base"; Rec."Quantity Base") { ApplicationArea = All; }
    } } }


}

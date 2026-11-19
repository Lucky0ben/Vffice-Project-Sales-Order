table 71001 "VPM Budget"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "External Id"; Guid) {  }
        field(2; "Project No."; Code[20]) { TableRelation = Job; }
        field(3; "Task No."; Code[20]) { TableRelation = "Job Task"."Job Task No." where("Job No." = field("Project No.")); }
        field(4; "Item No."; Code[20]) { TableRelation = Item; }
        field(5; "Variant Code"; Code[10]) {  }
        field(6; "Unit of Measure"; Code[10]) {  }
        field(7; "Quantity"; Decimal) { MinValue = 0; }
        field(8; "Unit Cost LCY"; Decimal) { MinValue = 0; }
        field(9; "Revision"; Integer) { MinValue = 1; }
        field(10; "Planning Date"; Date) {  }
        field(11; "Planning Line No."; Integer) { Editable = false; }
        field(12; "Planning Line Id"; Guid) { Editable = false; }
        field(13; "Inactive"; Boolean) {  }
        field(14; "Description"; Text[100]) {  }
    }
    keys
    {
        key(PK; "External Id") { Clustered = true; }
    }
    trigger OnInsert()
    var Mgt: Codeunit "VPM Budget Mgt.";
    begin Mgt.Apply(Rec, xRec, true); end;
    trigger OnModify()
    var Mgt: Codeunit "VPM Budget Mgt.";
    begin Mgt.Apply(Rec, xRec, false); end;
    trigger OnDelete()
    begin Error('Budget deletion is not allowed. Set inactive and increment revision.'); end;

}

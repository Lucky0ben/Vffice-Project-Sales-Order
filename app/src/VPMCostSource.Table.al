table 71004 "VPM Cost Source"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Item Entry No."; Integer) { TableRelation = "Item Ledger Entry"; }
        field(2; "Project No."; Code[20]) {  }
        field(3; "Task No."; Code[20]) {  }
        field(4; "Budget Id"; Guid) {  }
        field(5; "Target LCY"; Decimal) {  }
        field(6; "Transferred LCY"; Decimal) {  }
        field(7; "Last Checked"; DateTime) {  }
        field(8; "Status"; Text[100]) {  }
        field(9; "Document No."; Code[20]) {  }
        field(10; "Source Line Id"; Guid) {  }
    }
    keys
    {
        key(PK; "Item Entry No.") { Clustered = true; }
    }

}

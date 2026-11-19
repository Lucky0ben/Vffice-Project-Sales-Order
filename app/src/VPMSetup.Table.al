table 71000 "VPM Setup"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Primary Key"; Code[10]) {  }
        field(2; "Enabled"; Boolean) {  }
        field(3; "Posting Enabled"; Boolean) {  }
        field(4; "Journal Template"; Code[10]) { TableRelation = "Gen. Journal Template"; }
        field(5; "Journal Batch"; Code[10]) { TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template")); }
        field(6; "Target Account"; Code[20]) { TableRelation = "G/L Account"; }
        field(7; "Source Account"; Code[20]) { TableRelation = "G/L Account"; }
        field(8; "Posting Date"; Date) {  }
        field(9; "Sandbox Validated"; Boolean) {  }
        field(10; "Budget Demand Validated"; Boolean) {  }
        field(11; "Next Transfer No."; Integer) { Editable = false; }
    }
    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

}

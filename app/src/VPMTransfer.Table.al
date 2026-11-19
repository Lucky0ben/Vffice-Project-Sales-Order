table 71005 "VPM Transfer"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer) {  }
        field(2; "Item Entry No."; Integer) {  }
        field(3; "Value Entry No."; Integer) {  }
        field(4; "Project No."; Code[20]) {  }
        field(5; "Task No."; Code[20]) {  }
        field(6; "Budget Id"; Guid) {  }
        field(7; "Amount LCY"; Decimal) {  }
        field(8; "Document No."; Code[20]) {  }
        field(9; "Posting Date"; Date) {  }
        field(10; "Source Account"; Code[20]) {  }
        field(11; "Target Account"; Code[20]) {  }
        field(12; "Dimension Set ID"; Integer) {  }
        field(13; "Created At"; DateTime) {  }
        field(14; "Project Entry No."; Integer) {  }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Source; "Value Entry No.") { SumIndexFields = "Amount LCY"; }
    }

}

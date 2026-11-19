table 71002 "VPM Budget Revision"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Budget Id"; Guid) {  }
        field(3; "Revision"; Integer) {  }
        field(4; "Quantity"; Decimal) {  }
        field(5; "Unit Cost LCY"; Decimal) {  }
        field(6; "Inactive"; Boolean) {  }
        field(7; "Changed At"; DateTime) {  }
        field(8; "Changed By"; Guid) {  }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }

}

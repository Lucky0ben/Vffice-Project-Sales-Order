table 71006 "VPM Value Balance"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Value Entry No."; Integer) {  }
        field(2; "Transferred LCY"; Decimal) {  }
        field(3; "Source Account"; Code[20]) {  }
        field(4; "Target Account"; Code[20]) {  }
        field(5; "Dimension Set ID"; Integer) {  }
    }
    keys
    {
        key(PK; "Value Entry No.") { Clustered = true; }
    }

}

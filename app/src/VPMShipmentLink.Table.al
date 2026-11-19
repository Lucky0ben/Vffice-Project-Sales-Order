table 71003 "VPM Shipment Link"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Document No."; Code[20]) {  }
        field(2; "Document Line No."; Integer) {  }
        field(3; "Project No."; Code[20]) {  }
        field(4; "Task No."; Code[20]) {  }
        field(5; "Budget Id"; Guid) {  }
        field(6; "Source Line Id"; Guid) {  }
        field(7; "Item No."; Code[20]) {  }
        field(8; "Is Return"; Boolean) {  }
        field(9; "Quantity Base"; Decimal) {  }
    }
    keys
    {
        key(PK; "Is Return", "Document No.", "Document Line No.") { Clustered = true; }
    }

}

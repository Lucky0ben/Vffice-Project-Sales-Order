table 71007 "VPM Mapping Setup"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Mapping Name"; Code[20]) { TableRelation = "Integration Table Mapping"; }
        field(2; "BC Field No."; Integer) {  }
        field(3; "Dataverse Field No."; Integer) {  }
    }
    keys
    {
        key(PK; "Mapping Name", "BC Field No.") { Clustered = true; }
    }

}

tableextension 71001 "VPM Sales Line" extends "Sales Line"
{
    fields
    {
        field(71000; "VPM Project Material"; Boolean) { DataClassification = CustomerContent; }
        field(71001; "VPM Project No."; Code[20]) { DataClassification = CustomerContent; TableRelation = Job; }
        field(71002; "VPM Task No."; Code[20]) { DataClassification = CustomerContent; TableRelation = "Job Task"."Job Task No." where("Job No." = field("VPM Project No.")); }
        field(71003; "VPM Budget Id"; Guid) { DataClassification = CustomerContent; }
        field(71004; "VPM Source Line Id"; Guid) { DataClassification = CustomerContent; }
    }
}

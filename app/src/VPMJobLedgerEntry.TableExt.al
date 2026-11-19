tableextension 71002 "VPM Job Ledger Entry" extends "Job Ledger Entry"
{
    fields
    {
        field(71000; "VPM Item Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Ledger Entry";
        }
        field(71001; "VPM Value Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "Value Entry";
        }
        field(71002; "VPM Budget Id"; Guid) { DataClassification = CustomerContent; }
        field(71003; "VPM Source Line Id"; Guid) { DataClassification = CustomerContent; }
        field(71004; "VPM Source Document No."; Code[20]) { DataClassification = CustomerContent; }
    }
}

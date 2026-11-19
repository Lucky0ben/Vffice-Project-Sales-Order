page 71000 "VPM Setup"
{
    PageType = Card; SourceTable = "VPM Setup"; ApplicationArea = All; UsageCategory = Administration;
    layout { area(Content) { group(Setup) {
        field("Enabled"; Rec."Enabled") { ApplicationArea = All; }
        field("Posting Enabled"; Rec."Posting Enabled") { ApplicationArea = All; }
        field("Journal Template"; Rec."Journal Template") { ApplicationArea = All; }
        field("Journal Batch"; Rec."Journal Batch") { ApplicationArea = All; }
        field("Source Account"; Rec."Source Account") { ApplicationArea = All; }
        field("Target Account"; Rec."Target Account") { ApplicationArea = All; }
        field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
        field("Sandbox Validated"; Rec."Sandbox Validated") { ApplicationArea = All; }
        field("Budget Demand Validated"; Rec."Budget Demand Validated") { ApplicationArea = All; }
    } } }

    trigger OnOpenPage()
    begin if not Rec.Get('') then begin Rec.Init(); Rec."Primary Key" := ''; Rec.Insert(); end; end;

}

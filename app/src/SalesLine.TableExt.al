tableextension 71001 "VPM Sales Line" extends "Sales Line"
{
    fields
    {
        field(71000; "VPM Project Material"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not Rec."VPM Project Material" then begin
                    Clear(Rec."VPM Project No.");
                    Clear(Rec."VPM Task No.");
                    Clear(Rec."VPM Budget Id");
                    Clear(Rec."VPM Source Line Id");
                    exit;
                end;

                ResolveVPMIdentifiers();
            end;
        }
        field(71001; "VPM Project No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Job;

            trigger OnValidate()
            begin
                if Rec."VPM Project No." <> xRec."VPM Project No." then begin
                    Clear(Rec."VPM Task No.");
                    Clear(Rec."VPM Budget Id");
                end;

                ResolveVPMIdentifiers();
            end;
        }
        field(71002; "VPM Task No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("VPM Project No."));

            trigger OnValidate()
            begin
                if Rec."VPM Task No." <> xRec."VPM Task No." then
                    Clear(Rec."VPM Budget Id");

                ResolveVPMIdentifiers();
            end;
        }
        field(71003; "VPM Budget Id"; Guid) { DataClassification = CustomerContent; }
        field(71004; "VPM Source Line Id"; Guid) { DataClassification = CustomerContent; }

        modify(Type)
        {
            trigger OnAfterValidate()
            begin
                ResolveVPMIdentifiers();
            end;
        }

        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                ResolveVPMIdentifiers();
            end;
        }

        modify("Variant Code")
        {
            trigger OnAfterValidate()
            begin
                ResolveVPMIdentifiers();
            end;
        }
    }

    local procedure ResolveVPMIdentifiers()
    var
        Budget: Record "VPM Budget";
    begin
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;
        if not Rec."VPM Project Material" then
            exit;

        if IsNullGuid(Rec."VPM Source Line Id") then
            Rec."VPM Source Line Id" := CreateGuid();

        if (Rec.Type <> Rec.Type::Item) or (Rec."No." = '') or
           (Rec."VPM Project No." = '') or (Rec."VPM Task No." = '')
        then begin
            Clear(Rec."VPM Budget Id");
            exit;
        end;

        if BudgetIdentifierIsValid() then
            exit;

        Clear(Rec."VPM Budget Id");
        Budget.SetRange("Project No.", Rec."VPM Project No.");
        Budget.SetRange("Task No.", Rec."VPM Task No.");
        Budget.SetRange("Item No.", Rec."No.");
        Budget.SetRange("Variant Code", Rec."Variant Code");
        Budget.SetRange(Inactive, false);
        if not Budget.FindSet() then
            Error(
              'No active VPM budget matches project %1, task %2, item %3 and variant %4.',
              Rec."VPM Project No.", Rec."VPM Task No.", Rec."No.", Rec."Variant Code");

        Rec."VPM Budget Id" := Budget."External Id";
        if Budget.Next() <> 0 then begin
            Clear(Rec."VPM Budget Id");
            Error(
              'More than one active VPM budget matches project %1, task %2, item %3 and variant %4. Inactivate the duplicate budget or use a different item or variant.',
              Rec."VPM Project No.", Rec."VPM Task No.", Rec."No.", Rec."Variant Code");
        end;
    end;

    local procedure BudgetIdentifierIsValid(): Boolean
    var
        Budget: Record "VPM Budget";
    begin
        if IsNullGuid(Rec."VPM Budget Id") then
            exit(false);
        if not Budget.Get(Rec."VPM Budget Id") then
            exit(false);

        exit(
          not Budget.Inactive and
          (Budget."Project No." = Rec."VPM Project No.") and
          (Budget."Task No." = Rec."VPM Task No.") and
          (Budget."Item No." = Rec."No.") and
          (Budget."Variant Code" = Rec."Variant Code"));
    end;
}

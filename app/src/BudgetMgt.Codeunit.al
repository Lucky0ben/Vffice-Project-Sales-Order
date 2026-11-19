codeunit 71000 "VPM Budget Mgt."
{
    procedure Apply(var B: Record "VPM Budget"; Old: Record "VPM Budget"; IsNew: Boolean)
    var
        Line: Record "Job Planning Line";
        LastLine: Record "Job Planning Line";
        History: Record "VPM Budget Revision";
        Setup: Record "VPM Setup";
    begin
        if IsNullGuid(B."External Id") then Error('externalId is required.');
        B.TestField("Project No."); B.TestField("Task No."); B.TestField("Item No.");
        if B.Revision < 1 then Error('Revision must be positive.');
        if B.Quantity < 0 then Error('Quantity cannot be negative.');
        if B."Unit Cost LCY" < 0 then Error('Cost cannot be negative.');
        if not IsNew then begin
            if B."External Id" <> Old."External Id" then Error('Budget identity is immutable.');
            if (B."Project No." <> Old."Project No.") or (B."Task No." <> Old."Task No.") or
               (B."Item No." <> Old."Item No.") or (B."Variant Code" <> Old."Variant Code") or
               (B."Unit of Measure" <> Old."Unit of Measure") then
                Error('Create a new budget identity for a different project, task, item, variant or unit.');
            if B.Revision <= Old.Revision then Error('Increment revision when changing the budget.');
        end;
        Setup.Get(''); Setup.TestField("Budget Demand Validated", true);
        Line.LockTable();
        if IsNew then begin
            LastLine.SetRange("Job No.", B."Project No.");
            LastLine.SetRange("Job Task No.", B."Task No.");
            B."Planning Line No." := 10000;
            if LastLine.FindLast() then B."Planning Line No." := LastLine."Line No." + 10000;
            Line.Init();
            Line.Validate("Job No.", B."Project No.");
            Line.Validate("Job Task No.", B."Task No.");
            Line."Line No." := B."Planning Line No.";
            Line.Validate("Line Type", Line."Line Type"::Budget);
            Line.Validate(Type, Line.Type::Item);
            Line.Validate("No.", B."Item No.");
            Line.Validate("Variant Code", B."Variant Code");
            if B."Unit of Measure" <> '' then Line.Validate("Unit of Measure Code", B."Unit of Measure");
        end else begin
            Line.Get(B."Project No.", B."Task No.", B."Planning Line No.");
            if Line.SystemId <> B."Planning Line Id" then Error('Planning line identity changed.');
            Line.TestField("VPM Budget Id", B."External Id");
        end;
        Line."VPM Budget Id" := B."External Id";
        Line.Validate("Usage Link", false);
        Line.Validate("Planning Date", B."Planning Date");
        if B.Inactive then Line.Validate(Quantity, 0) else Line.Validate(Quantity, B.Quantity);
        Line.Validate("Unit Cost (LCY)", B."Unit Cost LCY");
        if B.Description <> '' then Line.Description := B.Description;
        if IsNew then Line.Insert(true) else Line.Modify(true);
        B."Planning Line Id" := Line.SystemId;
        History.Init(); History."Budget Id" := B."External Id"; History.Revision := B.Revision;
        History.Quantity := B.Quantity; History."Unit Cost LCY" := B."Unit Cost LCY";
        History.Inactive := B.Inactive; History."Changed At" := CurrentDateTime();
        History."Changed By" := UserSecurityId(); History.Insert(true);
    end;
}

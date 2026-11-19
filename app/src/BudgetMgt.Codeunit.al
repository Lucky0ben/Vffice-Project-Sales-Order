codeunit 71000 "VPM Budget Mgt."
{
    procedure Apply(var B: Record "VPM Budget"; Old: Record "VPM Budget"; IsNew: Boolean)
    var
        Line: Record "Job Planning Line";
        LastLine: Record "Job Planning Line";
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
        Line.SetVPMBudgetSynchronizationInProgress(true);
        if IsNew then
            Line.Insert(true)
        else
            Line.Modify(true);
        Line.SetVPMBudgetSynchronizationInProgress(false);
        B."Planning Line Id" := Line.SystemId;
        InsertHistory(B);
    end;

    procedure RegisterPlanningLine(var Line: Record "Job Planning Line")
    var
        B: Record "VPM Budget";
    begin
        CheckBudgetDemandValidated();
        ValidateMaterialBudgetLine(Line);

        B.Init();
        B."External Id" := CreateGuid();
        CopyPlanningLineToBudget(Line, B);
        B.Revision := 1;
        B.Inactive := false;
        B."Planning Line No." := Line."Line No.";
        B."Planning Line Id" := Line.SystemId;
        B.Insert(false);
        InsertHistory(B);

        Line."VPM Budget Id" := B."External Id";
        Line.Validate("Usage Link", false);
        Line.SetVPMBudgetSynchronizationInProgress(true);
        Line.Modify(true);
        Line.SetVPMBudgetSynchronizationInProgress(false);
    end;

    procedure UpdateFromPlanningLine(Line: Record "Job Planning Line")
    var
        B: Record "VPM Budget";
        EffectiveQuantity: Decimal;
    begin
        CheckBudgetDemandValidated();
        ValidateMaterialBudgetLine(Line);
        Line.TestField("Usage Link", false);
        B.Get(Line."VPM Budget Id");
        ValidatePlanningLineIdentity(Line, B);

        EffectiveQuantity := Line.Quantity;
        if B.Inactive and (Line.Quantity = 0) then
            EffectiveQuantity := B.Quantity;

        if not PlanningLineValuesChanged(Line, B, EffectiveQuantity) then
            exit;

        B.Quantity := EffectiveQuantity;
        B."Unit Cost LCY" := Line."Unit Cost (LCY)";
        B."Planning Date" := Line."Planning Date";
        B.Description := Line.Description;
        if B.Inactive and (Line.Quantity <> 0) then
            B.Inactive := false;
        B.Revision += 1;
        B.Modify(false);
        InsertHistory(B);
    end;

    local procedure CheckBudgetDemandValidated()
    var
        Setup: Record "VPM Setup";
    begin
        Setup.Get('');
        Setup.TestField("Budget Demand Validated", true);
    end;

    local procedure ValidateMaterialBudgetLine(Line: Record "Job Planning Line")
    begin
        Line.TestField("Job No.");
        Line.TestField("Job Task No.");
        Line.TestField("Line Type", Line."Line Type"::Budget);
        Line.TestField(Type, Line.Type::Item);
        Line.TestField("No.");
        if Line.Quantity < 0 then
            Error('Quantity cannot be negative.');
        if Line."Unit Cost (LCY)" < 0 then
            Error('Cost cannot be negative.');
    end;

    local procedure CopyPlanningLineToBudget(Line: Record "Job Planning Line"; var B: Record "VPM Budget")
    begin
        B."Project No." := Line."Job No.";
        B."Task No." := Line."Job Task No.";
        B."Item No." := Line."No.";
        B."Variant Code" := Line."Variant Code";
        B."Unit of Measure" := Line."Unit of Measure Code";
        B.Quantity := Line.Quantity;
        B."Unit Cost LCY" := Line."Unit Cost (LCY)";
        B."Planning Date" := Line."Planning Date";
        B.Description := Line.Description;
    end;

    local procedure ValidatePlanningLineIdentity(Line: Record "Job Planning Line"; B: Record "VPM Budget")
    begin
        if (Line."Job No." <> B."Project No.") or (Line."Job Task No." <> B."Task No.") or
           (Line."No." <> B."Item No.") or (Line."Variant Code" <> B."Variant Code") or
           (Line."Unit of Measure Code" <> B."Unit of Measure") then
            Error('A VPM-managed planning line cannot change project, task, item, variant, or unit of measure. Create a new planning line for a different identity.');
        if (Line."Line No." <> B."Planning Line No.") or (Line.SystemId <> B."Planning Line Id") then
            Error('The VPM-managed planning line identity has changed.');
    end;

    local procedure PlanningLineValuesChanged(Line: Record "Job Planning Line"; B: Record "VPM Budget"; EffectiveQuantity: Decimal): Boolean
    begin
        exit((EffectiveQuantity <> B.Quantity) or
             (Line."Unit Cost (LCY)" <> B."Unit Cost LCY") or
             (Line."Planning Date" <> B."Planning Date") or
             (Line.Description <> B.Description) or
             (B.Inactive and (Line.Quantity <> 0)));
    end;

    local procedure InsertHistory(B: Record "VPM Budget")
    var
        History: Record "VPM Budget Revision";
    begin
        History.Init();
        History."Budget Id" := B."External Id";
        History.Revision := B.Revision;
        History.Quantity := B.Quantity;
        History."Unit Cost LCY" := B."Unit Cost LCY";
        History.Inactive := B.Inactive;
        History."Changed At" := CurrentDateTime();
        History."Changed By" := UserSecurityId();
        History.Insert(true);
    end;
}

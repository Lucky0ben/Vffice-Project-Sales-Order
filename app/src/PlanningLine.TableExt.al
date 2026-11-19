tableextension 71000 "VPM Planning Line" extends "Job Planning Line"
{
    fields { field(71000; "VPM Budget Id"; Guid) { DataClassification = CustomerContent; Editable = false; } }

    trigger OnAfterInsert()
    begin
        SynchronizeBudget();
    end;

    trigger OnAfterModify()
    begin
        SynchronizeBudget();
    end;

    trigger OnBeforeDelete()
    begin
        if not IsNullGuid(Rec."VPM Budget Id") then
            Error('A VPM-managed planning line cannot be deleted. Retire the budget through the VPM budget API, or set the planning quantity to zero to keep its audit history.');
    end;

    trigger OnBeforeRename()
    begin
        if not IsNullGuid(xRec."VPM Budget Id") then
            Error('A VPM-managed planning line cannot be renumbered. Create a new line when a different identity is required.');
    end;

    var
        VPMBudgetSynchronizationInProgress: Boolean;

    procedure SetVPMBudgetSynchronizationInProgress(NewValue: Boolean)
    begin
        VPMBudgetSynchronizationInProgress := NewValue;
    end;

    local procedure SynchronizeBudget()
    var
        BudgetMgt: Codeunit "VPM Budget Mgt.";
    begin
        if VPMBudgetSynchronizationInProgress then
            exit;

        if IsNullGuid(Rec."VPM Budget Id") then begin
            if IsMaterialBudgetLine() then
                BudgetMgt.RegisterPlanningLine(Rec);
            exit;
        end;

        BudgetMgt.UpdateFromPlanningLine(Rec);
    end;

    local procedure IsMaterialBudgetLine(): Boolean
    begin
        exit((Rec."Line Type" = Rec."Line Type"::Budget) and (Rec.Type = Rec.Type::Item));
    end;
}

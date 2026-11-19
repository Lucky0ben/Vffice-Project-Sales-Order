codeunit 71005 "VPM Journal Poster"
{
    Permissions = tabledata "Job Journal Line" = RIMD,
                  tabledata "Job Ledger Entry" = RM;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Post(Source: Record "VPM Cost Source"; VE: Record "Value Entry"; var Setup: Record "VPM Setup"; Delta: Decimal; DimId: Integer)
    var
        Jnl: Record "Gen. Journal Line";
        ProjectJnl: Record "Job Journal Line";
        Transfer: Record "VPM Transfer";
        ProjectEntry: Record "Job Ledger Entry";
        GLEntry: Record "G/L Entry";
        TargetGLEntry: Record "G/L Entry";
        PostBatch: Codeunit "Gen. Jnl.-Post Batch";
        Total: Decimal;
        DocNo: Code[20];
    begin
        Jnl.LockTable();
        Jnl.SetRange("Journal Template Name", Setup."Journal Template");
        Jnl.SetRange("Journal Batch Name", Setup."Journal Batch");
        if not Jnl.IsEmpty() then Error('The dedicated project material journal batch must be empty.');
        ProjectJnl.LockTable();
        ProjectJnl.SetRange("Journal Template Name", Setup."Project Journal Template");
        ProjectJnl.SetRange("Journal Batch Name", Setup."Project Journal Batch");
        if not ProjectJnl.IsEmpty() then Error('The dedicated VPM project journal batch must be empty.');
        Setup."Next Transfer No." += 1;
        DocNo := CopyStr('VPM' + Format(Setup."Next Transfer No.", 0, 9), 1, 20);
        GLEntry.SetRange("Document No.", DocNo);
        if not GLEntry.IsEmpty() then Error('Transfer document number %1 already exists.', DocNo);
        MakeLine(Jnl, Setup, 10000, DocNo, Setup."Target Account", Delta, DimId);
        Jnl.Insert(true);
        MakeLine(Jnl, Setup, 20000, DocNo, Setup."Source Account", -Delta, DimId);
        Jnl.Insert(true);
        Jnl.SetRange("Journal Template Name", Setup."Journal Template");
        Jnl.SetRange("Journal Batch Name", Setup."Journal Batch");
        Jnl.FindFirst();
        PostBatch.SetSuppressCommit(true);
        PostBatch.Run(Jnl); // No Boolean return here: financial transaction must remain with caller.

        TargetGLEntry.SetRange("Document No.", DocNo);
        TargetGLEntry.SetRange("G/L Account No.", Setup."Target Account");
        TargetGLEntry.SetRange("Dimension Set ID", DimId);
        if TargetGLEntry.Count() <> 1 then
            Error('Expected exactly one target G/L entry for transfer %1.', DocNo);
        TargetGLEntry.FindFirst();
        TargetGLEntry.TestField(Amount, Delta);
        PostProjectCost(ProjectJnl, ProjectEntry, Source, VE, Setup, Delta, DimId, DocNo, TargetGLEntry."Entry No.");

        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocNo);
        if GLEntry.FindSet() then repeat Total += GLEntry.Amount; until GLEntry.Next() = 0;
        if Total <> 0 then Error('Transfer %1 is not balanced.', DocNo);
        Transfer.Init(); Transfer."Entry No." := Setup."Next Transfer No.";
        Transfer."Item Entry No." := Source."Item Entry No."; Transfer."Value Entry No." := VE."Entry No.";
        Transfer."Project No." := Source."Project No."; Transfer."Task No." := Source."Task No.";
        Transfer."Budget Id" := Source."Budget Id"; Transfer."Amount LCY" := Delta;
        Transfer."Document No." := DocNo; Transfer."Posting Date" := Setup."Posting Date";
        Transfer."Source Account" := Setup."Source Account"; Transfer."Target Account" := Setup."Target Account";
        Transfer."Dimension Set ID" := DimId; Transfer."Created At" := CurrentDateTime();
        Transfer."Project Entry No." := ProjectEntry."Entry No.";
        Transfer."Source Line Id" := Source."Source Line Id";
        Transfer.Insert(true);
    end;

    local procedure PostProjectCost(var ProjectJnl: Record "Job Journal Line"; var ProjectEntry: Record "Job Ledger Entry"; Source: Record "VPM Cost Source"; VE: Record "Value Entry"; Setup: Record "VPM Setup"; Delta: Decimal; DimId: Integer; DocNo: Code[20]; GLEntryNo: Integer)
    var
        ProjectTemplate: Record "Job Journal Template";
        ProjectBatch: Record "Job Journal Batch";
        ProjectPostLine: Codeunit "Job Jnl.-Post Line";
        ProjectEntryNo: Integer;
    begin
        ProjectTemplate.Get(Setup."Project Journal Template");
        ProjectTemplate.TestField(Recurring, false);
        ProjectBatch.Get(Setup."Project Journal Template", Setup."Project Journal Batch");
        ProjectBatch.TestField(Recurring, false);

        ProjectJnl.Init();
        ProjectJnl."Journal Template Name" := Setup."Project Journal Template";
        ProjectJnl."Journal Batch Name" := Setup."Project Journal Batch";
        ProjectJnl."Line No." := 10000;
        ProjectJnl."Source Code" := ProjectTemplate."Source Code";
        ProjectJnl."Reason Code" := ProjectBatch."Reason Code";
        ProjectJnl."Posting No. Series" := ProjectBatch."Posting No. Series";
        ProjectJnl.Validate("Posting Date", Setup."Posting Date");
        ProjectJnl."Document No." := DocNo;
        ProjectJnl."External Document No." := Source."Document No.";
        ProjectJnl.Validate("Job No.", Source."Project No.");
        ProjectJnl.Validate("Job Task No.", Source."Task No.");
        ProjectJnl.Validate("Line Type", ProjectJnl."Line Type"::" ");
        ProjectJnl.Validate(Type, ProjectJnl.Type::"G/L Account");
        ProjectJnl.Validate("No.", Setup."Target Account");
        ProjectJnl.Validate(Chargeable, false);
        ProjectJnl.Validate(Quantity, 1);
        if Delta < 0 then
            ProjectJnl.Validate(Quantity, -1);
        ProjectJnl.Validate("Unit Cost (LCY)", Abs(Delta));
        ProjectJnl.Validate("Unit Price (LCY)", 0);
        ProjectJnl.TestField("Total Cost (LCY)", Delta);
        ProjectJnl.Validate("Dimension Set ID", DimId);
        ProjectJnl."Job Posting Only" := true;
        ProjectJnl.Description := CopyStr(StrSubstNo(ProjectCostDescriptionLbl, VE."Item No.", VE."Entry No."), 1, MaxStrLen(ProjectJnl.Description));
        ProjectJnl.Insert(true);

        ProjectPostLine.SetGLEntryNo(GLEntryNo);
        ProjectEntryNo := ProjectPostLine.RunWithCheck(ProjectJnl);
        ProjectJnl.Delete(true);

        ProjectEntry.Get(ProjectEntryNo);
        ProjectEntry.TestField("Document No.", DocNo);
        ProjectEntry.TestField("Job No.", Source."Project No.");
        ProjectEntry.TestField("Job Task No.", Source."Task No.");
        ProjectEntry.TestField("Total Cost (LCY)", Delta);
        ProjectEntry.TestField("Ledger Entry Type", ProjectEntry."Ledger Entry Type"::"G/L Account");
        ProjectEntry.TestField("Ledger Entry No.", GLEntryNo);
        ProjectEntry."VPM Item Entry No." := Source."Item Entry No.";
        ProjectEntry."VPM Value Entry No." := VE."Entry No.";
        ProjectEntry."VPM Budget Id" := Source."Budget Id";
        ProjectEntry."VPM Source Line Id" := Source."Source Line Id";
        ProjectEntry."VPM Source Document No." := Source."Document No.";
        ProjectEntry.Modify(false);
    end;

    local procedure MakeLine(var Jnl: Record "Gen. Journal Line"; Setup: Record "VPM Setup"; LineNo: Integer; DocNo: Code[20]; Account: Code[20]; Amount: Decimal; DimId: Integer)
    begin
        Jnl.Init();
        Jnl."Journal Template Name" := Setup."Journal Template"; Jnl."Journal Batch Name" := Setup."Journal Batch";
        Jnl."Line No." := LineNo; Jnl.Validate("Posting Date", Setup."Posting Date");
        Jnl."Document No." := DocNo;
        Jnl.Validate("Account Type", Jnl."Account Type"::"G/L Account"); Jnl.Validate("Account No.", Account);
        Jnl.Validate("Gen. Posting Type", Jnl."Gen. Posting Type"::" ");
        Jnl.Validate("VAT Bus. Posting Group", ''); Jnl.Validate("VAT Prod. Posting Group", '');
        Jnl.Validate("Currency Code", ''); Jnl.Validate(Amount, Amount);
        Jnl.Validate("Dimension Set ID", DimId);
        Jnl.Description := 'Project material cost transfer';
    end;

    var
        ProjectCostDescriptionLbl: Label 'VPM material %1 value entry %2', Comment = '%1 = Item number, %2 = Value entry number';
}

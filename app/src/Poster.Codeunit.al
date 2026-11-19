codeunit 71005 "VPM Journal Poster"
{
    [CommitBehavior(CommitBehavior::Error)]
    procedure Post(Source: Record "VPM Cost Source"; VE: Record "Value Entry"; var Setup: Record "VPM Setup"; Delta: Decimal; DimId: Integer)
    var
        Jnl: Record "Gen. Journal Line";
        PostBatch: Codeunit "Gen. Jnl.-Post Batch";
        Transfer: Record "VPM Transfer";
        ProjectEntry: Record "Job Ledger Entry";
        GLEntry: Record "G/L Entry";
        Total: Decimal;
        DocNo: Code[20];
    begin
        Jnl.LockTable();
        Jnl.SetRange("Journal Template Name", Setup."Journal Template");
        Jnl.SetRange("Journal Batch Name", Setup."Journal Batch");
        if not Jnl.IsEmpty() then Error('The dedicated project material journal batch must be empty.');
        Setup."Next Transfer No." += 1;
        DocNo := CopyStr('VPM' + Format(Setup."Next Transfer No.", 0, 9), 1, 20);
        GLEntry.SetRange("Document No.", DocNo);
        if not GLEntry.IsEmpty() then Error('Transfer document number %1 already exists.', DocNo);
        MakeLine(Jnl, Setup, 10000, DocNo, Setup."Target Account", Delta, DimId);
        Jnl.Validate("Job No.", Source."Project No.");
        Jnl.Validate("Job Task No.", Source."Task No.");
        Jnl.Validate("Job Quantity", 1);
        if Delta < 0 then Jnl.Validate("Job Quantity", -1);
        Jnl.Validate("Job Unit Cost (LCY)", Abs(Delta));
        Jnl.Validate("Job Unit Price (LCY)", 0);
        Jnl.TestField("Job Total Cost (LCY)", Delta);
        Jnl.Validate("Dimension Set ID", DimId);
        Jnl.Insert(true);
        MakeLine(Jnl, Setup, 20000, DocNo, Setup."Source Account", -Delta, DimId);
        Jnl.Insert(true);
        Jnl.SetRange("Journal Template Name", Setup."Journal Template");
        Jnl.SetRange("Journal Batch Name", Setup."Journal Batch");
        Jnl.FindFirst();
        PostBatch.SetSuppressCommit(true);
        PostBatch.Run(Jnl); // No Boolean return here: financial transaction must remain with caller.
        ProjectEntry.SetRange("Document No.", DocNo);
        ProjectEntry.SetRange("Job No.", Source."Project No.");
        ProjectEntry.SetRange("Job Task No.", Source."Task No.");
        if ProjectEntry.Count() <> 1 then Error('Expected exactly one project usage entry for %1.', DocNo);
        ProjectEntry.FindFirst();
        ProjectEntry.TestField("Total Cost (LCY)", Delta);
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
        Transfer."Project Entry No." := ProjectEntry."Entry No."; Transfer.Insert(true);
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
}

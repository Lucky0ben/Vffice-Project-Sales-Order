codeunit 71004 "VPM Process Source"
{
    TableNo = "VPM Cost Source";
    trigger OnRun()
    begin
        Process(Rec."Item Entry No.");
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure Process(ItemEntryNo: Integer)
    var
        Setup: Record "VPM Setup";
        Source: Record "VPM Cost Source";
        ILE: Record "Item Ledger Entry";
        Item: Record Item;
        VE: Record "Value Entry";
        Balance: Record "VPM Value Balance";
        GLSetup: Record "General Ledger Setup";
        Math: Codeunit "VPM Cost Math";
        Poster: Codeunit "VPM Journal Poster";
        DimId: Integer;
        Change: Decimal;
        Target: Decimal;
    begin
        // Global setup lock serializes workers and the dedicated journal batch.
        Setup.LockTable(); Setup.Get('');
        if not Setup.Enabled then exit;
        Source.LockTable(); Source.Get(ItemEntryNo);
        Source."Last Checked" := CurrentDateTime();
        GLSetup.Get(); GLSetup.TestField("Additional Reporting Currency", '');
        ILE.Get(ItemEntryNo); Item.Get(ILE."Item No.");
        if not (Item."Costing Method" in [Item."Costing Method"::FIFO, Item."Costing Method"::Average, Item."Costing Method"::Specific]) then
            Error('Only purchased FIFO, Average and Specific items are supported in this release.');
        if Item."Replenishment System" <> Item."Replenishment System"::Purchase then
            Error('Assembly and production items require a separate valuation policy.');
        // No supplier invoice hook posts a project journal. Standard valuation runs first.
        VE.LockTable(); VE.SetRange("Item Ledger Entry No.", ItemEntryNo);
        if not VE.FindSet() then begin SetPending(Source, 'Awaiting value entries'); exit; end;
        repeat
            if VE."Cost Amount (Actual)" <> VE."Cost Posted to G/L" then begin
                SetPending(Source, 'Awaiting inventory cost posting to G/L'); exit;
            end;
            Target -= VE."Cost Amount (Actual)";
        until VE.Next() = 0;
        if ILE."Invoiced Quantity" = 0 then begin
            SetPending(Source, 'Awaiting technical sales invoice'); exit;
        end;
        Source."Target LCY" := Round(Target, GLSetup."Amount Rounding Precision");
        // Preflight the complete source before transferring any component.
        VE.FindSet();
        repeat
            if VE."Cost Amount (Actual)" <> 0 then ResolveExpense(VE, Setup, DimId);
        until VE.Next() = 0;
        if not Setup."Posting Enabled" then begin
            SetPending(Source, 'Dry run - target calculated, no posting'); exit;
        end;
        Setup.TestField("Sandbox Validated", true);
        Setup.TestField("Target Account"); Setup.TestField("Source Account");
        Setup.TestField("Journal Template"); Setup.TestField("Journal Batch"); Setup.TestField("Posting Date");
        Setup.TestField("Project Journal Template"); Setup.TestField("Project Journal Batch");
        if Setup."Target Account" = Setup."Source Account" then Error('Use distinct source and project expense accounts.');
        Balance.LockTable();
        VE.FindSet();
        repeat
            if not Balance.Get(VE."Entry No.") then begin
                Balance.Init(); Balance."Value Entry No." := VE."Entry No."; Balance.Insert();
            end;
            Change := Math.Delta(VE."Cost Amount (Actual)", Balance."Transferred LCY", GLSetup."Amount Rounding Precision");
            if Change <> 0 then begin
                if VE."Cost Amount (Actual)" <> 0 then ResolveExpense(VE, Setup, DimId)
                else DimId := Balance."Dimension Set ID";
                if Balance."Transferred LCY" <> 0 then begin
                    Balance.TestField("Source Account", Setup."Source Account");
                    Balance.TestField("Target Account", Setup."Target Account");
                    Balance.TestField("Dimension Set ID", DimId);
                end;
                Poster.Post(Source, VE, Setup, Change, DimId);
                Balance."Transferred LCY" += Change;
                Balance."Source Account" := Setup."Source Account";
                Balance."Target Account" := Setup."Target Account";
                Balance."Dimension Set ID" := DimId;
                Balance.Modify();
                Source."Transferred LCY" += Change;
            end;
        until VE.Next() = 0;
        Source.Status := 'Reconciled'; Source.Modify();
        Setup.Modify();
        // No COMMIT. Boolean Run caller owns the single transaction boundary.
    end;

    local procedure SetPending(var Source: Record "VPM Cost Source"; Reason: Text)
    begin
        Source.Status := CopyStr(Reason, 1, MaxStrLen(Source.Status)); Source.Modify();
    end;

    local procedure ResolveExpense(VE: Record "Value Entry"; Setup: Record "VPM Setup"; var DimId: Integer)
    var
        Relation: Record "G/L - Item Ledger Relation";
        Other: Record "G/L - Item Ledger Relation";
        Entry: Record "G/L Entry";
        Seen: Dictionary of [Integer, Boolean];
        Found: Boolean;
        Total: Decimal;
    begin
        // Conservative resolver: never divide an aggregated G/L amount between value entries.
        Relation.SetRange("Value Entry No.", VE."Entry No.");
        if Relation.FindSet() then repeat
            Entry.Get(Relation."G/L Entry No.");
            if (Entry."G/L Account No." = Setup."Source Account") and not Seen.ContainsKey(Entry."Entry No.") then begin
                Other.SetRange("G/L Entry No.", Entry."Entry No.");
                Other.SetFilter("Value Entry No.", '<>%1', VE."Entry No.");
                if not Other.IsEmpty() then
                    Error('Value entry %1 has aggregated G/L evidence. Use per-entry inventory posting; historical aggregation needs an evidence adapter.', VE."Entry No.");
                if Found and (DimId <> Entry."Dimension Set ID") then
                    Error('Mixed expense dimensions on value entry %1 require review.', VE."Entry No.");
                DimId := Entry."Dimension Set ID"; Found := true;
                Total += Entry.Amount; Seen.Add(Entry."Entry No.", true);
            end;
        until Relation.Next() = 0;
        if (not Found) or (Total <> -VE."Cost Amount (Actual)") then
            Error('Value entry %1 has no exact actual expense evidence on account %2. Reconcile source accounting before retry.', VE."Entry No.", Setup."Source Account");
    end;
}

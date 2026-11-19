codeunit 71003 "VPM Cost Worker"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        Setup: Record "VPM Setup";
        Link: Record "VPM Shipment Link";
        ILE: Record "Item Ledger Entry";
        Source: Record "VPM Cost Source";
        Processor: Codeunit "VPM Process Source";
        Failure: Text;
    begin
        if not Setup.Get('') then exit;
        if not Setup.Enabled then exit;
        if Link.FindSet() then repeat
            ILE.Reset();
            ILE.SetRange("Document No.", Link."Document No.");
            ILE.SetRange("Document Line No.", Link."Document Line No.");
            ILE.SetRange("Item No.", Link."Item No.");
            ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
            if Link."Is Return" then
                ILE.SetRange("Document Type", ILE."Document Type"::"Sales Return Receipt")
            else
                ILE.SetRange("Document Type", ILE."Document Type"::"Sales Shipment");
            if ILE.FindSet() then repeat
                if not Source.Get(ILE."Entry No.") then begin
                    Source.Init(); Source."Item Entry No." := ILE."Entry No.";
                    Source."Project No." := Link."Project No."; Source."Task No." := Link."Task No.";
                    Source."Budget Id" := Link."Budget Id"; Source."Document No." := Link."Document No.";
                    Source.Status := 'Pending'; Source.Insert(true);
                end;
            until ILE.Next() = 0;
        until Link.Next() = 0;
        Commit(); // Discovery only; each financial unit below has its own transaction.
        Source.Reset();
        if Source.FindSet() then repeat
            Clear(Processor); ClearLastError();
            // Boolean Codeunit.Run rolls back failed financial units; do not replace with TryFunction.
            if not Processor.Run(Source) then begin
                Failure := GetLastErrorText();
                Source.Get(Source."Item Entry No.");
                Source.Status := CopyStr(Failure, 1, MaxStrLen(Source.Status));
                Source."Last Checked" := CurrentDateTime(); Source.Modify();
                Commit(); // Error record is outside the rolled-back posting transaction.
            end;
        until Source.Next() = 0;
    end;
}

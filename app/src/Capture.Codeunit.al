codeunit 71001 "VPM Source Capture"
{
    SingleInstance = true;

    var
        TempPendingSalesLine: Record "Sales Line" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure ValidateDocument(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var L: Record "Sales Line"; B: Record "VPM Budget";
    begin
        ClearPendingSalesLines();
        L.SetRange("Document Type", SalesHeader."Document Type");
        L.SetRange("Document No.", SalesHeader."No.");
        L.SetRange("VPM Project Material", true);
        if L.FindSet() then repeat
            L.TestField(Type, L.Type::Item); L.TestField("Unit Price", 0);
            L.TestField("Line Amount", 0); L.TestField("Job No.", '');
            L.TestField("VPM Project No."); L.TestField("VPM Task No.");
            if IsNullGuid(L."VPM Budget Id") or IsNullGuid(L."VPM Source Line Id") then
                Error('Material line %1 requires budget and source line identifiers.', L."Line No.");
            B.Get(L."VPM Budget Id");
            B.TestField(Inactive, false); B.TestField("Project No.", L."VPM Project No.");
            B.TestField("Task No.", L."VPM Task No."); B.TestField("Item No.", L."No.");
            if (L."Document Type" = L."Document Type"::Invoice) or
               (L."Document Type" = L."Document Type"::"Credit Memo") then
                Error('Use a Sales Order or Return Order for included project material.');
            if L."Document Type" = L."Document Type"::Order then begin
                TempPendingSalesLine := L;
                TempPendingSalesLine.Insert();
            end;
        until L.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure PostedSalesOrder(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        HasVPMMaterial: Boolean;
    begin
        HasVPMMaterial := not TempPendingSalesLine.IsEmpty();
        if PreviewMode or (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) then begin
            ClearPendingSalesLines();
            exit;
        end;

        if SalesShptHdrNo <> '' then
            CapturePostedShipment(SalesShptHdrNo);

        ClearPendingSalesLines();
        if HasVPMMaterial and not CommitIsSuppressed and not InvtPickPutaway then
            RunCostAdjustment();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Return Receipt Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure Receipt(var Rec: Record "Return Receipt Line"; RunTrigger: Boolean)
    var L: Record "Sales Line";
    begin
        if Rec.IsTemporary() then exit;
        if L.Get(L."Document Type"::"Return Order", Rec."Return Order No.", Rec."Return Order Line No.") then
            SaveLink(L, Rec."Document No.", Rec."Line No.", true, Rec."Quantity (Base)");
    end;

    local procedure SaveLink(L: Record "Sales Line"; Doc: Code[20]; LineNo: Integer; IsReturn: Boolean; Qty: Decimal)
    var Link: Record "VPM Shipment Link";
    begin
        if not L."VPM Project Material" then exit;
        if Link.Get(IsReturn, Doc, LineNo) then exit;
        Link.Init(); Link."Document No." := Doc; Link."Document Line No." := LineNo;
        Link."Is Return" := IsReturn; Link."Project No." := L."VPM Project No.";
        Link."Task No." := L."VPM Task No."; Link."Budget Id" := L."VPM Budget Id";
        Link."Source Line Id" := L."VPM Source Line Id"; Link."Item No." := L."No.";
        Link."Quantity Base" := Qty; Link.Insert(true);
    end;

    local procedure CapturePostedShipment(SalesShipmentNo: Code[20])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SetRange("Document No.", SalesShipmentNo);
        if SalesShipmentLine.FindSet() then
            repeat
                if TempPendingSalesLine.Get(
                     TempPendingSalesLine."Document Type"::Order,
                     SalesShipmentLine."Order No.",
                     SalesShipmentLine."Order Line No.")
                then
                    SaveLink(
                      TempPendingSalesLine,
                      SalesShipmentLine."Document No.",
                      SalesShipmentLine."Line No.",
                      false,
                      SalesShipmentLine."Quantity (Base)");
            until SalesShipmentLine.Next() = 0;
    end;

    local procedure RunCostAdjustment()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Worker: Codeunit "VPM Cost Worker";
    begin
        JobQueueEntry.Init();
        Worker.Run(JobQueueEntry);
    end;

    local procedure ClearPendingSalesLines()
    begin
        TempPendingSalesLine.Reset();
        TempPendingSalesLine.DeleteAll();
    end;
}

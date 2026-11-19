codeunit 71001 "VPM Source Capture"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure ValidateDocument(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var L: Record "Sales Line"; B: Record "VPM Budget";
    begin
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
        until L.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure Shipment(var Rec: Record "Sales Shipment Line"; RunTrigger: Boolean)
    var L: Record "Sales Line";
    begin
        if Rec.IsTemporary() then exit;
        if L.Get(L."Document Type"::Order, Rec."Order No.", Rec."Order Line No.") then
            SaveLink(L, Rec."Document No.", Rec."Line No.", false, Rec."Quantity (Base)");
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
        Link.Init(); Link."Document No." := Doc; Link."Document Line No." := LineNo;
        Link."Is Return" := IsReturn; Link."Project No." := L."VPM Project No.";
        Link."Task No." := L."VPM Task No."; Link."Budget Id" := L."VPM Budget Id";
        Link."Source Line Id" := L."VPM Source Line Id"; Link."Item No." := L."No.";
        Link."Quantity Base" := Qty; Link.Insert(true);
    end;
}

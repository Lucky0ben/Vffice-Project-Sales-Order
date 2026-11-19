codeunit 71007 "VPM Technical Invoice"
{
    procedure InvoiceShipped(var Header: Record "Sales Header")
    var L: Record "Sales Line"; SalesPost: Codeunit "Sales-Post"; HasQty: Boolean;
    begin
        Header.TestField("Document Type", Header."Document Type"::Order);
        L.SetRange("Document Type", Header."Document Type"); L.SetRange("Document No.", Header."No.");
        if L.FindSet(true) then repeat
            if L.Type <> L.Type::" " then begin
                L.TestField("VPM Project Material", true); L.TestField("Unit Price", 0);
                L.Validate("Qty. to Ship", 0);
                L.Validate("Qty. to Invoice", L."Quantity Shipped" - L."Quantity Invoiced");
                if L."Qty. to Invoice" <> 0 then HasQty := true;
                L.Modify(true);
            end;
        until L.Next() = 0;
        if not HasQty then Error('No shipped, uninvoiced project material is available.');
        Header.Ship := false; Header.Invoice := true;
        SalesPost.Run(Header);
    end;
}

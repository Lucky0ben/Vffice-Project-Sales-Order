pageextension 71002 "VPM Sales Order" extends "Sales Order"
{
    actions
    {
        addlast(Processing)
        {
            action(VPMInvoiceShipped)
            {
                Caption = 'Invoice shipped project material at zero'; ApplicationArea = All; Image = Invoice;
                trigger OnAction()
                var Mgt: Codeunit "VPM Technical Invoice";
                begin Mgt.InvoiceShipped(Rec); end;
            }
        }
    }
}

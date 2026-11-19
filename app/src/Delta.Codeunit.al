codeunit 71002 "VPM Cost Math"
{
    procedure Delta(ActualInventoryCost: Decimal; PostedProjectCost: Decimal; Precision: Decimal): Decimal
    begin
        if Precision <= 0 then Error('Amount rounding precision must be positive.');
        exit(Round(-ActualInventoryCost, Precision) - PostedProjectCost);
    end;
}

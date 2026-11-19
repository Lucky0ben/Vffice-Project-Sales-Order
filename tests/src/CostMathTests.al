codeunit 71150 "VPM Cost Math Tests"
{
    Subtype = Test;
    [Test]
    procedure InitialAndLateSupplierCosts()
    var Math: Codeunit "VPM Cost Math";
    begin
        AssertEqual(1200, Math.Delta(-1200, 0, 0.01));
        AssertEqual(180, Math.Delta(-1380, 1200, 0.01));
        AssertEqual(120, Math.Delta(-1500, 1380, 0.01));
    end;
    [Test]
    procedure RetryDoesNotDuplicate()
    var Math: Codeunit "VPM Cost Math";
    begin AssertEqual(0, Math.Delta(-1500, 1500, 0.01)); end;
    [Test]
    procedure ReturnsAndCostDecreasesKeepSigns()
    var Math: Codeunit "VPM Cost Math";
    begin
        AssertEqual(-250, Math.Delta(250, 0, 0.01));
        AssertEqual(-100, Math.Delta(-1400, 1500, 0.01));
        AssertEqual(-1500, Math.Delta(0, 1500, 0.01));
    end;
    [Test]
    procedure RoundCumulativeTarget()
    var Math: Codeunit "VPM Cost Math";
    begin AssertEqual(0.01, Math.Delta(-1.005, 1, 0.01)); end;
    [Test]
    procedure RejectMissingBudgetIdentity()
    var B: Record "VPM Budget";
    begin
        B.Init(); asserterror B.Insert(true);
        if StrPos(GetLastErrorText(), 'externalId') = 0 then Error('Expected identity validation.');
    end;
    local procedure AssertEqual(Expected: Decimal; Actual: Decimal)
    begin if Expected <> Actual then Error('Expected %1, got %2.', Expected, Actual); end;
}

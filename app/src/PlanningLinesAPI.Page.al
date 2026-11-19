page 71011 "VPM Planning Lines API"
{
    PageType = API; APIPublisher = 'vffice'; APIGroup = 'projectMaterials'; APIVersion = 'v1.0';
    EntityName = 'materialPlanningLine'; EntitySetName = 'materialPlanningLines';
    SourceTable = "Job Planning Line"; ODataKeyFields = SystemId;
    SourceTableView = where(Type = const(Item), "Line Type" = const(Budget));
    InsertAllowed = false; ModifyAllowed = false; DeleteAllowed = false; Extensible = false;
    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(id; Rec.SystemId) { }
                field(projectNumber; Rec."Job No.") { }
                field(taskNumber; Rec."Job Task No.") { }
                field(lineNumber; Rec."Line No.") { }
                field(itemNumber; Rec."No.") { }
                field(quantity; Rec.Quantity) { }
                field(unitCostLCY; Rec."Unit Cost (LCY)") { }
                field(totalCostLCY; Rec."Total Cost (LCY)") { }
                field(budgetId; Rec."VPM Budget Id") { }
                field(planningDate; Rec."Planning Date") { }
            }
        }
    }
}

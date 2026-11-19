page 71010 "VPM Material Budget API"
{
    PageType = API; APIPublisher = 'vffice'; APIGroup = 'projectMaterials'; APIVersion = 'v1.0';
    EntityName = 'materialBudget'; EntitySetName = 'materialBudgets';
    SourceTable = "VPM Budget"; ODataKeyFields = SystemId; DelayedInsert = true;
    DeleteAllowed = false; Extensible = false;
    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(id; Rec.SystemId) { Editable = false; }
                field(externalId; Rec."External Id") { }
                field(projectNumber; Rec."Project No.") { }
                field(taskNumber; Rec."Task No.") { }
                field(itemNumber; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(unitOfMeasureCode; Rec."Unit of Measure") { }
                field(quantity; Rec.Quantity) { }
                field(unitCostLCY; Rec."Unit Cost LCY") { }
                field(revision; Rec.Revision) { }
                field(planningDate; Rec."Planning Date") { }
                field(inactive; Rec.Inactive) { }
                field(description; Rec.Description) { }
                field(planningLineNumber; Rec."Planning Line No.") { Editable = false; }
                field(planningLineId; Rec."Planning Line Id") { Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Editable = false; }
            }
        }
    }
}

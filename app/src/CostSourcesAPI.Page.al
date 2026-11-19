page 71012 "VPM Cost Sources API"
{
    PageType = API; APIPublisher = 'vffice'; APIGroup = 'projectMaterials'; APIVersion = 'v1.0';
    EntityName = 'projectMaterialCost'; EntitySetName = 'projectMaterialCosts';
    SourceTable = "VPM Cost Source"; ODataKeyFields = SystemId;
    InsertAllowed = false; ModifyAllowed = false; DeleteAllowed = false; Extensible = false;
    layout { area(Content) { repeater(Lines) {
        field(id; Rec.SystemId) { }
        field(itemEntryNumber; Rec."Item Entry No.") { }
        field(projectNumber; Rec."Project No.") { }
        field(taskNumber; Rec."Task No.") { }
        field(budgetId; Rec."Budget Id") { }
        field(sourceLineId; Rec."Source Line Id") { }
        field(targetCostLCY; Rec."Target LCY") { }
        field(transferredCostLCY; Rec."Transferred LCY") { }
        field(status; Rec.Status) { }
        field(lastChecked; Rec."Last Checked") { }
    } } }
}

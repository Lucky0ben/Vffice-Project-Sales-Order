codeunit 71006 "VPM Mapping Installer"
{
    procedure Install()
    var
        Config: Record "VPM Mapping Setup";
        Mapping: Record "Integration Table Mapping";
        Existing: Record "Integration Field Mapping";
        NewMapping: Record "Integration Field Mapping";
        BCRef: RecordRef;
        DVRef: RecordRef;
        BCField: FieldRef;
        DVField: FieldRef;
    begin
        Config.LockTable();
        if Config.FindSet() then repeat
            Mapping.Get(Config."Mapping Name");
            Mapping.TestField("Table ID", Database::"Sales Line");
            if not (Config."BC Field No." in [71000, 71001, 71002, 71003, 71004]) then
                Error('Only VPM Sales Line fields 71000 to 71004 may be installed.');
            BCRef.Open(Database::"Sales Line");
            DVRef.Open(Mapping."Integration Table ID");
            BCField := BCRef.Field(Config."BC Field No.");
            DVField := DVRef.Field(Config."Dataverse Field No.");
            if BCField.Type <> DVField.Type then
                Error('Types differ for BC field %1 and Dataverse proxy field %2. Configure a transformation explicitly.', Config."BC Field No.", Config."Dataverse Field No.");
            Existing.SetRange("Integration Table Mapping Name", Config."Mapping Name");
            Existing.SetRange("Field No.", Config."BC Field No.");
            if Existing.FindFirst() then begin
                Existing.TestField("Integration Table Field No.", Config."Dataverse Field No.");
                Existing.TestField(Direction, Existing.Direction::FromIntegrationTable);
            end else
                NewMapping.CreateRecord(Config."Mapping Name", Config."BC Field No.", Config."Dataverse Field No.",
                    NewMapping.Direction::FromIntegrationTable, '', true, false);
            BCRef.Close(); DVRef.Close();
        until Config.Next() = 0;
    end;
}

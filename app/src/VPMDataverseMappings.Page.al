page 71005 "VPM Dataverse Mappings"
{
    PageType = List; SourceTable = "VPM Mapping Setup"; ApplicationArea = All; UsageCategory = Lists;
    layout { area(Content) { repeater(Lines) {
        field("Mapping Name"; Rec."Mapping Name") { ApplicationArea = All; }
        field("BC Field No."; Rec."BC Field No.") { ApplicationArea = All; }
        field("Dataverse Field No."; Rec."Dataverse Field No.") { ApplicationArea = All; }
    } } }
    actions { area(Processing) { action(InstallMappings) { ApplicationArea = All; Caption = 'Install field mappings'; Image = Setup;
    trigger OnAction()
    var Installer: Codeunit "VPM Mapping Installer";
    begin Installer.Install(); Message('Mappings installed. Review native synchronization direction and job queues before enabling them.'); end;
    } } }


}

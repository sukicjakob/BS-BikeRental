table 50107 "Service Type"
{
    Caption = 'Service Type';
    LookupPageId = "Service Type List";
    DrillDownPageId = "Service Type List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            Tooltip = 'Specifies the Service Type code.';
            NotBlank = true;
        }

        field(2; Description; Text[100])
        {
            Caption = 'Description';
            Tooltip = 'Specifies the Service Type description.';
        }

        field(3; "Default Duration (Hours)"; Decimal)
        {
            Caption = 'Default Duration (Hours)';
            Tooltip = 'Specifies the default duration of the Service Type (in hours).';
            MinValue = 0;
        }

        field(4; "Service Item No."; Code[20])
        {
            Caption = 'Service Item No.';
            Tooltip = 'Specifies which Service Item belongs to the Service Type.';
            TableRelation = Item."No." where(Type = const(Service));

            trigger OnValidate()
            var
                Item: Record "Item";
            begin
                if Description = '' then
                    if Item.Get("Service Item No.") then
                        Description := Item.Description;
            end;
        }

        field(5; "Default Mechanic No."; Code[20])
        {
            Caption = 'Default Mechanic No.';
            Tooltip = 'Specifies which Mechanic belongs to the Service Type by default.';
            TableRelation = Mechanic."No.";

            trigger OnValidate()
            var
                Mechanic: Record "Mechanic";
            begin
                if Mechanic.Get("Default Mechanic No.") then
                    if Mechanic.Blocked then
                        Error(MechanicBlockedErr, Mechanic."No.");
            end;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Code", "Description")
        {
        }
    }

    var
        MechanicBlockedErr: Label 'Mechanic %1 is currently blocked and cannot be selected.', Comment = '%1 = Mechanic No.';
}
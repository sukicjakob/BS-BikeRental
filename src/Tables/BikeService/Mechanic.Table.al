table 50106 "Mechanic"
{
    Caption = 'Mechanic';
    LookupPageId = "Mechanic List";
    DrillDownPageId = "Mechanic List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the mechanic''s id number.';
            NotBlank = true;
        }

        field(2; "Name"; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Name';
            ToolTip = 'Specifies the mechanic''s name.';
        }

        field(3; "Phone No."; Text[30])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Phone No.';
            ToolTip = 'Specifies the mechanic''s phone number.';
            ExtendedDatatype = PhoneNo;
        }

        field(4; "E-Mail"; Text[80])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'E-Mail';
            ToolTip = 'Specifies the mechanic''s E-Mail address.';
            ExtendedDatatype = EMail;
        }

        field(5; "Hourly Rate"; Decimal)
        {
            Caption = 'Hourly Rate';
            ToolTip = 'Specifies the mechanic''s hourly rate to calculate labor costs.';
            MinValue = 0;
        }

        field(6; "Blocked"; Boolean)
        {
            Caption = 'Blocked';
            ToolTip = 'Specifies that the mechanic cannot be assigned to new service orders.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Name")
        {
        }
    }

    trigger OnDelete()
    var
        ServiceType: Record "Service Type";
    begin
        ServiceType.SetRange("Default Mechanic No.", "No.");
        if ServiceType.FindFirst() then
            Error(MechanicSetForServiceErr, "No.", ServiceType.Code);
    end;

    var
        MechanicSetForServiceErr: Label 'Mechanic %1 cannot be deleted because it is the default mechanic for service type %2.', Comment = '%1 = Mechanic No., %2 = Service Type Code';
}
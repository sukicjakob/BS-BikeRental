
table 50101 "Bicycle"
{
    Caption = 'Bicycle';
    DataClassification = CustomerContent;
    LookupPageId = "Bicycle List";
    DrillDownPageId = "Bicycle List";
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }

        field(2; "Rental Type Code"; Code[20])
        {
            Caption = 'Rental Type Code';
            NotBlank = true;
            TableRelation = "Rental Type".Code;

            trigger OnValidate()
            var
                RentalTypeRecord: Record "Rental Type";
            begin
                if RentalTypeRecord.Get("Rental Type Code") then
                    Description := RentalTypeRecord.Description;
            end;
        }

        field(3; "Description"; Text[100])
        {
            Caption = 'Description';
        }

        field(4; "Status"; Enum "Bicycle Status")
        {
            Caption = 'Status';
            InitValue = Available;
        }

        field(5; "Purchase Date"; Date)
        {
            Caption = 'Purchase Date';
        }

        field(6; "Purchase Price"; Decimal)
        {
            Caption = 'Purchase Price';
            MinValue = 0;
        }

        field(7; "Current Location"; Text[100])
        {
            Caption = 'Current Location';
        }

        field(8; "Last Service Date"; Date)
        {
            Caption = 'Last Service Date';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}
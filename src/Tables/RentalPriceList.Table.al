
table 50104 "Rental Price List"
{
    Caption = 'Rental Price List';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }

        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
        }

        field(3; "Rental Type Code"; Code[20])
        {
            Caption = 'Rental Type Code';
            NotBlank = true;
            TableRelation = "Rental Type".Code;
        }

        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if ("Ending Date" <> 0D) and ("Starting Date" > "Ending Date")
                then
                    Error('Starting Date cannot be after Ending Date.');
            end;
        }

        field(5; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                if ("Starting Date" <> 0D) and ("Ending Date" < "Starting Date")
                then
                    Error('Ending Date cannot be before Starting Date.');
            end;
        }

        field(6; "Daily Rate"; Decimal)
        {
            Caption = 'Daily Rate';
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CheckForOverlappingPeriod();
    end;

    trigger OnModify()
    begin
        CheckForOverlappingPeriod();
    end;

    local procedure CheckForOverlappingPeriod()
    var
        ExistingPriceList: Record "Rental Price List";
    begin
        if ("Rental Type Code" = '') or ("Starting Date" = 0D) or ("Ending Date" = 0D) then
            exit;

        ExistingPriceList.SetRange("Rental Type Code", "Rental Type Code");
        ExistingPriceList.SetFilter(Code, '<>%1', Code);
        ExistingPriceList.SetFilter("Starting Date", '<=%1', "Ending Date");
        ExistingPriceList.SetFilter("Ending Date", '>=%1', "Starting Date");

        if not ExistingPriceList.IsEmpty() then
            Error('A price list with an overlapping period already exists for %1.', "Rental Type Code");
    end;
}

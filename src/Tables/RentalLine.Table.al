namespace DefaultPublisher.BSBikeRental;

table 50103 "Rental Line"
{
    Caption = 'Rental Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Rental No."; Code[20])
        {
            Caption = 'Rental No.';
            NotBlank = true;
            TableRelation = "Rental Header"."No.";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(3; "Bicycle No."; Code[20])
        {
            Caption = 'Bicycle No.';
            NotBlank = true;
            TableRelation = Bicycle."No." where(Status = const(Available));

            trigger OnValidate()
            var
                BicycleRecord: Record Bicycle;
            begin
                if not BicycleRecord.Get("Bicycle No.") then
                    Error('Bicycle with number %1 does not exist.', "Bicycle No.");

                if BicycleRecord."Rental Type Code" = '' then
                    Error('Bicycle %1 does not have a rental type.', BicycleRecord."No.");

                Description := BicycleRecord.Description;
                SetDailyRate(BicycleRecord);
            end;
        }

        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
        }

        field(5; "Daily Rate"; Decimal)
        {
            Caption = 'Daily Rate';
            trigger OnValidate()
            begin
                CalculateLineAmount();
            end;
        }

        field(6; "Rental Days"; Integer)
        {
            Caption = 'Rental Days';
            MinValue = 1;

            trigger OnValidate()
            begin
                CalculateLineAmount();
            end;
        }

        field(7; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Rental No.", "Line No.")
        {
            Clustered = true;
        }
    }

    local procedure CalculateLineAmount()
    begin
        "Line Amount" := "Daily Rate" * "Rental Days";
    end;

    local procedure SetDailyRate(BicycleRecord: Record Bicycle)
    var
        RentalHeaderRecord: Record "Rental Header";
        RentalPriceListRecord: Record "Rental Price List";
        RentalTypeRecord: Record "Rental Type";
    begin
        if not RentalHeaderRecord.Get("Rental No.") then
            Error('Rental header %1 does not exist.', "Rental No.");

        RentalPriceListRecord.SetRange("Rental Type Code", BicycleRecord."Rental Type Code");
        RentalPriceListRecord.SetFilter("Starting Date", '<=%1', RentalHeaderRecord."Rental Date");
        RentalPriceListRecord.SetFilter("Ending Date", '>=%1', RentalHeaderRecord."Rental Date");

        if RentalPriceListRecord.FindFirst() then begin
            Validate("Daily Rate", RentalPriceListRecord."Daily Rate");
            exit;
        end;

        if not RentalTypeRecord.Get(BicycleRecord."Rental Type Code") then
            Error('No price is available for rental type %1.', BicycleRecord."Rental Type Code");

        Validate("Daily Rate", RentalTypeRecord."Daily Rate");
    end;
}

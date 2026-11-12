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
                BicycleRecord: Record "Bicycle";
                ExistingRentalLine: Record "Rental Line";
            begin
                if not BicycleRecord.Get("Bicycle No.") then
                    Error('Bicycle with number %1 does not exist.', "Bicycle No.");

                if BicycleRecord."Rental Type Code" = '' then
                    Error('Bicycle %1 does not have a rental type.', BicycleRecord."No.");

                ExistingRentalLine.SetRange("Rental No.", "Rental No.");
                ExistingRentalLine.SetRange("Line Type", "Line Type"::Rental);
                ExistingRentalLine.SetRange("Bicycle No.", "Bicycle No.");
                ExistingRentalLine.SetFilter("Line No.", '<>%1', "Line No.");

                if not ExistingRentalLine.IsEmpty() then
                    Error('Bicycle %1 is already present on rental %2.', "Bicycle No.", "Rental No.");

                if BicycleRecord.Status <> BicycleRecord.Status::Available then
                    Error('Bicycle %1 is not available. Current status: %2.', BicycleRecord."No.", BicycleRecord.Status);

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

        field(8; "Line Type"; Enum "Rental Line Type")
        {
            Caption = 'Line Type';
            InitValue = Rental;
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

    trigger OnInsert()
    begin
        EnsureRentalIsOpen();
    end;

    trigger OnModify()
    begin
        EnsureRentalIsOpen();
    end;

    trigger OnDelete()
    begin
        EnsureRentalIsOpen();
    end;

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

    local procedure EnsureRentalIsOpen()
    var
        RentalHeaderRecord: Record "Rental Header";
    begin
        if not RentalHeaderRecord.Get("Rental No.") then
            Error('Rental header %1 does not exist.', "Rental No.");

        if RentalHeaderRecord.Status <> RentalHeaderRecord.Status::Open then
            Error('Rental lines cannot be changed because rental %1 has status %2.', "Rental No.", RentalHeaderRecord.Status);
    end;
}

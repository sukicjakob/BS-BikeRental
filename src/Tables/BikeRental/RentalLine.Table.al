
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
                    Error(BicycleNotFoundErr, "Bicycle No.");

                if BicycleRecord."Rental Type Code" = '' then
                    Error(NoRentalTypeErr, BicycleRecord."No.");

                ExistingRentalLine.SetRange("Rental No.", "Rental No.");
                ExistingRentalLine.SetRange("Line Type", "Line Type"::Rental);
                ExistingRentalLine.SetRange("Bicycle No.", "Bicycle No.");
                ExistingRentalLine.SetFilter("Line No.", '<>%1', "Line No.");

                if not ExistingRentalLine.IsEmpty() then
                    Error(BicycleAlreadyOnRentalErr, "Bicycle No.", "Rental No.");

                if BicycleRecord.Status <> BicycleRecord.Status::Available then
                    Error(BicycleNotAvailableErr, BicycleRecord."No.", BicycleRecord.Status);

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
                UpdateDailyRateForRentalDays();
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

        field(9; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;

            trigger OnValidate()
            begin
                CalculateLineAmount();
            end;
        }
    }

    keys
    {
        key(PK; "Rental No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        BicycleNotFoundErr: Label 'Bicycle with number %1 does not exist.', Comment = '%1 = Bicycle No.';
        NoRentalTypeErr: Label 'Bicycle %1 does not have a rental type.', Comment = '%1 = Bicycle No.';
        BicycleAlreadyOnRentalErr: Label 'Bicycle %1 is already present on rental %2.', Comment = '%1 = Bicycle No., %2 = Rental No.';
        BicycleNotAvailableErr: Label 'Bicycle %1 is not available. Current status: %2.', Comment = '%1 = Bicycle No., %2 = Bicycle status';
        RentalHeaderNotFoundErr: Label 'Rental header %1 does not exist.', Comment = '%1 = Rental No.';
        RentalTypeNotFoundErr: Label 'Rental type %1 does not exist.', Comment = '%1 = Rental Type Code';
        NoSalesPriceErr: Label 'No sales price was found for item %1 (rental type %2).', Comment = '%1 = Item No., %2 = Rental Type Code';
        RentalNotOpenErr: Label 'Rental lines cannot be changed because rental %1 has status %2.', Comment = '%1 = Rental No., %2 = Rental status';

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
    var
        GrossAmount: Decimal;
    begin
        // Bruto znesek pred popustom
        GrossAmount := Round("Daily Rate" * "Rental Days");
        "Line Amount" := GrossAmount - Round(GrossAmount * "Line Discount %" / 100);
    end;

    local procedure SetDailyRate(BicycleRecord: Record Bicycle)
    var
        RentalHeaderRecord: Record "Rental Header";
        RentalTypeRecord: Record "Rental Type";
    begin
        if not RentalHeaderRecord.Get("Rental No.") then
            Error(RentalHeaderNotFoundErr, "Rental No.");

        if not RentalTypeRecord.Get(BicycleRecord."Rental Type Code") then
            Error(RentalTypeNotFoundErr, BicycleRecord."Rental Type Code");

        if RentalTypeRecord."Rental Item No." <> '' then
            ApplySalesPrice(RentalHeaderRecord, RentalTypeRecord)
        else begin
            Validate("Line Discount %", 0);
            Validate("Daily Rate", GetDailyRateFromRentalPriceList(RentalHeaderRecord, RentalTypeRecord));
        end;
    end;

    local procedure ApplySalesPrice(RentalHeaderRecord: Record "Rental Header"; RentalTypeRecord: Record "Rental Type")
    var
        RentalPriceCalculation: Codeunit "Rental Price Calculation";
        DailyRate: Decimal;
        LineDiscountPct: Decimal;
    begin
        RentalHeaderRecord.TestField("Customer No.");

        RentalPriceCalculation.GetSalesPrice(
            RentalHeaderRecord."Customer No.",
            RentalTypeRecord."Rental Item No.",
            RentalHeaderRecord."Rental Date",
            "Rental Days",
            DailyRate,
            LineDiscountPct
        );

        if DailyRate <= 0 then
            Error(NoSalesPriceErr, RentalTypeRecord."Rental Item No.", RentalTypeRecord.Code);

        Validate("Daily Rate", DailyRate);
        Validate("Line Discount %", LineDiscountPct);
    end;

    local procedure GetDailyRateFromRentalPriceList(RentalHeaderRecord: Record "Rental Header"; RentalTypeRecord: Record "Rental Type"): Decimal
    var
        RentalPriceListRecord: Record "Rental Price List";
    begin
        RentalPriceListRecord.SetRange("Rental Type Code", RentalTypeRecord.Code);
        RentalPriceListRecord.SetFilter("Starting Date", '<=%1', RentalHeaderRecord."Rental Date");
        RentalPriceListRecord.SetFilter("Ending Date", '>=%1', RentalHeaderRecord."Rental Date");

        if RentalPriceListRecord.FindFirst() then
            exit(RentalPriceListRecord."Daily Rate");

        exit(RentalTypeRecord."Daily Rate");
    end;

    local procedure UpdateDailyRateForRentalDays()
    var
        BicycleRecord: Record Bicycle;
        RentalTypeRecord: Record "Rental Type";
    begin
        if "Line Type" <> "Line Type"::Rental then
            exit;

        if not BicycleRecord.Get("Bicycle No.") then
            exit;

        if not RentalTypeRecord.Get(BicycleRecord."Rental Type Code") then
            exit;

        if RentalTypeRecord."Rental Item No." = '' then
            exit;

        SetDailyRate(BicycleRecord);
    end;

    local procedure EnsureRentalIsOpen()
    var
        RentalHeaderRecord: Record "Rental Header";
    begin
        if not RentalHeaderRecord.Get("Rental No.") then
            Error(RentalHeaderNotFoundErr, "Rental No.");

        if RentalHeaderRecord.Status <> RentalHeaderRecord.Status::Open then
            Error(RentalNotOpenErr, "Rental No.", RentalHeaderRecord.Status);
    end;
}

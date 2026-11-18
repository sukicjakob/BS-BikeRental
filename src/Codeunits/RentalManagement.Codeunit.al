codeunit 50100 "Rental Management"
{
    procedure StartRental(var RentalHeader: Record "Rental Header")
    var
        RentalLine: Record "Rental Line";
        BicycleRecord: Record "Bicycle";

    begin
        if RentalHeader.Status <> RentalHeader.Status::Open then
            Error(RentalNotOpenErr, RentalHeader."No.", RentalHeader.Status);

        RentalHeader.TestField("Customer No.");
        RentalHeader.TestField("Rental Date");

        CheckCustomerActiveRentalLimit(RentalHeader."Customer No.");

        RentalLine.SetRange("Rental No.", RentalHeader."No.");
        RentalLine.SetRange("Line Type", RentalLine."Line Type"::Rental);

        if RentalLine.IsEmpty() then
            Error(NoRentalLinesErr, RentalHeader."No.");

        RentalLine.FindSet();
        repeat
            if not BicycleRecord.Get(RentalLine."Bicycle No.") then
                Error(BicycleNotFoundErr, RentalLine."Bicycle No.");

            if BicycleRecord.Status <> BicycleRecord.Status::Available then
                Error(BicycleNotAvailableErr, RentalLine."Bicycle No.", BicycleRecord.Status);

        until RentalLine.Next() = 0;

        RentalLine.FindSet();
        repeat
            BicycleRecord.Get(RentalLine."Bicycle No.");
            BicycleRecord.Status := BicycleRecord.Status::Rented;
            BicycleRecord.Modify(true);
        until RentalLine.Next() = 0;

        RentalHeader.Status := RentalHeader.Status::Active;
        RentalHeader.Modify(true);
    end;

    procedure CancelRental(var RentalHeader: Record "Rental Header"; CancellationReason: Text[100])
    var
        RentalLine: Record "Rental Line";
        BicycleRecord: Record "Bicycle";
    begin
        if DelChr(CancellationReason, '=', ' ') = '' then
            Error(CancellationReasonMissingErr, RentalHeader."No.");

        RentalHeader.LockTable();
        RentalHeader.Get(RentalHeader."No.");

        case RentalHeader.Status of
            RentalHeader.Status::Open:
                ;// Ni potrebno urediti ničesar;

            RentalHeader.Status::Active:
                begin
                    RentalLine.SetRange("Rental No.", RentalHeader."No.");
                    RentalLine.SetRange("Line Type", RentalLine."Line Type"::Rental);

                    if RentalLine.FindSet() then
                        repeat
                            BicycleRecord.Get(RentalLine."Bicycle No.");
                            BicycleRecord.Status := BicycleRecord.Status::Available;
                            BicycleRecord.Modify(true);
                        until RentalLine.Next() = 0;
                end;

            RentalHeader.Status::Returned:
                if RentalHeader."Sales Order No." <> '' then
                    Error(CancelSalesOrderExistsErr, RentalHeader."No.", RentalHeader."Sales Order No.");
            else
                Error(CannotCancelErr, RentalHeader."No.", RentalHeader.Status);
        end;

        RentalHeader."Cancellation Reason" := CancellationReason;
        RentalHeader.Status := RentalHeader.Status::Cancelled;
        RentalHeader.Modify(true);
    end;

    procedure ProcessReturn(var RentalHeader: Record "Rental Header")
    var
        RentalLine: Record "Rental Line";
        BicycleRecord: Record "Bicycle";
        ActualRentalDays: Integer;

    begin
        if RentalHeader.Status <> RentalHeader.Status::Active then
            Error(RentalNotActiveErr, RentalHeader."No.", RentalHeader.Status);

        RentalHeader.TestField("Rental Date");
        RentalHeader."Actual Return Date" := WorkDate();

        if RentalHeader."Actual Return Date" < RentalHeader."Rental Date" then
            Error(ReturnBeforeRentalDateErr);

        ActualRentalDays := RentalHeader."Actual Return Date" - RentalHeader."Rental Date";

        if (ActualRentalDays < 1) then
            ActualRentalDays := 1;

        RentalLine.SetRange("Rental No.", RentalHeader."No.");
        RentalLine.SetRange("Line Type", RentalLine."Line Type"::Rental);

        if RentalLine.IsEmpty() then
            Error(NoRentalLinesErr, RentalHeader."No.");

        RentalLine.FindSet();
        repeat
            if not BicycleRecord.Get(RentalLine."Bicycle No.") then
                Error(BicycleNotFoundErr, RentalLine."Bicycle No.");

        until RentalLine.Next() = 0;

        RentalLine.FindSet();
        repeat
            BicycleRecord.Get(RentalLine."Bicycle No.");
            BicycleRecord.Status := BicycleRecord.Status::Available;
            BicycleRecord.Modify(true);

            RentalLine.Validate("Rental Days", ActualRentalDays);
            RentalLine.Modify(false);
        until RentalLine.Next() = 0;

        RentalHeader.Status := RentalHeader.Status::Returned;
        RentalHeader.Modify(true);
    end;

    procedure CreateSalesOrder(var RentalHeader: Record "Rental Header")
    var
        SalesHeader: Record "Sales Header";
        RentalLine: Record "Rental Line";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        if RentalHeader.Status <> RentalHeader.Status::Returned then
            Error(RentalNotReturnedErr, RentalHeader."No.");

        RentalHeader.TestField("Sales Order No.", '');

        RentalLine.SetRange("Rental No.", RentalHeader."No.");

        if RentalLine.IsEmpty() then
            Error(NoRentalLinesErr, RentalHeader."No.");

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", RentalHeader."Customer No.");
        SalesHeader.Validate("Document Date", WorkDate());
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Modify(true);

        LineNo := 0;
        RentalLine.FindSet();

        repeat
            LineNo += 10000;
            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := LineNo;
            SalesLine.Insert(true);

            SalesLine.Validate("Type", SalesLine."Type"::Item);
            SalesLine.Validate("No.", GetSalesItemNo(RentalLine));
            SalesLine.Validate(Description, RentalLine.Description);
            SalesLine.Validate(Quantity, RentalLine."Rental Days");
            SalesLine.Validate("Unit Price", RentalLine."Daily Rate");
            SalesLine.Validate("Line Discount %", RentalLine."Line Discount %");
            SalesLine.Modify(true);
        until RentalLine.Next() = 0;

        RentalHeader."Sales Order No." := SalesHeader."No.";
        RentalHeader.Modify(true);

        Page.Run(Page::"Sales Order", SalesHeader);
    end;

    local procedure CheckCustomerActiveRentalLimit(CustomerNo: Code[20])
    var
        CustomerRecord: Record Customer;
        RentalHeaderRecord: Record "Rental Header";
        ActiveRentalCount: Integer;
    begin
        if not CustomerRecord.Get(CustomerNo) then
            Error(CustomerNotFoundErr, CustomerNo);

        RentalHeaderRecord.SetRange("Customer No.", CustomerNo);
        RentalHeaderRecord.SetRange(Status, RentalHeaderRecord.Status::Active);
        ActiveRentalCount := RentalHeaderRecord.Count();

        if ActiveRentalCount >= CustomerRecord."Max Active Rentals" then
            Error(MaxActiveRentalsErr, CustomerNo, CustomerRecord."Max Active Rentals");
    end;

    procedure AddRentalAdjustment(var RentalHeader: Record "Rental Header"; BicycleNo: Code[20]; AdjustmentDays: Integer; AdjustmentReason: Text[100])
    var
        OriginalLine: Record "Rental Line";
        AdjustmentLine: Record "Rental Line";
        ExistingAdjustment: Record "Rental Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NextLineNo: Integer;
        AlreadyAdjustedDays: Integer;
    begin
        RentalHeader.LockTable();
        RentalHeader.Get(RentalHeader."No.");
        RentalHeader.TestField(Status, RentalHeader.Status::Returned);

        if AdjustmentDays < 1 then
            Error(AdjustmentDaysErr);

        if DelChr(AdjustmentReason, '=', ' ') = '' then
            Error(AdjustmentReasonMissingErr);

        // Če račun že obstaja, preverimo da je odprt in še neknjižen
        if RentalHeader."Sales Order No." <> '' then begin
            SalesHeader.LockTable();

            if not SalesHeader.Get(SalesHeader."Document Type"::Order, RentalHeader."Sales Order No.") then
                Error(SalesOrderNotFoundErr, RentalHeader."Sales Order No.");

            SalesHeader.TestField(Status, SalesHeader.Status::Open);
            SalesHeader.TestField("Sell-to Customer No.", RentalHeader."Customer No.");
        end;

        OriginalLine.SetRange("Rental No.", RentalHeader."No.");
        OriginalLine.SetRange("Line Type", OriginalLine."Line Type"::Rental);
        OriginalLine.SetRange("Bicycle No.", BicycleNo);

        if not OriginalLine.FindFirst() then
            Error(BicycleNotOnRentalErr, BicycleNo, RentalHeader."No.");

        if OriginalLine."Daily Rate" <= 0 then
            Error(DailyRateZeroErr, BicycleNo);

        // Upoštevamo morebitne predhodne popravke
        ExistingAdjustment.SetRange("Rental No.", RentalHeader."No.");
        ExistingAdjustment.SetRange("Line Type", ExistingAdjustment."Line Type"::Adjustment);
        ExistingAdjustment.SetRange("Bicycle No.", BicycleNo);

        if ExistingAdjustment.FindSet() then
            repeat
                AlreadyAdjustedDays += ExistingAdjustment."Rental Days"
            until ExistingAdjustment.Next() = 0;

        if AlreadyAdjustedDays + AdjustmentDays > OriginalLine."Rental Days" then
            Error(TooManyAdjustmentDaysErr, OriginalLine."Rental Days" - AlreadyAdjustedDays, BicycleNo);

        // Poiščemo naslednjo prosto številko vrstice izposoje
        AdjustmentLine.SetRange("Rental No.", RentalHeader."No.");

        if AdjustmentLine.FindLast() then
            NextLineNo := AdjustmentLine."Line No." + 10000
        else
            NextLineNo := 10000;

        AdjustmentLine.Init();
        AdjustmentLine."Rental No." := RentalHeader."No.";
        AdjustmentLine."Line No." := NextLineNo;
        AdjustmentLine."Line Type" := AdjustmentLine."Line Type"::Adjustment;
        AdjustmentLine."Bicycle No." := BicycleNo;
        AdjustmentLine.Description := AdjustmentReason;
        AdjustmentLine.Validate("Rental Days", AdjustmentDays);
        AdjustmentLine.Validate("Daily Rate", -OriginalLine."Daily Rate");
        AdjustmentLine.Validate("Line Discount %", OriginalLine."Line Discount %");
        AdjustmentLine.Insert(false);

        // Če račun že obstaja se doda samo nova negativna vrstica
        if RentalHeader."Sales Order No." <> '' then begin
            SalesLine.LockTable();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");

            if SalesLine.FindLast() then
                NextLineNo := SalesLine."Line No." + 10000
            else
                NextLineNo := 10000;

            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := NextLineNo;
            SalesLine.Insert(true);

            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", GetSalesItemNo(AdjustmentLine));
            SalesLine.Validate(Description, AdjustmentLine.Description);
            SalesLine.Validate(Quantity, AdjustmentLine."Rental Days");
            SalesLine.Validate("Unit Price", AdjustmentLine."Daily Rate");
            SalesLine.Validate("Line Discount %", AdjustmentLine."Line Discount %");
            SalesLine.Modify(true);
        end;
    end;

    local procedure GetSalesItemNo(RentalLine: Record "Rental Line"): Code[20]
    var
        BicycleRecord: Record Bicycle;
        RentalTypeRecord: Record "Rental Type";
    begin
        if BicycleRecord.Get(RentalLine."Bicycle No.") then
            if RentalTypeRecord.Get(BicycleRecord."Rental Type Code") then
                if RentalTypeRecord."Rental Item No." <> '' then
                    exit(RentalTypeRecord."Rental Item No.");

        exit(DefaultRentalItemNoTok);
    end;

    var
        RentalNotOpenErr: Label 'Rental %1 must have status Open before it can be started. Current status: %2', Comment = '%1 = Rental No., %2 = Rental status';
        RentalNotActiveErr: Label 'Rental %1 must have status Active before it can be returned. Current status: %2', Comment = '%1 = Rental No., %2 = Rental status';
        RentalNotReturnedErr: Label 'Rental %1 must have status Returned before a sales order can be created.', Comment = '%1 = Rental No.';
        NoRentalLinesErr: Label 'Rental %1 has no rental lines.', Comment = '%1 = Rental No.';
        BicycleNotFoundErr: Label 'Bicycle %1 does not exist.', Comment = '%1 = Bicycle No.';
        BicycleNotAvailableErr: Label 'Bicycle %1 is not available for rental. Current status: %2', Comment = '%1 = Bicycle No., %2 = Bicycle status';
        BicycleNotOnRentalErr: Label 'Bicycle %1 is not on rental %2.', Comment = '%1 = Bicycle No., %2 = Rental No.';
        CancellationReasonMissingErr: Label 'Enter a reason for the cancellation of rental %1.', Comment = '%1 = Rental No.';
        CancelSalesOrderExistsErr: Label 'Rental %1 cannot be cancelled because sales order %2 has already been created for it.', Comment = '%1 = Rental No., %2 = Sales Order No.';
        CannotCancelErr: Label 'Rental %1 cannot be cancelled. Current status: %2.', Comment = '%1 = Rental No., %2 = Rental status';
        ReturnBeforeRentalDateErr: Label 'Actual Return Date cannot be before Rental date.';
        CustomerNotFoundErr: Label 'Customer %1 does not exist.', Comment = '%1 = Customer No.';
        MaxActiveRentalsErr: Label 'Customer %1 has already reached the maximum number of active rentals (%2).', Comment = '%1 = Customer No., %2 = Max Active Rentals';
        AdjustmentDaysErr: Label 'Adjustment days must be at least 1.';
        AdjustmentReasonMissingErr: Label 'Enter a reason for the adjustment.';
        SalesOrderNotFoundErr: Label 'Sales order %1 no longer exists. It may have been fully posted or deleted. No adjustment was added.', Comment = '%1 = Sales Order No.';
        DailyRateZeroErr: Label 'The daily rate for bicycle %1 must be greater than 0.', Comment = '%1 = Bicycle No.';
        TooManyAdjustmentDaysErr: Label 'Only %1 additional days can be deducted for bicycle %2.', Comment = '%1 = Number of days, %2 = Bicycle No.';
        DefaultRentalItemNoTok: Label 'RENTAL', Locked = true;
}
namespace DefaultPublisher.BSBikeRental;

using Microsoft.Sales.Document;

codeunit 50100 "Rental Management"
{
    procedure StartRental(var RentalHeader: Record "Rental Header")
    var
        RentalLine: Record "Rental Line";
        BicycleRecord: Record "Bicycle";

    begin
        if RentalHeader.Status <> RentalHeader.Status::Open then
            Error('Rental %1 must have status Open before it can be started. Current status: %2', RentalHeader."No.", RentalHeader.Status);

        RentalLine.SetRange("Rental No.", RentalHeader."No.");
        if RentalLine.IsEmpty() then
            Error('Rental %1 has no rental lines.', RentalHeader."No.");

        RentalLine.FindSet();
        repeat
            if not BicycleRecord.Get(RentalLine."Bicycle No.") then
                Error('Bicycle %1 does not exist.', RentalLine."Bicycle No.");

            if BicycleRecord.Status <> BicycleRecord.Status::Available then
                Error('Bicycle %1 is not available for rental. Current status: %2', RentalLine."Bicycle No.", BicycleRecord.Status);

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

    procedure ProcessReturn(var RentalHeader: Record "Rental Header")
    var
        RentalLine: Record "Rental Line";
        BicycleRecord: Record "Bicycle";

    begin
        if RentalHeader.Status <> RentalHeader.Status::Active then
            Error('Rental %1 must have status Active before it can be returned. Current status: %2', RentalHeader."No.", RentalHeader.Status);

        RentalLine.SetRange("Rental No.", RentalHeader."No.");

        if RentalLine.IsEmpty() then
            Error('Rental %1 has no rental lines.', RentalHeader."No.");

        RentalLine.FindSet();
        repeat
            if not BicycleRecord.Get(RentalLine."Bicycle No.") then
                Error('Bicycle %1 does not exist.', RentalLine."Bicycle No.");

        until RentalLine.Next() = 0;

        RentalLine.FindSet();
        repeat
            BicycleRecord.Get(RentalLine."Bicycle No.");
            BicycleRecord.Status := BicycleRecord.Status::Available;
            BicycleRecord.Modify(true);
        until RentalLine.Next() = 0;

        RentalHeader."Actual Return Date" := Today();
        RentalHeader.Status := RentalHeader.Status::Returned;
        RentalHeader.Modify(true);
    end;

    procedure CreateSalesInvoice(RentalHeader: Record "Rental Header")
    var
        SalesHeader: Record "Sales Header";
        RentalLine: Record "Rental Line";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        if RentalHeader.Status <> RentalHeader.Status::Returned then
            Error('Rental %1 must have status Returned before it can be invoiced.', RentalHeader."No.");

        RentalLine.SetRange("Rental No.", RentalHeader."No.");

        if RentalLine.IsEmpty() then
            Error('Rental %1 has no rental lines.', RentalHeader."No.");

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", RentalHeader."Customer No.");
        SalesHeader.Validate("Document Date", Today());
        SalesHeader.Validate("Posting Date", Today());
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
            SalesLine.Validate("No.", 'RENTAL');
            SalesLine.Validate(Description, RentalLine.Description);
            SalesLine.Validate(Quantity, RentalLine."Rental Days");
            SalesLine.Validate("Unit Price", RentalLine."Daily Rate");
            SalesLine.Modify(true);
        until RentalLine.Next() = 0;

        Page.Run(Page::"Sales Invoice", SalesHeader);
    end;
}

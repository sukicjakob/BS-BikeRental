codeunit 50102 "Rental Price Calculation"
{
    procedure GetDailyRate(CustomerNo: Code[20]; ItemNo: Code[20]; PriceDate: Date; RentalDays: Integer): Decimal
    var
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
    begin
        CreateTempSalesHeader(TempSalesHeader, CustomerNo, PriceDate);
        CreateTempSalesLine(TempSalesLine, TempSalesHeader, ItemNo, RentalDays);

        exit(TempSalesLine."Unit Price");
    end;

    procedure CreateTempSalesHeader(var TempSalesHeader: Record "Sales Header" temporary; CustomerNo: Code[20]; PriceDate: Date)
    begin
        TempSalesHeader.Init();
        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Order;
        TempSalesHeader."No." := 'RENTALPRICE';
        TempSalesHeader."Order Date" := PriceDate;
        TempSalesHeader."Posting Date" := PriceDate;
        TempSalesHeader."Document Date" := PriceDate;
        TempSalesHeader.Insert();

        TempSalesHeader.SetHideValidationDialog(true);
        TempSalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        TempSalesHeader.Modify();
    end;

    local procedure CreateTempSalesLine(var TempSalesLine: Record "Sales Line" temporary; TempSalesHeader: Record "Sales Header" temporary; ItemNo: Code[20]; RentalDays: Integer)
    begin
        if RentalDays < 1 then
            RentalDays := 1;

        TempSalesLine.Init();

        TempSalesLine."Document Type" := TempSalesHeader."Document Type";
        TempSalesLine."Document No." := TempSalesHeader."No.";
        TempSalesLine."Line No." := 10000;
        TempSalesLine.SetSalesHeader(TempSalesHeader);
        TempSalesLine.Insert();

        TempSalesLine.Validate("Type", TempSalesLine.Type::Item);
        TempSalesLine.Validate("No.", ItemNo);
        TempSalesLine.Validate("Quantity", RentalDays);

        TempSalesLine.Modify();
    end;
}
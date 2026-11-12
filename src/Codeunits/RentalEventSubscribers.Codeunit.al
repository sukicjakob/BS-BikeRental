namespace DefaultPublisher.BSBikeRental;

using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;

codeunit 50101 "Rental Event Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure CheckRentalStatusOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        RentalHeader: Record "Rental Header";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        RentalHeader.SetRange("Sales Order No.", SalesHeader."No.");
        if not RentalHeader.FindFirst() then
            exit;

        if RentalHeader.Status <> RentalHeader.Status::Returned then
            Error('Sales order %1 cannot be posted because rental %2 has status "%3". The rental must have status "Returned".', SalesHeader."No.", RentalHeader."No.", RentalHeader.Status);
    end;
}
namespace DefaultPublisher.BSBikeRental;

using Microsoft.Sales.Customer;

report 50100 "Rental Report"
{
    Caption = 'Rental Report';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = Word;
    WordLayout = 'src/Layouts/RentalReport.docx';
    RDLCLayout = 'src/Layouts/RentalReport.rdl';

    dataset
    {
        dataitem(CustomerData; "Customer")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";

            column(ReportCompanyName; CompanyName())
            {
            }

            column(PrintDate; Format(Today(), 0, '<Day,2>.<Month,2>.<Year4>'))
            {
            }

            column(CustomerNo; "No.")
            {
            }

            column(CustomerName; Name)
            {
            }

            column(CustomerTotalAmount; CustomerTotal)
            {
            }

            dataitem(RentalHeader; "Rental Header")
            {
                DataItemLink = "Customer No." = field("No.");
                PrintOnlyIfDetail = true;

                column(RentalNo; "No.")
                {
                    Caption = 'Rental No.';
                }

                column(RentalStatus; Status)
                {
                }

                column(RentalDate; Format("Rental Date", 0, '<Day,2>.<Month,2>.<Year4>'))
                {
                }

                column(ExpectedReturnDate; Format("Expected Return Date", 0, '<Day,2>.<Month,2>.<Year4>'))
                {
                }

                column(ActualReturnDate; Format("Actual Return Date", 0, '<Day,2>.<Month,2>.<Year4>'))
                {
                }

                dataitem(RentalLine; "Rental Line")
                {
                    DataItemLink = "Rental No." = field("No.");

                    column(BicycleNo; "Bicycle No.")
                    {
                    }

                    column(BicycleDescription; "Description")
                    {
                    }

                    column(RentalDays; "Rental Days")
                    {
                    }

                    column(DailyRate; "Daily Rate")
                    {
                    }

                    column(LineAmount; "Line Amount")
                    {
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                Clear(CustomerTotal);

                RentalHeaderForTotal.Reset();
                RentalHeaderForTotal.SetRange("Customer No.", "No.");

                if RentalHeaderForTotal.FindSet() then
                    repeat
                        RentalHeaderForTotal.CalcFields("Total Amount");
                        CustomerTotal += RentalHeaderForTotal."Total Amount";
                    until RentalHeaderForTotal.Next() = 0;
            end;
        }
    }
    var
        RentalHeaderForTotal: Record "Rental Header";
        CustomerTotal: Decimal;
}

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

            column(PrintDate; Today())
            {
            }

            column(CustomerNo; "No.")
            {
            }

            column(CustomerName; Name)
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

                column(RentalDate; "Rental Date")
                {
                }

                column(ExpectedReturnDate; "Expected Return Date")
                {
                }

                column(ActualReturnDate; "Actual Return Date")
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
        }
    }
}
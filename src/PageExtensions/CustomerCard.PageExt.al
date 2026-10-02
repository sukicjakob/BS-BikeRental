namespace DefaultPublisher.BSBikeRental;

using Microsoft.Sales.Customer;

pageextension 50100 "Customer Card Rental Ext." extends "Customer Card"
{
    layout
    {
        addlast(Content)
        {
            group("Rental Information")
            {
                Caption = 'Rental Information';

                field("Preferred Rental Type"; Rec."Preferred Rental Type")
                {
                    ApplicationArea = All;
                }

                field("VIP Customer"; Rec."VIP Customer")
                {
                    ApplicationArea = All;
                }

                field("Max Active Rentals"; Rec."Max Active Rentals")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

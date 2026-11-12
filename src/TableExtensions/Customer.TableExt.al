namespace DefaultPublisher.BSBikeRental;

using Microsoft.Sales.Customer;

tableextension 50100 "Customer Rental Ext." extends Customer
{
    fields
    {
        field(50100; "Preferred Rental Type"; Code[20])
        {
            Caption = 'Preferred Rental Type';
            DataClassification = CustomerContent;
            TableRelation = "Rental Type".Code;
        }

        field(50101; "VIP Customer"; Boolean)
        {
            Caption = 'VIP Customer';
            DataClassification = CustomerContent;
        }

        field(50102; "Max Active Rentals"; Integer)
        {
            Caption = 'Max Active Rentals';
            DataClassification = CustomerContent;
            MinValue = 1;
        }
    }
}

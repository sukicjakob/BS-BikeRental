namespace DefaultPublisher.BSBikeRental;

enum 50101 "Rental Status"
{
    value(0; "Open")
    {
        Caption = 'Open';
    }

    value(1; "Active")
    {
        Caption = 'Active';
    }

    value(2; "Returned")
    {
        Caption = 'Returned';
    }

    value(3; "Cancelled")
    {
        Caption = 'Cancelled';
    }
}
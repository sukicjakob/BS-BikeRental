namespace DefaultPublisher.BSBikeRental;

enum 50102 "Rental Line Type"
{
    Caption = 'Rental Line Type';

    value(0; Rental)
    {
        Caption = 'Rental';
    }

    value(1; Adjustment)
    {
        Caption = 'Adjustment';
    }
}
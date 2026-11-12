namespace DefaultPublisher.BSBikeRental;

page 50111 "Rental Bicycle Lookup"
{
    PageType = List;
    SourceTable = "Rental Line";
    Caption = 'Select Rental Bicycle';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Bicycle No."; Rec."Bicycle No.")
                {
                    ApplicationArea = All;
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }

                field("Rental Days"; Rec."Rental Days")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
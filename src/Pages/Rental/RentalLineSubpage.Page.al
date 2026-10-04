namespace DefaultPublisher.BSBikeRental;

page 50106 "Rental Line Subpage"
{
    PageType = ListPart;
    SourceTable = "Rental Line";
    Caption = 'Rental Lines';
    ApplicationArea = All;
    AutoSplitKey = true;
    DelayedInsert = true;

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

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Daily Rate"; Rec."Daily Rate")
                {
                    ApplicationArea = All;
                }

                field("Rental Days"; Rec."Rental Days")
                {
                    ApplicationArea = All;
                }

                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
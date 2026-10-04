namespace DefaultPublisher.BSBikeRental;

page 50107 "Rental Price List"
{
    PageType = List;
    SourceTable = "Rental Price List";
    CardPageID = "Rental Price Card";
    Caption = 'Rental Price List';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(PriceLists)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }

                field("Rental Type Code"; Rec."Rental Type Code")
                {
                    ApplicationArea = All;
                }

                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                }

                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                }

                field("Daily Rate"; Rec."Daily Rate")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

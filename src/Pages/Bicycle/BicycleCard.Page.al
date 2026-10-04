namespace DefaultPublisher.BSBikeRental;

page 50103 "Bicycle Card"
{
    PageType = Card;
    SourceTable = "Bicycle";
    Caption = 'Bicycle Card';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(GeneralInfo)
            {
                Caption = 'General info';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }

                field("Rental Type Code"; Rec."Rental Type Code")
                {
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }

            group(PurchaseInfo)
            {
                Caption = 'Purchase Info';

                field("Purchase Date"; Rec."Purchase Date")
                {
                    ApplicationArea = All;
                }

                field("Purchase Price"; Rec."Purchase Price")
                {
                    ApplicationArea = All;
                }
            }
            group(OtherInfo)
            {
                Caption = 'Other Info';

                field("Current Location"; Rec."Current Location")
                {
                    ApplicationArea = All;
                }

                field("Last Service Date"; Rec."Last Service Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
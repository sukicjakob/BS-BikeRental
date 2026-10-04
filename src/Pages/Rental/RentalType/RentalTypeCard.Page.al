namespace DefaultPublisher.BSBikeRental;

page 50101 "Rental Type Card"
{
    PageType = Card;
    SourceTable = "Rental Type";
    Caption = 'Rental Type Card';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(GeneralInfo)
            {
                Caption = 'General info';

                field(Code; Rec."Code")
                {
                    ApplicationArea = All;
                }

                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                }
            }

            group(RentalInfo)
            {
                Caption = 'Rental Info';

                field(DailyRate; Rec."Daily Rate")
                {
                    ApplicationArea = All;
                }
                field(MaxRentalDays; Rec."Max Rental Days")
                {
                    ApplicationArea = All;
                }
            }

            group(DepositInfo)
            {
                Caption = 'Deposit Info';
                field(RequiresDeposit; Rec."Requires Deposit")
                {
                    ApplicationArea = All;
                }
                field(DepositAmount; Rec."Deposit Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
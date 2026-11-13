
page 50100 "Rental Type List"
{
    PageType = List;
    SourceTable = "Rental Type";
    CardPageID = "Rental Type Card";
    Caption = 'Rental Type List';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(RentalTypes)
            {
                field(Code; Rec."Code")
                {
                    ApplicationArea = All;
                }

                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                }

                field(DailyRate; Rec."Daily Rate")
                {
                    ApplicationArea = All;
                }

                field(RequiresDeposit; Rec."Requires Deposit")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
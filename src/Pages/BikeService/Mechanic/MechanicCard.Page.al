page 50115 "Mechanic Card"
{
    Caption = 'Mechanic';
    PageType = Card;
    SourceTable = "Mechanic";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General info';

                field("No."; Rec."No.")
                {

                }

                field("Name"; Rec."Name")
                {

                }

                field("Blocked"; Rec."Blocked")
                {

                }

                field("Hourly Rate"; Rec."Hourly Rate")
                {

                }
            }

            group(Contact)
            {
                Caption = 'Contact info';

                field("Phone No."; Rec."Phone No.")
                {

                }

                field("E-Mail"; Rec."E-Mail")
                {

                }
            }
        }
    }
}
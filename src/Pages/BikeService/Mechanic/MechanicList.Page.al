page 50114 "Mechanic List"
{
    Caption = 'Mechanics';
    PageType = List;
    SourceTable = "Mechanic";
    CardPageId = "Mechanic Card";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Mechanics)
            {
                field("No."; Rec."No.")
                {

                }

                field("Name"; Rec."Name")
                {

                }

                field("Phone No."; Rec."Phone No.")
                {

                }

                field("Hourly Rate"; Rec."Hourly Rate")
                {

                }

                field("Blocked"; Rec."Blocked")
                {

                }
            }
        }
    }
}
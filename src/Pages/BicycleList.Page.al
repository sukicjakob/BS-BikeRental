namespace DefaultPublisher.BSBikeRental;

page 50102 "Bicycle List"
{
    PageType = List;
    SourceTable = "Bicycle";
    CardPageID = "Bicycle Card";
    Caption = 'Bicycle List';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Bicycles)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                }

                field("Rental Type Code"; Rec."Rental Type Code")
                {
                    ApplicationArea = All;
                }

                field(Status; Rec."Status")
                {
                    ApplicationArea = All;
                }

                field("Current Location"; Rec."Current Location")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
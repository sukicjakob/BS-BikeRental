
page 50104 "Rental List"
{
    PageType = List;
    SourceTable = "Rental Header";
    CardPageId = "Rental Card";
    Caption = 'Rental List';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Rentals)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }

                field("Rental Date"; Rec."Rental Date")
                {
                    ApplicationArea = All;
                }

                field("Expected Return Date"; Rec."Expected Return Date")
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PrintRentalReport)
            {
                Caption = 'Rental Report';
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                RunObject = report "Rental Report";
            }
        }
    }
}

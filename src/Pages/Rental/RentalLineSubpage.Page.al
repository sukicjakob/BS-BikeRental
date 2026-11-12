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
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the line is a rental or an adjustment.';
                }

                field("Bicycle No."; Rec."Bicycle No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Daily Rate"; Rec."Daily Rate")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field("Rental Days"; Rec."Rental Days")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
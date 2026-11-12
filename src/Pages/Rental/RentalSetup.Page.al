namespace DefaultPublisher.BSBikeRental;

page 50112 "Rental Setup"
{
    Caption = 'Rental Setup';
    PageType = Card;
    SourceTable = "Rental Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Numbering)
            {
                Caption = 'Numbering';

                field("Rental Nos."; Rec."Rental Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series used for rentals.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
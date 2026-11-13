
page 50110 "Rental Adjustment Dialog"
{
    PageType = StandardDialog;
    Caption = 'Add Rental Adjustment';

    layout
    {
        area(Content)
        {
            group(Adjustment)
            {
                Caption = 'Adjustment';

                field("Bicycle No."; BicycleNo)
                {
                    ApplicationArea = All;
                    Caption = 'Bicycle No.';
                    ToolTip = 'Specifies the bicycle affected by the adjustment';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RentalLine: Record "Rental Line";
                        RentalBicycleLookup: Page "Rental Bicycle Lookup";
                    begin
                        RentalLine.SetRange("Rental No.", RentalNo);
                        RentalLine.SetRange("Line Type", RentalLine."Line Type"::Rental);

                        RentalBicycleLookup.SetTableView(RentalLine);
                        RentalBicycleLookup.LookupMode(true);

                        if RentalBicycleLookup.RunModal() = Action::LookupOK then begin
                            RentalBicycleLookup.GetRecord(RentalLine);
                            BicycleNo := RentalLine."Bicycle No.";
                        end;

                        // exit(true);
                    end;

                    trigger OnValidate()
                    var
                        RentalLine: Record "Rental Line";
                    begin
                        if BicycleNo = '' then
                            exit;

                        RentalLine.SetRange("Rental No.", RentalNo);
                        RentalLine.SetRange("Line Type", RentalLine."Line Type"::Rental);
                        RentalLine.SetRange("Bicycle No.", BicycleNo);

                        if RentalLine.IsEmpty() then
                            Error('Bicycle %1 is not on rental %2.', BicycleNo, RentalNo);
                    end;
                }

                field("Adjustment Days"; AdjustmentDays)
                {
                    ApplicationArea = All;
                    Caption = 'Adjustment Days';
                    MinValue = 1;
                    ToolTip = 'Specifies the number of days to deduct.';
                }

                field(Reason; AdjustmentReason)
                {
                    ApplicationArea = All;
                    Caption = 'Reason';
                    ToolTip = 'Specifies the reason for reducing the rental amount.';
                }
            }
        }
    }

    var
        BicycleNo: Code[20];
        AdjustmentDays: Integer;
        AdjustmentReason: Text[100];
        RentalNo: Code[20];

    trigger OnOpenPage()
    begin
        AdjustmentDays := 1;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then begin
            if BicycleNo = '' then
                Error('Bicycle must be selected.');

            if AdjustmentDays < 1 then
                Error('Adjustment days must be at least 1');

            if DelChr(AdjustmentReason, '=', ' ') = '' then
                Error('Enter a reason for the adjustment.');
        end;

        exit(true);
    end;

    procedure GetBicycleNo(): Code[20]
    begin
        exit(BicycleNo);
    end;

    procedure GetAdjustmentDays(): Integer
    begin
        exit(AdjustmentDays);
    end;

    procedure GetReason(): Text[100]
    begin
        exit(AdjustmentReason);
    end;

    procedure SetRentalNo(NewRentalNo: Code[20])
    begin
        RentalNo := NewRentalNo;
    end;
}
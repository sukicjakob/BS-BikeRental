namespace DefaultPublisher.BSBikeRental;

page 50113 "Rental Cancel Dialog"
{
    PageType = StandardDialog;
    Caption = 'Cancel Rental';

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;

                field("Rental No."; RentalNo)
                {
                    ApplicationArea = All;
                    Caption = 'Rental No.';
                    Editable = false;
                    ToolTip = 'Specifies the rental that will be cancelled.';
                }

                field("Cancellation Reason"; CancellationReason)
                {
                    ApplicationArea = All;
                    Caption = 'Cancellation Reason';
                    ToolTip = 'Specifies why the rental is being cancelled. The cancellation cannot be undone.';
                }
            }
        }
    }

    var
        RentalNo: Code[20];
        CancellationReason: Text[100];

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if DelChr(CancellationReason, '=', ' ') = '' then
                Error('Enter a reason for the cancellation.');

        exit(true);
    end;

    procedure SetRentalNo(NewRentalNo: Code[20])
    begin
        RentalNo := NewRentalNo;
    end;

    procedure GetCancellationReason(): Text[100]
    begin
        exit(CancellationReason);
    end;
}
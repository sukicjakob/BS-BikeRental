namespace DefaultPublisher.BSBikeRental;

page 50105 "Rental Card"
{
    PageType = Document;
    SourceTable = "Rental Header";
    Caption = 'Rental Card';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = RentalEditable;

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Cancellation Reason"; Rec."Cancellation Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies why the rental was cancelled.';
                }
            }

            group(Dates)
            {
                Caption = 'Dates';
                Editable = RentalEditable;

                field("Rental Date"; Rec."Rental Date")
                {
                    ApplicationArea = All;
                }

                field("Expected Return Date"; Rec."Expected Return Date")
                {
                    ApplicationArea = All;
                }

                field("Actual Return Date"; Rec."Actual Return Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            part(RentalLines; "Rental Line Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Rental No." = field("No.");
                UpdatePropagation = Both;
                Editable = RentalEditable;
            }

            group(Totals)
            {
                Caption = 'Totals';

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
            action(StartRental)
            {
                Caption = 'Start Rental';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec.Status = Rec.Status::Open;
                ToolTip = 'Starts the rental. The bicycles on the rental become rented.';
                Image = Start;

                trigger OnAction()
                var
                    RentalManagement: Codeunit "Rental Management";
                begin
                    RentalManagement.StartRental(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(ProcessReturn)
            {
                Caption = 'Process Return';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec.Status = Rec.Status::Active;
                ToolTip = 'Processes the return of the bicycles and calculates the actual rental days.';
                Image = ReturnOrder;

                trigger OnAction()
                var
                    RentalManagement: Codeunit "Rental Management";
                begin
                    RentalManagement.ProcessReturn(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(CreateSalesOrder)
            {
                Caption = 'Create Sales Order';
                Enabled = (Rec.Status = Rec.Status::Returned) and (Rec."Sales Order No." = '');
                ApplicationArea = All;
                Image = Order;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create a sales order for the returned rental.';

                trigger OnAction()
                var
                    RentalManagement: Codeunit "Rental Management";
                begin
                    RentalManagement.CreateSalesOrder(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(AddAdjustment)
            {
                Caption = 'Add Adjustment';
                ApplicationArea = All;
                Image = EditAdjustments;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec.Status = Rec.Status::Returned;
                ToolTip = 'Adds a negative rental adjustment and updates an existing open sales order.';

                trigger OnAction()
                var
                    AdjustmentDialog: Page "Rental Adjustment Dialog";
                    RentalManagement: Codeunit "Rental Management";
                begin
                    AdjustmentDialog.SetRentalNo(Rec."No.");

                    if AdjustmentDialog.RunModal() = Action::OK then begin
                        RentalManagement.AddRentalAdjustment(Rec, AdjustmentDialog.GetBicycleNo(), AdjustmentDialog.GetAdjustmentDays(), AdjustmentDialog.GetReason());
                        CurrPage.Update(false);
                    end;
                end;
            }

            action(CancelRental)
            {
                Caption = 'Cancel Rental';
                ApplicationArea = All;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = CanCancel;
                Tooltip = 'Cancels the rental. Rented bicycles become available again.';

                trigger OnAction()
                var
                    RentalManagement: Codeunit "Rental Management";
                    CancelDialog: Page "Rental Cancel Dialog";
                begin
                    CancelDialog.SetRentalNo(Rec."No.");

                    if CancelDialog.RunModal() <> Action::OK then
                        exit;

                    RentalManagement.CancelRental(Rec, CancelDialog.GetCancellationReason());
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        RentalEditable: Boolean;
        CanCancel: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        RentalEditable := Rec.Status = Rec.Status::Open;
        CanCancel := (Rec.Status in [Rec.Status::Open, Rec.Status::Active]) or ((Rec.Status = Rec.Status::Returned) and (Rec."Sales Order No." = ''));
    end;
}

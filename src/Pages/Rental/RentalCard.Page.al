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
                Caption = 'Add Ajdustment';
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
        }
    }

    var
        RentalEditable: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        RentalEditable := Rec.Status = Rec.Status::Open;
    end;
}

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
                }
            }

            group(Dates)
            {
                Caption = 'Dates';

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
                }
            }

            part(RentalLines; "Rental Line Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Rental No." = field("No.");
                UpdatePropagation = Both;
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

            action(CreateSalesInvoice)
            {
                Caption = 'Create Sales Invoice';
                ApplicationArea = All;
                Image = Invoice;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    RentalManagement: Codeunit "Rental Management";
                begin
                    RentalManagement.CreateSalesInvoice(Rec);
                end;
            }
        }
    }
}

namespace DefaultPublisher.BSBikeRental;

using Microsoft.Sales.Customer;

table 50102 "Rental Header"
{
    Caption = 'Rental Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }

        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                CustomerRecord: Record Customer;
                RentalHeaderRecord: Record "Rental Header";
                ActiveRentalCount: Integer;
            begin
                if "Customer No." = '' then
                    exit;

                if not CustomerRecord.Get("Customer No.") then
                    Error('Customer %1 does not exist.', "Customer No.");

                RentalHeaderRecord.SetRange("Customer No.", "Customer No.");
                RentalHeaderRecord.SetRange("Status", "Rental Status"::Active);

                ActiveRentalCount := RentalHeaderRecord.Count();

                if ActiveRentalCount >= CustomerRecord."Max Active Rentals" then
                    Error('Customer %1 has already reached the maximum number of active rentals (%2).', "Customer No.", CustomerRecord."Max Active Rentals");
            end;
        }

        field(3; "Rental Date"; Date)
        {
            Caption = 'Rental Date';

            trigger OnValidate()
            begin
                if ("Expected Return Date" <> 0D) and ("Rental Date" > "Expected Return Date") then
                    Error('Rental Date cannot be after the Expected Return Date.');
            end;
        }

        field(4; "Expected Return Date"; Date)
        {
            Caption = 'Expected Return Date';

            trigger OnValidate()
            begin
                if ("Rental Date" <> 0D) and ("Expected Return Date" <> 0D) and ("Expected Return Date" < "Rental Date") then
                    Error('Expected Return Date cannot be before the Rental Date.');
            end;
        }

        field(5; "Actual Return Date"; Date)
        {
            Caption = 'Actual Return Date';
        }

        field(6; Status; Enum "Rental Status")
        {
            Caption = 'Status';
            InitValue = Open;
        }

        field(7; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("Rental Line"."Line Amount" where("Rental No." = field("No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}

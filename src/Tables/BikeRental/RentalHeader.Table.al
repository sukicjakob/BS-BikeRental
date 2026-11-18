

table 50102 "Rental Header"
{
    Caption = 'Rental Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                RentalSetup: Record "Rental Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    RentalSetup.Get();
                    NoSeries.TestManual(RentalSetup."Rental Nos.");
                    "No. Series" := '';
                end;
            end;
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
                    Error(CustomerNotFoundErr, "Customer No.");

                RentalHeaderRecord.SetRange("Customer No.", "Customer No.");
                RentalHeaderRecord.SetRange("Status", "Rental Status"::Active);

                ActiveRentalCount := RentalHeaderRecord.Count();

                if ActiveRentalCount >= CustomerRecord."Max Active Rentals" then
                    Error(MaxActiveRentalsErr, "Customer No.", CustomerRecord."Max Active Rentals");
            end;
        }

        field(3; "Rental Date"; Date)
        {
            Caption = 'Rental Date';

            trigger OnValidate()
            begin
                if ("Expected Return Date" <> 0D) and ("Rental Date" > "Expected Return Date") then
                    Error(RentalDateAfterReturnErr);
            end;
        }

        field(4; "Expected Return Date"; Date)
        {
            Caption = 'Expected Return Date';

            trigger OnValidate()
            begin
                if ("Rental Date" <> 0D) and ("Expected Return Date" <> 0D) and ("Expected Return Date" < "Rental Date") then
                    Error(ReturnBeforeRentalDateErr);
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

        field(8; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            Editable = false;
            TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
        }

        field(9; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }

        field(10; "Cancellation Reason"; Text[100])
        {
            Caption = 'Cancellation Reason';
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

    var
        CustomerNotFoundErr: Label 'Customer %1 does not exist.', Comment = '%1 = Customer No.';
        MaxActiveRentalsErr: Label 'Customer %1 has already reached the maximum number of active rentals (%2).', Comment = '%1 = Customer No., %2 = Max Active Rentals';
        RentalDateAfterReturnErr: Label 'Rental Date cannot be after the Expected Return Date.';
        ReturnBeforeRentalDateErr: Label 'Expected Return Date cannot be before the Rental Date.';
        RentalDeleteNotAllowedErr: Label 'Rental %1 in status %2 cannot be deleted.', Comment = '%1 = Rental No., %2 = Rental Status Code';

    trigger OnInsert()
    var
        RentalSetup: Record "Rental Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            RentalSetup.Get();
            RentalSetup.TestField("Rental Nos.");
            "No. Series" := RentalSetup."Rental Nos.";
            "No." := NoSeries.GetNextNo("No. Series");
        end;

        if "Rental Date" = 0D then
            "Rental Date" := WorkDate();
    end;

    trigger OnDelete()
    var
        RentalLine: Record "Rental Line";
    begin
        if not (Status in [Status::Open, Status::Cancelled]) then
            Error(RentalDeleteNotAllowedErr, "No.", Status);

        RentalLine.SetRange("Rental No.", "No.");
        RentalLine.DeleteAll(false);
    end;

    procedure AssistEdit(OldRentalHeader: Record "Rental Header"): Boolean
    var
        RentalSetup: Record "Rental Setup";
        NoSeries: Codeunit "No. Series";
    begin
        RentalSetup.Get();
        RentalSetup.TestField("Rental Nos.");
        if NoSeries.LookupRelatedNoSeries(RentalSetup."Rental Nos.", OldRentalHeader."No. Series", "No. Series") then begin
            "No." := NoSeries.GetNextNo("No. Series");
            exit(true);
        end;
    end;
}
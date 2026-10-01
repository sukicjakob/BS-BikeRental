namespace DefaultPublisher.BSBikeRental;

table 50103 "Rental Line"
{
    Caption = 'Rental Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Rental No."; Code[20])
        {
            Caption = 'Rental No.';
            NotBlank = true;
            TableRelation = "Rental Header"."No.";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(3; "Bicycle No."; Code[20])
        {
            Caption = 'Bicycle No.';
            NotBlank = true;
            TableRelation = Bicycle."No." where(Status = const(Available));

            trigger OnValidate()
            var
                BicycleRecord: Record Bicycle;
            begin
                if BicycleRecord.Get("Bicycle No.") then
                    Description := BicycleRecord.Description;
            end;
        }

        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
        }

        field(5; "Daily Rate"; Decimal)
        {
            Caption = 'Daily Rate';
            trigger OnValidate()
            begin
                CalculateLineAmount();
            end;
        }

        field(6; "Rental Days"; Integer)
        {
            Caption = 'Rental Days';
            MinValue = 1;

            trigger OnValidate()
            begin
                CalculateLineAmount();
            end;
        }

        field(7; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Rental No.", "Line No.")
        {
            Clustered = true;
        }
    }

    local procedure CalculateLineAmount()
    begin
        "Line Amount" := "Daily Rate" * "Rental Days";
    end;
}
namespace DefaultPublisher.BSBikeRental;

xmlport 50100 "Bicycle Import"
{
    Caption = 'Bicycle Import';
    Direction = Import;
    Format = Xml;

    schema
    {
        textelement(Bicycles)
        {
            tableelement(BicycleRecord; Bicycle)
            {
                XmlName = 'Bicycle';

                fieldelement(No; BicycleRecord."No.")
                {
                }

                fieldelement(RentalType; BicycleRecord."Rental Type Code")
                {
                    FieldValidate = No;
                }

                fieldelement(Description; BicycleRecord.Description)
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    RentalTypeRecord: Record "Rental Type";
                begin
                    if not RentalTypeRecord.Get(BicycleRecord."Rental Type Code") then begin
                        CurrXmlport.Skip();
                        exit;
                    end;

                    BicycleRecord.Status := BicycleRecord.Status::Available;
                end;
            }
        }
    }
}

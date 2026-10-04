namespace DefaultPublisher.BSBikeRental;

page 50109 "Bicycle API"
{
    PageType = API;
    APIPublisher = 'bsbikerental';
    APIGroup = 'rental';
    APIVersion = 'v1.0';

    SourceTable = Bicycle;
    DelayedInsert = true;
    EntityName = 'bicycle';
    EntitySetName = 'bicycles';

    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec."SystemId")
                {
                    Caption = 'Id';
                }

                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }

                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }

                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }

                field(rentalType; Rec."Rental Type Code")
                {
                    Caption = 'Rental Type';
                }
            }
        }
    }
}



query 50100 "Rental Analysis"
{
    Caption = 'Rental Analysis';
    QueryType = Normal;

    elements
    {
        dataitem(CustomerData; "Customer")
        {
            column(CustomerNo; "No.")
            {
                Caption = 'Customer No.';
            }

            column(CustomerName; Name)
            {
                Caption = 'Customer Name';
            }

            dataitem(RentalHeader; "Rental Header")
            {
                DataItemLink = "Customer No." = CustomerData."No.";
                DataItemTableFilter = Status = const(Active);
                SqlJoinType = InnerJoin;

                column(RentalNo; "No.")
                {
                    Caption = 'Rental No.';
                }

                column(RentalStatus; Status)
                {
                    Caption = 'Rental Status';
                }

                dataitem(RentalLine; "Rental Line")
                {
                    DataItemLink = "Rental No." = RentalHeader."No.";
                    SqlJoinType = InnerJoin;

                    column(RentalDays; "Rental Days")
                    {
                        Caption = 'Rental Days';
                    }

                    column(LineAmount; "Line Amount")
                    {
                        Caption = 'Line Amount';
                    }

                    dataitem(BicycleData; Bicycle)
                    {
                        DataItemLink = "No." = RentalLine."Bicycle No.";
                        SqlJoinType = InnerJoin;

                        column(BicycleNo; "No.")
                        {
                            Caption = 'Bicycle No.';
                        }

                        column(BicycleDescription; Description)
                        {
                            Caption = 'Bicycle Description';
                        }
                    }
                }
            }
        }
    }
}
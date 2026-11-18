page 50116 "Service Type List"
{
    Caption = 'Service Types';
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Service Type";
    Editable = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater("Service Types")
            {
                field(Code; Rec."Code")
                {

                }

                field(Description; Rec."Description")
                {

                }

                field("Default Duration (Hours)"; Rec."Default Duration (Hours)")
                {

                }

                field("Service Item No."; Rec."Service Item No.")
                {

                }

                field("Default Mechanic No."; rec."Default Mechanic No.")
                {

                }
            }
        }
    }
}
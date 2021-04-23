pageextension 51086 "Bank Account Card" extends "Bank Account Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Balance (LCY)")
        {
            field("Source code"; "Source code")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
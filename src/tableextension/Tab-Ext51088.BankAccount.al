tableextension 51088 "Bank Account" extends "Bank Account"
{
    fields
    {
        field(51080; "Source code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source Code', Comment = 'FRA:"Code Journal"';
            TableRelation = "Source Code";
        }
        // Add changes to table fields here
    }

    var
        myInt: Integer;
}
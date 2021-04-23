tableextension 51087 "Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(51080; "Code Retenue à la Source"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(50000; "External Reference"; Text[50])
        {
            Caption = 'External Reference', Comment = 'FRA=Référence Externe, ENU= External Reference';
            DataClassification = ToBeClassified;
        }
        // Add changes to table fields here
    }

    var
        myInt: Integer;
}
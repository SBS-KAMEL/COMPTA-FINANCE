tableextension 51085 "Payment Post. Buffer" extends "Payment Post. Buffer"
{
    fields
    {
        field(5180; "Code Retenue à la Source"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(51081; "Compte Retenue"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Groupe Retenue";
        }
        field(51082; "Amount Retenue"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51083; "Amount Retenue (LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51084; "Assiette RS"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51085; "External reference"; Text[50])
        {
            Caption = 'External reference', Comment = 'FRA = Référence externe, ENU = External reference';
            DataClassification = ToBeClassified;
        }
        // Add changes to table fields here
    }

    var
        myInt: Integer;
}
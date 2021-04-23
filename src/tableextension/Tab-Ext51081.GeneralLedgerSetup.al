tableextension 51081 "General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        // Add changes to table fields here
        field(51080; "Plafond Mnt Exonoration"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51081; "Code retenue par defaut"; code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Groupe Retenue";
        }
    }
}
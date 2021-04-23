/// <summary>
/// TableExtension Payment Step Ledger (ID 51083) extends Record Payment Step Ledger.
/// </summary>
tableextension 51083 "Payment Step Ledger" extends "Payment Step Ledger"
{
    fields
    {
        // Add changes to table fields here
        field(51080; "Calculer Retenue à la Source"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51081; "Annuler Retenue à la Source"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51082; "Groupe Compta Salarié"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Posting Group";
        }
    }
}
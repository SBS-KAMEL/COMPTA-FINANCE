/// <summary>
/// TableExtension "PaymentStepExt" (ID 51093) extends Record Payment Step.
/// </summary>
tableextension 51093 PaymentStepExt extends "Payment Step"
{
    fields
    {
        field(51080; "Lettrage Obligatoire"; Boolean)
        {
            Caption = 'Lettrage Obligatoire';
            DataClassification = ToBeClassified;
        }
        field(51081; "No. Doc Externe Obligatoir"; Boolean)
        {
            Caption = 'No. Doc Externe Obligatoir';
            DataClassification = ToBeClassified;
        }
        field(51082; "Banque Ligne obligatoire"; Boolean)
        {
            Caption = 'Banque Ligne obligatoire';
            DataClassification = ToBeClassified;
        }
        field(51083; "Blocage Compte"; Boolean)
        {
            Caption = 'Blocage Compte';
            DataClassification = ToBeClassified;
        }
        field(51084; "Réf. Bord. banque Oblogatoire"; Boolean)
        {
            Caption = 'Réf. Borderau banque Oblogatoire';
            DataClassification = ToBeClassified;
        }

    }
}

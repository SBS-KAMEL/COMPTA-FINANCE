tableextension 51084 "Payment Status" extends "Payment Status"
{
    fields
    {

        field(51080; "Calculer Retenue à la Source"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}
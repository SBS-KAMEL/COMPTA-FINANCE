pageextension 51085 "Payment Step Ledger List" extends "Payment Step Ledger List"
{
    layout
    {
        addafter("Account No.")
        {

            field("Calculer Retenue à la Source"; "Calculer Retenue à la Source")
            {
                ApplicationArea = All;
            }
            field("Annuler Retenue à la Source"; "Annuler Retenue à la Source")
            {
                ApplicationArea = All;
            }

        }

    }

}
pageextension 51082 "Payment Step Ledger" extends "Payment Step Ledger"
{
    layout
    {
        addafter("Vendor Posting Group")
        {
            field("Groupe Compta Salarié"; "Groupe Compta Salarié")
            {
                ApplicationArea = all;
            }
        }
        addafter("Document No.")
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
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
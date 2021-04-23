pageextension 51083 "Payment Status" extends "Payment Status"
{
    layout
    {
        addafter(RIB)
        {
            field("Calculer Retenue à la Source"; "Calculer Retenue à la Source")
            {
                ApplicationArea = All;
            }
        }
        // Add changes to page layout here
    }

}
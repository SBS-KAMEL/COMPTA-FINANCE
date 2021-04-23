/// <summary>
/// PageExtension "PaymentSlipCard" (ID 51100) extends Record Payment Step Card.
/// </summary>
pageextension 51100 PaymentSlipCard extends "Payment Step Card"
{
    layout
    {
        addlast(Control1)
        {

            field("Réf. Bord. banque Oblogatoire"; Rec."Réf. Bord. banque Oblogatoire")
            {
                ApplicationArea = All;
            }
        }
    }

}
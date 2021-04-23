/// <summary>
/// PageExtension "PaymentStepExt" (ID 51099) extends Record MyTargetPage.
/// </summary>
pageextension 51099 PaymentStepExt extends "Payment Steps"
{
    layout
    {
        // Add changes to page layout here
        addafter(Name)
        {
            field("Lettrage Obligatoire"; "Lettrage Obligatoire")
            {

            }
            field("Affectation utilisateur"; AffectationUser)
            {
                trigger OnAssistEdit()
                var
                    RecAutorisationEtape: Record "Autorisation Etape";
                begin
                    //MIGRATION 2015
                    RecAutorisationEtape.SETRANGE("Type de règlement", "Payment Class");
                    RecAutorisationEtape.SETRANGE("No. Etape", Line);
                    PAGE.RUNMODAL(51087, RecAutorisationEtape);
                    //MIGRATION 2015
                end;
            }
        }


    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
        AffectationUser: Code[50];
}

/// <summary>
/// PageExtension "Purge" (ID 51089) extends Record Contact List.
/// </summary>
pageextension 51089 Purge extends "Contact List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addfirst(reporting)
        {
            action(Purge)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    if Confirm('Voulez vous Maj Groupement BL', true, false) then begin


                        /*clear(RecTableTmp);
                        RecTabletmp.FindFirst();
                        repeat
                            //RecTableTmp.CalcFields("Code Vendeur");
                            RecTableTmp."Code Vendeur" := RecTableTmp."Code Vendeur tmp";
                            RecTableTmp.Modify();
                        until RecTableTmp.Next() = 0;*/

                        SalesHeader.setfilter("Document Type", '%1', SalesHeader."Document Type"::Order);
                        SalesHeader.FindFirst();
                        repeat
                            SalesHeader."Combine Shipments" := true;
                            SalesHeader.Modify();
                        until SalesHeader.next = 0;

                        Message('terminer');

                    end;


                end;
            }
        }
    }

    var
        myInt: Integer;
        RecTableTmp: Record "Payment Line";
        SalesHeader: Record "Sales Header";

}
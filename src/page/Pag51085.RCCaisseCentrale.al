/// <summary>
/// Page RC-Caissier-Comptable (ID 51082).
/// </summary>51085
page 51085 "RC-Caisse Centrale"
{
    PageType = RoleCenter;
    Caption = 'Caisse centrale';

    layout
    {
        area(RoleCenter)
        {
            part(Headline; HeadLineCaissierComptable)
            {
                ApplicationArea = Basic, Suite;
            }
            part(Activities; ActivityCaisseCentrale)
            {
                ApplicationArea = Basic, Suite;
            }
            part("Help And Chart Wrapper"; "Help And Chart Wrapper")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Report Inbox Part"; "Report Inbox Part")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Power BI Report Spinner Part"; "Power BI Report Spinner Part")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(Sections)          //Liste des documents enregistrés
        {
            group(DocumentVentesvalidés)
            {
                Caption = 'Documents ventes validés';
                Image = Sales;

                action(BLVentesEnregistrees)
                {
                    Caption = 'Expéditions enregistrées';
                    ApplicationArea = all;
                    RunObject = page "Posted Sales Shipments";


                }
                action(FactureVentesEnregistrées)
                {
                    Caption = 'Factures enregistrées';
                    ApplicationArea = all;
                    RunObject = page "Posted Sales Invoices";
                }
                action(AvoirVentesEnregistrées)
                {
                    Caption = 'Avoir enregistrées';
                    ApplicationArea = all;
                    RunObject = page "Posted Sales Credit Memos";
                }

            }
            group(DocumenstSerivcesenregistres)
            {
                Caption = 'Documents services validés';
                Image = Sales;
                action(FactureServiceEnregistrées)
                {
                    Caption = 'Factures enregistrées';
                    ApplicationArea = all;
                    RunObject = page "Posted Service Invoices";
                }
                action(AvoirServiceEnregistrees)
                {
                    Caption = 'Avoirs enregistrés';
                    ApplicationArea = all;
                    RunObject = page "Posted Service Credit Memos";
                }
            }
            group(DocumentAchatsvalidés)
            {
                Caption = 'Documents achats validés';
                Image = Purchasing;
                action(Bondereceptionenregistres)
                {
                    Caption = 'Réceptions enregistées';
                    RunObject = page "Posted Purchase Receipts";
                    ApplicationArea = all;

                }
                action(FacturesAchatsenregistres)
                {
                    Caption = 'Factures enregistés';
                    RunObject = page "Posted Purchase Invoices";
                    ApplicationArea = all;

                }
                action(AvoirAchatsenregistres)
                {
                    Caption = 'Avoirs enregistés';
                    RunObject = page "Posted Purchase Credit Memos";
                    ApplicationArea = all;

                }

            }

        }
        area(Embedding)
        {
            action(Customer)
            {
                Caption = 'Clients';
                ApplicationArea = all;
                RunObject = page "Customer List";
            }
            action(Vendor)
            {
                Caption = 'Fournisseur';
                ApplicationArea = all;
                RunObject = page "Vendor List";
            }
            action(Bank)
            {
                Caption = 'Banques';
                ApplicationArea = all;
                RunObject = page "Bank Account List";
            }
            action(Bordereau)
            {
                Caption = 'Bordereau de paiement';
                ApplicationArea = all;
                RunObject = page "Payment Slip List";
            }

        }
        area(Processing)
        {
            group(Traitement)
            {
                Caption = 'Traitement';
                action(AfficherEditerLignepaiement)
                {
                    Caption = 'Afficher/Edier ligne paiments';
                    Image = Action;
                    RunObject = page "View/Edit Payment Line";
                    ApplicationArea = all;

                }
                action(CreerBorderauPaiement)
                {
                    Caption = 'Creer Borderau Paiement';
                    Image = Action;
                    RunObject = codeunit "Payment Management";
                    ApplicationArea = all;

                }
            }
        }
    }


}
// Creates a profile that uses the Role Center
profile "RC Caissie Comp Flower-Hyg"
{
    ProfileDescription = 'Rôle center Caissie Comptable';
    RoleCenter = "RC-Caissie-Secondaire";
    Caption = 'Rôle center Caissie Comptable';
}


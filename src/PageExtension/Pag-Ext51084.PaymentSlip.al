
/// <summary>
/// PageExtension Payment Slip (ID 51084) extends Record Payment Slip.
/// </summary>
pageextension 51084 "Payment Slip" extends "Payment Slip"
{
    layout
    {
        // Add changes to page layout here
        addafter("Posting Date")
        {
            field("Date validation"; "Date validation")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Type Réglement"; Rec."Type Réglement")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Code Vendeur"; Rec."Code Vendeur")
            {
                ApplicationArea = All;
                Editable = true;
            }
            field("Réf. Borderaeu banque"; "Réf. Borderaeu banque")
            {
                ApplicationArea = All;
                Editable = true;
            }
            field(Recouvreur; Recouvreur)
            {
                ApplicationArea = All;

            }

        }
    }
    actions
    {
        addfirst(processing)
        //addafter(SuggestCustomerPayments)
        {
            action("valider bordereau")
            {
                ApplicationArea = All;
                Caption = 'valider bordereau', comment = 'NLB="Valider bordereau"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Post;
                trigger OnAction()
                begin
                    PaymentStep.SetFilter(
                     "Action Type",
                     '%1|%2|%3',
                     PaymentStep."Action Type"::None, PaymentStep."Action Type"::Ledger, PaymentStep."Action Type"::"Cancel File");
                    PaymentMgtDuplicate.ProcessPaymentSteps(Rec, PaymentStep);
                end;
            }
        }
        addlast("P&osting")
        {
            action("Imprimer")
            {
                ApplicationArea = All;
                Caption = 'Imprimer', comment = 'FRA=Imprimer,ENU=Print';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Print;
                trigger OnAction()
                begin
                    CurrPage.Lines.PAGE.MarkLines(TRUE);
                    PaymentStep.SETRANGE("Action Type", PaymentStep."Action Type"::Report);
                    PaymentMgtDuplicate.ProcessPaymentSteps(Rec, PaymentStep);
                    CurrPage.Lines.PAGE.MarkLines(FALSE);
                end;
            }
        }
        modify(Post)
        {
            Visible = false;
        }
        modify(Print)
        {
            Visible = false;
        }
    }
    var
        PaymentStep: Record "Payment Step";
        PaymentMgtDuplicate: Codeunit "Payment Management Duplique";
}

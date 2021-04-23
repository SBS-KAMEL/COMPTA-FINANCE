/// <summary>
/// PageExtension Payment Slip Subform (ID 51081) extends Record Payment Slip Subform.
/// </summary>
pageextension 51081 "Payment Slip Subform" extends "Payment Slip Subform"
{
    layout
    {
        addafter(Amount)
        {
            field("Code Retenue à la Source"; "Code Retenue à la Source")
            {
                ApplicationArea = All;

            }
            field("Montant Retenue"; "Montant Retenue")
            {
                ApplicationArea = All;
            }
            field("Montant Retenue validé"; "Montant Retenue validé")
            {
                ApplicationArea = All;
            }
            field("Montant Initial"; "Montant Initial")
            {
                ApplicationArea = All;
            }
            field("Montant Initial DS"; "Montant Initial DS")
            {
                ApplicationArea = All;
            }
            field("Assiette Retenue à la source"; "Assiette Retenue à la source")
            {
                ApplicationArea = All;
            }
            field("Copied To No."; "Copied To No.")
            {
                ApplicationArea = All;

            }
            field("Created from No."; "Created from No.")
            {
                ApplicationArea = All;

            }
            /* field("External Reference"; Rec."External Reference")
            {
                ApplicationArea = All;
            } */

        }
        addafter("Account No.")
        {

            field("Libellé"; Rec."Libellé")
            {
                ApplicationArea = All;
            }
            field("ExternalDocumentNo."; Rec."External Document No.")
            {
                ApplicationArea = All;
            }
            field("BankAccountCode"; Rec."Bank Account Code")
            {
                ApplicationArea = All;
            }
            field("BankAccountName"; Rec."Bank Account Name")
            {
                ApplicationArea = All;
            }
            field("Code Vendeur"; "Code Vendeur")
            {
                ApplicationArea = All;
            }

        }
        modify("Debit Amount")
        {
            Enabled = DebitAmountEditable;
        }
        modify("Credit Amount")
        {
            Enabled = CreditAmountEditable;
        }
        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                DisableFields;
            end;
        }
        // Add changes to page layout here
    }

    var
        DebitAmountEditable: Boolean;
        CreditAmountEditable: Boolean;

    local procedure DisableFields()
    var
        PaymentHeadr: Record "Payment Header";
        PaymentStatus: Record "Payment Status";
    begin
        clear(PaymentHeadr);
        PaymentHeadr.get(Rec."No.");
        clear(PaymentStatus);
        PaymentStatus.get(PaymentHeadr."Payment Class", PaymentHeadr."Status No.");
        DebitAmountEditable := PaymentStatus.Debit;
        CreditAmountEditable := PaymentStatus.Credit;
    end;
}
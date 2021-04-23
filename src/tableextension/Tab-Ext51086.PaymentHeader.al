/// <summary>
/// TableExtension Payment Header (ID 51086) extends Record Payment Header.
/// </summary>
tableextension 51086 "Payment Header" extends "Payment Header"
{
    fields
    {
        // Add changes to table fields here
        field(51080; "Date validation"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(51081; "Type Réglement"; Enum "Payment Class: Type Réglement")
        {
            Caption = 'Payment Class', Comment = 'FRA=Type Réglement, ENU= Payment Class';
            DataClassification = ToBeClassified;
        }
        field(51082; "Code Vendeur"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
            Caption = 'Code Vendeur';

            trigger OnValidate()
            var
                PaymentLineTmp: Record "Payment Line";
            begin
                IF ("Code Vendeur" <> '') THEN begin
                    Clear(PaymentLineTmp);
                    PaymentLineTmp.SetFilter("No.", '%1', "No.");
                    if PaymentLineTmp.FindFirst then
                        repeat
                            if PaymentLineTmp."Code Vendeur" = '' then begin
                                PaymentLineTmp."Code Vendeur" := "Code Vendeur";
                                PaymentLineTmp.Modify();
                            end;
                        until PaymentLineTmp.next = 0;
                end;

            end;
        }
        field(51083; "Réf. Borderaeu banque"; Code[20])
        {
            DataClassification = ToBeClassified;

            Caption = 'Réf. Borderaeu banque';
        }
        field(51084; Recouvreur; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No." where(Recouvreur = const(true));


        }
    }
}
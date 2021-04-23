/// <summary>
/// TableExtension Payment Line (ID 51082) extends Record Payment Line.
/// </summary>
tableextension 51082 "Payment Line" extends "Payment Line"
{
    fields
    {
        // Add changes to table fields here
        field(51082; Libellé; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(51083; "Code Retenue à la Source"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF ("Account Type" = filter(Vendor)) "Groupe Retenue"."Code Retenue" WHERE(Proposition = FILTER(Fournisseurs))
            else
            if ("Account Type" = filter(Customer)) "Groupe Retenue"."Code Retenue" where(Proposition = filter(Clients));
        }
        field(51084; "Groupe Comptabilisation"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = if ("Account Type" = const(Vendor)) "Vendor Posting Group"
            else
            if ("Account Type" = const(Customer)) "Customer Posting Group";

        }
        field(51085; "Montant Initial"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51086; "Montant Initial DS"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51087; "Assiette Retenue à la source"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(51088; "Montant Retenue"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF ((Amount > 0) AND ("Montant Retenue" > 0)) OR ((Amount < 0) AND ("Montant Retenue" < 0)) THEN
                    "Montant Retenue" := -"Montant Retenue";

            end;

        }
        field(51089; "Montant Retenue validé"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(51090; "No. Salarié"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;
        }
        field(51091; "Date de validation"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(51092; "External Reference"; Text[50])
        {
            Caption = 'External Reference', Comment = 'FRA = Référence externe ENU = External Reference';
            DataClassification = ToBeClassified;
        }
        field(51093; "Code Vendeur"; Code[20])
        {
            //FieldClass = FlowField;
            // CalcFormula = look"Paym"Payment Line"ent Line"up("Payment Header"."Code Vendeur" where("No." = field("Document No.")));
            TableRelation = "Salesperson/Purchaser";
            Caption = 'Code Vendeur';
        }
        field(51094; "Code Vendeur Tmp"; Code[20])
        {

            TableRelation = "Salesperson/Purchaser";
            Caption = 'Code Vendeur Tmp';
        }
        modify("Account No.")
        {
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Account Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Account Type" = CONST(Employee)) Employee;

        }
    }
    /// <summary>
    /// CalcRetenueSource.
    /// </summary>
    procedure CalcRetenueSource()
    var
        GroupeRetenu: Record "Groupe Retenue";
        StatusTmp: Record "Payment Status";
    begin
        Paramcpta.GET;
        CLEAR(GroupeRetenu);
        IF GroupeRetenu.GET("Code Retenue à la Source") THEN;
        IF StatusTmp.GET("Payment Class", "Status No.") THEN
            IF ("Montant Retenue Validé" = 0) AND (StatusTmp."Calculer Retenue à la Source") THEN    //add bay rh
           BEGIN
                "Montant Retenue" := -ROUND("Assiette Retenue à la source" * (GroupeRetenu."% Retenue" / 100), Paramcpta."Amount Rounding Precision");
                //CalcAmountRetenueSource();//10/11/20
                //if "Montant Initial" > 0 then
                //   validate(amount, "Montant Initial" - abs("Montant Retenue"))
                //else
                validate(amount, "Montant Initial" + ("Montant Retenue"));

            END;
    end;

    /// <summary>
    /// CalcAmountRetenueSource.
    /// </summary>
    /**procedure CalcAmountRetenueSource()
    begin
        validate(amount, "Montant Initial" + "Montant Retenue")
    end;*/

    trigger OnDelete()
    var
        Text00002: Label 'Impossible de supprimer une ligne validée';
    begin
        if "Copied To No." <> '' then
            ERROR(Text00002);
    end;



    var
        Paramcpta: Record "General Ledger Setup";


}
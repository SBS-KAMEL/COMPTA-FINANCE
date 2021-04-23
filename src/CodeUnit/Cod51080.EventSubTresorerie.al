/// <summary>
/// Codeunit EventSubTresorerie (ID 51080).
/// </summary>
codeunit 51080 "EventSubTresorerie"
{
    [EventSubscriber(ObjectType::table, Database::"Payment Line", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure OnAfterValidateAccountNo(var Rec: Record "Payment Line")
    var
        RecGvendor: Record Vendor;
        RecGCustomer: Record Customer;
        RecGBanque: Record "Bank Account";
        RecGLAccountL: Record "G/L Account";
        RecGpaymentHeader: Record "Payment Header";
        Text00001: Label 'Fournisseur bloqué : Veuillez contacter le service financier';
        Text00002: Label 'Client bloqué : Veuillez contacter le service financier';
        Text00003: Label 'banque bloqué : Veuillez contacter le service financier';
    begin
        clear(RecGpaymentHeader);
        RecGpaymentHeader.get(rec."No.");
        rec."Code Vendeur" := RecGpaymentHeader."Code Vendeur";
        case rec."Account Type" of
            rec."Account Type"::Vendor:
                begin
                    RecGvendor.get(rec."Account No.");
                    if RecGvendor.Blocked = RecGvendor.Blocked::all then
                        ERROR(Text00001);
                    Rec."Libellé" := RecGvendor.Name;
                end;
            rec."Account Type"::Customer:
                begin
                    RecGCustomer.get(rec."Account No.");
                    if RecGCustomer.Blocked = RecGCustomer.Blocked::all then
                        ERROR(Text00002);
                    rec."Libellé" := RecGCustomer.Name;
                    rec."Posting Group" := RecGCustomer."Customer Posting Group";
                end;
            rec."Account Type"::"Bank Account":
                begin
                    RecGBanque.get(rec."Account No.");
                    if RecGBanque.Blocked = true then
                        ERROR(Text00003);
                    rec."Libellé" := RecGBanque.Name;
                    rec."Posting Group" := RecGBanque."Bank Acc. Posting Group";

                end;
            rec."Account Type"::"G/L Account":
                begin
                    RecGLAccountL.Get(Rec."Account No.");
                    rec."Libellé" := RecGLAccountL.Name;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::table, database::"Payment Line", 'OnAfterValidateEvent', 'Amount', false, false)]
    local procedure OnAfterValidateAmount(var Rec: Record "Payment Line")
    var
        RecGParamCompta: Record "General Ledger Setup";
        RecGVendor: Record Vendor;
        RecGCustomer: Record Customer;

    begin
        IF (Rec."Montant Retenue" = 0) AND (Rec."Montant Retenue Validé" = 0) THEN BEGIN
            Rec."Montant Initial" := Rec.Amount;
            Rec."Montant Initial DS" := Rec."Amount (LCY)";
            //if Rec."Assiette Retenue à la source" = 0 then
            Rec."Assiette Retenue à la source" := Rec."Montant Initial";
        END;

        RecGParamCompta.get;
        if rec.Amount > RecGParamCompta."Plafond Mnt Exonoration" then begin
            case rec."Account Type" of
                rec."Account Type"::Vendor:
                    begin
                        if rec."Code Retenue à la Source" = '' then begin
                            if (Not RecGvendor."Exonoré RS") or ((RecGvendor."Exonoré RS") AND (RecGvendor."Fin Exonoration" < WorkDate)) THEN begin
                                if RecGvendor."Code retenue RS" <> '' then
                                    Rec.validate("Code Retenue à la Source", RecGvendor."Code retenue RS")
                                else
                                    rec.validate("Code Retenue à la Source", RecGParamCompta."Code retenue par defaut");
                            end;
                        end;
                    end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Header", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure OnAfterValidateEventAccountNo(var Rec: Record "Payment Header")
    var
        CompanyBank: Record "Bank Account";

    begin
        if (Rec."Account Type" = Rec."Account Type"::"Bank Account") and (Rec."Account No." <> '') then begin
            CompanyBank.RESET;
            CompanyBank.GET(Rec."Account No.");
            Rec.validate("Source Code", CompanyBank."Source Code");
            Rec.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Table, database::"Payment Line", 'OnAfterValidateEvent', 'Montant Retenue', true, false)]
    local procedure OnAfterValidateEventMontantRetenue(var Rec: Record "Payment Line")
    var
        RecGGeneralLedgerSetup: Record "General Ledger Setup";
        RecGCurrency: Record Currency;
        RecGCurrencyExchangeRate: Record "Currency Exchange Rate";
        RecGPaymentStatus: Record "Payment Status";
    begin
        IF ((Rec.Amount > 0) AND (Rec."Montant Retenue" > 0)) OR ((Rec.Amount < 0) AND (Rec."Montant Retenue" < 0)) THEN
            Rec."Montant Retenue" := -Rec."Montant Retenue";
        RecGPaymentStatus.RESET;
        IF RecGPaymentStatus.GET(rec."Payment Class", rec."Status No.") THEN
            IF Rec."Currency Code" <> '' THEN RecGCurrency.GET(rec."Currency Code");
        IF (Rec."Montant Retenue" <> 0) AND (Rec."Montant Retenue Validé" = 0) AND (RecGPaymentStatus."Calculer Retenue à la source") THEN BEGIN
            IF Rec."Currency Code" <> '' THEN
                Rec."Montant Retenue" := ROUND(RecGCurrencyExchangeRate.ExchangeAmtFCYToLCY(rec."Posting Date",
                Rec."Currency Code", Rec."Montant Retenue", Rec."Currency Factor")
                , RecGCurrency."Amount Rounding Precision")
            ELSE
                Rec."Montant Retenue" := ROUND(Rec."Montant Retenue", RecGGeneralLedgerSetup."Amount Rounding Precision");
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Header", 'OnAfterValidateEvent', 'Status No.', false, false)]
    local procedure OnAfterValidateStatusNo(var Rec: Record "Payment Header")
    var
        CompanyBank: Record "Bank Account";
    begin
        if (Rec."Account Type" = Rec."Account Type"::"Bank Account") and (Rec."Account No." <> '') then begin
            CompanyBank.RESET;
            CompanyBank.GET(Rec."Account No.");
            Rec.validate("Source Code", CompanyBank."Source Code");
            Rec.Modify;
        end;
    end;

    //SS 12/11/2020
    [EventSubscriber(ObjectType::Table, Database::"Payment Header", 'OnAfterValidateEvent', 'Payment Class', false, false)]
    /// <summary> 
    /// Description for OnAfterCopyCustLedgerEntryFromGenJnlLineSub.
    /// </summary>
    local procedure OnAfterCopyCustLedgerEntryFromGenJnlLineSub(var Rec: Record "Payment Header")
    var
        RecPaymentClassL: Record "Payment Class";
    begin
        RecPaymentClassL.Get(Rec."Payment Class");
        Rec."Type Réglement" := RecPaymentClassL."Type Réglement";
    end;

    [EventSubscriber(ObjectType::Table, DataBase::"Payment Header", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure MyProcedure(var Rec: Record "Payment Header")
    var
        PayLine: Record "Payment Line";
        FromPayHeader: Record "Payment Header";
        AccNoErr: Label 'No de compte ne doit pas être différent du bordereau d''origine ';
    begin
        PayLine.Reset;
        PayLine.SetRange("No.", Rec."No.");
        If PayLine.FindFirst() then begin
            If PayLine."Created from No." <> '' then begin
                FromPayHeader.GET(PayLine."Created from No.");
                IF rec."Account No." <> FromPayHeader."Account No." then
                    Error(AccNoErr);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, DataBase::"Payment Line", 'OnBeforeDeleteEvent', '', false, true)]
    local procedure OnBeforeDeleteEventPayLine(var Rec: Record "Payment Line")
    begin
        if rec."Status No." > 0 then
            Error('Vous ne pouvez pas supprimé une ligne dont le statut est %1', Rec."Status Name");

    end;
}
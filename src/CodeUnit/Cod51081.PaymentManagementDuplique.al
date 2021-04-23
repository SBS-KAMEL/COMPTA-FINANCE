/// <summary>
/// Codeunit Payment Management Duplique (ID 51081).
/// </summary>
codeunit 51081 "Payment Management Duplique"
{
    Permissions = TableData "Cust. Ledger Entry" = rm,
                  TableData "Vendor Ledger Entry" = rm;

    trigger OnRun()
    begin
        CreatePaymentHeaders;
    end;

    var
        Text001: Label 'Number %1 cannot be extended to more than 20 characters.';
        Text002: Label 'One or more acceptation codes are No.';
        Text003: Label 'One or more lines have an incorrect RIB code.';
        Text004: Label 'There is no Payment Header to create.';
        Text005: Label 'Ledger Posting';
        Text006: Label 'One or more due dates are not specified.';
        Text007: Label 'The action has been canceled.';
        Text008: Label 'The header RIB is not correct.';
        Text009: Label 'The combination of dimensions used in Payment Header %1 is blocked. %2.', Comment = '%1 - payment header no, %2 - dimension error';
        Text010: Label 'The combination of dimensions used in Payment Header %1, line no. %2 is blocked. %3.', Comment = '%1 - payment header no, %2 - payment line no, %3 - dimension error';
        InvPostingBuffer: array[2] of Record "Payment Post. Buffer" temporary;
        CustomerPostingGroup: Record "Customer Posting Group";
        EmployeePostingGroupG: Record "Employee Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        Customer: Record Customer;
        CustomerOdherCompany: Record Customer;
        Company2: Record Company;
        Vendor: Record Vendor;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentLine: Record "Payment Line";
        OldPaymentLine: Record "Payment Line";
        StepLedger: Record "Payment Step Ledger";
        Step: Record "Payment Step";
        PaymentHeader: Record "Payment Header";
        PaymentClass: Record "Payment Class";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
        N: Integer;
        Suffix: Text;
        EntryTypeDebit: Enum "Gen. Journal Account Type";
        EntryNoAccountDebit: Code[20];
        EntryPostGroupDebit: Code[20];
        EntryTypeCredit: Enum "Gen. Journal Account Type";
        EntryNoAccountCredit: Code[20];
        EntryPostGroupCredit: Code[20];
        GLEntryNoTmp: Integer;
        Text011: Label 'XX';
        Text012: Label 'Customer Posting Group %1 does not exist.';
        Text014: Label 'You must enter a G/L account for customer posting group %1.';
        Text016: Label 'A posted line cannot be deleted.';
        Text017: Label 'Source Code %1 does not exist.';
        HeaderAccountUsedGlobally: Boolean;
        Text018: Label 'You must specify a debit account number for step %1 of payment type %2.';
        Text019: Label 'You must specify a credit account number for step %1 of payment type %2.';
        Text020: Label 'You must specify an account number in the payment header.';
        Text021: Label 'Code %1 does not contain a number.';
        Text022: Label 'The status of document %1 does not authorize archiving.';
        CheckDimVauePostingLineErr: Label 'A dimension used in %1 %2 %3 has caused an error. %4', Comment = '%1=Payment Header No., %2=tablecaption, %3=Payment Line No., %4=Error text';
        CheckDimVauePostingHeaderErr: Label 'A dimension used in %1 has caused an error. %2', Comment = '%1=Payment Header No., %2=Error text';
        Text100: Label 'Rounding on %1';

    /// <summary> 
    /// Description for Actualiserstat.
    /// </summary>
    /// <param name="rec">Parameter of type Record "Payment Header".</param>
    procedure Actualiserstat(var rec: Record "Payment Header")
    var
        RecTmp: Record "Payment Line";
        PaymentStatus: Record "Payment Status";
    begin
        WITH Rec DO BEGIN
            CLEAR(PaymentStatus);
            IF PaymentStatus.GET("Payment Class", "Status No.") AND (PaymentStatus."Calculer Retenue à la Source") THEN BEGIN
                CLEAR(RecTmp);
                RecTmp.SETFILTER("Payment Class", '%1', "Payment Class");
                RecTmp.SETFILTER("Status No.", '%1', "Status No.");
                RecTmp.SETFILTER("No.", '%1', "No.");
                IF RecTmp.FIND('-') THEN BEGIN
                    REPEAT
                        RecTmp.CalcRetenueSource;
                        //RecTmp.CalcAmountRetenueSource();
                        RecTmp.MODIFY;
                    UNTIL RecTmp.NEXT = 0;
                    COMMIT;
                END;
            END;

        END;
    end;

    /// <summary>
    /// Application.
    /// </summary>
    [Scope('OnPrem')]
    procedure Application()
    begin
        if StepLedger.Application <> StepLedger.Application::None then
            if StepLedger.Application = StepLedger.Application::"Applied Entry" then begin
                InvPostingBuffer[1]."Applies-to Doc. Type" := PaymentLine."Applies-to Doc. Type";
                InvPostingBuffer[1]."Applies-to Doc. No." := PaymentLine."Applies-to Doc. No.";
                InvPostingBuffer[1]."Applies-to ID" := PaymentLine."Applies-to ID";
            end else
                if StepLedger.Application = StepLedger.Application::"Entry Previous Step" then begin
                    InvPostingBuffer[1]."Applies-to ID" := PaymentLine."No." + '/' + Format(PaymentLine."Line No.") + Text011;
                    if InvPostingBuffer[1]."Account Type" = InvPostingBuffer[1]."Account Type"::Customer then begin
                        if (InvPostingBuffer[1].Amount < 0) xor InvPostingBuffer[1].Correction then
                            CustLedgerEntry.SetRange("Entry No.", OldPaymentLine."Entry No. Debit")
                        else
                            CustLedgerEntry.SetRange("Entry No.", OldPaymentLine."Entry No. Credit");
                        if CustLedgerEntry.FindFirst then begin
                            CustLedgerEntry."Applies-to ID" := InvPostingBuffer[1]."Applies-to ID";
                            CustLedgerEntry.CalcFields("Remaining Amount");
                            CustLedgerEntry.Validate("Amount to Apply", CustLedgerEntry."Remaining Amount");
                            CustLedgerEntry.Modify;
                        end;
                    end else
                        if InvPostingBuffer[1]."Account Type" = InvPostingBuffer[1]."Account Type"::Vendor then begin
                            if (InvPostingBuffer[1].Amount < 0) xor InvPostingBuffer[1].Correction then
                                VendorLedgerEntry.SetRange("Entry No.", OldPaymentLine."Entry No. Debit")
                            else
                                VendorLedgerEntry.SetRange("Entry No.", OldPaymentLine."Entry No. Credit");
                            if VendorLedgerEntry.FindFirst then begin
                                VendorLedgerEntry."Applies-to ID" := InvPostingBuffer[1]."Applies-to ID";
                                VendorLedgerEntry.CalcFields("Remaining Amount");
                                VendorLedgerEntry.Validate("Amount to Apply", VendorLedgerEntry."Remaining Amount");
                                VendorLedgerEntry.Modify;
                            end;
                        end;
                end else
                    if StepLedger.Application = StepLedger.Application::"Memorized Entry" then begin
                        InvPostingBuffer[1]."Applies-to ID" := PaymentLine."No." + '/' + Format(PaymentLine."Line No.") + Text011;
                        if InvPostingBuffer[1]."Account Type" = InvPostingBuffer[1]."Account Type"::Customer then begin
                            CustLedgerEntry.Reset;
                            if (InvPostingBuffer[1].Amount < 0) xor InvPostingBuffer[1].Correction then
                                CustLedgerEntry.SetRange("Entry No.", OldPaymentLine."Entry No. Debit Memo")
                            else
                                CustLedgerEntry.SetRange("Entry No.", OldPaymentLine."Entry No. Credit Memo");
                            if CustLedgerEntry.FindFirst then begin
                                CustLedgerEntry."Applies-to ID" := InvPostingBuffer[1]."Applies-to ID";
                                CustLedgerEntry.CalcFields("Remaining Amount");
                                CustLedgerEntry.Validate("Amount to Apply", CustLedgerEntry."Remaining Amount");
                                CustLedgerEntry.Modify;
                            end;
                        end else
                            if InvPostingBuffer[1]."Account Type" = InvPostingBuffer[1]."Account Type"::Vendor then begin
                                if (InvPostingBuffer[1].Amount < 0) xor InvPostingBuffer[1].Correction then
                                    VendorLedgerEntry.SetRange("Entry No.", OldPaymentLine."Entry No. Debit Memo")
                                else
                                    VendorLedgerEntry.SetRange("Entry No.", OldPaymentLine."Entry No. Credit Memo");
                                if VendorLedgerEntry.FindFirst then begin
                                    VendorLedgerEntry."Applies-to ID" := InvPostingBuffer[1]."Applies-to ID";
                                    VendorLedgerEntry.CalcFields("Remaining Amount");
                                    VendorLedgerEntry.Validate("Amount to Apply", VendorLedgerEntry."Remaining Amount");
                                    VendorLedgerEntry.Modify;
                                end;
                            end;
                    end;
        if StepLedger."Detail Level" = StepLedger."Detail Level"::Account then begin
            if (InvPostingBuffer[1]."Account Type" = InvPostingBuffer[1]."Account Type"::Vendor) or
               (InvPostingBuffer[1]."Account Type" = InvPostingBuffer[1]."Account Type"::Customer)
            then
                InvPostingBuffer[1]."Due Date" := PaymentLine."Due Date" // FR Payment due date
        end else
            InvPostingBuffer[1]."Due Date" := PaymentLine."Due Date"; // FR Payment due date
    end;

    /// <summary>
    /// ArchiveDocument.
    /// </summary>
    /// <param name="Document">Record "Payment Header".</param>
    [Scope('OnPrem')]
    procedure ArchiveDocument(Document: Record "Payment Header")
    var
        ArchiveHeader: Record "Payment Header Archive";
        ArchiveLine: Record "Payment Line Archive";
        PaymentLine: Record "Payment Line";
    begin
        Document.CalcFields("Archiving Authorized");
        if not Document."Archiving Authorized" then
            Error(Text022, Document."No.");
        ArchiveHeader.TransferFields(Document);
        ArchiveHeader.Insert;
        Document.Delete;
        PaymentLine.SetRange("No.", Document."No.");
        if PaymentLine.Find('-') then
            repeat
                ArchiveLine.TransferFields(PaymentLine);
                ArchiveLine.Insert;
                PaymentLine.Delete;
            until PaymentLine.Next = 0;
    end;

    /// <summary>
    // CopyLigBor.
    /// </summary>
    /// <param name="FromPaymentLine">VAR Record "Payment Line".</param>
    /// <param name="NewStep">Integer.</param>
    /// <param name="PayNum">VAR Code[20].</param>
    [Scope('OnPrem')]
    procedure CopyLigBor(var FromPaymentLine: Record "Payment Line"; NewStep: Integer; var PayNum: Code[20])
    var
        ToBord: Record "Payment Header";
        ToPaymentLine: Record "Payment Line";
        Step: Record "Payment Step";
        Process: Record "Payment Class";
        PaymentStatus: Record "Payment Status";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        i: Integer;
        Recpaymentheader: Record "Payment Header";
    begin
        if FromPaymentLine.Find('-') then begin
            Step.Get(FromPaymentLine."Payment Class", NewStep);
            Process.Get(FromPaymentLine."Payment Class");
            if PayNum = '' then
                with ToBord do begin
                    i := 10000;
                    NoSeriesMgt.InitSeries(Step."Header Nos. Series", "No. Series", 0D, "No.", "No. Series");
                    "Payment Class" := FromPaymentLine."Payment Class";
                    "Status No." := Step."Next Status";
                    PaymentStatus.Get("Payment Class", "Status No.");
                    "Archiving Authorized" := PaymentStatus."Archiving Authorized";
                    "Currency Code" := FromPaymentLine."Currency Code";
                    "Currency Factor" := FromPaymentLine."Currency Factor";

                    InitHeader;

                    Insert;
                end else begin
                ToBord.Get(PayNum);
                //KK&RH
                Recpaymentheader.get(FromPaymentLine."No.");
                ToBord."Account Type" := ToBord."Account Type";
                ToBord.VALIDATE("Account No.", Recpaymentheader."Account No.");
                ToBord."Code Vendeur" := FromPaymentLine."Code Vendeur";
                IF Recpaymentheader."Source Code" <> '' THEN
                    ToBord."Source Code" := Recpaymentheader."Source Code";
                ToBord.MODIFY;
                //KK&RH
                ToPaymentLine.SetRange("No.", PayNum);
                if ToPaymentLine.FindLast then
                    i := ToPaymentLine."Line No." + 10000
                else
                    i := 10000;

            end;
            repeat
                ToPaymentLine.Copy(FromPaymentLine);
                ToPaymentLine."No." := ToBord."No.";
                ToPaymentLine."Line No." := i;
                ToPaymentLine.IsCopy := true;
                ToPaymentLine."Status No." := Step."Next Status";
                ToPaymentLine."Copied To No." := '';
                ToPaymentLine."Copied To Line" := 0;
                ToPaymentLine.Posted := false;
                ToPaymentLine."Created from No." := FromPaymentLine."No.";
                ToPaymentLine."Dimension Set ID" := FromPaymentLine."Dimension Set ID";
                ToPaymentLine.Insert(true);
                FromPaymentLine."Copied To No." := ToPaymentLine."No.";
                FromPaymentLine."Copied To Line" := ToPaymentLine."Line No.";
                //ADD RH
                ToPaymentLine."Montant Retenue" := FromPaymentLine."Montant Retenue";
                ToPaymentLine."Montant Retenue Validé" := FromPaymentLine."Montant Retenue Validé";
                ToPaymentLine."Code Vendeur" := FromPaymentLine."Code Vendeur";
                //END
                FromPaymentLine.Modify;
                i += 10000;
            until FromPaymentLine.Next = 0;
            PayNum := ToBord."No.";
        end;
    end;

    /// <summary>
    /// CreatePaymentHeaders.
    /// </summary>
    [Scope('OnPrem')]
    procedure CreatePaymentHeaders()
    begin
        Step.SetRange("Action Type", Step."Action Type"::"Create New Document");

        if StepSelect('', -1, Step, true) then
            ExecuteCreatePaymtHead(Step);
    end;

    /// <summary>
    /// DeleteLigBorCopy.
    /// </summary>
    /// <param name="FromPaymentLine">VAR Record "Payment Line".</param>
    [Scope('OnPrem')]
    procedure DeleteLigBorCopy(var FromPaymentLine: Record "Payment Line")
    var
        ToPaymentLine: Record "Payment Line";
    begin
        ToPaymentLine.SetCurrentKey("Copied To No.", "Copied To Line");

        if FromPaymentLine.Find('-') then
            if FromPaymentLine.Posted then
                Message(Text016)
            else
                repeat
                    ToPaymentLine.SetRange("Copied To No.", FromPaymentLine."No.");
                    ToPaymentLine.SetRange("Copied To Line", FromPaymentLine."Line No.");
                    ToPaymentLine.FindFirst;
                    ToPaymentLine."Copied To No." := '';
                    ToPaymentLine."Copied To Line" := 0;
                    ToPaymentLine.Modify;
                    FromPaymentLine.Delete(true);
                until FromPaymentLine.Next = 0;
    end;

    /// <summary>
    /// ExecuteCreatePaymtHead.
    /// </summary>
    /// <param name="PaymtStep">Record "Payment Step".</param>
    /// <returns>Return value of type Code[20].</returns>
    [Scope('OnPrem')]
    procedure ExecuteCreatePaymtHead(PaymtStep: Record "Payment Step"): Code[20]
    var
        Bor: Record "Payment Header";
        StatementForm: Page "Payment Slip";
        InserForm: Page "Payment Lines List";
        PayNum: Code[20];
    begin
        PaymentLine.SetRange("Payment Class", PaymtStep."Payment Class");
        PaymentLine.SetRange("Status No.", PaymtStep."Previous Status");
        PaymentLine.SetRange("Copied To No.", '');
        PaymentLine.FilterGroup(2);
        InserForm.SetSteps(PaymtStep.Line);
        InserForm.SetTableView(PaymentLine);
        InserForm.LookupMode(true);
        InserForm.RunModal;
        PayNum := InserForm.GetNumBor;
        if Bor.Get(PayNum) then begin
            StatementForm.SetRecord(Bor);
            StatementForm.Run;
        end else
            Error(Text004);
        exit(PayNum);
    end;

    /// <summary>
    /// GenerEntries.
    /// </summary>
    [Scope('OnPrem')]
    procedure GenerEntries()
    var
        Currency: Record Currency;
        Difference: Decimal;
        TotalDebit: Decimal;
        TotalCredit: Decimal;
        LastGLEntryNo: Integer;
        PaymentLineTmp: Record "Payment Line"; //ADD RH
    begin
        if InvPostingBuffer[1].Find('+') then
            with PaymentHeader do
                repeat
                    LastGLEntryNo := PostInvPostingBuffer;
                    PaymentLine.Reset;
                    PaymentLine.SetRange("No.", "No.");
                    PaymentLine.SetRange("Line No.");
                    if GenJnlLine.Amount >= 0 then begin
                        TotalDebit := TotalDebit + GenJnlLine."Amount (LCY)";
                        StepLedger.Get(Step."Payment Class", Step.Line, StepLedger.Sign::Debit);
                        PaymentLine.SetRange("Entry No. Debit", InvPostingBuffer[1]."GL Entry No.");
                        if StepLedger."Memorize Entry" then
                            PaymentLine.ModifyAll(PaymentLine."Entry No. Debit Memo", LastGLEntryNo);
                        PaymentLine.ModifyAll("Entry No. Debit", LastGLEntryNo);
                        PaymentLine.SetRange("Entry No. Debit");
                    end else begin
                        TotalCredit := TotalCredit + Abs(GenJnlLine."Amount (LCY)");
                        StepLedger.Get(Step."Payment Class", Step.Line, StepLedger.Sign::Credit);
                        PaymentLine.SetRange("Entry No. Credit", InvPostingBuffer[1]."GL Entry No.");
                        if StepLedger."Memorize Entry" then
                            PaymentLine.ModifyAll(PaymentLine."Entry No. Credit Memo", LastGLEntryNo);
                        PaymentLine.ModifyAll("Entry No. Credit", LastGLEntryNo);
                        PaymentLine.SetRange("Entry No. Credit");
                    end;
                    //ADD RH
                    PaymentLineTmp.RESET;
                    PaymentLineTmp.SETRANGE("No.", PaymentHeader."No.");
                    PaymentLineTmp.SETRANGE("Line No.");
                    IF PaymentLineTmp.FIND('-') THEN
                        REPEAT
                            IF (PaymentLineTmp."Montant Retenue" <> 0) AND
                               (StepLedger."Calculer Retenue à la Source") THEN BEGIN
                                PaymentLineTmp."Montant Retenue Validé" := PaymentLineTmp."Montant Retenue";
                                PaymentLineTmp."Montant Retenue" := 0;
                                PaymentLineTmp.MODIFY;
                            END;
                            IF (PaymentLineTmp."Montant Retenue Validé" <> 0) AND
                               (StepLedger."Annuler Retenue à la Source") THEN BEGIN
                                PaymentLineTmp."Montant Retenue" := PaymentLineTmp."Montant Retenue Validé";
                                PaymentLineTmp."Montant Retenue Validé" := 0;
                                PaymentLineTmp.MODIFY;
                            END;
                        until PaymentLineTmp.next = 0;
                //END ADD
                until InvPostingBuffer[1].Next(-1) = 0;

        if HeaderAccountUsedGlobally then begin
            Difference := TotalDebit - TotalCredit;
            if Difference <> 0 then begin
                GenJnlLine.Init;
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                Currency.Get(PaymentHeader."Currency Code");
                if Difference < 0 then begin
                    GenJnlLine."Account No." := Currency."Unrealized Losses Acc.";
                    StepLedger.Get(Step."Payment Class", Step.Line, StepLedger.Sign::Debit);
                    GenJnlLine.Validate("Debit Amount", -Difference);
                end else begin
                    GenJnlLine."Account No." := Currency."Unrealized Gains Acc.";
                    StepLedger.Get(Step."Payment Class", Step.Line, StepLedger.Sign::Credit);
                    GenJnlLine.Validate("Credit Amount", Difference);
                end;
                GenJnlLine."Posting Date" := PaymentHeader."Posting Date";
                GenJnlLine."Document No." := PaymentHeader."No.";
                GenJnlLine.Description := StrSubstNo(
                  Text100, StrSubstNo(StepLedger.Description, PaymentHeader."Document Date", '', PaymentHeader."No."));
                GenJnlLine."Shortcut Dimension 1 Code" := PaymentHeader."Shortcut Dimension 1 Code";
                GenJnlLine."Shortcut Dimension 2 Code" := PaymentHeader."Shortcut Dimension 2 Code";
                GenJnlLine."Dimension Set ID" := PaymentHeader."Dimension Set ID";
                GenJnlLine."Source Code" := PaymentHeader."Source Code";
                GenJnlLine."Reason Code" := Step."Reason Code";
                GenJnlLine."Document Date" := PaymentHeader."Document Date";
                GenJnlPostLine.RunWithCheck(GenJnlLine);
            end;
        end;

        InvPostingBuffer[1].DeleteAll;
    end;

    /// <summary>
    /// GenererInv.
    /// </summary>
    procedure GenererInv()
    var
    begin
        IF (StepLedger."Calculer Retenue à la Source") THEN
            if PaymentLine."Montant Retenue" <> 0 THEN
                geninv2(True);
        IF StepLedger."Annuler Retenue à la Source" THEN
            if PaymentLine."Montant Retenue validé" <> 0 THEN
                geninv2(False);
    end;

    /// <summary>
    /// GenerInvPostingBuffer.
    /// </summary>
    [Scope('OnPrem')]
    procedure GenerInvPostingBuffer()
    var
        PaymentClass: Record "Payment Class";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        StepLedgerTmp: Record "Payment Step Ledger"; //ADD RH
        Description: Text[98];
    begin
        StepLedger.SetRange("Payment Class", Step."Payment Class");
        StepLedger.SetRange(Line, Step.Line);
        if StepLedger.Find('-') then begin
            repeat
                Clear(InvPostingBuffer[1]);
                SetPostingGroup;
                SetAccountNo;
                InvPostingBuffer[1]."System-Created Entry" := true;
                // comptabilisation retenue fournisseur
                if PaymentLine."Account Type" = PaymentLine."Account Type"::Vendor then begin
                    IF (StepLedger.Sign = StepLedger.Sign::Debit) THEN BEGIN
                        IF StepLedgerTmp.GET(Step."Payment Class", Step.Line, StepLedger.Sign::Credit) THEN;
                        IF (StepLedgerTmp."Calculer Retenue à la Source") THEN BEGIN
                            InvPostingBuffer[1].VALIDATE(Amount, (PaymentLine.Amount - PaymentLine."Montant Retenue"));
                            InvPostingBuffer[1].VALIDATE("Amount (LCY)", (PaymentLine."Amount (LCY)" - PaymentLine."Montant Retenue"));
                        END
                        ELSE BEGIN
                            IF StepLedgerTmp."Annuler Retenue à la Source" THEN BEGIN
                                InvPostingBuffer[1].VALIDATE(Amount, (PaymentLine.Amount - PaymentLine."Montant Retenue Validé"));
                                InvPostingBuffer[1].VALIDATE("Amount (LCY)", (PaymentLine."Amount (LCY)" - PaymentLine."Montant Retenue Validé"));
                            END
                            ELSE BEGIN
                                InvPostingBuffer[1].VALIDATE(Amount, (PaymentLine.Amount));
                                InvPostingBuffer[1].VALIDATE("Amount (LCY)", (PaymentLine."Amount (LCY)"));
                            END;
                        END;
                    END
                    ELSE BEGIN
                        IF StepLedgerTmp.GET(Step."Payment Class", Step.Line, StepLedger.Sign::Debit) THEN;
                        IF (StepLedgerTmp."Calculer Retenue à la Source") THEN BEGIN
                            InvPostingBuffer[1].VALIDATE(Amount, (PaymentLine.Amount - PaymentLine."Montant Retenue") * -1);
                            InvPostingBuffer[1].VALIDATE("Amount (LCY)", (PaymentLine."Amount (LCY)" - PaymentLine."Montant Retenue") * -1);
                        END ELSE BEGIN
                            IF StepLedgerTmp."Annuler Retenue à la Source" THEN BEGIN
                                InvPostingBuffer[1].VALIDATE(Amount, (PaymentLine.Amount - PaymentLine."Montant Retenue Validé") * -1);
                                InvPostingBuffer[1].VALIDATE("Amount (LCY)", (PaymentLine."Amount (LCY)" - PaymentLine."Montant Retenue Validé") * -1);
                            END
                            ELSE BEGIN
                                InvPostingBuffer[1].VALIDATE(Amount, (PaymentLine.Amount) * -1);
                                InvPostingBuffer[1].VALIDATE("Amount (LCY)", (PaymentLine."Amount (LCY)") * -1);
                            END;
                        END;
                        //---Ramzi
                        //IF StepLedger."Utilisé Montant Principal" THEN BEGIN
                        //  InvPostingBuffer[1].VALIDATE(Amount, -ABS(PaymentLine."Montant Initial"));
                        // InvPostingBuffer[1].VALIDATE("Amount (LCY)", -ABS(PaymentLine."Montant Initial"));
                        //END;
                        //---Ramzi
                    END;
                end;

                //comptabilisation retnue client

                if PaymentLine."Account Type" = PaymentLine."Account Type"::Customer then begin
                    IF (StepLedger.Sign = StepLedger.Sign::Debit) THEN BEGIN
                        IF StepLedgerTmp.GET(Step."Payment Class", Step.Line, StepLedger.Sign::Credit) THEN;
                        IF (StepLedgerTmp."Calculer Retenue à la Source") THEN BEGIN
                            InvPostingBuffer[1].VALIDATE(Amount, (PaymentLine.Amount - PaymentLine."Montant Retenue"));
                            InvPostingBuffer[1].VALIDATE("Amount (LCY)", (PaymentLine."Amount (LCY)" - PaymentLine."Montant Retenue"));
                        END
                        ELSE BEGIN
                            IF StepLedgerTmp."Annuler Retenue à la Source" THEN BEGIN
                                InvPostingBuffer[1].VALIDATE(Amount, Abs((PaymentLine.Amount - PaymentLine."Montant Retenue Validé")));
                                InvPostingBuffer[1].VALIDATE("Amount (LCY)", Abs((PaymentLine."Amount (LCY)" - PaymentLine."Montant Retenue Validé")));
                            END
                            ELSE BEGIN
                                InvPostingBuffer[1].VALIDATE(Amount, Abs(PaymentLine.Amount));
                                InvPostingBuffer[1].VALIDATE("Amount (LCY)", Abs(PaymentLine."Amount (LCY)"));
                            END;
                        END;
                    END
                    ELSE BEGIN
                        IF StepLedgerTmp.GET(Step."Payment Class", Step.Line, StepLedger.Sign::Debit) THEN;
                        IF (StepLedgerTmp."Calculer Retenue à la Source") THEN BEGIN
                            InvPostingBuffer[1].VALIDATE(Amount, (abs(PaymentLine.Amount) + PaymentLine."Montant Retenue") * -1);
                            InvPostingBuffer[1].VALIDATE("Amount (LCY)", (abs(PaymentLine."Amount (LCY)") + PaymentLine."Montant Retenue") * -1);
                        END ELSE BEGIN
                            IF StepLedgerTmp."Annuler Retenue à la Source" THEN BEGIN
                                InvPostingBuffer[1].VALIDATE(Amount, (abs(PaymentLine.Amount) + PaymentLine."Montant Retenue Validé") * -1);
                                InvPostingBuffer[1].VALIDATE("Amount (LCY)", (abs(PaymentLine."Amount (LCY)") + PaymentLine."Montant Retenue Validé") * -1);
                            END
                            ELSE BEGIN
                                InvPostingBuffer[1].VALIDATE(Amount, abs(PaymentLine.Amount) * -1);
                                InvPostingBuffer[1].VALIDATE("Amount (LCY)", abs(PaymentLine."Amount (LCY)") * -1);
                            END;
                        END;

                    END;
                end;  //fin comptabilisation client

                //comptabilisation compte génarale

                if (PaymentLine."Account Type" = PaymentLine."Account Type"::"G/L Account") or (PaymentLine."Account Type" = PaymentLine."Account Type"::"Bank Account")
                or (PaymentLine."Account Type" = PaymentLine."Account Type"::Employee) then begin
                    IF (StepLedger.Sign = StepLedger.Sign::Debit) THEN BEGIN

                        InvPostingBuffer[1].VALIDATE(Amount, Abs(PaymentLine.Amount));
                        InvPostingBuffer[1].VALIDATE("Amount (LCY)", Abs(PaymentLine."Amount (LCY)"));

                    END else BEGIN

                        InvPostingBuffer[1].VALIDATE(Amount, abs(PaymentLine.Amount) * -1);
                        InvPostingBuffer[1].VALIDATE("Amount (LCY)", abs(PaymentLine."Amount (LCY)") * -1);

                    END;
                end;  //fin comptabilisation compte générale






                //end add rh




                InvPostingBuffer[1]."Currency Code" := PaymentLine."Currency Code";
                InvPostingBuffer[1]."Currency Factor" := PaymentLine."Currency Factor";
                InvPostingBuffer[1].Correction := PaymentLine.Correction xor Step.Correction;
                //KK_091120
                InvPostingBuffer[1]."External reference" := PaymentLine."External Reference";
                //END

                if StepLedger."Detail Level" = StepLedger."Detail Level"::Line then
                    InvPostingBuffer[1]."Payment Line No." := PaymentLine."Line No."
                else
                    if StepLedger."Detail Level" = StepLedger."Detail Level"::"Due Date" then
                        InvPostingBuffer[1]."Due Date" := PaymentLine."Due Date";

                InvPostingBuffer[1]."Document Type" := StepLedger."Document Type";
                if StepLedger."Document No." = StepLedger."Document No."::"Header No." then
                    InvPostingBuffer[1]."Document No." := PaymentHeader."No."
                else begin
                    if (InvPostingBuffer[1].Sign = InvPostingBuffer[1].Sign::Positive) and
                       (PaymentLine."Entry No. Debit" = 0) and (PaymentLine."Entry No. Credit" = 0)
                    then begin
                        PaymentClass.Get(PaymentHeader."Payment Class");
                        if PaymentClass."Line No. Series" = '' then
                            PaymentLine.TestField("Document No.", NoSeriesMgt.GetNextNo(PaymentHeader."No. Series", PaymentLine."Posting Date", false))
                        else
                            PaymentLine.TestField("Document No.", NoSeriesMgt.GetNextNo(PaymentClass."Line No. Series", PaymentLine."Posting Date",
                                false));
                    end;
                    InvPostingBuffer[1]."Document No." := PaymentLine."Document No.";
                end;
                InvPostingBuffer[1]."Header Document No." := PaymentHeader."No.";
                if StepLedger.Sign = StepLedger.Sign::Debit then begin
                    EntryTypeDebit := InvPostingBuffer[1]."Account Type";
                    EntryNoAccountDebit := InvPostingBuffer[1]."Account No.";
                    EntryPostGroupDebit := InvPostingBuffer[1]."Posting Group";
                end else begin
                    EntryTypeCredit := InvPostingBuffer[1]."Account Type";
                    EntryNoAccountCredit := InvPostingBuffer[1]."Account No.";
                    EntryPostGroupCredit := InvPostingBuffer[1]."Posting Group";
                end;
                InvPostingBuffer[1]."System-Created Entry" := true;
                Application;
                PaymentClass.Get(PaymentHeader."Payment Class");
                if (PaymentClass."Unrealized VAT Reversal" = PaymentClass."Unrealized VAT Reversal"::Delayed) and
                   Step."Realize VAT"
                then begin
                    InvPostingBuffer[1]."Applies-to Doc. Type" := PaymentLine."Applies-to Doc. Type";
                    InvPostingBuffer[1]."Applies-to Doc. No." := PaymentLine."Applies-to Doc. No.";
                    if InvPostingBuffer[1]."Applies-to ID" = '' then
                        InvPostingBuffer[1]."Applies-to ID" := PaymentLine."Applies-to ID";
                    InvPostingBuffer[1]."Created from No." := PaymentLine."Created from No.";
                end;
                Description :=
                  StrSubstNo(StepLedger.Description, PaymentLine."Due Date", PaymentLine."Account No.", PaymentLine."Document No.", PaymentLine."External Document No.");
                InvPostingBuffer[1].Description := CopyStr(Description, 1, 50);
                InvPostingBuffer[1]."Source Type" := PaymentLine."Account Type";
                InvPostingBuffer[1]."Source No." := PaymentLine."Account No.";
                InvPostingBuffer[1]."External Document No." := PaymentLine."External Document No.";
                InvPostingBuffer[1]."Dimension Set ID" := PaymentLine."Dimension Set ID";
                UpdtBuffer;
                if (InvPostingBuffer[1].Amount >= 0) xor InvPostingBuffer[1].Correction then
                    PaymentLine."Entry No. Debit" := InvPostingBuffer[1]."GL Entry No."
                else
                    PaymentLine."Entry No. Credit" := InvPostingBuffer[1]."GL Entry No.";
                //ADD RH
                //message('Montant cpt %1  compte cpt %2 ', InvPostingBuffer[1]."Account No.", InvPostingBuffer[1].Amount);
                GenererInv();
            until StepLedger.Next = 0;
            NoSeriesMgt.SaveNoSeries;
        end;
    end;

    /// <summary>
    /// geninv2.
    /// </summary>
    /// <param name="SignePaymentLigne">Boolean.</param>
    procedure geninv2(SignePaymentLigne: Boolean)
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GroupeRetenu: Record "Groupe Retenue";
        PaymentClass: Record "Payment Class";
        StepLedgerTmp: Record "Payment Step Ledger";
    begin
        CLEAR(GroupeRetenu);
        InvPostingBuffer[1].INIT;
        InvPostingBuffer[1]."System-Created Entry" := TRUE;
        IF GroupeRetenu.GET(PaymentLine."Code Retenue à la Source") THEN;
        InvPostingBuffer[1]."Account Type" := InvPostingBuffer[1]."Account Type"::"G/L Account";
        InvPostingBuffer[1].VALIDATE("Account No.", GroupeRetenu."Compte Retenue");
        InvPostingBuffer[1]."Code Retenue à la Source" := PaymentLine."Code Retenue à la Source";
        //Error('Sihem');
        if SignePaymentLigne = true then begin
            InvPostingBuffer[1].VALIDATE(Amount, PaymentLine."Montant Retenue");
            IF InvPostingBuffer[1].Amount < 0 THEN
                InvPostingBuffer[1]."Assiette RS" := -PaymentLine."Assiette Retenue à la source"
            ELSE
                InvPostingBuffer[1]."Assiette RS" := PaymentLine."Assiette Retenue à la source";
            InvPostingBuffer[1].VALIDATE("Amount (LCY)", PaymentLine."Montant Retenue");
            //Message('compte retenue  %1  mnt : %2', InvPostingBuffer[1]."Account No.", InvPostingBuffer[1].Amount);
        end
        //if SignePaymentLigne = false then 
        else begin
            InvPostingBuffer[1].VALIDATE(Amount, -PaymentLine."Montant Retenue Validé");
            IF InvPostingBuffer[1].Amount < 0 THEN
                InvPostingBuffer[1]."Assiette RS" := -PaymentLine."Assiette Retenue à la source"
            ELSE
                InvPostingBuffer[1]."Assiette RS" := PaymentLine."Assiette Retenue à la source";
            InvPostingBuffer[1].VALIDATE("Amount (LCY)", -PaymentLine."Montant Retenue Validé");
            //Message('Annulation compta retenue');

        end;
        //Error('ici');
        InvPostingBuffer[1].Correction := PaymentLine.Correction XOR Step.Correction;
        IF (StepLedger."Detail Level" = StepLedger."Detail Level"::Line) THEN
            InvPostingBuffer[1]."Payment Line No." := PaymentLine."Line No."
        ELSE
            IF (StepLedger."Detail Level" = StepLedger."Detail Level"::"Due Date") THEN
                InvPostingBuffer[1]."Due Date" := PaymentLine."Due Date";
        InvPostingBuffer[1]."Document Type" := StepLedger."Document Type";
        IF StepLedger."Document No." = StepLedger."Document No."::"Header No." THEN
            InvPostingBuffer[1]."Document No." := PaymentHeader."No."
        ELSE BEGIN
            IF (InvPostingBuffer[1].Sign = InvPostingBuffer[1].Sign::Positive) AND
               (PaymentLine."Entry No. Debit" = 0) AND (PaymentLine."Entry No. Credit" = 0) THEN BEGIN
                PaymentClass.GET(PaymentHeader."Payment Class");
                IF PaymentClass."Line No. Series" = '' THEN
                    PaymentLine.TESTFIELD("Document No.", NoSeriesMgt.GetNextNo(PaymentHeader."No. Series", PaymentLine."Posting Date", FALSE))
            END;
            InvPostingBuffer[1]."Document No." := PaymentLine."Document No.";
        END;
        InvPostingBuffer[1]."Header Document No." := PaymentHeader."No.";

        InvPostingBuffer[1]."System-Created Entry" := TRUE;
        Application;
        /**InvPostingBuffer[1].Description := STRSUBSTNO(StepLedger.Description,
              PaymentLine.Libellé, PaymentLine."Account No.", PaymentLine."Document No.",
              PaymentLine."External Document No.");*/
        IF GroupeRetenu.GET(PaymentLine."Code Retenue à la Source") THEN;
        InvPostingBuffer[1].Description := GroupeRetenu.Designation;
        InvPostingBuffer[1]."Source Type" := PaymentLine."Account Type";
        InvPostingBuffer[1]."Source No." := PaymentLine."Account No.";
        InvPostingBuffer[1]."External Document No." := PaymentLine."External Document No.";
        InvPostingBuffer[1]."Global Dimension 1 Code" := PaymentHeader."Shortcut Dimension 1 Code";
        InvPostingBuffer[1]."Global Dimension 2 Code" := PaymentHeader."Shortcut Dimension 2 Code";
        InvPostingBuffer[1]."Applies-to ID" := '';

        UpdtBuffer;
    end;

    /// <summary>
    /// IncrementNoText.
    /// </summary>
    /// <param name="No">VAR Code[20].</param>
    /// <param name="IncrementByNo">Decimal.</param>
    [Scope('OnPrem')]
    procedure IncrementNoText(var No: Code[20]; IncrementByNo: Decimal)
    var
        DecimalNo: Decimal;
        StartPos: Integer;
        EndPos: Integer;
        NewNo: Text[30];
    begin
        GetIntegerPos(No, StartPos, EndPos);
        Evaluate(DecimalNo, CopyStr(No, StartPos, EndPos - StartPos + 1));
        NewNo := Format(DecimalNo + IncrementByNo, 0, 1);
        ReplaceNoText(No, NewNo, 0, StartPos, EndPos);
    end;

    /// <summary>
    /// LinesInsert.
    /// </summary>
    /// <param name="HeaderNumber">Code[20].</param>
    [Scope('OnPrem')]
    procedure LinesInsert(HeaderNumber: Code[20])
    var
        Header: Record "Payment Header";
        PaymentLine: Record "Payment Line";
        Step: Record "Payment Step";
        InserForm: Page "Payment Lines List";
    begin
        Header.Get(HeaderNumber);
        if StepSelect(Header."Payment Class", Header."Status No.", Step, false) then begin
            PaymentLine.SetRange("Payment Class", Header."Payment Class");
            PaymentLine.SetRange("Copied To No.", '');
            PaymentLine.SetFilter("Status No.", Format(Step."Previous Status"));
            PaymentLine.SetRange("Currency Code", Header."Currency Code");
            PaymentLine.FilterGroup(2);
            InserForm.SetSteps(Step.Line);
            InserForm.SetNumBor(Header."No.");
            InserForm.SetTableView(PaymentLine);
            InserForm.LookupMode(true);
            InserForm.RunModal;
        end;
    end;

    [Scope('OnPrem')]
    /// <summary> 
    /// Description for PaymentAddr.
    /// </summary>
    /// <param name="AddrArray">Parameter of type array[8] of Text[100].</param>
    /// <param name="PaymentAddress">Parameter of type Record "Payment Address".</param>
    procedure PaymentAddr(var AddrArray: array[8] of Text[100]; PaymentAddress: Record "Payment Address")
    var
        FormatAddress: Codeunit "Format Address";
    begin
        with PaymentAddress do
            FormatAddress.FormatAddr(
              AddrArray, Name, "Name 2", Contact, Address, "Address 2",
              City, "Post Code", County, "Country/Region Code");
    end;

    /// <summary>
    /// PaymentBankAcc.
    /// </summary>
    /// <param name="AddrArray">VAR array[8] of Text[100].</param>
    /// <param name="BankAcc">Record "Payment Header".</param>
    [Scope('OnPrem')]
    procedure PaymentBankAcc(var AddrArray: array[8] of Text[100]; BankAcc: Record "Payment Header")
    var
        FormatAddress: Codeunit "Format Address";
    begin
        with BankAcc do
            FormatAddress.FormatAddr(
              AddrArray, "Bank Name", "Bank Name 2", "Bank Contact", "Bank Address", "Bank Address 2",
              "Bank City", "Bank Post Code", "Bank County", "Bank Country/Region Code");
    end;

    /// <summary>
    /// PickPaymentStep.
    /// </summary>
    /// <param name="PaymentHeader">Record "Payment Header".</param>
    /// <param name="PaymentStep">VAR Record "Payment Step".</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('OnPrem')]
    procedure PickPaymentStep(PaymentHeader: Record "Payment Header"; var PaymentStep: Record "Payment Step"): Boolean
    var
        PaymentSteps: Page "Payment Steps";
        RecAutorisationEtapes: Record "Autorisation Etape";
    begin
        with PaymentStep do begin
            FilterGroup(2);
            // Filter on "Action Type" is passed with PaymentStep
            SetRange("Payment Class", PaymentHeader."Payment Class");
            SetRange("Previous Status", PaymentHeader."Status No.");
            FilterGroup(0);
            if IsEmpty then
                exit(false);

            if Count = 1 then begin
                FindFirst;
                //KK_050421
                //OLD exit(Confirm(Name, true));
                IF CONFIRM(Name, TRUE) THEN BEGIN
                    RecAutorisationEtapes.SETRANGE("Type de règlement", PaymentStep."Payment Class");
                    RecAutorisationEtapes.SETRANGE("No. Etape", PaymentStep.Line);
                    RecAutorisationEtapes.SETRANGE("Code utilisateur", USERID);
                    IF NOT RecAutorisationEtapes.FINDFIRST THEN
                        ERROR('Vous n''êtes pas autorisé a cette étape');
                    EXIT(TRUE);
                END ELSE
                    EXIT(false);
                exit(Confirm(Name, true));

            end;

            FindSet;
        end;
        PaymentSteps.LookupMode(true);
        PaymentSteps.SetTableView(PaymentStep);
        PaymentSteps.SetRecord(PaymentStep);
        PaymentSteps.Editable(false);
        if PaymentSteps.RunModal = ACTION::LookupOK then begin
            PaymentSteps.GetRecord(PaymentStep);
            //KK_050421__Autorisation étape de réglement
            RecAutorisationEtapes.SETRANGE("Type de règlement", PaymentStep."Payment Class");
            RecAutorisationEtapes.SETRANGE("No. Etape", PaymentStep.Line);
            RecAutorisationEtapes.SETRANGE("Code utilisateur", USERID);
            IF NOT RecAutorisationEtapes.FINDFIRST THEN
                ERROR('Vous n''êtes pas autorisé a cette étape');
            //END KK
            exit(true);
        end;
        exit(false);
    end;

    /// <summary>
    /// ProcessPaymentSteps.
    /// </summary>
    /// <param name="PaymentHeader">Record "Payment Header".</param>
    /// <param name="PaymentStep">VAR Record "Payment Step".</param>
    [Scope('OnPrem')]
    procedure ProcessPaymentSteps(PaymentHeader: Record "Payment Header"; var PaymentStep: Record "Payment Step")
    begin
        PaymentHeader.TestNbOfLines;
        if PickPaymentStep(PaymentHeader, PaymentStep) then
            ProcessPaymentStep(PaymentHeader."No.", PaymentStep);
    end;

    /// <summary>
    /// SetAccountNo.
    /// </summary>
    [Scope('OnPrem')]
    procedure SetAccountNo()
    begin
        case StepLedger."Accounting Type" of
            StepLedger."Accounting Type"::"Payment Line Account":
                begin
                    InvPostingBuffer[1]."Account Type" := PaymentLine."Account Type";
                    InvPostingBuffer[1]."Account No." := PaymentLine."Account No.";
                    if PaymentLine."Account Type" = PaymentLine."Account Type"::Customer then//*******************
                        InvPostingBuffer[1]."Posting Group" := CustomerPostingGroup.Code;
                    if PaymentLine."Account Type" = PaymentLine."Account Type"::Vendor then
                        InvPostingBuffer[1]."Posting Group" := VendorPostingGroup.Code
                    else
                        if PaymentLine."Account Type" = PaymentLine."Account Type"::Employee then begin
                            InvPostingBuffer[1]."Posting Group" := EmployeePostingGroupG.Code;
                            If StepLedger."Groupe Compta Salarié" <> '' THEN
                                InvPostingBuffer[1]."Posting Group" := StepLedger."Groupe Compta Salarié";
                        end;
                    InvPostingBuffer[1]."Line No." := PaymentLine."Line No.";
                    DimMgt.UpdateGlobalDimFromDimSetID(PaymentLine."Dimension Set ID",
                      InvPostingBuffer[1]."Global Dimension 1 Code", InvPostingBuffer[1]."Global Dimension 2 Code");
                end;
            StepLedger."Accounting Type"::"Associated G/L Account":
                begin
                    InvPostingBuffer[1]."Account Type" := InvPostingBuffer[1]."Account Type"::"G/L Account";
                    if PaymentLine."Account Type" = PaymentLine."Account Type"::Customer then
                        InvPostingBuffer[1]."Account No." := CustomerPostingGroup."Receivables Account"
                    else
                        InvPostingBuffer[1]."Account No." := VendorPostingGroup."Payables Account";
                    InvPostingBuffer[1]."Line No." := PaymentLine."Line No.";
                end;
            StepLedger."Accounting Type"::"Setup Account":
                begin
                    InvPostingBuffer[1]."Account Type" := StepLedger."Account Type";
                    InvPostingBuffer[1]."Account No." := StepLedger."Account No.";
                    if StepLedger."Account No." = '' then begin
                        PaymentHeader.CalcFields("Payment Class Name");
                        if StepLedger.Sign = StepLedger.Sign::Debit then
                            Error(Text018, Step.Name, PaymentHeader."Payment Class Name");

                        Error(Text019, Step.Name, PaymentHeader."Payment Class Name");
                    end;
                    if StepLedger."Account Type" = StepLedger."Account Type"::Customer then
                        InvPostingBuffer[1]."Posting Group" := StepLedger."Customer Posting Group"
                    else
                        if StepLedger."Account Type" = StepLedger."Account Type"::Employee then
                            InvPostingBuffer[1]."Posting Group" := EmployeePostingGroupG.Code
                        else
                            InvPostingBuffer[1]."Posting Group" := StepLedger."Vendor Posting Group";


                    InvPostingBuffer[1]."Line No." := PaymentLine."Line No.";
                end;
            StepLedger."Accounting Type"::"G/L Account / Month":
                begin
                    InvPostingBuffer[1]."Account Type" := InvPostingBuffer[1]."Account Type"::"G/L Account";
                    N := Date2DMY(PaymentLine."Due Date", 2);
                    if N < 10 then
                        Suffix := '0' + Format(N)
                    else
                        Suffix := Format(N);
                    InvPostingBuffer[1]."Account No." := CopyStr(StepLedger.Root + Suffix, 1, MaxStrLen(InvPostingBuffer[1]."Account No."));
                    InvPostingBuffer[1]."Line No." := PaymentLine."Line No.";
                end;
            StepLedger."Accounting Type"::"G/L Account / Week":
                begin
                    InvPostingBuffer[1]."Account Type" := InvPostingBuffer[1]."Account Type"::"G/L Account";
                    N := Date2DWY(PaymentLine."Due Date", 2);
                    if N < 10 then
                        Suffix := '0' + Format(N)
                    else
                        Suffix := Format(N);
                    InvPostingBuffer[1]."Account No." := CopyStr(StepLedger.Root + Suffix, 1, MaxStrLen(InvPostingBuffer[1]."Account No."));
                    InvPostingBuffer[1]."Line No." := PaymentLine."Line No.";
                end;
            StepLedger."Accounting Type"::"Bal. Account Previous Entry":
                begin
                    if (StepLedger.Sign = StepLedger.Sign::Debit) and not (PaymentLine.Correction xor Step.Correction) then begin
                        InvPostingBuffer[1]."Account Type" := PaymentLine."Acc. Type Last Entry Credit";
                        InvPostingBuffer[1]."Account No." := PaymentLine."Acc. No. Last Entry Credit";
                        InvPostingBuffer[1]."Posting Group" := PaymentLine."P. Group Last Entry Credit";
                    end else begin
                        InvPostingBuffer[1]."Account Type" := PaymentLine."Acc. Type Last Entry Debit";
                        InvPostingBuffer[1]."Account No." := PaymentLine."Acc. No. Last Entry Debit";
                        InvPostingBuffer[1]."Posting Group" := PaymentLine."P. Group Last Entry Debit";
                    end;
                    InvPostingBuffer[1]."Line No." := PaymentLine."Line No.";
                end;
            StepLedger."Accounting Type"::"Header Payment Account":
                begin
                    InvPostingBuffer[1]."Account Type" := PaymentHeader."Account Type";
                    InvPostingBuffer[1]."Account No." := PaymentHeader."Account No.";
                    if PaymentHeader."Account No." = '' then
                        Error(Text020);
                    if StepLedger."Detail Level" = StepLedger."Detail Level"::Account then
                        HeaderAccountUsedGlobally := true;
                    InvPostingBuffer[1]."Line No." := 0;
                    DimMgt.UpdateGlobalDimFromDimSetID(PaymentHeader."Dimension Set ID",
                      InvPostingBuffer[1]."Global Dimension 1 Code", InvPostingBuffer[1]."Global Dimension 2 Code");
                end;
        end;
    end;

    /// <summary>
    /// SetPostingGroup.
    /// </summary>
    [Scope('OnPrem')]
    procedure SetPostingGroup()
    var
        PostingGroup: Code[20];
        RecLEmployee: record Employee;
        RecLEmpPosGr: Record "Employee Posting Group";
    begin
        if PaymentLine."Account Type" = PaymentLine."Account Type"::Customer then
            if ((StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Payment Line Account") or
                (StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Associated G/L Account") or
                (StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Header Payment Account") or
                ((StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Setup Account") and
                 (StepLedger."Account Type" = StepLedger."Account Type"::Customer)))
            then begin
                //if PaymentLine."Posting Group" <> '' then
                // PostingGroup := PaymentLine."Posting Group"
                //else
                if StepLedger."Customer Posting Group" <> '' then
                    PostingGroup := StepLedger."Customer Posting Group"
                else begin
                    Customer.Get(PaymentLine."Account No.");
                    PostingGroup := Customer."Customer Posting Group";
                end;
                if not CustomerPostingGroup.Get(PostingGroup) then
                    Error(Text012, PostingGroup);
                if CustomerPostingGroup."Receivables Account" = '' then
                    Error(Text014, PostingGroup);
            end;

        if PaymentLine."Account Type" = PaymentLine."Account Type"::Vendor then
            if ((StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Payment Line Account") or
                (StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Associated G/L Account") or
                (StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Header Payment Account") or
                ((StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Setup Account") and
                 (StepLedger."Account Type" = StepLedger."Account Type"::Vendor)))
            then begin
                //if PaymentLine."Posting Group" <> '' then
                //    PostingGroup := PaymentLine."Posting Group"
                //else
                if StepLedger."Vendor Posting Group" <> '' then
                    PostingGroup := StepLedger."Vendor Posting Group"
                else begin
                    Vendor.Get(PaymentLine."Account No.");
                    PostingGroup := Vendor."Vendor Posting Group";
                end;
                if not VendorPostingGroup.Get(PostingGroup) then
                    Error(Text012, PostingGroup);
                if VendorPostingGroup."Payables Account" = '' then
                    Error(Text014, PostingGroup);
            end;
        //KK_020321___
        if PaymentLine."Account Type" = PaymentLine."Account Type"::Employee then
            if ((StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Payment Line Account") or
                (StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Associated G/L Account") or
                (StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Header Payment Account") or
                ((StepLedger."Accounting Type" = StepLedger."Accounting Type"::"Setup Account") and
                 (StepLedger."Account Type" = StepLedger."Account Type"::Employee)))
            then begin

                if StepLedger."Groupe Compta Salarié" <> '' then
                    PostingGroup := StepLedger."Groupe Compta Salarié"
                else begin
                    RecLEmployee.Get(PaymentLine."Account No.");
                    PostingGroup := RecLEmployee."Employee Posting Group";
                end;
                if not RecLEmpPosGr.Get(PostingGroup) then
                    Error('Groupe Compta Salarié n''existe pas %1 !', PostingGroup);
                if RecLEmpPosGr."Payables Account" = '' then
                    Error(Text014, PostingGroup);
            end;
        //END KK    
    end;

    /// <summary>
    /// StepSelect.
    /// </summary>
    /// <param name="Process">Text[30].</param>
    /// <param name="NextStatus">Integer.</param>
    /// <param name="Step">VAR Record "Payment Step".</param>
    /// <param name="CreateDocumentFilter">Boolean.</param>
    /// <returns>Return variable OK of type Boo-lean.</returns>
    [Scope('OnPrem')]
    procedure StepSelect(Process: Text[30]; NextStatus: Integer; var Step: Record "Payment Step"; CreateDocumentFilter: Boolean) OK: Boolean
    var
        PaymentClass: Record "Payment Class";
        Options: Text[250];
        Choice: Integer;
        i: Integer;
    begin
        OK := false;
        i := 0;
        if Process = '' then begin
            PaymentClass.SetRange(Enable, true);
            if CreateDocumentFilter then
                PaymentClass.SetRange("Is Create Document", true);
            if PaymentClass.Find('-') then
                repeat
                    i += 1;
                    if Options = '' then
                        Options := PaymentClass.Code
                    else
                        Options := Options + ',' + PaymentClass.Code;
                until PaymentClass.Next = 0;
            if i > 0 then
                Choice := StrMenu(Options, 1);
            i := 1;
            if Choice > 0 then begin
                PaymentClass.Find('-');
                while Choice > i do begin
                    i += 1;
                    PaymentClass.Next;
                end;
            end;
        end else begin
            PaymentClass.Get(Process);
            Choice := 1;
        end;
        if Choice > 0 then begin
            Options := '';
            Step.SetRange("Payment Class", PaymentClass.Code);
            Step.SetRange("Action Type", Step."Action Type"::"Create New Document");
            if NextStatus > -1 then
                Step.SetRange("Next Status", NextStatus);
            i := 0;
            if Step.Find('-') then begin
                i += 1;
                repeat
                    if Options = '' then
                        Options := Step.Name
                    else
                        Options := Options + ',' + Step.Name;
                until Step.Next = 0;
                if i > 0 then begin
                    Choice := StrMenu(Options, 1);
                    i := 1;
                    if Choice > 0 then begin
                        Step.Find('-');
                        while Choice > i do begin
                            i += 1;
                            Step.Next;
                        end;
                        OK := true;
                    end;
                end;
            end;
        end;
    end;

    /// <summary>
    /// TestSourceCode.
    /// </summary>
    /// <param name="Code">Code[10].</param>
    [Scope('OnPrem')]
    procedure TestSourceCode("Code": Code[10])
    var
        SourceCode: Record "Source Code";
    begin
        if not SourceCode.Get(Code) then
            Error(Text017, Code);
    end;

    /// <summary>
    /// UpdtBuffer.
    /// </summary>
    [Scope('OnPrem')]
    procedure UpdtBuffer()
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        InvPostingBuffer[2] := InvPostingBuffer[1];
        if InvPostingBuffer[2].Find then begin
            InvPostingBuffer[2].Validate(Amount, InvPostingBuffer[2].Amount + InvPostingBuffer[1].Amount);
            InvPostingBuffer[2]."Amount (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY(PaymentHeader."Posting Date",
                  PaymentHeader."Currency Code", InvPostingBuffer[2].Amount, PaymentHeader."Currency Factor"));
            InvPostingBuffer[2]."VAT Amount" :=
              InvPostingBuffer[2]."VAT Amount" + InvPostingBuffer[1]."VAT Amount";
            InvPostingBuffer[2]."Line Discount Amount" :=
              InvPostingBuffer[2]."Line Discount Amount" + InvPostingBuffer[1]."Line Discount Amount";
            if InvPostingBuffer[1]."Line Discount Account" <> '' then
                InvPostingBuffer[2]."Line Discount Account" := InvPostingBuffer[1]."Line Discount Account";
            InvPostingBuffer[2]."Inv. Discount Amount" :=
              InvPostingBuffer[2]."Inv. Discount Amount" + InvPostingBuffer[1]."Inv. Discount Amount";
            if InvPostingBuffer[1]."Inv. Discount Account" <> '' then
                InvPostingBuffer[2]."Inv. Discount Account" := InvPostingBuffer[1]."Inv. Discount Account";
            InvPostingBuffer[2]."VAT Base Amount" :=
              InvPostingBuffer[2]."VAT Base Amount" + InvPostingBuffer[1]."VAT Base Amount";
            InvPostingBuffer[2]."Amount (ACY)" :=
              InvPostingBuffer[2]."Amount (ACY)" + InvPostingBuffer[1]."Amount (ACY)";
            InvPostingBuffer[2]."VAT Amount (ACY)" :=
              InvPostingBuffer[2]."VAT Amount (ACY)" + InvPostingBuffer[1]."VAT Amount (ACY)";
            InvPostingBuffer[2]."VAT Difference" :=
              InvPostingBuffer[2]."VAT Difference" + InvPostingBuffer[1]."VAT Difference";
            InvPostingBuffer[2]."Line Discount Amt. (ACY)" :=
              InvPostingBuffer[2]."Line Discount Amt. (ACY)" +
              InvPostingBuffer[1]."Line Discount Amt. (ACY)";
            InvPostingBuffer[2]."Inv. Discount Amt. (ACY)" :=
              InvPostingBuffer[2]."Inv. Discount Amt. (ACY)" +
              InvPostingBuffer[1]."Inv. Discount Amt. (ACY)";
            InvPostingBuffer[2]."VAT Base Amount (ACY)" :=
              InvPostingBuffer[2]."VAT Base Amount (ACY)" +
              InvPostingBuffer[1]."VAT Base Amount (ACY)";
            InvPostingBuffer[2].Quantity :=
              InvPostingBuffer[2].Quantity + InvPostingBuffer[1].Quantity;
            if not InvPostingBuffer[1]."System-Created Entry" then
                InvPostingBuffer[2]."System-Created Entry" := false;
            InvPostingBuffer[2].Modify;
        end else begin
            GLEntryNoTmp += 1;
            InvPostingBuffer[1]."GL Entry No." := GLEntryNoTmp;
            InvPostingBuffer[1].Insert;
        end;
    end;

    local procedure CheckDim()
    begin
        PaymentLine."Line No." := 0;
        CheckDimCombAndValue(PaymentLine);

        PaymentLine.SetRange("No.", PaymentHeader."No.");
        if PaymentLine.FindSet then
            repeat
                CheckDimCombAndValue(PaymentLine);
            until PaymentLine.Next = 0;
    end;

    local procedure CheckDimCombAndValue(PaymentLine2: Record "Payment Line")
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        if PaymentLine."Line No." = 0 then begin
            if not DimMgt.CheckDimIDComb(PaymentHeader."Dimension Set ID") then
                Error(
                  Text009,
                  PaymentHeader."No.", DimMgt.GetDimCombErr);
            TableID[1] := DATABASE::"Payment Header";
            No[1] := PaymentHeader."No.";
            if not DimMgt.CheckDimValuePosting(TableID, No, PaymentHeader."Dimension Set ID") then
                ThrowPmtPostError(PaymentLine2, CheckDimVauePostingHeaderErr, DimMgt.GetDimValuePostingErr);
        end;

        if PaymentLine."Line No." <> 0 then begin
            if not DimMgt.CheckDimIDComb(PaymentLine2."Dimension Set ID") then
                Error(
                  Text010,
                  PaymentHeader."No.", PaymentLine2."Line No.", DimMgt.GetDimCombErr);
            TableID[1] := TypeToTableID(PaymentLine2."Account Type".AsInteger());
            No[1] := PaymentLine2."Account No.";
            if not DimMgt.CheckDimValuePosting(TableID, No, PaymentLine2."Dimension Set ID") then
                ThrowPmtPostError(PaymentLine2, CheckDimVauePostingLineErr, DimMgt.GetDimValuePostingErr);
        end;
    end;

    local procedure DeleteDirectDebitCollection(DirectDebitCollectionNo: Integer)
    var
        DirectDebitCollection: Record "Direct Debit Collection";
    begin
        if DirectDebitCollection.Get(DirectDebitCollectionNo) then
            DirectDebitCollection.Delete(true);
    end;

    local procedure ExportSEPACreditTransfer(XMLPortId: Integer; var PaymentHeader: Record "Payment Header")
    var
        GenJnlLine: Record "Gen. Journal Line";
        SEPACTExportFile: Codeunit "SEPA CT-Export File";
    begin
        GenJnlLine.SetRange("Journal Template Name", '');
        GenJnlLine.SetRange("Journal Batch Name", '');
        GenJnlLine.SetRange("Document No.", PaymentHeader."No.");
        if SEPACTExportFile.Export(GenJnlLine, XMLPortId) then begin
            PaymentHeader."File Export Completed" := true;
            PaymentHeader.Modify;
        end;
    end;

    local procedure ExportSEPADirectDebit(var PaymentHeader: Record "Payment Header")
    var
        DirectDebitCollection: Record "Direct Debit Collection";
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
        LastError: Text;
    begin
        PaymentHeader.TestField("Account Type", PaymentHeader."Account Type"::"Bank Account");
        DirectDebitCollection.CreateRecord(PaymentHeader."No.", PaymentHeader."Account No.", PaymentHeader."Partner Type");
        DirectDebitCollection."Source Table ID" := DATABASE::"Payment Header";
        DirectDebitCollection.Modify;
        DirectDebitCollectionEntry.SetRange("Direct Debit Collection No.", DirectDebitCollection."No.");
        Commit;
        ClearLastError;
        if CODEUNIT.Run(CODEUNIT::"SEPA DD-Export File", DirectDebitCollectionEntry) then begin
            DeleteDirectDebitCollection(DirectDebitCollection."No.");
            PaymentHeader."File Export Completed" := true;
            PaymentHeader.Modify;
            exit;
        end;

        LastError := GetLastErrorText;
        DeleteDirectDebitCollection(DirectDebitCollection."No.");
        Commit;
        Error(LastError);
    end;

    local procedure GetIntegerPos(No: Code[20]; var StartPos: Integer; var EndPos: Integer)
    var
        IsDigit: Boolean;
        i: Integer;
    begin
        StartPos := 0;
        EndPos := 0;
        if No <> '' then begin
            i := StrLen(No);
            repeat
                IsDigit := No[i] in ['0' .. '9'];
                if IsDigit then begin
                    if EndPos = 0 then
                        EndPos := i;
                    StartPos := i;
                end;
                i := i - 1;
            until (i = 0) or (StartPos <> 0) and not IsDigit;
        end;
        if (StartPos = 0) and (EndPos = 0) then
            Error(Text021, No);
    end;

    local procedure PostInvPostingBuffer(): Integer
    var
        GLEntry: Record "G/L Entry";
        GroupeRetenu: Record "Groupe Retenue";
        Desc: Code[100];
        RecBankAccount: Record "Bank Account";
    begin
        with GenJnlLine do begin
            Init;
            "Posting Date" := PaymentHeader."Posting Date";
            "Document Date" := PaymentHeader."Document Date";
            Description := InvPostingBuffer[1].Description;
            "Reason Code" := Step."Reason Code";
            PaymentClass.Get(PaymentHeader."Payment Class");
            "Delayed Unrealized VAT" :=
              (PaymentClass."Unrealized VAT Reversal" = PaymentClass."Unrealized VAT Reversal"::Delayed);
            "Realize VAT" := Step."Realize VAT";
            "Created from No." := InvPostingBuffer[1]."Created from No.";
            "Document Type" := InvPostingBuffer[1]."Document Type";
            "Document No." := InvPostingBuffer[1]."Document No.";
            "Account Type" := InvPostingBuffer[1]."Account Type";
            "Account No." := InvPostingBuffer[1]."Account No.";
            "System-Created Entry" := InvPostingBuffer[1]."System-Created Entry";
            "Currency Code" := InvPostingBuffer[1]."Currency Code";
            "Currency Factor" := InvPostingBuffer[1]."Currency Factor";
            Validate(Amount, InvPostingBuffer[1].Amount);
            Correction := InvPostingBuffer[1].Correction;
            "Code Retenue à la Source" := InvPostingBuffer[1]."Code Retenue à la Source";
            //KK_091120
            "External Reference" := InvPostingBuffer[1]."External reference";
            //END


            if PaymentHeader."Source Code" <> '' then begin
                TestSourceCode(PaymentHeader."Source Code");
                "Source Code" := PaymentHeader."Source Code";
            end else begin
                Step.TestField("Source Code");
                TestSourceCode(Step."Source Code");
                "Source Code" := Step."Source Code";
            end;
            "Applies-to ID" := InvPostingBuffer[1]."Applies-to ID";
            if "Applies-to ID" = '' then begin
                "Applies-to Doc. Type" := InvPostingBuffer[1]."Applies-to Doc. Type";
                "Applies-to Doc. No." := InvPostingBuffer[1]."Applies-to Doc. No.";
            end;
            "Posting Group" := InvPostingBuffer[1]."Posting Group";
            "Source Type" := InvPostingBuffer[1]."Source Type";
            "Source No." := InvPostingBuffer[1]."Source No.";
            "External Document No." := InvPostingBuffer[1]."External Document No.";
            "Due Date" := InvPostingBuffer[1]."Due Date";
            "Shortcut Dimension 1 Code" := InvPostingBuffer[1]."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := InvPostingBuffer[1]."Global Dimension 2 Code";
            "Dimension Set ID" := InvPostingBuffer[1]."Dimension Set ID";

        end;

        GenJnlPostLine.RunWithCheck(GenJnlLine);

        GLEntry.SetRange("Document Type", GenJnlLine."Document Type");
        GLEntry.SetRange("Document No.", GenJnlLine."Document No.");
        if GLEntry.FindLast then
            exit(GLEntry."Entry No.");
        exit(0);
    end;

    local procedure ProcessPaymentStep(PaymentHeaderNo: Code[20]; PaymentStep: Record "Payment Step")
    var
        PaymentStatus: Record "Payment Status";
        Window: Dialog;
        ActionValidated: Boolean;
        PaymentLine5: Record "Payment Line";
        CustLedgerEntry5: Record "Cust. Ledger Entry";
        VendorLedgerEntry5: Record "Vendor Ledger Entry";
        RecVendorLettrage: Record Vendor;
        RecPaymentClass: record "Payment Class";

        Text050: Label 'Veuillez faire le lettrage. Client  N° : %1  dans le Bordereau N° :  %2 dans le Ligne N° : %3';

    begin
        PaymentHeader.Get(PaymentHeaderNo);
        PaymentHeader.SetRange("No.", PaymentHeader."No.");

        if PaymentStep."Verify Header RIB" and not PaymentHeader."RIB Checked" then
            Error(Text008);

        PaymentLine.SetRange("No.", PaymentHeader."No.");
        PaymentLine.SetRange("Copied To No.", '');

        if PaymentStep."Acceptation Code<>No" then begin
            PaymentLine.SetRange("Acceptation Code", PaymentLine."Acceptation Code"::No);
            if PaymentLine.Find('-') then
                Error(Text002);
            PaymentLine.SetRange("Acceptation Code");
        end;

        if PaymentStep."Verify Lines RIB" then begin
            PaymentLine.SetRange("RIB Checked", false);
            if PaymentLine.Find('-') then
                Error(Text003);
            PaymentLine.SetRange("RIB Checked");
        end;

        if PaymentStep."Verify Due Date" then begin
            PaymentLine.SetRange("Due Date", 0D);
            if PaymentLine.Find('-') then
                Error(Text006);
            PaymentLine.SetRange("Due Date");
        end;


        Step.Get(PaymentStep."Payment Class", PaymentStep.Line);
        //ADD RH
        //controle référence bordereau bvanque
        if PaymentStep."Réf. Bord. banque Oblogatoire" then
            PaymentHeader.TestField("Réf. Borderaeu banque");
        //___________all controle
        clear(PaymentClass);
        PaymentClass.get(PaymentHeader."Payment Class");
        CLEAR(PaymentLine5);
        PaymentLine5.SETFILTER(PaymentLine5."No.", '%1', PaymentHeader."No.");
        IF PaymentLine5.FINDFIRST THEN
            REPEAT
                //controel reclassement
                if PaymentClass.Reclassement then begin
                    PaymentHeader.TestField("Account Type", PaymentHeader."Account Type"::Customer);
                    PaymentLine5.TestField("Account Type", PaymentLine5."Account Type"::Vendor);
                end;

                //controle doc externe
                if PaymentStep."No. Doc Externe Obligatoir" then begin
                    PaymentLine5.TestField("External Document No.");
                    PaymentLine5.TestField("Bank Account Code");
                    PaymentLine5.TestField("Bank Account Name");
                    if PaymentClass."Type Réglement" = PaymentClass."Type Réglement"::Check then
                        if StrLen(PaymentLine5."External Document No.") <> 7 then
                            Error('No. de chèque doit avoir 7 caractères');
                    if PaymentClass."Type Réglement" = PaymentClass."Type Réglement"::Draft then
                        if StrLen(PaymentLine5."External Document No.") <> 13 then
                            Error('No. Effet doit avoir 13 caractères');
                end;



                //controle lettrage obligatoire
                if PaymentStep."Lettrage Obligatoire" then begin
                    IF PaymentLine5."Account Type" = PaymentLine5."Account Type"::Customer THEN BEGIN
                        CLEAR(CustLedgerEntry5);
                        CustLedgerEntry5.SETCURRENTKEY("Customer No.", "Applies-to ID", Open, Positive, "Due Date");
                        CustLedgerEntry5.SETRANGE(CustLedgerEntry5."Customer No.", PaymentLine5."Account No.");
                        CustLedgerEntry5.SETRANGE(CustLedgerEntry5.Open, TRUE);
                        CustLedgerEntry5.SETFILTER(CustLedgerEntry5."Applies-to ID", '%1', PaymentLine5."No." + '*');
                        IF NOT CustLedgerEntry5.FINDFIRST THEN
                            ERROR(Text050, PaymentLine5."Account No.", PaymentLine5."No.", PaymentLine5."Line No.");
                    END;
                    IF PaymentLine5."Account Type" = PaymentLine5."Account Type"::Vendor THEN BEGIN
                        CLEAR(VendorLedgerEntry5);
                        VendorLedgerEntry5.SETRANGE("Vendor No.", PaymentLine5."Account No.");
                        VendorLedgerEntry5.SETRANGE(Open, TRUE);
                        VendorLedgerEntry5.SETFILTER("Applies-to ID", '%1', PaymentLine5."No." + '*');
                        IF NOT VendorLedgerEntry5.FINDFIRST AND RecVendorLettrage.GET(PaymentLine5."Account No.") THEN
                            ERROR(Text050, PaymentLine5."Account No.", PaymentLine5."No.", PaymentLine5."Line No.");
                    END;
                end;
                if PaymentStep."Blocage Compte" then begin
                    case PaymentLine5."Account Type" of
                        PaymentLine5."Account Type"::Customer:
                            begin
                                clear(Customer);
                                Customer.get(PaymentLine5."Account No.");
                                Customer.Blocked := Customer.Blocked::Ship;
                                customer.Modify();
                                Message('Le compte client %1 a été bloqué suite à cet transaction', PaymentLine5."Account No.");

                                Company2.FindFirst();
                                repeat
                                    IF Company2.Name <> CompanyName then BEGIN
                                        clear(CustomerOdherCompany);
                                        CustomerOdherCompany.ChangeCompany(Company2.Name);
                                        CustomerOdherCompany.setrange("VAT Registration No.", Customer."VAT Registration No.");
                                        if CustomerOdherCompany.FindFirst then begin
                                            CustomerOdherCompany.Blocked := CustomerOdherCompany.Blocked::Ship;
                                            CustomerOdherCompany.Modify();
                                        end;
                                    END;
                                Until Company2.next = 0;

                            end;
                        PaymentLine5."Account Type"::Vendor:
                            begin
                                /*clear(Vendor);
                                Vendor.get(PaymentLine5."Account No.");
                                Vendor.Blocked := Vendor.Blocked::All;
                                Vendor.Modify();*/


                            end;
                    end;
                end;


            until PaymentLine5.next = 0;












        Actualiserstat(PaymentHeader);
        //END ADD
        case Step."Action Type" of
            Step."Action Type"::None:
                ActionValidated := true;
            Step."Action Type"::"Cancel File":
                begin
                    PaymentHeader."File Export Completed" := false;
                    PaymentHeader.Modify;
                    ActionValidated := true;
                end;
            Step."Action Type"::File:
                begin
                    PaymentHeader."File Export Completed" := false;
                    PaymentHeader.Modify;
                    Commit;

                    case Step."Export Type" of
                        Step."Export Type"::Report:
                            REPORT.RunModal(Step."Export No.", true, false, PaymentHeader);
                        Step."Export Type"::XMLport:
                            RunXmlPortExport(Step."Export No.", PaymentHeader);
                    end;

                    PaymentHeader.Find;
                    ActionValidated := PaymentHeader."File Export Completed";
                end;
            Step."Action Type"::Report:
                begin
                    //REPORT.RunModal(Step."Report No.", true, true, PaymentLine); //Commentaire RH
                    Report.RunModal(Step."Report No.", true, true, PaymentHeader); //ADD RH
                    ActionValidated := true;
                end;
            Step."Action Type"::Ledger:
                begin
                    InvPostingBuffer[1].DeleteAll;
                    CheckDim;
                    Window.Open(
                      '#1#################################\\' +
                      Text005);
                    if PaymentLine.Find('-') then
                        repeat
                            Window.Update(1, Text005 + ' ' + PaymentLine."No." + ' ' + Format(PaymentLine."Line No."));
                            OldPaymentLine := PaymentLine;
                            HeaderAccountUsedGlobally := false;
                            GenerInvPostingBuffer;
                            PaymentLine."Acc. Type Last Entry Debit" := EntryTypeDebit;
                            PaymentLine."Acc. No. Last Entry Debit" := EntryNoAccountDebit;
                            PaymentLine."P. Group Last Entry Debit" := EntryPostGroupDebit;
                            PaymentLine."Acc. Type Last Entry Credit" := EntryTypeCredit;
                            PaymentLine."Acc. No. Last Entry Credit" := EntryNoAccountCredit;
                            PaymentLine."P. Group Last Entry Credit" := EntryPostGroupCredit;
                            PaymentLine.Validate("Status No.", Step."Next Status");
                            PaymentLine.Posted := true;
                            PaymentLine.Modify;
                        until PaymentLine.Next = 0;
                    Window.Close;
                    GenerEntries;
                    ActionValidated := true;
                end;
        end;

        if ActionValidated then begin
            PaymentHeader.Validate("Status No.", Step."Next Status");
            PaymentHeader."Date validation" := CurrentDateTime; //Add by RH
            PaymentHeader.Modify;
            PaymentLine.SetRange("No.", PaymentHeader."No.");
            PaymentLine.ModifyAll("Status No.", Step."Next Status");
            PaymentStatus.Get(PaymentHeader."Payment Class", Step."Next Status");
            PaymentLine.ModifyAll("Payment in Progress", PaymentStatus."Payment in Progress");
            PaymentLine.MODIFYALL("Status No.", Step."Next Status");   //Add by RH
        end else
            Message(Text007);
    end;

    local procedure ReplaceNoText(var No: Code[20]; NewNo: Code[30]; FixedLength: Integer; StartPos: Integer; EndPos: Integer)
    var
        StartNo: Code[20];
        EndNo: Code[20];
        ZeroNo: Code[20];
        NewLength: Integer;
        OldLength: Integer;
    begin
        if StartPos > 1 then
            StartNo := CopyStr(No, 1, StartPos - 1);
        if EndPos < StrLen(No) then
            EndNo := CopyStr(No, EndPos + 1);
        NewLength := StrLen(NewNo);
        OldLength := EndPos - StartPos + 1;
        if FixedLength > OldLength then
            OldLength := FixedLength;
        if OldLength > NewLength then
            ZeroNo := PadStr('', OldLength - NewLength, '0');
        if StrLen(StartNo) + StrLen(ZeroNo) + StrLen(NewNo) + StrLen(EndNo) > 20 then
            Error(Text001, No);

        No := CopyStr(StartNo + ZeroNo + NewNo + EndNo, 1, MaxStrLen(No));
    end;

    local procedure RunXmlPortExport(XMLPortID: Integer; var PaymentHeader: Record "Payment Header")
    begin
        PaymentClass.Get(PaymentHeader."Payment Class");
        case PaymentClass."SEPA Transfer Type" of
            PaymentClass."SEPA Transfer Type"::"Credit Transfer":
                ExportSEPACreditTransfer(XMLPortID, PaymentHeader);
            PaymentClass."SEPA Transfer Type"::"Direct Debit":
                ExportSEPADirectDebit(PaymentHeader);
            else
                XMLPORT.Run(XMLPortID, false, false, PaymentHeader);
        end;
    end;

    local procedure ThrowPmtPostError(ReceivedPaymentLine: Record "Payment Line"; ErrorTemplate: Text; ErrorText: Text)
    begin
        with ReceivedPaymentLine do
            if "Line No." <> 0 then
                Error(
                  ErrorTemplate, PaymentHeader."No.", TableCaption, "Line No.", ErrorText);
        Error(ErrorTemplate, PaymentHeader."No.", ErrorText);
    end;

    local procedure TypeToTableID(Type: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset"): Integer
    begin
        case Type of
            Type::"G/L Account":
                exit(DATABASE::"G/L Account");
            Type::Customer:
                exit(DATABASE::Customer);
            Type::Vendor:
                exit(DATABASE::Vendor);
            Type::"Bank Account":
                exit(DATABASE::"Bank Account");
            Type::"Fixed Asset":
                exit(DATABASE::"Fixed Asset");
        end;
    end;
    //ADD SS 16/11/2020
    /// <summary> 
    /// validation des encaissements importés
    /// </summary>
    /// <param name="PaymentHeaderNo">Parameter of type Code[20].</param>
    /// <param name="PaymentStep">Parameter of type Record "Payment Step".</param>
    procedure ValidationBordereauParLot(PaymentHeaderNo: Code[20]; PaymentStep: Record "Payment Step")
    var
        PaymentStatus: Record "Payment Status";
        Window: Dialog;
        ActionValidated: Boolean;
    begin
        PaymentHeader.Get(PaymentHeaderNo);
        PaymentHeader.SetRange("No.", PaymentHeader."No.");

        if PaymentStep."Verify Header RIB" and not PaymentHeader."RIB Checked" then
            Error(Text008);

        PaymentLine.SetRange("No.", PaymentHeader."No.");
        PaymentLine.SetRange("Copied To No.", '');

        if PaymentStep."Acceptation Code<>No" then begin
            PaymentLine.SetRange("Acceptation Code", PaymentLine."Acceptation Code"::No);
            if PaymentLine.Find('-') then
                Error(Text002);
            PaymentLine.SetRange("Acceptation Code");
        end;

        if PaymentStep."Verify Lines RIB" then begin
            PaymentLine.SetRange("RIB Checked", false);
            if PaymentLine.Find('-') then
                Error(Text003);
            PaymentLine.SetRange("RIB Checked");
        end;

        if PaymentStep."Verify Due Date" then begin
            PaymentLine.SetRange("Due Date", 0D);
            if PaymentLine.Find('-') then
                Error(Text006);
            PaymentLine.SetRange("Due Date");
        end;

        Step.Get(PaymentStep."Payment Class", PaymentStep.Line);
        //ADD RH
        Actualiserstat(PaymentHeader);
        //END ADD
        case Step."Action Type" of
            Step."Action Type"::None:
                ActionValidated := true;
            Step."Action Type"::"Cancel File":
                begin
                    PaymentHeader."File Export Completed" := false;
                    PaymentHeader.Modify;
                    ActionValidated := true;
                end;
            Step."Action Type"::File:
                begin
                    PaymentHeader."File Export Completed" := false;
                    PaymentHeader.Modify;
                    Commit;

                    case Step."Export Type" of
                        Step."Export Type"::Report:
                            REPORT.RunModal(Step."Export No.", true, false, PaymentHeader);
                        Step."Export Type"::XMLport:
                            RunXmlPortExport(Step."Export No.", PaymentHeader);
                    end;

                    PaymentHeader.Find;
                    ActionValidated := PaymentHeader."File Export Completed";
                end;
            Step."Action Type"::Report:
                begin
                    //REPORT.RunModal(Step."Report No.", true, true, PaymentLine); //Commentaire RH
                    Report.RunModal(Step."Report No.", true, true, PaymentHeader); //ADD RH
                    ActionValidated := true;
                end;
            Step."Action Type"::Ledger:
                begin
                    InvPostingBuffer[1].DeleteAll;
                    CheckDim;
                    Window.Open(
                      '#1#################################\\' +
                      Text005);
                    if PaymentLine.Find('-') then
                        repeat
                            Window.Update(1, Text005 + ' ' + PaymentLine."No." + ' ' + Format(PaymentLine."Line No."));
                            OldPaymentLine := PaymentLine;
                            HeaderAccountUsedGlobally := false;
                            GenerInvPostingBuffer;
                            PaymentLine."Acc. Type Last Entry Debit" := EntryTypeDebit;
                            PaymentLine."Acc. No. Last Entry Debit" := EntryNoAccountDebit;
                            PaymentLine."P. Group Last Entry Debit" := EntryPostGroupDebit;
                            PaymentLine."Acc. Type Last Entry Credit" := EntryTypeCredit;
                            PaymentLine."Acc. No. Last Entry Credit" := EntryNoAccountCredit;
                            PaymentLine."P. Group Last Entry Credit" := EntryPostGroupCredit;
                            PaymentLine.Validate("Status No.", Step."Next Status");
                            PaymentLine.Posted := true;
                            PaymentLine.Modify;
                        until PaymentLine.Next = 0;
                    Window.Close;
                    GenerEntries;
                    ActionValidated := true;
                end;
        end;

        if ActionValidated then begin
            PaymentHeader.Validate("Status No.", Step."Next Status");
            PaymentHeader."Date validation" := CurrentDateTime; //Add by RH
            PaymentHeader.Modify;
            PaymentLine.SetRange("No.", PaymentHeader."No.");
            PaymentLine.ModifyAll("Status No.", Step."Next Status");
            PaymentStatus.Get(PaymentHeader."Payment Class", Step."Next Status");
            PaymentLine.ModifyAll("Payment in Progress", PaymentStatus."Payment in Progress");
            PaymentLine.MODIFYALL("Status No.", Step."Next Status");   //Add by RH
        end else
            Message(Text007);
    end;

}


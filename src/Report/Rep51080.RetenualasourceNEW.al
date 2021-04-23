/// <summary>
/// Report Retenu a la source - NEW (ID 51080).
/// </summary>
report 51080 "Retenu a la source - NEW"
{
    // version Encaiss/Décaissment MG
    Caption = 'Retenue à la source';
    DefaultLayout = RDLC;
    RDLCLayout = '.\src\Report\Rep51000.RetenualasourceNEW.rdl';
    PreviewMode = PrintLayout;
    // EnableHyperlinks = true;

    dataset
    {
        dataitem("Payment Header"; "Payment Header")
        {

            dataitem("Payment Line"; "Payment Line")
            {
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("No.", "Line No.");
                column("Numéro"; "Payment Line"."No.")
                {
                }
                column(Increment; Increment)
                {
                }
                column(ExternelDoc; "Payment Line"."External Document No.")
                {
                }
                column(DraweeRef; "Payment Line"."Drawee Reference")
                {
                }
                column(BankAccountName; "Payment Line"."Bank Account Name")
                {
                }
                column(BankCity; "Payment Line"."Bank City")
                {
                }
                column(AmountLCY; ABS("Payment Line"."Amount (LCY)"))
                {
                }
                column(P2; Partition2)
                {
                }
                column(DueDate_PaymentLine; "Payment Line"."Due Date")
                {
                }
                column(TxtAdresse; TXTADRESSE)
                {
                }
                column(MatriculeFiscal; Rec_Company."VAT Registration No.")
                {
                }
                column(NameBanque; FORMAT("Payment Line"."Account No.") + ' : ' + FORMAT("Payment Line".Libellé))
                {
                }
                column(NomUtilisateur; RecUser."Full Name")
                {
                }
                column(CityBanque; RecGBanque.City)
                {
                }
                column(NomDeLaBanque; RecBankAccount.Name)
                {
                }
                column(TxtReportTitle; TxtReportTitle)
                {
                }
                column(TxtCompanyName; TxtCompanyname)
                {
                }
                column(Picture; Rec_Company.Picture)
                {
                }
                column(Montant; "Payment Line".Amount)
                {
                }
                column(BankAccountNo_PaymentLine; "Payment Line"."Bank Account No.")
                {
                }
                column(BankBranchNo; RecGPaymentHeader."Bank Branch No.")
                {
                }
                column(AgencyCode; RecGPaymentHeader."Agency Code")
                {
                }
                column(BankAccountNo; RecGPaymentHeader."Bank Account No.")
                {
                }
                column(BankAccountCode_PaymentLine; "Payment Line"."Bank Account Code")
                {
                }
                column(RibKey; RecGPaymentHeader."Bank Branch No." + RecGPaymentHeader."Agency Code" + RecGPaymentHeader."Bank Account No." + FORMAT(RecGPaymentHeader."RIB Key"))
                {
                }
                column(BankName; RecGPaymentHeader."Bank Name")
                {
                }
                column(PostingDate; RecGPaymentHeader."Posting Date")
                {
                }

                column(Logo; Rec_Company.Picture)
                {
                }
                column(CompanyName; Rec_Company.Name)
                {
                }
                column(CompanyAddress; Rec_Company.Address)
                {
                }

                column(NomeBank; RecBankAccount.Name)
                {
                }
                column(MntLettre; TexteLettre)
                {
                }
                column(AccountNo_PaymentLine; "Payment Line"."Account No.")
                {
                }
                column("Libellé_PaymentLine"; "Payment Line".Libellé)
                {
                }
                column(DocLettrer; DocLettrer)
                {
                }
                column(MontantRetenue_PaymentLine; "Payment Line"."Montant Retenue")
                {
                }

                column(AssietteRS_PaymentLine; "Payment Line"."Assiette Retenue à la source")
                {
                }
                column(AdresseClient; RecVendor.Address + ' ' + RecVendor.City + ' ' + RecVendor."Post Code")
                {
                }
                column(MatriculeClient; RecVendor."VAT Registration No.")
                {
                }
                column(ImpDate; ImpDate)
                {
                }
                column(MatEntrep; MatEntrep)
                {
                }
                column(CdeTva; CdeTva)
                {
                }
                column(Categorie; Categorie)
                {
                }
                column(Etab; Etab)
                {
                }
                column(MatEntrepEntrep; MatEntrepEntrep)
                {
                }
                column(CdeTvaEntrep; CdeTvaEntrep)
                {
                }
                column(CategorieEntrep; CategorieEntrep)
                {
                }
                column(EtabEntrep; EtabEntrep)
                {
                }
                column(DescRentenu; RecGroupeRetenue.Designation)
                {
                }

                trigger OnAfterGetRecord();
                begin
                    ImpDate := WORKDATE;
                    CumulMntLCY += ABS("Amount (LCY)");
                    Increment += 1;
                    IF RecGBanque.GET("Account No.") THEN;
                    IF RecGPaymentHeader.GET("No.") THEN;
                    TexteLettre := '';
                    CU_MntLettre."Montant en texte"(TexteLettre, ABS(CumulMntLCY));

                    CLEAR(RecUser);
                    RecUser.SETRANGE(RecUser."User Name", USERID);
                    IF RecUser.FINDFIRST THEN;

                    // Get Bank
                    CLEAR(RecBankAccount);
                    RecBankAccount.SETFILTER(RecBankAccount.Code, '%1', "Bank Account Code");
                    RecBankAccount.SETRANGE("Customer No.", "Payment Line"."Account No.");
                    IF RecBankAccount.FINDFIRST THEN;
                    BEGIN
                    END;

                    // Code TVA Client
                    NewMat := '';
                    MatEntrep := '';
                    CdeTva := '';
                    Categorie := '';
                    Etab := '';

                    // GET CUSTOMER
                    CLEAR(RecVendor);
                    IF RecVendor.GET("Payment Line"."Account No.") THEN
                        NewMat := DELCHR(RecVendor."VAT Registration No.", '=', '/|\| ');
                    // GET CUSTOMER
                    CLEAR(RecCustomer);
                    IF RecCustomer.GET("Payment Line"."Account No.") THEN
                        NewMat := DELCHR(RecCustomer."VAT Registration No.", '=', '/|\| ');



                    //NewMat := DELCHR(RecVendor."VAT Registration No.",'=','/|\| ');
                    MatEntrep := COPYSTR(NewMat, 1, 8);
                    CdeTva := COPYSTR(NewMat, 9, 1);
                    Categorie := COPYSTR(NewMat, 10, 1);
                    Etab := COPYSTR(NewMat, 11, 3);


                    // Get Description de retenu
                    CLEAR(RecGroupeRetenue);
                    RecGroupeRetenue.SETRANGE(RecGroupeRetenue."Code Retenue", "Payment Line"."Code Retenue à la Source");
                    IF RecGroupeRetenue.FINDFIRST THEN;
                end;

                trigger OnPreDataItem();
                begin
                    Increment := 1;
                    IF Rec_Company.GET() THEN;
                    Rec_Company.CALCFIELDS(Picture);
                    TxtCompanyname := Rec_Company.Name;
                    TXTADRESSE := Rec_Company.Address + ' ' + Rec_Company.City + ' ' + Rec_Company."Post Code";
                    CumulMntLCY := 0;


                    NewMatEntrep := DELCHR(Rec_Company."VAT Registration No.", '=', '/|\| ');
                    MatEntrepEntrep := COPYSTR(NewMatEntrep, 1, 8);
                    CdeTvaEntrep := COPYSTR(NewMatEntrep, 9, 1);
                    CategorieEntrep := COPYSTR(NewMatEntrep, 10, 1);
                    EtabEntrep := COPYSTR(NewMatEntrep, 11, 3);
                end;
            }
            dataitem(Integer; Integer)
            {
                DataItemTableView = SORTING(Number)
                                    ORDER(Ascending)
                                    WHERE(Number = CONST(1));
                column(CumulMntLCY; CumulMntLCY)
                {
                }
                column(MontantLettrer; MontantLettrer)
                {
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        TxtCompanyname: Code[50];
        Increment: Integer;
        Rec_Company: Record 79;
        CU_MntLettre: Codeunit "Montant Toute Lettre";
        TexteLettre: Text[1024];
        CumulMntLCY: Decimal;
        test: Decimal;
        Partition: array[20] of Decimal;
        Partition2: Decimal;
        NombreLigne: Decimal;
        Pagination: array[100] of Decimal;
        TxtTitre: Label 'BORDEREAU DE REMISE  %1  A L''ENCAISSEMENT';
        TxtReportTitle: Text[250];
        RecGBanque: Record 270;
        RecGPaymentHeader: Record "Payment Header";
        MontantLettrer: Decimal;
        TXTADRESSE: Text;
        RecUser: Record 2000000120;
        RecBankAccount: Record 287;
        IdLettrage: Text[50];
        SlachPos: Integer;
        DocLettrer: Text;
        "Cust. Ledger Entry": Record 21;
        RecVendor: Record 23;
        RecCustomer: Record 18;
        ImpDate: Date;
        MatEntrep: Text;
        CdeTva: Text;
        Categorie: Text;
        Etab: Text;
        NewMat: Text;
        MatEntrepEntrep: Text;
        CdeTvaEntrep: Text;
        CategorieEntrep: Text;
        EtabEntrep: Text;
        NewMatEntrep: Text;
        RecGroupeRetenue: Record "Groupe Retenue";
}


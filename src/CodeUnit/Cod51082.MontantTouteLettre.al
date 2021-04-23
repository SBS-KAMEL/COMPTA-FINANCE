/// <summary>
/// Codeunit Montant Toute Lettre (ID 51082).
/// </summary>
codeunit 51082 "Montant Toute Lettre"
{

    trigger OnRun();
    begin
    end;

    var
        million: Text[250];
        mille: Text[250];
        cent: Text[250];
        entiere: Integer;
        decimal: Integer;
        nbre: Integer;
        nbre1: Integer;
        j: Integer;
        "Chèque": Report 1401;
        chaine1: Text[30];
        VarDeviseEntiere: Text[30];
        VarDeviseDecimal: Text[30];
        AsciiStr: Text[250];
        AnsiStr: Text[250];
        CharVar: array[32] of Char;

    /// <summary>
    /// Montant en texte.
    /// </summary>
    /// <param name="strprix">VAR Text[250].</param>
    /// <param name="prix">Decimal.</param>
    procedure "Montant en texte"(var strprix: Text[250]; prix: Decimal);
    begin
        entiere := ROUND(prix, 1, '<');
        decimal := ROUND((prix - entiere) * 1000, 1, '=');
        nbre := entiere;
        million := '';
        mille := '';
        cent := '';
        nbre1 := nbre DIV 1000000;
        IF nbre1 <> 0 THEN BEGIN
            Centaine(million, nbre1);
            million := million + ' million';
        END;
        nbre := nbre MOD 1000000;
        nbre1 := nbre DIV 1000;
        IF nbre1 <> 0 THEN BEGIN
            Centaine(mille, nbre1);
            IF mille <> 'un' THEN
                mille := mille + ' mille'
            ELSE
                mille := 'mille'
        END;

        nbre := nbre MOD 1000;

        IF nbre <> 0 THEN BEGIN
            Centaine(cent, nbre);
        END;

        IF million <> '' THEN
            strprix := million;
        IF ((mille <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + mille
        ELSE
            strprix := strprix + mille;
        IF ((cent <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + cent
        ELSE
            strprix := strprix + cent;

        IF entiere > 1 THEN
            strprix := strprix + ' dinars';
        IF entiere = 1 THEN
            strprix := strprix + ' dinar';

        cent := '';
        IF decimal <> 0 THEN BEGIN
            Centaine(cent, decimal);
            IF strprix <> '' THEN
                strprix := strprix + ' ' + cent
            ELSE
                strprix := strprix + cent;
            IF decimal = 1 THEN
                strprix := strprix + ' millime'
            ELSE
                strprix := strprix + ' millimes';
        END;

        strprix := UPPERCASE(strprix);
    end;

    /// <summary>
    /// Centaine.
    /// </summary>
    /// <param name="chaine">VAR Text[250].</param>
    /// <param name="i">Integer.</param>
    procedure Centaine(var chaine: Text[250]; i: Integer);
    var
        k: Integer;
    begin
        k := i DIV 100;
        chaine := '';
        CASE k OF
            1:
                chaine := 'cent';
            2:
                chaine := 'deux cent';
            3:
                chaine := 'trois cent';
            4:
                chaine := 'quatre cent';
            5:
                chaine := 'cinq cent';
            6:
                chaine := 'six cent';
            7:
                chaine := 'sept cent';
            8:
                chaine := 'huit cent';
            9:
                chaine := 'neuf cent';
        END;
        k := i MOD 100;
        Dizaine(chaine, k);
    end;

    /// <summary>
    /// Dizaine.
    /// </summary>
    /// <param name="chaine">VAR Text[250].</param>
    /// <param name="i">Integer.</param>
    procedure Dizaine(var chaine: Text[250]; i: Integer);
    var
        k: Integer;
        l: Integer;
    begin
        IF i > 16 THEN BEGIN
            k := i DIV 10;
            chaine1 := '';
            CASE k OF
                1:
                    chaine1 := 'dix';
                2:
                    chaine1 := 'vingt';
                3:
                    chaine1 := 'trente';
                4:
                    chaine1 := 'quarante';
                5:
                    chaine1 := 'cinquante';
                6:
                    chaine1 := 'soixante';
                7:
                    chaine1 := 'soixante';
                8:
                    chaine1 := 'quatre vingt';
                9:
                    chaine1 := 'quatre vingt';
            END;
            IF ((chaine1 <> '') AND (chaine <> '')) THEN
                chaine1 := ' ' + chaine1;
            chaine := chaine + chaine1;
            l := k;
            IF ((k = 7) OR (k = 9)) THEN
                k := (i MOD 10) + 10
            ELSE
                k := (i MOD 10);
        END
        ELSE
            k := i;

        IF ((l <> 8) AND (l <> 0) AND ((k = 1) OR (k = 11))) THEN
            chaine := chaine + ' et';
        IF (((k = 0) OR (k > 16)) AND ((l = 7) OR (l = 9))) THEN BEGIN
            chaine := chaine + ' dix';
            IF k > 16 THEN
                k := k - 10;
        END;

        Unité(chaine, k);
    end;

    procedure "Unité"(var chaine: Text[250]; i: Integer);
    begin
        chaine1 := '';
        CASE i OF
            1:
                chaine1 := 'un';
            2:
                chaine1 := 'deux';
            3:
                chaine1 := 'trois';
            4:
                chaine1 := 'quatre';
            5:
                chaine1 := 'cinq';
            6:
                chaine1 := 'six';
            7:
                chaine1 := 'sept';
            8:
                chaine1 := 'huit';
            9:
                chaine1 := 'neuf';
            10:
                chaine1 := 'dix';
            11:
                chaine1 := 'onze';
            12:
                chaine1 := 'douze';
            13:
                chaine1 := 'treize';
            14:
                chaine1 := 'quatorze';
            15:
                chaine1 := 'quinze';
            16:
                chaine1 := 'seize';
        END;
        IF ((chaine1 <> '') AND (chaine <> '')) THEN
            chaine1 := ' ' + chaine1;
        chaine := chaine + chaine1;
    end;

    /// <summary>
    /// Montant en texte sans millimes.
    /// </summary>
    /// <param name="strprix">VAR Text[250].</param>
    /// <param name="prix">Decimal.</param>
    procedure "Montant en texte sans millimes"(var strprix: Text[250]; prix: Decimal);
    begin
        entiere := ROUND(prix, 1, '<');
        decimal := ROUND((prix - entiere) * 1000, 1, '<');

        nbre := entiere;
        //Chèque.FormatNumTexte(strprix,nbre);

        million := '';
        mille := '';
        cent := '';

        nbre1 := nbre DIV 1000000;
        IF nbre1 <> 0 THEN BEGIN
            Centaine(million, nbre1);
            million := million + ' million';
        END;

        nbre := nbre MOD 1000000;
        nbre1 := nbre DIV 1000;
        IF nbre1 <> 0 THEN BEGIN
            Centaine(mille, nbre1);
            IF mille <> 'un' THEN
                mille := mille + ' mille'
            ELSE
                mille := 'mille'
        END;

        nbre := nbre MOD 1000;

        IF nbre <> 0 THEN BEGIN
            Centaine(cent, nbre);
        END;

        IF million <> '' THEN
            strprix := million;
        IF ((mille <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + mille
        ELSE
            strprix := strprix + mille;
        IF ((cent <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + cent
        ELSE
            strprix := strprix + cent;

        IF entiere > 1 THEN
            strprix := strprix + ' dinars';
        IF entiere = 1 THEN
            strprix := strprix + ' dinar';

        IF decimal <> 0 THEN BEGIN
            IF strprix <> '' THEN
                strprix := strprix + ' ' + FORMAT(decimal)
            ELSE
                strprix := strprix + FORMAT(decimal);
            IF decimal = 1 THEN
                strprix := strprix + ' millime'
            ELSE
                strprix := strprix + ' millimes';
        END;

        strprix := UPPERCASE(strprix);
    end;

    /// <summary>
    /// Montant en texteDevise.
    /// </summary>
    /// <param name="strprix">VAR Text[250].</param>
    /// <param name="prix">Decimal.</param>
    /// <param name="Devise">Text[30].</param>
    procedure "Montant en texteDevise"(var strprix: Text[250]; prix: Decimal; Devise: Text[30]);
    begin
        QuelleDevise(Devise, 0);
        entiere := ROUND(prix, 1, '<');
        decimal := ROUND((prix - entiere) * 100, 1, '<');
        nbre := entiere;
        million := '';
        mille := '';
        cent := '';
        nbre1 := nbre DIV 1000000;
        IF nbre1 <> 0 THEN BEGIN
            Centaine(million, nbre1);
            million := million + ' million';
        END;
        nbre := nbre MOD 1000000;
        nbre1 := nbre DIV 1000;
        IF nbre1 <> 0 THEN BEGIN
            Centaine(mille, nbre1);
            IF mille <> 'un' THEN
                mille := mille + ' mille'
            ELSE
                mille := 'mille'
        END;

        nbre := nbre MOD 1000;

        IF nbre <> 0 THEN BEGIN
            Centaine(cent, nbre);
        END;

        IF million <> '' THEN
            strprix := million;
        IF ((mille <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + mille
        ELSE
            strprix := strprix + mille;
        IF ((cent <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + cent
        ELSE
            strprix := strprix + cent;

        IF entiere > 1 THEN
            strprix := strprix + ' ' + VarDeviseEntiere;
        IF entiere = 1 THEN
            strprix := strprix + ' ' + VarDeviseEntiere;

        cent := '';
        IF decimal <> 0 THEN BEGIN
            Centaine(cent, decimal);
            IF strprix <> '' THEN
                strprix := strprix + ' ' + cent
            ELSE
                strprix := strprix + cent;
            IF decimal = 1 THEN
                strprix := strprix + ' ' + VarDeviseDecimal
            ELSE
                strprix := strprix + ' ' + VarDeviseDecimal;



        END;

        strprix := UPPERCASE(strprix);
    end;

    /// <summary>
    /// QuelleDevise.
    /// </summary>
    /// <param name="StrDevise">VAR Text[30].</param>
    /// <param name="lng">Integer.</param>
    procedure QuelleDevise(var StrDevise: Text[30]; lng: Integer);
    begin

        IF StrDevise = 'USD' THEN
            CASE lng OF
                1033:
                    BEGIN
                        VarDeviseEntiere := 'US Dollars';
                        VarDeviseDecimal := 'Cents';
                    END;
                ELSE BEGIN
                        VarDeviseEntiere := 'Dollars US';
                        VarDeviseDecimal := 'Cents';
                    END;
            END;

        IF StrDevise = 'EUR' THEN
            CASE lng OF
                1033:
                    BEGIN
                        VarDeviseEntiere := 'Euro';
                        VarDeviseDecimal := 'EuroCents';
                    END;
                ELSE BEGIN
                        VarDeviseEntiere := 'Euro';
                        VarDeviseDecimal := 'Centimes';
                    END;
            END;
        IF StrDevise = 'JPY' THEN
            CASE lng OF
                1033:
                    BEGIN
                        VarDeviseEntiere := 'YEN';
                        VarDeviseDecimal := 'Cents';
                    END;
                ELSE BEGIN
                        VarDeviseEntiere := 'YEN';
                        VarDeviseDecimal := 'Centimes';
                    END;
            END;
        IF StrDevise = 'EURO' THEN
            CASE lng OF
                1033:
                    BEGIN
                        VarDeviseEntiere := 'Euro';
                        VarDeviseDecimal := 'EuroCents';
                    END;
                ELSE BEGIN
                        VarDeviseEntiere := 'Euro';
                        VarDeviseDecimal := 'Centimes';
                    END;
            END;
        IF StrDevise = 'EUR DOM.' THEN
            CASE lng OF
                1033:
                    BEGIN
                        VarDeviseEntiere := 'Euro';
                        VarDeviseDecimal := 'EuroCents';
                    END;
                ELSE BEGIN
                        VarDeviseEntiere := 'Euro';
                        VarDeviseDecimal := 'Centimes';
                    END;
            END;

        IF StrDevise = '£' THEN
            CASE lng OF
                1033:
                    BEGIN
                        VarDeviseEntiere := 'Pounds';
                        VarDeviseDecimal := 'Cents';
                    END;
                ELSE BEGIN
                        VarDeviseEntiere := 'Livres Sterling';
                        VarDeviseDecimal := 'Cents';
                    END;
            END;
    end;

    /// <summary>
    /// MontantTexteLangue.
    /// </summary>
    /// <param name="strprix">VAR Text[250].</param>
    /// <param name="prix">Decimal.</param>
    /// <param name="lng">Integer.</param>
    procedure MontantTexteLangue(var strprix: Text[250]; prix: Decimal; lng: Integer);
    begin
        entiere := ROUND(prix, 1, '<');
        decimal := ROUND((prix - entiere) * 1000, 1, '<');
        nbre := entiere;
        million := '';
        mille := '';
        cent := '';
        nbre1 := nbre DIV 1000000;
        IF nbre1 <> 0 THEN BEGIN
            CentaineLangue(million, nbre1, lng);
            CASE lng OF
                1033:
                    million := million + ' million';
                ELSE
                    million := million + ' million';
            END;
        END;

        nbre := nbre MOD 1000000;
        nbre1 := nbre DIV 1000;
        IF nbre1 <> 0 THEN BEGIN
            CentaineLangue(mille, nbre1, lng);
            IF mille <> 'un' THEN
                CASE lng OF
                    1033:
                        mille := mille + ' thousand';
                    ELSE
                        mille := mille + ' mille';
                END
            ELSE
                mille := 'mille'
        END;

        nbre := nbre MOD 1000;

        IF nbre <> 0 THEN BEGIN
            CentaineLangue(cent, nbre, lng);
        END;

        IF million <> '' THEN
            strprix := million;
        IF ((mille <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + mille
        ELSE
            strprix := strprix + mille;
        IF ((cent <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + cent
        ELSE
            strprix := strprix + cent;

        IF entiere > 1 THEN
            strprix := strprix + ' dinars';
        IF entiere = 1 THEN
            strprix := strprix + ' dinar';

        cent := '';
        IF decimal <> 0 THEN BEGIN
            CentaineLangue(cent, decimal, lng);
            IF strprix <> '' THEN
                strprix := strprix + ' ' + cent
            ELSE
                strprix := strprix + cent;
            IF decimal = 1 THEN
                strprix := strprix + ' millime'
            ELSE
                strprix := strprix + ' millimes';
        END;

        strprix := UPPERCASE(strprix);
    end;

    /// <summary>
    /// MontantTexteDeviseLangue.
    /// </summary>
    /// <param name="strprix">VAR Text[250].</param>
    /// <param name="prix">Decimal.</param>
    /// <param name="Devise">Text[30].</param>
    /// <param name="lng">Integer.</param>
    procedure MontantTexteDeviseLangue(var strprix: Text[250]; prix: Decimal; Devise: Text[30]; lng: Integer);
    begin
        QuelleDevise(Devise, lng);
        entiere := ROUND(prix, 1, '<');
        decimal := ROUND((prix - entiere) * 100, 1, '<');

        nbre := entiere;
        million := '';
        mille := '';
        cent := '';

        nbre1 := nbre DIV 1000000;
        IF nbre1 <> 0 THEN BEGIN
            CentaineLangue(million, nbre1, lng);
            CASE lng OF
                1033:
                    million := million + ' million';
                ELSE
                    million := million + ' million';
            END;
        END;

        nbre := nbre MOD 1000000;
        nbre1 := nbre DIV 1000;
        IF nbre1 <> 0 THEN BEGIN
            CentaineLangue(mille, nbre1, lng);
            IF mille <> 'un' THEN
                CASE lng OF
                    1033:
                        mille := mille + ' thousand';
                    ELSE
                        mille := mille + ' mille';
                END
            ELSE
                mille := 'mille'
        END;

        nbre := nbre MOD 1000;

        IF nbre <> 0 THEN BEGIN
            CentaineLangue(cent, nbre, lng);
        END;

        IF million <> '' THEN
            strprix := million;
        IF ((mille <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + mille
        ELSE
            strprix := strprix + mille;
        IF ((cent <> '') AND (strprix <> '')) THEN
            strprix := strprix + ' ' + cent
        ELSE
            strprix := strprix + cent;

        IF entiere > 1 THEN
            strprix := strprix + ' ' + VarDeviseEntiere;
        IF entiere = 1 THEN
            strprix := strprix + ' ' + VarDeviseEntiere;

        cent := '';
        IF decimal <> 0 THEN BEGIN
            CentaineLangue(cent, decimal, lng);
            IF strprix <> '' THEN
                strprix := strprix + ' ' + cent
            ELSE
                strprix := strprix + cent;
            IF decimal = 1 THEN
                strprix := strprix + ' ' + VarDeviseDecimal
            ELSE
                strprix := strprix + ' ' + VarDeviseDecimal;



        END;

        strprix := UPPERCASE(strprix);
    end;

    /// <summary>
    /// CentaineLangue.
    /// </summary>
    /// <param name="chaine">VAR Text[250].</param>
    /// <param name="i">Integer.</param>
    /// <param name="lng">Integer.</param>
    procedure CentaineLangue(var chaine: Text[250]; i: Integer; lng: Integer);
    var
        k: Integer;
    begin
        k := i DIV 100;
        chaine := '';
        CASE lng OF
            1033:
                BEGIN
                    CASE k OF
                        1:
                            chaine := 'one hundred';
                        2:
                            chaine := 'two hundred';
                        3:
                            chaine := 'three hundred';
                        4:
                            chaine := 'four hundred';
                        5:
                            chaine := 'five hundred';
                        6:
                            chaine := 'six hundred';
                        7:
                            chaine := 'seven hundred';
                        8:
                            chaine := 'height hundred';
                        9:
                            chaine := 'nine hundred';
                    END;
                END;
            ELSE BEGIN
                    CASE k OF
                        1:
                            chaine := 'cent';
                        2:
                            chaine := 'deux cent';
                        3:
                            chaine := 'trois cent';
                        4:
                            chaine := 'quatre cent';
                        5:
                            chaine := 'cinq cent';
                        6:
                            chaine := 'six cent';
                        7:
                            chaine := 'sept cent';
                        8:
                            chaine := 'huit cent';
                        9:
                            chaine := 'neuf cent';
                    END;
                END;
        END;
        k := i MOD 100;
        DizaineLangue(chaine, k, lng);
    end;

    /// <summary>
    /// DizaineLangue.
    /// </summary>
    /// <param name="chaine">VAR Text[250].</param>
    /// <param name="i">Integer.</param>
    /// <param name="lng">Integer.</param>
    procedure DizaineLangue(var chaine: Text[250]; i: Integer; lng: Integer);
    var
        k: Integer;
        l: Integer;
    begin
        CASE lng OF
            1033:
                BEGIN
                    IF i > 19 THEN BEGIN
                        k := i DIV 10;
                        chaine1 := '';
                        CASE k OF
                            1:
                                chaine1 := 'ten';
                            2:
                                chaine1 := 'twenty';
                            3:
                                chaine1 := 'thirty';
                            4:
                                chaine1 := 'fourty';
                            5:
                                chaine1 := 'fivety';
                            6:
                                chaine1 := 'sixty';
                            7:
                                chaine1 := 'seventy';
                            8:
                                chaine1 := 'heighty';
                            9:
                                chaine1 := 'ninety';
                        END;
                        IF ((chaine1 <> '') AND (chaine <> '')) THEN
                            chaine1 := ' ' + chaine1;
                        chaine := chaine + chaine1;
                        l := k;
                        k := (i MOD 10);
                    END
                    ELSE
                        k := i;

                    IF ((l <> 8) AND (l <> 0) AND ((k = 11) OR (k = 11))) THEN
                        chaine := chaine + ' and';
                    IF (((k = 0) OR (k > 19)) AND ((l = 7) OR (l = 9))) THEN BEGIN
                        chaine := chaine + ' dix';
                        IF k > 19 THEN
                            k := k - 10;
                    END;
                END;
            ELSE BEGIN
                    IF i > 16 THEN BEGIN
                        k := i DIV 10;
                        chaine1 := '';
                        CASE k OF
                            1:
                                chaine1 := 'dix';
                            2:
                                chaine1 := 'vingt';
                            3:
                                chaine1 := 'trente';
                            4:
                                chaine1 := 'quarante';
                            5:
                                chaine1 := 'cinquante';
                            6:
                                chaine1 := 'soixante';
                            7:
                                chaine1 := 'soixante';
                            8:
                                chaine1 := 'quatre vingt';
                            9:
                                chaine1 := 'quatre vingt';
                        END;
                        IF ((chaine1 <> '') AND (chaine <> '')) THEN
                            chaine1 := ' ' + chaine1;
                        chaine := chaine + chaine1;
                        l := k;
                        IF ((k = 7) OR (k = 9)) THEN
                            k := (i MOD 10) + 10
                        ELSE
                            k := (i MOD 10);
                    END
                    ELSE
                        k := i;

                    IF ((l <> 8) AND (l <> 0) AND ((k = 1) OR (k = 11))) THEN
                        chaine := chaine + ' et';
                    IF (((k = 0) OR (k > 16)) AND ((l = 7) OR (l = 9))) THEN BEGIN
                        chaine := chaine + ' dix';
                        IF k > 16 THEN
                            k := k - 10;
                    END;
                END;
        END;
        UnitéLangue(chaine, k, lng);
    end;

    /// <summary>
    /// UnitéLangue.
    /// </summary>
    /// <param name="chaine">VAR Text[250].</param>
    /// <param name="i">Integer.</param>
    /// <param name="lng">Integer.</param>
    procedure "UnitéLangue"(var chaine: Text[250]; i: Integer; lng: Integer);
    begin
        chaine1 := '';
        CASE lng OF
            1033:
                CASE i OF
                    1:
                        chaine1 := 'one';
                    2:
                        chaine1 := 'two';
                    3:
                        chaine1 := 'three';
                    4:
                        chaine1 := 'four';
                    5:
                        chaine1 := 'five';
                    6:
                        chaine1 := 'six';
                    7:
                        chaine1 := 'seven';
                    8:
                        chaine1 := 'height';
                    9:
                        chaine1 := 'nine';
                    10:
                        chaine1 := 'ten';
                    11:
                        chaine1 := 'eleven';
                    12:
                        chaine1 := 'twelve';
                    13:
                        chaine1 := 'thirteen';
                    14:
                        chaine1 := 'fourteen';
                    15:
                        chaine1 := 'fifteen';
                    16:
                        chaine1 := 'sixteen';
                    17:
                        chaine1 := 'seventeen';
                    18:
                        chaine1 := 'heighteen';
                    19:
                        chaine1 := 'ninteen';
                END;
            ELSE
                CASE i OF
                    1:
                        chaine1 := 'un';
                    2:
                        chaine1 := 'deux';
                    3:
                        chaine1 := 'trois';
                    4:
                        chaine1 := 'quatre';
                    5:
                        chaine1 := 'cinq';
                    6:
                        chaine1 := 'six';
                    7:
                        chaine1 := 'sept';
                    8:
                        chaine1 := 'huit';
                    9:
                        chaine1 := 'neuf';
                    10:
                        chaine1 := 'dix';
                    11:
                        chaine1 := 'onze';
                    12:
                        chaine1 := 'douze';
                    13:
                        chaine1 := 'treize';
                    14:
                        chaine1 := 'quatorze';
                    15:
                        chaine1 := 'quinze';
                    16:
                        chaine1 := 'seize';
                END;
        END;
        IF ((chaine1 <> '') AND (chaine <> '')) THEN
            chaine1 := ' ' + chaine1;
        chaine := chaine + chaine1;
    end;

    /// <summary>
    /// Ansi2Ascii.
    /// </summary>
    /// <param name="_Text">Text[250].</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure Ansi2Ascii(_Text: Text[250]): Text[250];
    begin
        MakeVars;
        EXIT(CONVERTSTR(_Text, AnsiStr, AsciiStr));
    end;

    /// <summary>
    /// Ascii2Ansi.
    /// </summary>
    /// <param name="_Text">Text[250].</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure Ascii2Ansi(_Text: Text[250]): Text[250];
    begin
        MakeVars;
        EXIT(CONVERTSTR(_Text, AsciiStr, AnsiStr));
    end;

    /// <summary>
    /// MakeVars.
    /// </summary>
    procedure MakeVars();
    begin
        AsciiStr := 'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜø£Ø×ƒáíóúñÑªº¿®¬½¼¡«»¦¦¦¦¦ÁÂÀ©¦¦++¢¥++--+-+ãÃ++--¦-+';
        AsciiStr := AsciiStr + '¤ðÐÊËÈiÍÎÏ++¦_¦Ì¯ÓßÔÒõÕµþÞÚÛÙýÝ¯´­±=¾¶§÷¸°¨·¹³²¦ ';
        CharVar[1] := 196;
        CharVar[2] := 197;
        CharVar[3] := 201;
        CharVar[4] := 242;
        CharVar[5] := 220;
        CharVar[6] := 186;
        CharVar[7] := 191;
        CharVar[8] := 188;
        CharVar[9] := 187;
        CharVar[10] := 193;
        CharVar[11] := 194;
        CharVar[12] := 192;
        CharVar[13] := 195;
        CharVar[14] := 202;
        CharVar[15] := 203;
        CharVar[16] := 200;
        CharVar[17] := 205;
        CharVar[18] := 206;
        CharVar[19] := 204;
        CharVar[20] := 175;
        CharVar[21] := 223;
        CharVar[22] := 213;
        CharVar[23] := 254;
        CharVar[24] := 218;
        CharVar[25] := 219;
        CharVar[26] := 217;
        CharVar[27] := 180;
        CharVar[28] := 177;
        CharVar[29] := 176;
        CharVar[30] := 185;
        CharVar[31] := 179;
        CharVar[32] := 178;
        AnsiStr := 'Ã³ÚÔõÓÕþÛÙÞ´¯ý' + FORMAT(CharVar[1]) + FORMAT(CharVar[2]) + FORMAT(CharVar[3]) + 'µã¶÷' + FORMAT(CharVar[4]);
        AnsiStr := AnsiStr + '¹¨ Í' + FORMAT(CharVar[5]) + '°úÏÎâßÝ¾·±Ð¬' + FORMAT(CharVar[6]) + FORMAT(CharVar[7]);
        AnsiStr := AnsiStr + '«¼¢' + FORMAT(CharVar[8]) + 'í½' + FORMAT(CharVar[9]) + '___ªª' + FORMAT(CharVar[10]) + FORMAT(CharVar[11]);
        AnsiStr := AnsiStr + FORMAT(CharVar[12]) + '®ªª++óÑ++--+-+Ò' + FORMAT(CharVar[13]) + '++--ª-+ñ­ð';
        AnsiStr := AnsiStr + FORMAT(CharVar[14]) + FORMAT(CharVar[15]) + FORMAT(CharVar[16]) + 'i' + FORMAT(CharVar[17]) + FORMAT(CharVar[18]);
        AnsiStr := AnsiStr + '¤++__ª' + FORMAT(CharVar[19]) + FORMAT(CharVar[20]) + 'Ë' + FORMAT(CharVar[21]) + 'ÈÊ§';
        AnsiStr := AnsiStr + FORMAT(CharVar[22]) + 'Á' + FORMAT(CharVar[23]) + 'Ì' + FORMAT(CharVar[24]) + FORMAT(CharVar[25]);
        AnsiStr := AnsiStr + FORMAT(CharVar[26]) + '²¦»' + FORMAT(CharVar[27]) + '¡' + FORMAT(CharVar[28]) + '=¥Âº¸©' + FORMAT(CharVar[29]);
        AnsiStr := AnsiStr + '¿À' + FORMAT(CharVar[30]) + FORMAT(CharVar[31]) + FORMAT(CharVar[32]) + '_ ';
    end;
}


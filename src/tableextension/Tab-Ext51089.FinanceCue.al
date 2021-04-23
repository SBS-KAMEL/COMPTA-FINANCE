/// <summary>
/// TableExtension Finance Cue (ID 51089) extends Record Finance Cue.
/// </summary>
tableextension 51089 "Finance Cue" extends "Finance Cue"
{
    fields
    {
        //_______________________Fournisseur
        field(51080; "Chèque Frs en coffre"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('DEC-CHQ'), "Status No." = filter(30000), "Copied To No." = filter('')));
        }
        field(51081; "Chèque Frs Remis"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('DEC-CHQ'), "Status No." = filter(40000), "Copied To No." = filter('')));
        }
        field(51082; "Chèque Frs Impayé"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('DEC-CHQ'), "Status No." = filter(60000), "Copied To No." = filter('')));
        }
        //__________________________Client
        field(51083; "Chèque Client en coffre"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-CHQ'), "Status No." = filter(20000), "Copied To No." = filter('')));
        }
        field(51084; "Chèque Client impayé"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-CHQ'), "Status No." = filter(70000), "Copied To No." = filter('')));
        }
        field(51085; "Effet Client en coffre"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-EFFET'), "Status No." = filter(30000), "Copied To No." = filter('')));
        }
        field(51086; "Effet Encaissé"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-EFFET'), "Status No." = filter(60000), "Copied To No." = filter('')));
        }
        field(51087; "Effet Escompté"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-EFFET'), "Status No." = filter(80000), "Copied To No." = filter('')));
        }
        field(51088; "Effet Client Impayé"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-EFFET'), "Status No." = filter(130000), "Copied To No." = filter('')));
        }
        field(51089; "Espèce en Coffre"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = - sum("Payment Line"."Amount (LCY)" WHERE("Payment Class" = filter('ENC-ESP'), "Status No." = filter(20000), "Copied To No." = filter('')));
        }
        field(51090; "Effet Frs en coffre"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('DEC-EFFET'), "Status No." = filter(30000), "Copied To No." = filter('')));
        }
        field(51091; "Effet Frs Remis"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('DEC-EFFET'), "Status No." = filter(40000), "Copied To No." = filter('')));
        }
        field(51092; "Effet Frs Impayé"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('DEC-EFFET'), "Status No." = filter(60000), "Copied To No." = filter('')));
        }
        field(51093; "Bord. versement Chq"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-CHQ'), "Status No." = filter(90000), "Copied To No." = filter('')));
        }
        field(51094; "Déch. Effe - Encaiss"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-EFFET'), "Status No." = filter(160000), "Copied To No." = filter('')));
        }
        field(51095; "Déch. Effe - Escpt"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-EFFET'), "Status No." = filter(150000), "Copied To No." = filter('')));
        }
        field(51096; "Déch. espècé versé"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-ESP'), "Status No." = filter(60000), "Copied To No." = filter('')));
        }
        field(51097; "Chèque de garantie"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-CHQ'), "Status No." = filter(240000), "Copied To No." = filter('')));
        }
        field(51098; "Chèque Chez commercial"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Payment Line" WHERE("Payment Class" = filter('ENC-CHQ'), "Status No." = filter(120000), "Copied To No." = filter('')));
        }
        field(51099; "Espèce Chez commercial"; Decimal)
        {
            FieldClass = FlowField;

            CalcFormula = - sum("Payment Line"."Amount (LCY)" WHERE("Payment Class" = filter('ENC-ESP'), "Status No." = filter(70000), "Copied To No." = filter('')));
        }

    }

    var
        myInt: Integer;

}
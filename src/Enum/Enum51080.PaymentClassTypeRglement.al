/// <summary>
/// Enum Payment Class: Type Réglement (ID 51080).
/// </summary>
enum 51080 "Payment Class: Type Réglement"
{
    Extensible = true;

    value(0; " ")
    {
    }

    value(1; "Check")
    {
        Caption = 'Chèque', Comment = 'FRA= Chèque, ENU= Check';
    }
    value(2; "Draft")
    {
        Caption = 'Effet', Comment = 'FRA= Traite, ENU= Draft';
    }
    value(3; transfer)
    {
        Caption = 'Virement', Comment = 'FRA= Virement, ENU= Transfer';
    }
    value(4; Species)
    {
        Caption = 'Espèce', Comment = 'FRA= Espèce, ENU= Cash';
    }
    value(5; LettreC)
    {
        Caption = 'Lettre de crédit', Comment = 'FRA= Lettre de crédit, ENU= LettreC';
    }
    value(6; Other)
    {
        Caption = 'Autre ', Comment = 'FRA= Autre, ENU= Other';
    }
    value(7; TPE)
    {
        Caption = 'TPE', Comment = 'FRA= TPE, ENU= TPE';
    }
    value(8; Deduction)
    {
        Caption = 'Retenue à la Source', Comment = 'FRA= Retenue à la Source, ENU= Deduction';
    }
    value(9; "VAT Deduction")
    {
        Caption = 'Retenue TVA', Comment = 'FRA= Retenue TVA, ENU= VAT Deduction';
    }
}
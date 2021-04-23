/// <summary>
/// Page Autorisation Type de règlement (ID 51086).
/// </summary>
page 51086 "Autorisation Type de règlement"
{

    ApplicationArea = All;
    Caption = 'Autorisation Type de règlement';
    PageType = List;
    SourceTable = "Autorisation Type de reglement";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code utilisateur"; Rec."Code utilisateur")
                {
                    ToolTip = 'Specifies the value of the Code utilisateur field';
                    ApplicationArea = All;
                }
                field("Type de règlement"; Rec."Type de règlement")
                {
                    ToolTip = 'Specifies the value of the Type de règlement field';
                    ApplicationArea = All;
                }
            }
        }
    }

}

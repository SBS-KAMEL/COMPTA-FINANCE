/// <summary>
/// Page Autorisation Etape (ID 51087).
/// </summary>
page 51087 "Autorisation Etape"
{

    ApplicationArea = All;
    Caption = 'Autorisation Etape';
    PageType = List;
    SourceTable = "Autorisation Etape";
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
                field("No. Etape"; Rec."No. Etape")
                {
                    ToolTip = 'Specifies the value of the No. Etape field';
                    ApplicationArea = All;
                }
                field("Nom Etape"; Rec."Nom Etape")
                {
                    ToolTip = 'Specifies the value of the Nom Etape field';
                    ApplicationArea = All;
                }
            }
        }
    }

}

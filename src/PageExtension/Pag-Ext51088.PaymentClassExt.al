/// <summary>
/// PageExtension Payment Class Ext (ID 51088) extends Record Payment Class.
/// </summary>
pageextension 51088 "Payment Class Ext" extends "Payment Class"
{
    layout
    {
        // Add changes to page layout here
        addafter(Name)
        {
            field("Type Réglement"; Rec."Type Réglement")
            {
                ApplicationArea = All;
            }

            field(Reclassement; Rec.Reclassement)
            {
                ApplicationArea = All;
            }
            field("Affectation Utisateur"; AffectationUser)
            {
                trigger OnAssistEdit()
                var
                    RecAutorisationType: Record "Autorisation Type de reglement";
                begin
                    RecAutorisationType.SETRANGE("Type de règlement", Code);
                    PAGE.RUNMODAL(51086, RecAutorisationType);
                end;
            }

        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
        AffectationUser: code[20];
}
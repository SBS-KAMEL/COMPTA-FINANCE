/// <summary>
/// Page ListeGroupeRetenue (ID 51080).
/// </summary>
page 51080 "ListeGroupeRetenue"
{
    Caption = 'ListeGroupeRetenue';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Groupe Retenue";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code Retenue"; "Code Retenue")
                {
                    ApplicationArea = All;
                }
                field(Designation; Designation)
                {
                    ApplicationArea = All;
                }
                field("Type Retenue"; "Type Retenue")
                {
                    ApplicationArea = All;
                }
                field("% Retenue"; "% Retenue")
                {
                    ApplicationArea = All;
                }
                field(Proposition; Proposition)
                {
                    ApplicationArea = All;
                }
                field("Compte Retenue"; "Compte Retenue")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}
pageextension 51080 "General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        addafter(Application)
        {
            group("Standard TN")
            {
                field("Plafond Mnt Exonoration"; "Plafond Mnt Exonoration")
                {
                    ApplicationArea = All;
                }
                field("Code retenue par defaut"; "Code retenue par defaut")
                {
                    ApplicationArea = All;
                }
            }
        }

    }


    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
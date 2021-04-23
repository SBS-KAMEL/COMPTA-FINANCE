/// <summary>
/// Table Groupe Retenue (ID 51080).
/// </summary>
table 51080 "Groupe Retenue"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = ListeGroupeRetenue;
    LookupPageId = ListeGroupeRetenue;
    Permissions = tabledata 18 = rm;
    fields
    {
        field(1; "Code Retenue"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Deduction Code', comment = 'FRA="Code Retenue"';
        }
        field(2; "Designation"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(3; "% Retenue"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Compte Retenue"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";

        }
        field(5; "Type Retenue"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "à la source","de garantie";

        }
        field(6; "Proposition"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "","Clients","Fournisseurs","Salarié";

        }
        field(7; "Annexe"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","I","II","III","VI","V";
        }
        field(8; "Pos. mnt Brut dans Annexe"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Sous Pos. mnt Brut ds  Annexe"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Activé"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Ristourne"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Activé R.S"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Date Début Activation"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Priorité"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "0","1";
        }
    }

    keys
    {
        key(PK; "Code Retenue")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;
}
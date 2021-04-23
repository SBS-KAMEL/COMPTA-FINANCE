/// <summary>
/// Table Autorisation Etape de règlement (ID 51082).
/// </summary>
table 51082 "Autorisation Etape"
{
    Caption = 'Autorisation Etape de règlement';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No. Etape"; Integer)
        {
            Caption = 'No. Etape';
            DataClassification = ToBeClassified;
        }
        field(2; "Code utilisateur"; Code[50])
        {
            Caption = 'Code utilisateur';
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";
        }
        field(3; "Type de règlement"; Code[20])
        {
            Caption = 'Type de règlement';
            DataClassification = ToBeClassified;
        }
        field(4; "Nom Etape"; Text[50])
        {
            Caption = 'Nom Etape';
            FieldClass = FlowField;
            CalcFormula = Lookup("Payment Step".Name WHERE("Payment Class" = FIELD("Type de règlement"), Line = FIELD("No. Etape")));
        }
    }
    keys
    {
        key(PK; "No. Etape", "Type de règlement", "Code utilisateur")
        {
            Clustered = true;
        }
    }

}

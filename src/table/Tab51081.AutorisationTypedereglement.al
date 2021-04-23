/// <summary>
/// Table Autorisation Type de reglement (ID 51081).
/// </summary>
table 51081 "Autorisation Type de reglement"
{
    Caption = 'Autorisation Type de reglement';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code utilisateur"; Code[50])
        {
            Caption = 'Code utilisateur';
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";
        }
        field(2; "Type de règlement"; Code[20])
        {
            Caption = 'Type de règlement';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Code utilisateur", "Type de règlement")
        {
            Clustered = true;
        }
    }

}

tableextension 51080 "Vendor" extends Vendor
{
    fields
    {
        // Add changes to table fields here
        field(51080; "Exonoré RS"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51081; "Fin Exonoration"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(51082; "Code retenue RS"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Groupe Retenue";
        }
    }
}
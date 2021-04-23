/// <summary>
/// TableExtension Payment Class (ID 51092) extends Record Payment Class.
/// </summary>
tableextension 51092 "Payment Class" extends "Payment Class"
{
    fields
    {
        field(51000; "Type Réglement"; Enum "Payment Class: Type Réglement")
        {
            Caption = 'Payment Class', Comment = 'FRA=Type Réglement, ENU= Payment Class';
            DataClassification = ToBeClassified;
        }
        field(51001; Reclassement; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Reclassement', Comment = 'FRA=Reclassement, ENU= Reclassement';
        }
    }
}

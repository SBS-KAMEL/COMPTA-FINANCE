/// <summary>
/// TableExtension MyExtension (ID 51094) extends Record MyTargetTable.
/// </summary>
tableextension 51094 "Employee" extends Employee
{
    fields
    {
        // Add changes to table fields here
        field(51080; Recouvreur; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }


    var
        myInt: Integer;
}
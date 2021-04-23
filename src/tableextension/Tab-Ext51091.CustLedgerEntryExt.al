/// <summary>
/// TableExtension Cust. Ledger Entry Ext (ID 51091) extends Record Cust. Ledger Entry.
/// </summary>
tableextension 51091 "Cust. Ledger Entry Ext" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50000; "External Reference"; Text[50])
        {
            Caption = 'External Reference', Comment = 'FRA = Référence externe ENU = External Reference';
            DataClassification = ToBeClassified;
        }
    }
}
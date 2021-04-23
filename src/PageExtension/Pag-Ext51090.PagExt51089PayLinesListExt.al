/// <summary>
/// PageExtension Pag-Ext51089.PayLinesListExt (ID 51090) extends Record Payment Lines List.
/// </summary>
pageextension 51090 "PayLinesListExt" extends "Payment Lines List"
{
    layout
    {
        addafter(Control1)
        {
            group(Total)
            {
                //SumPayLine: Decimal;
            }
        }
    }
    var
        //SumPayLine: Decimal;
        PaymentLine: Record "Payment Line";
}

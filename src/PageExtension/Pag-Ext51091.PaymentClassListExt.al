/// <summary>
/// PageExtension Payment Class List Ext (ID 51091) extends Record Payment Class List.
/// </summary>
pageextension 51091 "Payment Class List Ext" extends "Payment Class List"
{
    trigger OnOpenPage()
    var
        RecAutoTypeReg: Record "Autorisation Type de reglement";
    begin
        RecAutoTypeReg.RESET;
        RecAutoTypeReg.SETRANGE("Code utilisateur", USERID);
        IF RecAutoTypeReg.ISEMPTY THEN ERROR('Aucun Type de paiement n est autorisé');
        IF FINDFIRST THEN
            REPEAT
                IF RecAutoTypeReg.GET(USERID, Code) THEN
                    MARK(TRUE);
                MODIFY;
            UNTIL NEXT = 0;
        MARKEDONLY(TRUE);
    end;
}

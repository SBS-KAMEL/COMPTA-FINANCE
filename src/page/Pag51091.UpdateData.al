/// <summary>
/// Page "UpdateData" (ID 51091).
/// </summary>
page 51091 UpdateData
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    //SourceTable = "Sales Invoice Header";
    Permissions = tabledata 112 = RIMD;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                // field("Sell-to Customer No."; "Sell-to Customer No.")
                // {
                //     ApplicationArea = All;

                // }
                // field("Sell-to Customer Name"; "Sell-to Customer Name")
                // {
                //     ApplicationArea = All;

                // }
                field(tableNo; tableNo)
                {
                    ApplicationArea = All;
                    // TableRelation = Object.ID where(Type = const(Table));

                }
                field(fieldNo; fieldNo)
                {
                    ApplicationArea = All;
                    TableRelation = Field."No.";
                }
                field(keyvalueCodeG; keyvalueCodeG)
                {
                    ApplicationArea = All;

                }
                field(keyValueIntG; keyValueIntG)
                {
                    ApplicationArea = All;

                }
                field(newvalueTextG; newvalueTextG)
                {
                    ApplicationArea = All;

                }
                field(newvalueCodeG; newvalueCodeG)
                {
                    ApplicationArea = All;

                }
                field(newvalueIntG; newvalueIntG)
                {
                    ApplicationArea = All;

                }
                field(newvalueDecG; newvalueDecG)
                {
                    ApplicationArea = All;

                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    updatethis();
                end;
            }
        }
    }

    var
        myInt: Integer;
        RecordRefG: recordref;
        FieldRefG: FieldRef;
        tableNo: Integer;
        fieldNo: Integer;
        newvalueCodeG: Code[50];
        newvalueTextG: Text[250];
        newvalueIntG: Integer;
        newvalueDecG: Decimal;
        keyvalueCodeG: Code[50];
        keyValueIntG: Integer;
        fieldref2G: FieldRef;
        actualKeyValueCodeG: Code[50];
        actualKeyValueIntG: Integer;

    local procedure updatethis()
    var
        ObjectL: Record Object;
    begin
        RecordRefG.Open(tableNo);

        RecordRefG.FindSet();
        repeat

            fieldref2G := RecordRefG.Field(1);
            if FieldRef2G.Type = fieldref2G.Type::Code then
                Evaluate(actualKeyValueCodeG, fieldref2G.Value)
            else
                if FieldRef2G.Type = fieldref2G.Type::Integer then
                    Evaluate(actualKeyValueIntG, fieldref2G.Value);

            if ((keyvalueCodeG = actualKeyValueCodeG) and (keyvalueCodeG <> '')) or ((keyValueIntG = actualKeyValueIntG) and (keyValueIntG <> 0)) then begin
                FieldRefG := RecordRefG.Field(fieldNo);
                if not FieldRefG.Active then
                    exit;
                if FieldRefG.Type = FieldRefG.Type::Code then
                    FieldRefG.Validate(newvalueCodeG);
                if FieldRefG.Type = FieldRefG.Type::Integer then
                    FieldRefG.Validate(newvalueIntG);
                if FieldRefG.Type = FieldRefG.Type::Text then
                    FieldRefG.Validate(newvalueTextG);
                if FieldRefG.Type = FieldRefG.Type::Decimal then
                    FieldRefG.Validate(newvalueDecG);
                RecordRefG.Modify();
            end;
        until RecordRefG.Next() = 0;

    end;
}
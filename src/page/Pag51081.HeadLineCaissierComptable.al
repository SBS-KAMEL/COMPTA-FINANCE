/// <summary>
/// Page HeadLineCaissierComptable (ID 51081).
/// </summary>
page 51081 "HeadLineCaissierComptable"
{
    PageType = HeadlinePart;
    Caption = 'RoleCenterHedLine';
    layout
    {
        area(Content)
        {
            /**field(Text00001; Text00001 + ' ' + UserName)
            {
                ApplicationArea = All;
            }*/
            field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Greeting headline';
                Editable = false;

            }
            field(Text00002; Text00002 + ' ' + Format(TotCustBlocked))
            {
                Caption = 'Total Clients bloqués';
                ApplicationArea = All;

            }

            field(Text00003; Text00003 + ' ' + Format(ChqClientCoffre))
            {
                Caption = 'Total Bordereau chèque client en coffre';
                ApplicationArea = All;

            }
        }
    }

    trigger OnOpenPage()
    var

    begin
        clear(Cust);
        Cust.SetFilter(Blocked, '%1', Cust.Blocked::All);
        TotCustBlocked := cust.Count;
        clear(UserSetup);
        UserSetup.get(UserId);
        UserName := UserSetup.Name;
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"Headline RC Order Processor");

        clear(FinanceCue);
        FinanceCue.get;
        FinanceCue.CalcFields("Chèque Client en coffre");
        ChqClientCoffre := FinanceCue."Chèque Client en coffre";

    end;

    var
        Text00001: Label 'Bienvenue';
        Text00002: Label 'Total Clients bloqués';
        Text00003: Label 'Total Bord. Chèque en coffre';
        Cust: Record Customer;
        TotCustBlocked: Integer;
        UserSetup: Record "User Setup";
        UserName: Text[50];
        UserConnet: Record User;
        FinanceCue: Record "Finance Cue";
        ChqClientCoffre: Integer;
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";


}
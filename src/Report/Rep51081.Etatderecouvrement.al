/// <summary>
/// Report MyReport (ID 51080).
/// </summary>
report 51081 "Etat de recouvrement"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    RDLCLayout = '.\src\Report\Layout\Etat de recouvrement.rdl';
    dataset
    {
        dataitem("Payment Header"; "Payment Header")
        {

            RequestFilterFields = Recouvreur, "Posting Date";
            column(PostingDate_PH; "Posting Date")
            {

            }
            column(PaymentClassGName; PaymentClassG.Name)
            {

            }
            column(Recouvreur; EmployeeG."No.")
            {

            }
            column(NomRecouvreur; EmployeeG.FullName())
            {

            }
            column(Account_No_PL; "Payment Line"."Account No.")
            {

            }
            dataitem("Payment Line"; "Payment Line")
            {
                DataItemLink = "No." = field("No.");
                DataItemTableView = where("Account Type" = const(Customer), "Account No." = filter('<>'''));
                column(PaymentClass_PL; "Payment Class")
                {

                }

                column(Amount_PL; Amount)
                {

                }
                column(MontantRetenue_PL; "Montant Retenue")
                {

                }
                column(MontantRetenueValide_PL; "Montant Retenue validé")
                {

                }
                column(NomClient_PL; CustomerG.Name)
                {

                }
                dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
                {
                    DataItemLink = "Applies-to ID" = field("No.");
                    column(Document_No_CLE; "Document No.")
                    {

                    }
                }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    PaymentClassG.Get("Payment Class");
                    CustomerG.get("Account No.");
                end;
            }

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {
                    //     ApplicationArea = All;

                    // }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        myInt: Integer;
        PaymentClassG: Record "Payment Class";
        EmployeeG: Record Employee;
        CustomerG: Record Customer;
}
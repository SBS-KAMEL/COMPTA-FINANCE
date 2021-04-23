/// <summary>
/// Page ActivityCaisserComptabe (ID 51083).
/// </summary>
page 51083 "ActivityCaisseSecondaire"
{
    Caption = 'Caissier Secondaire';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Finance Cue";
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            cuegroup(Recette)
            {
                field("Espèce en Coffre"; "Espèce en Coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Espèce en Coffre';
                }
                field("Espèce Transféré"; "Espèce Transféré")
                {
                    ApplicationArea = All;
                    Caption = 'Espèce Transféré';
                }
            }

            cuegroup(Chèque)
            {
                field("Chèque en coffre"; "Chèque en coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre Chèque Encaissé';
                }
                field("Total Chèque en coffre"; "Total Chèque en coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Total Chèque en caisse';
                }
                field("Chèques transférés"; "Chèques transférés")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque transféré';
                }
                field("Chèque Client impayé"; "Chèque Client impayé")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque Impayé';
                }
            }
            cuegroup(Effet)
            {
                field("Effet en coffre"; "Effet en coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre Effet Encaissé';
                }
                field("Total Effet en coffre"; "Total Effet en coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Total Effet en caisse';
                }
                field("Effets transférés"; "Effets transférés")
                {
                    ApplicationArea = All;
                    Caption = 'Effet transféré';
                }
                field("Effet Client Impayé"; "Effet Client Impayé")
                {
                    ApplicationArea = All;
                    Caption = 'Effet Impayé';
                }
            }
            cuegroup(Autre)
            {
                field("Virement client"; "Virement client")
                {
                    ApplicationArea = All;
                    Caption = 'Virement client';
                }
                field("Versement client"; "Versement client")
                {
                    ApplicationArea = All;
                    Caption = 'Versement client';
                }
            }

        }
    }
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        RESET;
        if not get then begin
            INIT;
            INSERT;
        end;

        //KK_230421
        SetFilter("Date Filter", '%1', WorkDate());
    end;
    /**
        trigger OnOpenPage()
        begin
            Reset();
            If not Get() then begin
                Init();
                Insert();
            end;

        end;

        trigger OnAfterGetRecord()
        begin
            CalculateCueFieldValues();
        end;

        local procedure CalculateCueFieldValues()
        begin
            if FIELDACTIVE("Normal field") then
                "Normal field" := 2 + 1 //add some calculation here for normal fields;
        end;
    */
}
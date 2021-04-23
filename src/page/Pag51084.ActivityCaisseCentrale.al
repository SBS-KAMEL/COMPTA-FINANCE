/// <summary>
/// Page ActivityCaisserComptabe (ID 51083).
/// </summary>
page 51084 "ActivityCaisseCentrale"
{
    Caption = 'Caissie Centrale';
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
                field("Espèce Transféré"; "Espèce Transféré")
                {
                    ApplicationArea = All;
                    Caption = 'Espèce à recevoir';
                }
                field("Espèce Reçu"; "Espèce Reçu")
                {
                    ApplicationArea = All;
                    Caption = 'Espèce en coffre';
                }
            }

            cuegroup(Chèque)
            {
                field("Chèques transférés"; "Chèques transférés")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque à recevoir';
                }
                field("Chèques Reçus"; "Chèques Reçus")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque en caisse';
                }
                field("Total Chèques Reçus"; "Total Chèques Reçus")
                {
                    ApplicationArea = All;
                    Caption = 'Total Chèques encaissés';
                }
                field("Chèque Client impayé"; "Chèque Client impayé")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque Impayé';
                }
            }
            cuegroup(Effet)
            {
                field("Effets transférés"; "Effets transférés")
                {
                    ApplicationArea = All;
                    Caption = 'Effet à recevoir';
                }
                field("Effets Reçus"; "Effets Reçus")
                {
                    ApplicationArea = All;
                    Caption = 'Effet en caisse';
                }
                field("Total Effets Reçus"; "Total Effets Reçus")
                {
                    ApplicationArea = All;
                    Caption = 'Total Effets en coffre';
                }
                field("Effet Encaissé"; "Effet Encaissé")
                {
                    ApplicationArea = All;
                    Caption = 'Effets à encaisser';
                }
                field("Effet Escompté"; "Effet Escompté")
                {
                    ApplicationArea = All;
                    Caption = 'Effets Escomptés';
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
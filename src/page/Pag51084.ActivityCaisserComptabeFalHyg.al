/// <summary>
/// Page ActivityCaisserComptabe (ID 51083).
/// </summary>
page 51084 "ActivityCaisserComptabeFalHyg"
{
    Caption = 'CaisserComptabeActivityFalcon';
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
                field("Espèce Chez commercial"; Rec."Espèce Chez commercial")
                {
                    ApplicationArea = All;
                }

                field("Espèce en Coffre"; "Espèce en Coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Espèce en Coffre';
                }
            }

            cuegroup(Client)
            {

                field("Chèque Chez commercial"; Rec."Chèque Chez commercial")
                {
                    ApplicationArea = All;
                }
                field("Chèque de garantie"; Rec."Chèque de garantie")
                {
                    ApplicationArea = All;
                }
                field("Chèque Client en coffre"; "Chèque Client en coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque Client en coffre';
                }
                field("Effet Client en coffre"; "Effet Client en coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Effet Client en coffre';
                }
                field("Effet Encaissé"; "Effet Encaissé")
                {
                    ApplicationArea = All;
                    Caption = 'Effet Encaissé';
                }
                field("Effet Escompté"; "Effet Escompté")
                {
                    ApplicationArea = All;
                    Caption = 'Effet Escompté';
                }
                field("Chèque Client impayé"; "Chèque Client impayé")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque Client impayé';
                }
                field("Effet Client Impayé"; "Effet Client Impayé")
                {
                    ApplicationArea = All;
                    Caption = 'Effet Impayé';
                }


            }
            cuegroup(Fournisseur)
            {
                //CuegroupLayout = Wide;
                field("Chèque Frs en coffre"; "Chèque Frs en coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque Frs en coffre';
                }

                field("Chèque Frs Remis"; "Chèque Frs Remis")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque Frs Remis';
                }
                field("Effet Frs en coffre"; "Effet Frs en coffre")
                {
                    ApplicationArea = All;
                    Caption = 'Effet Frs en coffre"';
                }
                field("Effet Frs Remis"; "Effet Frs Remis")
                {
                    ApplicationArea = All;
                    Caption = 'Effet Frs Remis';
                }
                field("Chèque Frs Impayé"; "Chèque Frs Impayé")
                {
                    ApplicationArea = All;
                    Caption = 'Chèque Frs Impayé';
                }
                field("Effet Frs Impayé"; "Effet Frs Impayé")
                {
                    ApplicationArea = All;
                    Caption = 'Effet Frs Impayé';
                }

            }
            cuegroup(Décharge)
            {
                field("Bord. versement Chq"; "Bord. versement Chq")
                {
                    ApplicationArea = All;
                    Caption = 'Décharge Chèque versé';
                }
                field("Déch. Effe - Encaiss"; "Déch. Effe - Encaiss")
                {
                    ApplicationArea = All;
                    Caption = 'Décharge Effet Ecaissé';
                }
                field("Déch. Effe - Escpt"; "Déch. Effe - Escpt")
                {
                    ApplicationArea = All;
                    Caption = 'Décharge Effe-Escpt';
                }
                field("Déch. espècé versé"; "Déch. espècé versé")
                {
                    ApplicationArea = All;
                    Caption = 'Décharge Espèce versé ';
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
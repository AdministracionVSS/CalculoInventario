tableextension 86900 "VSS_Item Journal Line" extends "Item Journal Line"
{

    fields
    {
        // Add changes to table fields here

        field(60100; "Lote linea"; code[50])
        {
            trigger OnValidate()
            var

                OldTrackingSpecification: Record "Tracking Specification" temporary;


            begin
                Rec.TestField("Quantity (Base)");
                if "Lote linea" <> xRec."Lote linea" then begin
                    "Fecha caducidad linea" := 0D;
                    EliminaReserva();
                end;

            end;
        }
        field(60101; "Fecha caducidad linea"; date)
        {
            trigger OnValidate()
            var
                cuLote: Codeunit Funciones;
                OldTrackingSpecification: Record "Tracking Specification" temporary;
            begin
                Rec.TestField("Quantity (Base)");
                if "Fecha caducidad linea" <> xRec."Fecha caducidad linea" then
                    EliminaReserva();
                if Rec."Line No." = 0 then begin
                    Message('Debe guardar la línea antes de informar la fecha caducidad');
                    Error('');
                end;

                OldTrackingSpecification."Source Type" := 83;
                if Rec."Entry Type" = Rec."Entry Type"::"Positive Adjmt." then
                    OldTrackingSpecification."Source Subtype" := 2;
                if Rec."Entry Type" = Rec."Entry Type"::"Negative Adjmt." then
                    OldTrackingSpecification."Source Subtype" := 3;
                OldTrackingSpecification."Source ID" := Rec."Journal Template Name";
                OldTrackingSpecification."Source Batch Name" := Rec."Journal Batch Name";
                OldTrackingSpecification."Source Ref. No." := Rec."Line No.";
                OldTrackingSpecification."Qty. per Unit of Measure" := 1;
                OldTrackingSpecification."Quantity (Base)" := Rec."Quantity (Base)";
                OldTrackingSpecification."Lot No." := Rec."Lote linea";
                OldTrackingSpecification."Location Code" := Rec."Location Code";
                OldTrackingSpecification."Expiration Date" := Rec."Fecha caducidad linea";
                OldTrackingSpecification."Bin Code" := Rec."Bin Code";
                OldTrackingSpecification."Item No." := Rec."Item No.";

                cuLote.CreaMovReserva(OldTrackingSpecification);
            end;
        }

    }

    local procedure EliminaReserva()
    var
        MovReserva: Record "Reservation Entry";
    begin

        MovReserva.SetRange("Source Type", 83);
        MovReserva.SetRange("Source Subtype", 2);
        MovReserva.SetRange("Source ID", Rec."Journal Template Name");
        MovReserva.SetRange("Source Batch Name", Rec."Journal Batch Name");
        MovReserva.SetRange("Source Ref. No.", Rec."Line No.");
        MovReserva.SetRange("Item No.", Rec."Item No.");
        MovReserva.DeleteAll();
    end;

    var
        myInt: Integer;
}
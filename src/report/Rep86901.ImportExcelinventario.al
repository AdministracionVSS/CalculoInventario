report 86901 "Import Excel inventario"
{


    ProcessingOnly = true;
    UseRequestPage = false;


    dataset
    {


    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    trigger OnPreReport()
    var
        Excel: Page "Abrir Excel VSS";

        NumTotalFilas: Integer;
        ContadorFilas: Integer;
        NumFilaInicioExcel: Integer;
        ErrorUbicacion: Text;
        Ubicacion: Record Bin;
        CodU: Code[20];
    begin
        Ventana.Open('Procesando #1################################');
        Excel.RunModal();
        NumFilaInicioExcel := 2;
        Excel.GetExcel(ExcelBuffer);
        ExcelBuffer.FINDLAST;
        NumTotalFilas := ExcelBuffer."Row No.";
        FOR ContadorFilas := NumFilaInicioExcel TO NumTotalFilas DO BEGIN
            CodU := ObtenerCeldaExcel(ContadorFilas, 4);
            Ubicacion.SetRange(Code, CodU);
            if not Ubicacion.FindSet() then begin
                ErrorUbicacion += CodU + '\';
            end;
        end;
        if ErrorUbicacion <> '' then begin
            Message('Ubicaciones no existe:' + ErrorUbicacion);
            Error('');
        end;
        FOR ContadorFilas := NumFilaInicioExcel TO NumTotalFilas DO BEGIN
            ExcelBuffer.RESET;
            ExcelBuffer.SETRANGE("Row No.", ContadorFilas);
            IF ExcelBuffer.FINDFIRST THEN BEGIN
                ValidarDatosExcel(ContadorFilas);
            END;
        END;
        Ventana.Close();
        Message('Proceso finalizado');
    end;


    LOCAL procedure ValidarDatosExcel(NumFila: Integer)
    Var
        Inventario: Record CalcInventario;
        Producto: Record item;
    begin



        Valor := ObtenerCeldaExcel(NumFila, 1);
        Producto.get(Valor);
        if Producto.Type = Producto.Type::Inventory then begin
            nlin += 1;
            Inventario.Init();
            Inventario.nlin := nlin;
            Ventana.Update(1, Valor);
            Inventario.Validate(Producto, Valor);
            //Descripcion
            Inventario.Validate(Almacen, ObtenerCeldaExcel(NumFila, 3));
            Inventario.Validate("Ubicación", ObtenerCeldaExcel(NumFila, 4));
            //cantidad
            evaluate(Inventario."Cantidad real", ObtenerCeldaExcel(NumFila, 6));
            Inventario.validate(Lote, ObtenerCeldaExcel(NumFila, 7));
            Evaluate(Inventario."Fecha caducidad", ObtenerCeldaExcel(NumFila, 8));
            Evaluate(Inventario.Coste, ObtenerCeldaExcel(NumFila, 9));

            Inventario.Insert();
        end;

    end;

    local procedure ObtenerCeldaExcel(RowNo: Integer; ColumnNo: Integer): Text
    begin
        IF ExcelBuffer.GET(RowNo, ColumnNo) THEN
            EXIT(ExcelBuffer."Cell Value as Text");

        EXIT('');
    end;

    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        Valor: Text;
        Ventana: Dialog;
        nlin: Integer;
}

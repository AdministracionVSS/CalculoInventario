report 86902 "Registra Inventario"
{

    ProcessingOnly = true;

    dataset
    {

        dataitem("Calc. Inventario"; CalcInventario)
        {
            //DataItemTableView = sorting(nlin) order(descending);

            trigger OnPreDataItem()
            begin
                Ventana.Open('Procesando #1###################');
                Lindia.SetRange(LinDia."Journal Template Name", 'AJUSTE');
                Lindia.SetRange(LinDia."Journal Batch Name", 'INVENTARIO');
                if Lindia.FindFirst() then
                    Lindia.DeleteAll();
            end;

            trigger OnAfterGetRecord()
            var

            begin
                Ventana.Update(1, "Calc. Inventario".Producto);
                if "Calc. Inventario".Producto <> '' then begin
                    t_Producto.get("Calc. Inventario".Producto);

                    if t_Producto.Blocked then begin
                        TempProducto := t_Producto;
                        TempProducto.insert;
                        t_Producto.Blocked := false;
                        t_Producto.Modify();
                    end;


                    If "Calc. Inventario"."Stock Inicial" then
                        NOAjuste := True;

                    if t_Producto.Type = t_Producto.Type::Inventory then begin
                        CantDif := "Cantidad stock" - "Cantidad real";
                        if CantDif <> 0 then begin
                            nlinea += 10000;
                            LinDia.Init();
                            LinDia."Journal Template Name" := 'PRODUCTO';
                            LinDia."Journal Batch Name" := 'INVENTARIO';
                            LinDia."Line No." := nlinea;
                            LinDia."Document No." := 'INV.' + DelChr(FORMAT(FechaReg), '=', '/');
                            Lindia.Insert();
                            LinDia.validate("Item No.", "Calc. Inventario".Producto);
                            LinDia.validate("Posting Date", FechaReg);
                            Lindia."Unit of Measure Code" := "Calc. Inventario"."Unidad medida";
                            if CantDif > 0 then begin
                                TotalCostes += ("Calc. Inventario".Coste * CantDif);
                                LinDia."Entry Type" := LinDia."Entry Type"::"Negative Adjmt.";
                                LinDia.Validate(Quantity, CantDif);
                            end else begin
                                TotalCostes += ("Calc. Inventario".Coste * -CantDif);
                                LinDia."Entry Type" := LinDia."Entry Type"::"Positive Adjmt.";
                                LinDia.Validate(Quantity, -CantDif);
                            end;
                            LinDia."Location Code" := "Calc. Inventario".Almacen;
                            Lindia."Bin Code" := "Calc. Inventario"."Ubicación";
                            Lindia.validate("Qty. per Unit of Measure", 1);
                            Lindia.Validate(Lindia."Quantity", Lindia.Quantity);
                            LinDia.Validate("Lote linea", "Calc. Inventario".Lote);
                            Lindia.Validate("Fecha caducidad linea", "Calc. Inventario"."Fecha caducidad");
                            lindia.validate("Unit Cost", "Calc. Inventario".Coste);
                            Lindia.Validate("Unit Amount", "Calc. Inventario".Coste);
                            ConfigInventario.get();
                            LinDia.Modify();

                        end;
                    end;
                end;
            end;

            trigger OnPostDataItem()
            var

                cuRegistroDiario: Codeunit "Item Jnl.-Post Batch";
            begin

                /*if TempProducto.FindFirst() then
                    repeat
                        t_Producto.get(TempProducto."No.");
                        t_Producto.Blocked := true;
                        t_Producto.Modify();
                    until TempProducto.next = 0;
                If NOAjuste = FALSE then begin
                    //CREAR DIARIO CON PRODUCTO INV
                    ConfigInventario.Reset();
                    ConfigInventario.Get();

                    nlinea += 10000;
                    LinDia.Init();
                    LinDia."Journal Template Name" := 'PRODUCTO';
                    LinDia."Journal Batch Name" := 'INVENTARIO';
                    LinDia."Line No." := nlinea;
                    LinDia."Document No." := 'INV.' + DelChr(FORMAT(FechaReg), '=', '/');
                    Lindia.Insert();

                    LinDia.validate("Posting Date", FechaReg);

                    if TotalCostes > 0 then begin
                        LinDia."Entry Type" := LinDia."Entry Type"::"Negative Adjmt.";
                    end else begin
                        LinDia."Entry Type" := LinDia."Entry Type"::"Positive Adjmt.";
                    end;
                    LinDia."Location Code" := "Calc. Inventario".Almacen;
                    LinDia.Validate(Quantity, 1);
                    lindia.validate("Unit Cost", TotalCostes);
                    Lindia.Validate("Unit Amount", TotalCostes);
                    LinDia.Modify();
                end;
                Commit();
                cuRegistroDiario.run(Lindia);
                deleteall;
                Message('Registro de inventario realizado');
                */
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Datos)
                {
                    field("Fecha registro"; FechaReg)
                    { ApplicationArea = all; }
                }
            }
        }

    }

    trigger OnPreReport()
    begin
        if FechaReg = 0D then
            Error('Debe informar la fecha de registro');

        Libro.SetRange(Name, 'PRODUCTO');
        if not Libro.FindFirst() then begin
            Libro.Name := 'PRODUCTO';
            Libro.Type := Libro.Type::"Prod. Order";
            Libro.Insert();
        end;



        Secc.SetRange("Journal Template Name", 'PRODUCTO');
        Secc.SetRange(Name, 'INVENTARIO');
        if Secc.Delete(true) then;

        Secc.Init();
        Secc."Journal Template Name" := 'PRODUCTO';
        Secc.Name := 'INVENTARIO';
        if Secc.Insert() then;

        LinDia.SetRange("Journal Template Name", 'PRODUCTO');
        LinDia.SetRange("Journal Batch Name", 'INVENTARIO');
        LinDia.DeleteAll();
        MovReserva.SetRange("Source ID", 'PRODUCTO');
        MovReserva.SetRange("Source Batch Name", 'INVENTARIO');
        MovReserva.DeleteAll();
    end;

    var
        Lindia: Record "Item Journal Line";
        Libro: Record "Item Journal Template";
        Secc: Record "Item Journal Batch";
        FechaReg: Date;
        CantDif: Decimal;
        nlinea: Integer;
        MovReserva: Record "Reservation Entry";
        Ventana: Dialog;
        TempProducto: Record item temporary;
        t_Producto: Record Item;
        TotalCostes: Decimal;
        ConfigInventario: Record "Inventory Setup";
        NOAjuste: Boolean;



}

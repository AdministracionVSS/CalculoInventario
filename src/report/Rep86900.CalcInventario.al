report 86900 "Calc. Inventario"
{

    Caption = 'Calc. Inventario';

    ProcessingOnly = true;
    dataset
    {

        dataitem(Prod; Item)
        {
            //RequestFilterFields = "Inventory Posting Group", "Location Filter";
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var

            begin
                If RecItem."No." <> '' then
                    prod.SetRange(Prod."No.", RecItem."No.");

                CalcInv.DeleteAll();
            end;

            trigger OnAfterGetRecord()
            var
                ConfFab: Record "Manufacturing Setup";
                OrdenLanzada: Record "Production Order";
                ConfigInventario: Record "Inventory Setup";
                InfoEmpresa: Record "Company Information";
            begin
                ConfigInventario.Get();
                InfoEmpresa.get();
                If RecItem."No." <> '' then
                    Prod.SetRange(prod."No.", RecItem."No.");

                If StockInicial then begin
                    nlin += 10000;
                    CalcInv.Init();
                    CalcInv.nlin := nlin;
                    CalcInv.Producto := Prod."No.";
                    CalcInv.Nombre := Prod.Description;
                    CalcInv.Almacen := InfoEmpresa."Location Code";

                    CalcInv."Unidad medida" := Prod."Base Unit of Measure";
                    CalcInv.Insert();
                end;
                ConfFab.get;
                MovProd.SetCurrentKey("Item No.", Open);
                MovAlmacen.SetCurrentKey("Location Code", "Item No.", "Variant Code", "Zone Code", "Bin Code", "Lot No.");
                Prod.CalcFields(inventory);
                CalcInv.SetCurrentKey(Producto, Almacen, "Ubicación", Lote);
                if (Prod.Inventory <> 0) and (StockInicial = FALSE) then begin
                    MovProd.SetRange("Item No.", Prod."No.");
                    MovProd.setfilter("Location Code", GetFilter("Location Filter"));
                    //MovProd.SetRange("Global Dimension 1 Code", ConfigInventario."Productos disponibles");
                    MovProd.SetRange(Open, true);
                    if MovProd.FindSet() then
                        repeat
                            Ubicacion := '';
                            MovAlmacen.SetRange("Registering Date", MovProd."Posting Date");
                            MovAlmacen.SetRange("Location Code", MovProd."Location Code");
                            MovAlmacen.SetRange("Item No.", MovProd."Item No.");
                            MovAlmacen.SetRange("Lot No.", MovProd."Lot No.");
                            MovAlmacen.SetRange("Entry Type", MovAlmacen."Entry Type"::"Positive Adjmt.");
                            MovAlmacen.SetRange("Reference No.", MovProd."Document No.");
                            if MovAlmacen.FindFirst() then
                                Ubicacion := MovAlmacen."Bin Code";

                            If RecItem."No." <> '' then
                                CalcInv.SetRange(Producto, RecItem."No.")
                            else
                                CalcInv.SetRange(Producto, Prod."No.");

                            CalcInv.SetRange(Almacen, MovProd."Location Code");
                            CalcInv.SetRange("Ubicación", Ubicacion);
                            CalcInv.SetRange(lote, MovProd."Lot No.");
                            if CalcInv.FindSet() then begin
                                CalcInv."Cantidad stock" += MovProd."Remaining Quantity";
                                // CalcInv."Cantidad real" := CalcInv."Cantidad stock";
                                CalcInv.Modify();
                            end else begin
                                nlin += 10000;
                                CalcInv.Init();
                                CalcInv.nlin := nlin;
                                CalcInv.Producto := Prod."No.";

                                CalcInv.Nombre := prod.Description;
                                CalcInv.Almacen := MovProd."Location Code";
                                CalcInv."Ubicación" := Ubicacion;
                                CalcInv.lote := MovProd."Lot No.";
                                CalcInv.Coste := Prod."Unit Cost";
                                CalcInv."Fecha caducidad" := MovProd."Expiration Date";
                                CalcInv."Unidad medida" := Prod."Base Unit of Measure";
                                CalcInv."Cantidad stock" := MovProd."Remaining Quantity";
                                // CalcInv."Cantidad real" := CalcInv."Cantidad stock";
                                CalcInv.Insert();
                            end;
                        until MovProd.Next() = 0;
                end;
            end;
        }


    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    field(CodigoBarras; CodigoBarras)
                    {
                        Caption = 'Código de Barras';
                        ApplicationArea = all;
                        visible = false;
                        trigger OnValidate()
                        var

                            PosGuion: Integer;
                            LongitudLectura: Integer;
                            ProductoLeido: Code[20];

                        begin
                            PosGuion := StrPos(CodigoBarras, '-');
                            If PosGuion <> 0 then begin
                                ProductoLeido := CopyStr(FORMAT(CodigoBarras), 1, (PosGuion - 1));
                                LongitudLectura := StrLen(FORMAT(CodigoBarras)) - (PosGuion);

                                RecItem.Reset();
                                RecItem.SetRange(RecItem."No.", ProductoLeido);
                                If RecItem.FindFirst() then
                                    Prod.SetRange(Prod."No.", RecItem."No.");



                            end else begin

                                RecItem.Reset();
                                RecItem.SetRange(RecItem."No.", CodigoBarras);
                                If RecItem.FindFirst() then
                                    Prod.SetRange(Prod."No.", RecItem."No.");


                            end;
                        end;

                    }

                    field(StockInicial; StockInicial)
                    {
                        ApplicationArea = all;
                        Caption = 'Stock Inicial';
                        visible = false;
                    }
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
    begin
        CalcInv.DeleteAll();
        MovProd.SetCurrentKey(Open);
        iF RecItem."No." <> '' THEN
            Prod.SetRange(Prod."No.", RecItem."No.");
    end;

    var

        CodigoBarras: Code[50];
        MovProd: Record "Item Ledger Entry";
        CalcInv: Record CalcInventario;
        nlin: Integer;
        MovAlmacen: Record "Warehouse Entry";
        Ubicacion: Code[20];
        RecItem: Record Item;
        StockInicial: Boolean;

}

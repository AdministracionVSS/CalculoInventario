page 86900 "Calculo inventario"
{
    ApplicationArea = All;
    Caption = 'Calculo inventario';
    PageType = List;
    SourceTable = CalcInventario;
    //SourceTableView = sorting(Producto, Almacen, "Ubicación", Lote);
    UsageCategory = Lists;
    AutoSplitKey = true;


    layout
    {
        area(content)
        {

            field(LecturaCodigo; LecturaCodigo)
            {
                ApplicationArea = all;
                Editable = true;
                visible = false;
                Caption = 'Lectura Codigo';
            }
            field(StockInicial; StockInicial)
            {
                ApplicationArea = all;
                Editable = true;
                visible = false;
                Caption = 'Stock Inicial';
                trigger OnValidate()
                var
                    LineasInventario: Record CalcInventario;
                begin
                    LineasInventario.Reset();
                    If LineasInventario.FindFirst() then begin
                        repeat
                            LineasInventario."Stock Inicial" := StockInicial;
                            LineasInventario.Modify();
                        until LineasInventario.Next() = 0;
                    end;
                end;
            }

            repeater(General)
            {

                field(Producto; Rec.Producto)
                {
                    ToolTip = 'Specifies the value of the Producto field.';
                    ApplicationArea = All;

                }
                field(Nombre; Rec.Nombre)
                {
                    ToolTip = 'Specifies the value of the Nombre field.';
                    ApplicationArea = All;

                }
                field("Codigo EAN"; Rec."Codigo EAN")
                {
                    ToolTip = 'Specifies the EAN/GTIN code of the product.';
                    ApplicationArea = All;
                    Editable = false;
                    visible = false;
                }

                field(Almacen; Rec.Almacen)
                {
                    ToolTip = 'Specifies the value of the Almacen field.';
                    ApplicationArea = All;

                }
                field("Ubicación"; Rec."Ubicación")
                {
                    ToolTip = 'Specifies the value of the Ubicación field.';
                    ApplicationArea = All;


                }
                field(Lote; Rec.Lote)
                {
                    ToolTip = 'Specifies the value of the Lote field.', Comment = '%';
                    ApplicationArea = All;

                }
                field("Fecha caducidad"; Rec."Fecha caducidad")
                {
                    ToolTip = 'Specifies the value of the Fecha caducidad field.', Comment = '%';
                    ApplicationArea = All;
                }


                field("Cantidad stock"; Rec."Cantidad stock")
                {
                    ToolTip = 'Specifies the value of the Cantidad field.';
                    ApplicationArea = All;


                }
                field("Cantidad real"; Rec."Cantidad real")
                {
                    ToolTip = 'Specifies the value of the Cantidad real field.';
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 10;
                }

                field("Unidad medida"; Rec."Unidad medida")
                {
                    ToolTip = 'Specifies the value of the Unidad medida field.';
                    ApplicationArea = All;

                }

                field(Coste; Rec.Coste)
                {
                    ToolTip = 'Specifies the value of the Coste field.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Creation)
        {
            // action("Exporta plantilla Excel")
            // {
            //     //ApplicationArea = All;

            //     trigger OnAction()
            //     begin

            //     end;
            // }
            action("Importar Excel")
            {
                ApplicationArea = All;
                Image = Excel;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ImpExcel: Report "Import Excel inventario";
                    LinDia: Record "Item Journal Line";
                    MovReserva: Record "Reservation Entry";
                begin
                    Clear(ImpExcel);
                    ImpExcel.RunModal();
                    LinDia.SetRange("Journal Template Name", 'AJUSTE');
                    LinDia.SetRange("Journal Batch Name", 'INVENTARIO');
                    LinDia.DeleteAll();
                    MovReserva.SetRange("Source ID", 'AJUSTE');
                    MovReserva.SetRange("Source Batch Name", 'INVENTARIO');
                    MovReserva.DeleteAll();

                end;
            }
        }
        area(Processing)
        {
            action("Calcula inventario")
            {
                ApplicationArea = All;
                Image = CalculateInventory;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = report "Calc. Inventario";

            }
            action("Registra inventario")
            {
                ApplicationArea = All;
                Image = PostInventoryToGL;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    RegistraInv: Report "Registra Inventario";
                    SelLineas: Record CalcInventario;
                begin
                    CurrPage.SetSelectionFilter(SelLineas);
                    RegistraInv.SetTableView(SelLineas);
                    RegistraInv.RunModal();
                end;
            }

        }
    }
    var
        LecturaCodigo: Decimal;
        StockInicial: Boolean;
}

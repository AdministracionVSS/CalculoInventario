table 86903 "CalcInventario"
{
    Caption = 'CalcInventario';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; nlin; Integer)
        {
            Caption = 'nlin';
            DataClassification = ToBeClassified;
        }
        field(2; Producto; Code[20])
        {
            Caption = 'Producto';
            DataClassification = ToBeClassified;
            TableRelation = item;
            trigger OnValidate()
            var
                Prod: Record Item;
            begin
                if Producto <> '' then begin
                    Prod.get(Producto);
                    Nombre := Prod.Description;
                    "Unidad medida" := Prod."Base Unit of Measure";
                    "Codigo EAN" := Prod.GTIN;
                    Coste := Prod."Unit Cost";
                end

            end;
        }
        field(3; Nombre; Text[150])
        {
            Caption = 'Nombre';
            DataClassification = ToBeClassified;
        }
        field(4; Almacen; Code[20])
        {
            Caption = 'Almacen';
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(5; "Ubicación"; Code[20])
        {
            Caption = 'Ubicación';
            DataClassification = ToBeClassified;
            TableRelation = Bin.Code where("Location Code" = field(Almacen));

        }
        field(6; Lote; Code[50])
        {
            Caption = 'Lote';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                ContUbica: Record "Bin Content";
                MovAlmacen: Record "Warehouse Entry";
            begin
                ContUbica.SetRange("Item No.", Producto);
                ContUbica.SetRange("Location Code", Almacen);
                ContUbica.SetRange("Bin Code", "Ubicación");
                ContUbica.SetRange("Lot No. Filter", lote);
                if ContUbica.FindFirst() then begin
                    ContUbica.CalcFields("Quantity (Base)");
                    "Cantidad stock" := ContUbica."Quantity (Base)";
                    MovAlmacen.SetRange("Item No.", Producto);
                    MovAlmacen.SetRange("Location Code", Almacen);
                    MovAlmacen.SetRange("Bin Code", "Ubicación");
                    MovAlmacen.SetRange("Lot No.", Lote);
                    if MovAlmacen.FindFirst() then
                        "Fecha caducidad" := MovAlmacen."Expiration Date";
                end
            end;
        }
        field(7; "Fecha caducidad"; Date)
        {
            Caption = 'Fecha caducidad';
            DataClassification = ToBeClassified;
        }
        field(8; "Cantidad stock"; Decimal)
        {
            Caption = 'Cantidad';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 10;
        }
        field(9; "Unidad medida"; Code[20])
        {
            Caption = 'Unidad medida';
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure";

        }
        field(10; "Cantidad real"; Decimal)
        {
            DecimalPlaces = 0 : 10;
        }

        field(11; Coste; Decimal)
        {
            Caption = 'Costes';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 10;
        }


        field(14; "Stock Inicial"; Boolean)
        {
            Caption = 'Stock Inicial';
        }

        field(15; "Codigo EAN"; Code[14])
        {
            Caption = 'Codigo EAN';
            DataClassification = ToBeClassified;
        }


    }
    keys
    {
        key(PK; nlin)
        {
            Clustered = true;
        }
        key(Key1; Producto, Almacen, "Ubicación", Lote)
        {

        }
    }
}

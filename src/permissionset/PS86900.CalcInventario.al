permissionset 86900 "VSS Calc. Inventario"
{
    Assignable = true;
    Caption = 'VSS Calc. Inventario';

    Permissions =
        tabledata CalcInventario = RIMD,
        table CalcInventario = X,
        page "Calculo inventario" = X,
        page "Abrir Excel VSS" = X,
        report "Calc. Inventario" = X,
        report "Import Excel inventario" = X,
        report "Registra Inventario" = X,
        codeunit "Funciones" = X;
}

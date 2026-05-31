page 86905 "Abrir Excel VSS"
{
    PageType = StandardDialog;
    SourceTable = "Excel Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Abrir)
            {
                field(NomFichero; NomFichero)
                {
                    Caption = 'Nombre fichero';
                    ApplicationArea = All;
                    trigger OnAssistEdit()

                    begin
                        UploadFile;
                    end;
                }
                field(SheetName; SheetName)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre hoja';
                    trigger OnAssistEdit()

                    begin
                        SheetName := Rec.SelectSheetsNameStream(InStr);
                    end;
                }
            }
        }
    }



    var
        FileName: Text;
        InStr: InStream;
        NomFichero: Text;
        SheetName: Text;
        CommonDialogMgt: Codeunit "File Management";
        Importar: Boolean;

    trigger OnQueryClosePage(CloseAction: Action): Boolean

    begin
        if CloseAction = Action::OK then begin
            Importar := true;
            Rec.OpenBookStream(InStr, SheetName);
            //OpenBook(FileName, SheetName);
            Rec.ReadSheet;

        end;

    end;


    local procedure UploadFile()

    begin
        //Oncloud
        file.UploadIntoStream('Importar fich. Excel', '', '', FileName, Instr);

        //OnPrem
        //FileName := CommonDialogMgt.UploadFile('Importar fich. Excel', '.xlsx');
        NomFichero := CommonDialogMgt.GetFileName(FileName);
    end;

    procedure GetImportar(): Boolean

    begin
        exit(Importar);
    end;

    procedure GetExcel(var T_Excel: Record "Excel Buffer" temporary)
    begin
        T_Excel.reset;
        T_Excel.DeleteAll();
        if Rec.FindFirst() then
            repeat
                T_Excel.Init();
                T_Excel := rec;
                T_Excel.Insert();
            until Rec.next = 0;
    end;

}
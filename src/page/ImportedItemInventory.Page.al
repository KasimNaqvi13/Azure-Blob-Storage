page 90551 "Imported Item Inventory"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Imported Item Inventory";
    Caption = 'Imported Item Inventory';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No"; Rec."Item No")
                {
                    ToolTip = 'Specifies the value of the Item No field.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                }
                field("Vendor No"; Rec."Vendor No")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Vendor No field.';
                }
                field(Inventory; Rec.Inventory)
                {
                    ToolTip = 'Specifies the value of the Inventory field.';
                }
                field("Last Updated Date Time"; Rec."Last Updated Value")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Updated Value field.';
                }
            }
        }
        area(Factboxes)
        {
        }
    }
    actions
    {
        area(Processing)
        {
            action("Import Excel through CSV")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Import;
                Caption = 'Import CSV';

                trigger OnAction();
                var
                begin
                    //Rec.DeleteAll();
                    Xmlport.Run(50200, true, true);
                end;
            }
            action(DeleteALL)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Delete;
                Caption = 'Delete All';

                trigger OnAction();
                var
                begin
                    Rec.DeleteAll();
                end;
            }
            // action("Import Excel")
            // {
            //     ApplicationArea = All;
            //     Promoted = true;
            //     PromotedIsBig = true;
            //     PromotedCategory = Process;
            //     Image = ImportExcel;
            //     trigger OnAction();
            //     var
            //         Buffer: Record "Excel Buffer" temporary;
            //         MSCInvoice: Record "Imported Item Inventory";
            //     begin
            //         MSCInvoice.DeleteAll();
            //         ReadExcelSheet();
            //         //ImportExcelData();
            //     end;
            // }
        }
    }
    Var
        Batchname: code[30];
        ItemNo: Integer;
        FileName: Text[100];
        SheetName: Text[100];
        TempExcelBuffer: Record "Excel Buffer" temporary;
        UploadMsg: Label 'Please choose the Excel file';
        NoFileMsg: Label 'No Excel file found';
        BatchIsBlankMsg: Label 'Transaction name is blank';
        ExcelImportSuccess: Label 'Excel imported successfully';
        ItemRec: Record Item;

    trigger OnAfterGetRecord()
    begin
        ItemRec.Reset();
        ItemRec.SetRange("No.", Rec."Item No");
        if ItemRec.FindFirst() then rec."Item Description" := ItemRec.Description;
    end;

    local procedure ReadExcelSheet()
    var
        Filemgmt: Codeunit "File Management";
        InStr: InStream;
        FromFile: Text[100];
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        FileDialogTxt: Label 'Attachments (%1)|%1', Comment = '%1=file types, such as *.txt or *.docx';
        FilterTxt: Label '*.jpg;*.jpeg;*.bmp;*.png;*.gif;*.tiff;*.tif;*.pdf;*.docx;*.doc;*.xlsx;*.xls;*.pptx;*.ppt;*.msg;*.xml;*.*', Locked = true;
    begin
        UploadIntoStream(UploadMsg, '', '', FromFile, InStr);
        //Message('Uploaded %1', CurrentDateTime);
        //Message('Instr %1', CurrentDateTime);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(InStr);
        //Message('SheetName %1', CurrentDateTime);
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(InStr, SheetName);
        TempExcelBuffer.ReadSheet();
        //Message('Read %1', CurrentDateTime);
        //File.UploadIntoStream('All Files (*.*)|*.*', InStr);
        //UploadIntoStream(UploadMsg, '', '', FromFile, InStr);
        // SheetName := TempExcelBuffer.SelectSheetsNameStream(InStr);
        // if FromFile <> '' then begin
        //     FileName := Filemgmt.GetFileName(FromFile);
        //     SheetName := TempExcelBuffer.SelectSheetsNameStream(InStr);
        //     Message('FileRead');
        // end else
        //     Error(NoFileMsg);
        // TempExcelBuffer.Reset();
        // TempExcelBuffer.DeleteAll();
        // TempExcelBuffer.OpenBookStream(InStr, SheetName);
        // TempExcelBuffer.ReadSheet();
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    var
        myInt: Integer;
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell value as Text")
        else
            exit('');
    end;

    local procedure ImportExcelData()
    var
        ImportedItemInv: Record "Imported Item Inventory";
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRow: Integer;
        ItemNo: Integer;
        Progress: Dialog;
        Counter: Integer;
        Text000: Label 'Counting to 100 ------ #1 of #2';
    begin
        RowNo := 0;
        ColNo := 0;
        LineNo := 0;
        MaxRow := 0;
        TempExcelBuffer.Reset();
        If TempExcelBuffer.FindLast() then begin
            MaxRow := TempExcelBuffer."Row No."
        end;
        for RowNo := 3 to MaxRow do begin
            Counter := RowNo;
            Progress.Open(Text000, Counter);
            Counter += 1;
            Progress.Update(1, Counter);
            Progress.Update(2, MaxRow);
            Sleep(50);
            ImportedItemInv.Init();
            Evaluate(ImportedItemInv."Item No", GetValueAtCell(RowNo, 1));
            ImportedItemInv."Vendor No" := 'V01560';
            //Evaluate(ImportedItemInv."Vendor No", GetValueAtCell(RowNo, 2));
            Evaluate(ImportedItemInv.Inventory, GetValueAtCell(RowNo, 2));
            ImportedItemInv.Insert();
        end;
        Progress.Close();
        Message(ExcelImportSuccess);
    end;
}

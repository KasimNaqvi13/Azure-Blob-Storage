xmlport 90551 ImportMscXML
{
    Format = VariableText;
    Caption = 'Import Item Inventory';
    TableSeparator = ''; //New line

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(ImportedItemInventory; "Imported Item Inventory")
            {
                fieldelement(ItemNo; ImportedItemInventory."Item No")
                {
                }
                fieldelement(Inventory; ImportedItemInventory.Inventory)
                {
                }
                trigger OnBeforeInsertRecord()
                var
                begin
                    SkipRowsNo += 1;
                    if SkipRowsNo <= 2 then begin
                        currXMLport.Skip();
                    end;
                end;

                trigger OnPreXmlItem()
                begin
                    SkipRowsNo := 1;
                end;
            }
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
    var
        SkipRowsNo: Integer;
}

codeunit 90551 FetchAndSaveInventory
{
    trigger OnRun()
    var
        AzureBlob: Codeunit AzureAccess;
    begin
        if AzureBlob.FetchAzureContainer() then
            if AzureBlob.DeleteContainerFiles() then;
    end;
}

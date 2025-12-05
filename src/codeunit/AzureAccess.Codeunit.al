codeunit 90552 AzureAccess
{
    trigger OnRun()
    begin
        //CreateAzureContainer();
    end;

    procedure CreateAzureContainer()
    begin
        ItemInvSetup.Get();
        Authorization := GetAuthorization();
        ABSContainerClient.Initialize(ItemInvSetup."StorageAccount Name", Authorization);
        Response := ABSContainerClient.CreateContainer(ContainerName);
        if Response.IsSuccessful() then begin
            Message('Container Created');
        end
        else
            Message(Response.GetError());
    end;

    procedure ListAzureContainer()
    begin
        ItemInvSetup.Get();
        Authorization := GetAuthorization();
        ABSContainerClient.Initialize(ItemInvSetup."StorageAccount Name", Authorization);
        Response := ABSContainerClient.ListContainers(ABSContainerRec);
        if Response.IsSuccessful() then begin
            if ABSContainerRec.FindSet() then
                repeat
                    Message('Container Name - %1', ABSContainerRec.Name);
                until ABSContainerRec.Next() = 0;
        end
        else
            Message(Response.GetError());
    end;

    procedure DeleteAzureContainer()
    begin
        ItemInvSetup.Get();
        Authorization := GetAuthorization();
        ABSContainerClient.Initialize(ItemInvSetup."StorageAccount Name", Authorization);
        Response := ABSContainerClient.DeleteContainer(ItemInvSetup."Container Name");
        if Response.IsSuccessful() then begin
            Message('Container Deleted');
        end
        else
            Message(Response.GetError());
    end;

    procedure DeleteContainerFiles(): Boolean
    begin
        ItemInvSetup.Get();
        Authorization := GetAuthorization();
        ABSBlob.Initialize(ItemInvSetup."StorageAccount Name", ItemInvSetup."Container Name", Authorization);
        Response := ABSBlob.ListBlobs(ABSContainerContentRec);
        if ABSContainerContentRec.FindSet() then begin
            repeat
                Response := ABSBlob.DeleteBlob(ABSContainerContentRec.Name);
                if GuiAllowed then begin
                    if Response.IsSuccessful() then
                        Message('')
                    else
                        Message(Response.GetError());
                end
                else if not Response.IsSuccessful() then exit(false);
            until ABSContainerContentRec.Next() = 0;
            if GuiAllowed then Message('All container files deleted');
        end
        else if GuiAllowed then
            Message(Response.GetError())
        else
            exit(false);
    end;

    procedure FetchAzureContainer(): Boolean
    var
        Instr: InStream;
        ImportedItemInventory: Record "Imported Item Inventory";
    begin
        ItemInvSetup.Get();
        Authorization := GetAuthorization();
        ABSBlob.Initialize(ItemInvSetup."StorageAccount Name", ItemInvSetup."Container Name", Authorization);
        Response := ABSBlob.ListBlobs(ABSContainerContentRec);
        if ABSContainerContentRec.FindFirst() then begin
            // repeat
            Response := ABSBlob.GetBlobAsStream(ABSContainerContentRec.Name, Instr);
            if not Response.IsSuccessful() then exit(false);
            ImportedItemInventory.DeleteAll();
            Commit();
            if not Xmlport.Import(90551, Instr, ImportedItemInventory) then
                exit(false)
            else begin
                ItemInvSetup.LastImportedFileName := ABSContainerContentRec.Name;
                ItemInvSetup.Modify();
                exit(true);
            end;
            //  until ABSContainerContentRec.Next() = 0;
        end
        else
            exit(false);
    end;

    procedure InsertIntoAzureContainer()
    begin
        ItemInvSetup.Get();
        Authorization := GetAuthorization();
        ABSBlob.Initialize(ItemInvSetup."StorageAccount Name", ItemInvSetup."Container Name", Authorization);
        Response := ABSBlob.PutBlobBlockBlobUI();
        if Response.IsSuccessful() then begin
            if ABSContainerRec.FindSet() then
                repeat
                    Message('Inserted to Container Name - %1', ABSContainerRec.Name);
                until ABSContainerRec.Next() = 0;
        end
        else
            Message(Response.GetError());
    end;

    procedure listContainerFiles(): List of [Text]
    var
        Output: List of [Text];
    begin
        ItemInvSetup.Get();
        Authorization := GetAuthorization();
        ABSBlob.Initialize(ItemInvSetup."StorageAccount Name", ItemInvSetup."Container Name", Authorization);
        Response := ABSBlob.ListBlobs(ABSContainerContentRec);
        if Response.IsSuccessful() then begin
            if ABSContainerContentRec.FindSet() then begin
                repeat
                    Message(ABSContainerContentRec.Name);
                until ABSContainerContentRec.Next() = 0;
            end;
        end;
    end;

    local procedure GetAuthorization(): Interface "Storage Service Authorization"
    var
        ItemInvSetup: Record "Azure Blob Storage Setup";
    begin
        ItemInvSetup.Get();
        ContainerName := ItemInvSetup."Container Name";
        StorageAccountName := ItemInvSetup."StorageAccount Name";
        SharedKey := ItemInvSetup."Shared Key";
        exit(StorageServiceAuth.CreateSharedKey(SharedKey));
    end;

    var
        ABSContainerClient: Codeunit "ABS Container Client";
        StorageAccountName: text;
        ContainerName: text;
        Authorization: Interface "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        StorageServiceAuth: Codeunit "Storage Service Authorization";
        SharedKey: SecretText;
        ABSContainerRec: Record "ABS Container";
        ABSBlob: Codeunit "ABS Blob Client";
        ABSContainerContentRec: Record "ABS Container Content";
        ItemInvSetup: Record "Azure Blob Storage Setup";
}

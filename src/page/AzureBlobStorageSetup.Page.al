page 90552 "Azure Blob Storage Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Azure Blob Storage Setup";
    ModifyAllowed = true;
    InsertAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(Content)
        {
            group(General)
            {
                field("StorageAccount Name"; Rec."StorageAccount Name")
                {
                    ApplicationArea = All;
                    Caption = 'Storage Account Name';
                    ToolTip = 'Specifies the value of the StorageAccount Name field.';
                }
                field("Shared Key"; Rec."Shared Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shared Key field.';
                }
            }
            group(Containers)
            {
                field("Container Name"; Rec."Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Container Name field.';
                }
                field(LastImportedFileName; Rec.LastImportedFileName)
                {
                    ApplicationArea = All;
                    Caption = 'Last Imported File Name';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreateContainer)
            {
                ApplicationArea = all;
                Caption = 'Create Container';
                Image = NewItemNonStock;

                trigger OnAction()
                begin
                    AzureAccess.CreateAzureContainer();
                end;
            }
            action(ListContainer)
            {
                ApplicationArea = all;
                Caption = 'List Container';
                Image = ShowList;

                trigger OnAction()
                begin
                    AzureAccess.ListAzureContainer();
                end;
            }
            action(DeleteContainer)
            {
                ApplicationArea = all;
                Caption = 'Delete Container';
                Image = Delete;

                trigger OnAction()
                begin
                    AzureAccess.DeleteAzureContainer();
                end;
            }
            action(ListContainerFiles)
            {
                ApplicationArea = all;
                Caption = 'List Container Files';
                Image = ShowList;

                trigger OnAction()
                begin
                    AzureAccess.listContainerFiles();
                end;
            }
            action(FetchData)
            {
                ApplicationArea = all;
                Caption = 'Fetch Data';
                Image = GetEntries;

                trigger OnAction()
                begin
                    AzureAccess.FetchAzureContainer();
                end;
            }
            action(InsertIntoContainer)
            {
                ApplicationArea = all;
                Caption = 'Insert Into Container';
                Image = Insert;

                trigger OnAction()
                begin
                    AzureAccess.InsertIntoAzureContainer();
                end;
            }
            action(DeleteContainerFiles)
            {
                ApplicationArea = all;
                Caption = 'Delete Container Files';
                Image = Delete;

                trigger OnAction()
                begin
                    AzureAccess.DeleteContainerFiles();
                end;
            }
        }
        area(Promoted)
        {
            group(Container)
            {
                actionref(CreateCont; CreateContainer)
                {

                }
                actionref(List; ListContainer)
                {

                }
                actionref(DeleteCont; DeleteContainer)
                {

                }
            }
            group("Files")
            {
                actionref(ListFiles; ListContainerFiles)
                {

                }
                actionref(Insert; InsertIntoContainer)
                {

                }
                actionref(Fetch1; FetchData)
                {

                }
                actionref(DeleteFIles; DeleteContainerFiles)
                {

                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    var
        AzureAccess: Codeunit AzureAccess;
}

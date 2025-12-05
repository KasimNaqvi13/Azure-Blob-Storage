table 90552 "Azure Blob Storage Setup"
{
    DrillDownPageId = "Azure Blob Storage Setup";
    LookupPageId = "Azure Blob Storage Setup";

    fields
    {
        field(1; "Primary Key"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Container Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "StorageAccount Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Shared Key"; Text[150])
        {
            DataClassification = ToBeClassified;

        }
        field(5; LastImportedFileName; Text[80])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
    var
        myInt: Integer;
}

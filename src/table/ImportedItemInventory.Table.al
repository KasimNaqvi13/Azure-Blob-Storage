table 90551 "Imported Item Inventory"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Vendor No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Inventory"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Last Updated Value"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Item Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Item No", "Vendor No")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ItemRec: Record Item;
    begin
        "Last Updated Value" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Updated Value" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;
}

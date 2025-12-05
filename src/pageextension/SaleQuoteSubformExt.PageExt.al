pageextension 90552 SaleQuoteSubformExt extends "Sales Quote Subform"
{
    layout
    {
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                SalesHeader: Record "Sales Header";
                TotalQuantity: Decimal;
                ItemRec: Record Item;
                SalesLines: Record "Sales Line";
            begin
                ItemRec.Init();
                TotalQuantity := 0;
                SalesLines.Reset();
                SalesLines.SetRange("Document No.", Rec."Document No.");
                SalesLines.SetRange("Document Type", Rec."Document Type");
                SalesLines.SetRange("No.", Rec."No.");
                if SalesLines.FindSet() then
                    repeat
                        TotalQuantity += SalesLines.Quantity;
                    until SalesLines.Next() = 0;
                if ItemRec.Get(Rec."No.") then begin
                    if ItemRec."Vendor No." = 'V02310' then
                        CheckMSCInventory(ItemRec."No.", TotalQuantity)
                    else
                        exit;
                end;
            end;
        }
    }
    local procedure CheckMSCInventory(ItemNo: Code[20]; ReqQty: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ImpInv: Record "Imported Item Inventory";
        Qty: Decimal;
        ItemRec: Record Item;
        Desc: Text[100];
    begin
        ItemRec.Init();
        ImpInv.Reset();
        ImpInv.SetRange("Item No", ItemNo);
        if ItemRec.Get(ItemNo) then begin
            if ImpInv.FindFirst() then begin
                Evaluate(Qty, ImpInv.Inventory);
                if Qty < ReqQty then Message('Item Details %1 - %2\Requested Quantity %3\Available Quantity %4\', ImpInv."Item No", ItemRec.Description, ReqQty, Qty);
            end;
        end;
    end;

    var
        myInt: Integer;
}

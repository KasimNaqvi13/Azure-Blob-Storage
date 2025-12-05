**Azure Blob Storage Inventory Import for Business Central**

**Project Overview**
- **Purpose**: Integrates Business Central with Azure Blob Storage to import vendor inventory (MSC-style XML/CSV) into a local `Imported Item Inventory` table and validate stock during sales quote/order entry.
- **Primary Use Case**: Periodically fetch inventory files uploaded to an Azure Blob container, import the inventory into Business Central, and use that data to validate requested quantities for a specific vendor (`V02310`).

**Architecture & Flow**
- **Setup**: Configure storage account and container in the `Azure Blob Storage Setup` page (`page 90552`). This stores `StorageAccount Name`, `Shared Key`, and `Container Name` in the `Azure Blob Storage Setup` table (`table 90552`).
- **Container Management**: The setup page exposes actions to create, list, and delete containers and to list/upload/delete container files; these call procedures in the `AzureAccess` codeunit.
- **Fetch & Import**:
  - `Fetch Data` action or `FetchAndSaveInventory` job calls `AzureAccess.FetchAzureContainer()`.
  - `FetchAzureContainer()` lists blobs and downloads the first blob to an `InStream`.
  - The code clears `Imported Item Inventory` (table 90551), then runs `Xmlport.Import(90551, Instr, ImportedItemInventory)` using `xmlport 90551 ImportMscXML` to populate records.
  - The imported file name is saved into `Last Imported File Name` in setup.
  - Optionally (current runner `FetchAndSaveInventory`), the extension deletes the remote files after fetching.
- **Sales Validation**: Page extensions for `Sales Quote Subform` and `Sales Order Subform` intercept `Quantity` validation. For items supplied by vendor `V02310`, they check `Imported Item Inventory` availability and show a message when requested quantity exceeds available inventory.

**Files & Responsibilities**
- **`codeunit\AzureAccess.Codeunit.al` (90552)**: Core orchestration for Azure Blob operations including create/list/delete container, list blobs, download blob as stream, upload via UI, and calling the XMLPort to import.
- **`codeunit\FetchAndSaveInventory.Codeunit.al` (90551)**: Simple runner that calls fetch + delete; useful for job queue scheduling.
- **`xmlport\ImportMscXML.XmlPort.al` (90551)**: Parses incoming file (VariableText) and inserts into `Imported Item Inventory`. It skips the first two rows (header rows) using `OnBeforeInsertRecord`/`OnPreXmlItem` triggers.
- **`table\AzureBlobStorageSetup.Table.al` (90552)** & **`page\AzureBlobStorageSetup.Page.al` (90552)**: Stores storage account, container, shared key and exposes container/file actions.
- **`table\ImportedItemInventory.Table.al` (90551)** & **`page\ImportedItemInventory.Page.al` (90551)**: Stores and displays imported inventory rows. Triggers set `Last Updated Value` automatically.
- **`pageextension\SalesOrderSubformExt.PageExt.al` / `SaleQuoteSubformExt.PageExt.al`**: Add inventory checks on `OnAfterValidate` for `Quantity` field and notify when requested exceeds available.
- **`permissionset\GeneratedPermission.PermissionSet.al` (90551)**: Permission set bundling required permissions for the extension.

**Setup & Deployment**
- **Prerequisites**: The AL Azure Blob client codeunits/interfaces (`ABS Blob Client`, `ABS Container Client`, `Storage Service Authorization`, `ABS Operation Response`, etc.) are required and are not part of this repository. Add the appropriate Azure Blob Storage AL dependency package (from marketplace or vendor).
- **Deploy**: Use VS Code with the AL extension to publish the extension to your Business Central instance (F5 to debug/publish or use your CI pipeline to build and publish the .app).
- **Configure**:
  - Open the `Azure Blob Storage Setup` page (search for `Azure Blob Storage Setup`).
  - Set `StorageAccount Name`, `Container Name`, and `Shared Key` (store sensitive keys securely).
  - Save the record.

**Usage**
- **Upload file to container**: Use `Insert Into Container` on the setup page to upload a local file via UI (uses ABS client `PutBlobBlockBlobUI`).
- **Manual fetch/import**: Click `Fetch Data` on the setup page. This downloads the first blob found and runs the XMLPort import.
- **Automatic jobs**: Schedule `FetchAndSaveInventory` (codeunit 90551) as a Job Queue entry for periodic fetch-and-delete processing.
- **Verify imported data**: Open `Imported Item Inventory` page. `Item Description` is populated at runtime by looking up the `Item` table for the `Item No`.

**Import Details**
- **Format**: `xmlport 90551 ImportMscXML` uses `Format = VariableText` and maps `Item No` and `Inventory` fields. The XMLPort intentionally skips the first two rows (commonly header lines) before inserting records.
- **Field mapping**: If your source file has additional columns (like `Vendor No` or `Description`), the XMLPort and table need to be extended to map them.
- **Data types**: The `Inventory` field is stored as `Code[50]` in `Imported Item Inventory`. Consider converting it to a numeric type if you plan arithmetic comparisons or aggregations.

**Sales Validation Behaviour**
- During quantity validation on quote/order lines the extension:
  - Totals quantity for the same line across the document.
  - If the `Item`'s `Vendor No.` equals `'V02310'`, it looks up the `Imported Item Inventory` for that `Item No`.
  - If a matching record exists, it evaluates the `Inventory` value and if available quantity < requested quantity, it shows a message containing item details.
  - If no `Imported Item Inventory` record exists, a message warns no inventory is available.

**Troubleshooting**
- **Missing ABS codeunits**: If runtime errors reference `ABS Blob Client` or similar missing objects, add the Azure Blob Storage AL dependency package.
- **Credentials errors**: Ensure `StorageAccount Name` and `Shared Key` are correct and have required permissions.
- **Wrong file parsed**: `FetchAzureContainer()` downloads the first blob returned by the list. Modify `FetchAzureContainer()` to select by filename or pattern if a specific file must be imported.
- **Unexpected CSV layout**: The XMLPort skips two header rows; adjust the `SkipRowsNo` logic in `xmlport 90551` if your file headers differ.
- **Import overwrites data**: Current flow deletes all rows in `Imported Item Inventory` before importing. Change this if you need merge/append behavior.

**Improvement Ideas**
- Add blob selection filters (by name pattern, date, or metadata) instead of always picking the first blob.
- Store import batches with metadata (source file name, timestamp, user) to enable audit/history.
- Convert `Inventory` to a numeric field; validate parsing in the XMLPort and add error handling for non-numeric values.
- Add detailed logging or a `ABS Import Log` table for diagnosing failures in non-interactive job runs.
- Add unit tests for XMLPort parsing logic and `CheckMSCInventory` behavior.

**Permissions**
- Use the `GeneratedPermission` permission set (`permissionset 90551`) to assign required access to users or service accounts.

**Object IDs**
- Main objects in this repo use IDs in the `90551`–`90552` range. If you merge with other extensions, verify IDs to avoid collisions.

**Contact / Next Steps**
- To have me add this file directly into the repository, it's already created in this project. If you'd like, I can:
  - Modify `FetchAzureContainer()` to pick blobs by pattern.
  - Convert `Inventory` to numeric and update XMLPort.
  - Add an import log table for diagnostics.

---
Generated: December 05, 2025

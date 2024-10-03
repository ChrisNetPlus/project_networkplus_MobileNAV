codeunit 50909 "NP MobileFunctions"
{
    procedure ImportEmployeeContracts()
    var
        SelectFile: Label 'Select File to upload';
        Complete: Label 'Import Completed';
        Rec_ExcelBuffer: Record "Excel Buffer";
        EmployeeContracts: Record "NP Employee Contracts";
        Rows: Integer;
        Columns: Integer;
        UploadIntoStream: InStream;
        SheetName: Text;
        UploadResult: Boolean;
        DialogCaption: Text;
        Name: Text;
        NVInStream: InStream;
        RowNo: Integer;
        OrderCount: Integer;
        Window: Dialog;
    begin
        Rec_ExcelBuffer.DeleteAll();
        Rows := 0;
        Columns := 0;
        DialogCaption := SelectFile;
        UploadResult := UploadIntoStream(DialogCaption, '', '', Name, NVInStream);
        If Name = '' then exit;
        SheetName := 'Upload';
        Rec_ExcelBuffer.Reset();
        if Rec_ExcelBuffer.FindSet() then
            Rec_ExcelBuffer.DeleteAll();
        Rec_ExcelBuffer.OpenBookStream(NVInStream, SheetName);
        Rec_ExcelBuffer.ReadSheet();
        Commit();
        Rows := Rec_ExcelBuffer.Count;
        OrderCount := 0;
        for RowNo := 2 to Rows do begin
            Window.Open('##1###################');
            OrderCount := OrderCount + 1;
            if GetValueAtIndex(RowNo, 1) <> '' then begin
                EmployeeContracts."Employee No." := GetValueAtIndex(RowNo, 1);
                Window.Update(1, EmployeeContracts."Employee No.");
            end;
            if GetValueAtIndex(RowNo, 2) <> '' then begin
                EmployeeContracts."First Name" := GetValueAtIndex(RowNo, 2);
            end;
            if GetValueAtIndex(RowNo, 3) <> '' then begin
                EmployeeContracts."Last Name" := GetValueAtIndex(RowNo, 3);
            end;
            if GetValueAtIndex(RowNo, 4) <> '' then begin
                EmployeeContracts."Contract Code" := GetValueAtIndex(RowNo, 4);
            End;
            if GetValueAtIndex(RowNo, 5) <> '' then begin
                EmployeeContracts."Workstream Code" := GetValueAtIndex(RowNo, 5);
            end;
            if GetValueAtIndex(RowNo, 6) <> '' then begin
                EmployeeContracts."Gang Code" := GetValueAtIndex(RowNo, 6);
            end;
            if not EmployeeContracts.Insert(false) then
                EmployeeContracts.Modify(false);
            Commit;
        end;
        Window.Close();
        Message(Complete);
    end;

    local procedure GetValueAtIndex(RowNo: Integer; ColNo: Integer): Text
    var
        Rec_ExcelBuffer: Record "Excel Buffer";
    begin
        If Rec_ExcelBuffer.Get(RowNo, ColNo) then
            exit(Rec_ExcelBuffer."Cell Value as Text");
    end;


    [EventSubscriber(ObjectType::Table, Database::"NP Mobile NAV Item Journal", 'OnAfterInsertEvent', '', false, false)]
    local procedure AddUserInfo(var Rec: Record "NP Mobile NAV Item Journal")
    var
        UserSetup: Record "User Setup";
        User: Record User;
    begin
        User.Reset();
        User.SetRange("User Security ID", Rec.SystemCreatedBy);
        if User.FindFirst() then begin
            UserSetup.Reset();
            UserSetup.SetRange("User ID", UserId);
            if UserSetup.FindFirst() then begin
                Rec.Depot := UserSetup."NP Default Location";
                Rec."Journal Batch Name" := UserSetup."NP Mobile Batch";
                Rec.Modify(false);
            end;
        end;
    end;

    procedure CreateItemJnl(MobItemJnl: Record "NP Mobile NAV Item Journal")
    var
        IJL: Record "Item Journal Line";
        IJBatch: Record "Item Journal Batch";
        NoSeries: Record "No. Series Line";
        DimSetEntry: Record "Dimension Set Entry";
        DimValue: Record "Dimension Value";
        DataTransSetup: Record "NP Data Transfer Setup";
        Locations: Record Location;
        ReservEntry: Record "Reservation Entry";
        ResEntryNo: Integer;
        RecordCount: Decimal;
        DocNo: Text;
        ContCode: Code[20];
        WkstrmCode: Code[20];
        NewSNo: Code[50];
    begin
        IJL.Init();
        Clear(DocNo);
        Clear(ContCode);
        Clear(WkstrmCode);
        IJBatch.Reset();
        IJBatch.SetRange("Journal Template Name", 'ITEM');
        IJBatch.SetRange(Name, MobItemJnl."Journal Batch Name");
        if IJBatch.FindFirst() then begin
            NoSeries.Reset();
            NoSeries.SetRange("Series Code", IJBatch."No. Series");
            if NoSeries.FindFirst() then begin
                DocNo := incstr(NoSeries."Last No. Used");
            end else begin
                DocNo := MobItemJnl."Journal Batch Name" + Format(Today);
                DocNo := DelChr(DocNo, '=', '/');
            end;
        end;
        Locations.Reset();
        Locations.SetRange(Code, MobItemJnl.Depot);
        if Locations.FindFirst() then begin
            ContCode := Locations."NP Default Contract Code";
            WkstrmCode := Locations."NP Default Workstream Code";
        end;
        IJL."Journal Template Name" := MobItemJnl."Journal Template Name";
        IJL."Journal Batch Name" := MobItemJnl."Journal Batch Name";
        IJL."Line No." := MobItemJnl."Entry No.";
        IJL."Posting Date" := Today;
        IJL."Document No." := DocNo;
        IJL."Entry Type" := IJL."Entry Type"::Sale;
        IJL.Validate("Item No.", MobItemJnl."Item No.");
        IJL.Validate("Location Code", MobItemJnl.Depot);
        IJL.Validate(Quantity, MobItemJnl.Quantity);
        IJL."NP Work / Job Ref." := MobItemJnl."Work / Job Reference";
        IJL.Validate("Shortcut Dimension 1 Code", MobItemJnl."Contract Code");
        IJL.Validate("Shortcut Dimension 2 Code", MobItemJnl."Workstream Code");
        IJL.Insert(false);
        Commit();
        DimValue.Reset();
        DimValue.SetRange("Dimension Code", 'GANG');
        DimValue.SetRange(Code, MobItemJnl.Gang);
        if DimValue.FindFirst() then begin
            DimSetEntry.Reset();
            DimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
            DimSetEntry."Dimension Set ID" := IJL."Dimension Set ID";
            DimSetEntry."Dimension Code" := 'GANG';
            DimSetEntry."Dimension Value Code" := MobItemJnl.Gang;
            DimSetEntry."Global Dimension No." := 3;
            if not DimSetEntry.Insert(false) then
                DimSetEntry.Modify(false);
        end;
        IJL.Modify(false);
        Commit();
        if MobItemJnl."First Serial No." <> '0' then begin
            Clear(NewSNo);
            RecordCount := 0;
            if ReservEntry.FindLast() then
                ResEntryNo := ReservEntry."Entry No."
            else
                ResEntryNo := 1;
            if MobItemJnl.Quantity = 1 then begin
                ReservEntry.Init();
                ReservEntry."Entry No." := ResEntryNo + 1;
                ReservEntry."Serial No." := MobItemJnl."First Serial No.";
                ReservEntry.Positive := false;
                ReservEntry."Source Subtype" := 1;
                ReservEntry."Quantity (Base)" := -1;
                ReservEntry.VALIDATE("Quantity (Base)", -1);
                ReservEntry."Source ID" := 'ITEM';
                ReservEntry.Validate("Item No.", MobItemJnl."Item No.");
                ReservEntry."Location Code" := MobItemJnl.Depot;
                ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Prospect;
                ReservEntry."Source Type" := Database::"Item Journal Line";
                ReservEntry."Source Batch Name" := MobItemJnl."Journal Batch Name";
                ReservEntry."Source Ref. No." := MobItemJnl."Entry No.";
                ReservEntry.Insert(false);
                Commit();
            end else
                if MobItemJnl.Quantity > 1 then begin
                    ResEntryNo := ResEntryNo + 1;
                    NewSNo := MobItemJnl."First Serial No.";
                    ReservEntry.Init();
                    ReservEntry."Entry No." := ResEntryNo;
                    ReservEntry.Positive := false;
                    ReservEntry."Source Subtype" := 1;
                    ReservEntry."Quantity (Base)" := -1;
                    ReservEntry.VALIDATE("Quantity (Base)", ReservEntry."Quantity (Base)");
                    ReservEntry."Source ID" := 'Item';
                    ReservEntry.Validate("Item No.", MobItemJnl."Item No.");
                    ReservEntry."Location Code" := MobItemJnl.Depot;
                    ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Prospect;
                    ReservEntry."Source Type" := Database::"Item Journal Line";
                    ReservEntry."Source Batch Name" := MobItemJnl."Journal Batch Name";
                    ReservEntry."Source Ref. No." := MobItemJnl."Entry No.";
                    ReservEntry."Serial No." := NewSNo;
                    ReservEntry.Insert(false);
                    Commit();
                    repeat
                        NewSNo := IncStr(NewSNo);
                        RecordCount := RecordCount + 1;
                        ResEntryNo := ResEntryNo + 1;
                        ReservEntry.Init();
                        ReservEntry."Entry No." := ResEntryNo;
                        ReservEntry.Positive := false;
                        ReservEntry."Source Subtype" := 1;
                        ReservEntry."Quantity (Base)" := -1;
                        ReservEntry.VALIDATE("Quantity (Base)", ReservEntry."Quantity (Base)");
                        ReservEntry."Source ID" := 'Item';
                        ReservEntry.Validate("Item No.", MobItemJnl."Item No.");
                        ReservEntry."Location Code" := MobItemJnl.Depot;
                        ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Prospect;
                        ReservEntry."Source Type" := Database::"Item Journal Line";
                        ReservEntry."Source Batch Name" := MobItemJnl."Journal Batch Name";
                        ReservEntry."Source Ref. No." := MobItemJnl."Entry No.";
                        ReservEntry."Serial No." := NewSNo;
                        ReservEntry.Insert(false);
                        Commit();
                    until RecordCount = (MobItemJnl.Quantity - 1);
                end;
        end;
        MobItemJnl."Jnl Created" := true;
        MobItemJnl.Modify(false);
        Commit();
        DataTransSetup.Get();
        if DataTransSetup."NP Post Mobile Jnl" = true then
            PostJournal(IJL);
    end;

    local procedure GetEntryNo(): Integer
    var
        MobJnl: Record "NP Mobile NAV Item Journal";
        EntryNo: Integer;
    begin
        MobJnl.SetFilter("Entry No.", '<>%1', 0);
        if MobJnl.FindLast() then
            EntryNo := MobJnl."Entry No." + 1
        else
            EntryNo := 1;
        exit(EntryNo);
    end;

    local procedure PostJournal(IJL: Record "Item Journal Line")
    var
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        ItemJnlPostBatch.Run(IJL);
    end;

}

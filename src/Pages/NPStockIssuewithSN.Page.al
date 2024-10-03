page 50909 "NP Stock Issue with SN"
{
    ApplicationArea = All;
    Caption = 'Stock Issue with SN';
    PageType = List;
    SourceTable = "NP Mobile NAV Item Journal";
    UsageCategory = Tasks;
    Permissions = tabledata "Dimension Set Entry" = RIM, tabledata "Reservation Entry" = RIMD, tabledata "NP Mobile NAV Item Journal" = RIMD;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Employee No."; Rec."Employee No.")
                {
                    ToolTip = 'Specifies the code for Employee No.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'User ID';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Work / Job Reference"; Rec."Work / Job Reference")
                {
                    ToolTip = 'Specifies the value of the Work / Job Reference field.', Comment = '%';
                }
                field("First Serial No."; Rec."First Serial No.")
                {
                    ToolTip = 'Specifies the value of the First Serial No. field.', Comment = '%';
                    Caption = 'First Serial No.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                    trigger OnValidate()
                    begin
                        if Rec.Quantity > 0 then begin
                            BuildJnl();
                        end;
                    end;
                }
                field(FieldControl; FieldControl)
                {

                }
            }
        }
    }
    local procedure BuildJnl()
    var
        MobJNL: Record "NP Mobile NAV Item Journal";
        DataTransSetup: Record "NP Data Transfer Setup";
        EmployeeContracts: Record "NP Employee Contracts";
        UserSetup: Record "User Setup";
    begin
        Rec."Journal Template Name" := 'ITEM';
        EmployeeContracts.Reset();
        EmployeeContracts.SetRange("Employee No.", Rec."Employee No.");
        if EmployeeContracts.FindFirst() then begin
            Rec."Contract Code" := EmployeeContracts."Contract Code";
            Rec."Workstream Code" := EmployeeContracts."Workstream Code";
            Rec.Gang := EmployeeContracts."Gang Code";
        end;
        UserSetup.Reset();
        UserSetup.SetRange("User ID", Rec."User ID");
        if UserSetup.FindFirst() then begin
            Rec.Depot := UserSetup."NP Default Location";
            Rec."Journal Batch Name" := UserSetup."NP Mobile Batch";
        end;
        Commit();
        DataTransSetup.Get();
        if DataTransSetup."NP Create Mobile Postings" = true then
            CreateItemJnl(Rec);
        Rec."Item No." := '';
        Rec."Work / Job Reference" := '';
        Rec."First Serial No." := '';
        Rec.Quantity := 0;
        Rec."Contract Code" := '';
        Rec."Workstream Code" := '';
        Rec.Gang := '';
        Rec."Journal Template Name" := '';
        Rec."Journal Batch Name" := '';
        Rec.Depot := '';
        Rec.Modify(false);
        MobileNAVObjectFunctions.RefreshCurrent(FieldControl);
    end;

    local procedure CreateItemJnl(MobItemJnl: Record "NP Mobile NAV Item Journal")
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
        EntryNo: Integer;
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
        EntryNo := 0;
        IJL.Reset();
        IJL.SetRange("Journal Template Name", 'ITEM');
        IJL.SetRange("Journal Batch Name", MobItemJnl."Journal Batch Name");
        if IJL.FindLast() then begin
            EntryNo := IJL."Line No." + 10000
        end else
            EntryNo := 10000;
        IJL.Init();
        IJL."Journal Template Name" := MobItemJnl."Journal Template Name";
        IJL."Journal Batch Name" := MobItemJnl."Journal Batch Name";
        IJL."Line No." := EntryNo;
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
                ReservEntry."Source Ref. No." := EntryNo;
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
                    ReservEntry."Source Ref. No." := EntryNo;
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
                        ReservEntry."Source Ref. No." := EntryNo;
                        ReservEntry."Serial No." := NewSNo;
                        ReservEntry.Insert(false);
                        Commit();
                    until RecordCount = (MobItemJnl.Quantity - 1);
                end;
        end;
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

    trigger OnOpenPage()
    begin
        if not Rec.Get(UserId) then begin
            Rec.Init();
            Rec."User ID" := UserId;
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetRecord()
    var
        Item: Record Item;
        ShowSerial: Boolean;

    begin
        FieldControl := '';
        ShowSerial := false;
        if Rec."Item No." <> '' then begin
            if item.Get(Rec."Item No.") then begin
                if Item."Item Tracking Code" <> '' then
                    ShowSerial := true;
            end else
                Rec."Item No." := '';
        end;
        if ShowSerial = false then
            MobileNAVObjectFunctions.SetFieldReadOnly(FieldControl, 'First Serial No.');
    end;

    var
        FieldControl: Text;
        MobileNAVObjectFunctions: Codeunit "MobileNAV Object Functions";
}

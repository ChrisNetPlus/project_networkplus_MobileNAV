page 50901 "NP Stock Issue"
{
    ApplicationArea = All;
    Caption = 'Stock Issue';
    PageType = List;
    SourceTable = "NP Mobile NAV Item Journal";
    UsageCategory = Lists;
    Permissions = tabledata "Dimension Set Entry" = RIM, tabledata "Reservation Entry" = RIMD, tabledata "NP Mobile NAV Item Journal" = RIMD;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Employee No."; Rec."Employee No.")
                {
                    ToolTip = 'Specifies the code for Employee No.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Work / Job Reference"; Rec."Work / Job Reference")
                {
                    ToolTip = 'Specifies the value of the Work / Job Reference field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                    trigger OnValidate()
                    begin
                        if Rec.Quantity > 0 then
                            BuildJnl();
                    end;
                }
            }
        }
    }
    local procedure BuildJnl()
    var
        TmpMobJNL: Record "NP Mobile NAV Item Journal";
        DelMobJNL: Record "NP Mobile NAV Item Journal";
        DataTransSetup: Record "NP Data Transfer Setup";
        EmployeeContracts: Record "NP Employee Contracts";
        Locations: Record Location;
        UserSetup: Record "User Setup";
        User: Record User;
    begin
        Rec."Journal Template Name" := 'ITEM';
        Rec.Depot := UserSetup."NP Default Location";
        Rec."Journal Batch Name" := UserSetup."NP Mobile Batch";
        EmployeeContracts.Reset();
        EmployeeContracts.SetRange("Employee No.", Rec."Employee No.");
        if EmployeeContracts.FindFirst() then begin
            Rec."Contract Code" := EmployeeContracts."Contract Code";
            Rec."Workstream Code" := EmployeeContracts."Workstream Code";
            Rec.Gang := EmployeeContracts."Gang Code";
        end;
        Commit();
        // TmpMobJNL.Reset();
        // TmpMobJNL.SetRange("Entry No.", 0);
        // if TmpMobJNL.FindFirst() then 
        begin
            TmpMobJNL.Init();
            TmpMobJNL.TransferFields(Rec);
            TmpMobJNL."Entry No." := GetEntryNo();
            TmpMobJNL.Insert(false);
        end;
        Commit();
        Rec."Employee No." := '';
        Rec."Item No." := '';
        Rec."Work / Job Reference" := '';
        Rec.Quantity := 0;
        Rec.Modify(false);
        DataTransSetup.Get();
        if DataTransSetup."NP Create Mobile Postings" = true then
            CreateItemJnl(TmpMobJNL);
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
        Locations.SetRange(Code, Rec.Depot);
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
            if GuiAllowed then
                Message(Format(IJL."Dimension Set ID"));
        end;
        IJL.Modify(false);
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

    trigger OnOpenPage()
    var
        TmpMobJNL: Record "NP Mobile NAV Item Journal";
    begin
        TmpMobJNL.Reset();
        TmpMobJNL.SetRange("Entry No.", 0);
        if TmpMobJNL.FindFirst() then
            TmpMobJNL.Delete(false);
    end;
}

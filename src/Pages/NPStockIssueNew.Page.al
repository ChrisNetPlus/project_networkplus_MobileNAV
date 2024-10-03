page 50910 "NP Stock Issue New"
{
    ApplicationArea = All;
    Caption = 'Stock Issue New';
    PageType = List;
    SourceTable = "NP Mobile NAV Item Journal";
    UsageCategory = Tasks;
    Permissions = tabledata "Dimension Set Entry" = RIM, tabledata "Reservation Entry" = RIMD;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the item on the journal line.';
                    Caption = 'Item No.';
                }
                field(EmployeeNo; Rec."Employee No.")
                {
                    ToolTip = 'Specifies the code for Employee No.';
                    Caption = 'Employee No.';
                }
                field(WorkInfo; Rec."Work / Job Reference")
                {
                    ToolTip = 'Specifies the code for Work / Job Referenc';
                    Caption = 'Work / Job Reference';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the number of units of the item to be included on the journal line.';
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 2;
                    trigger OnValidate()
                    begin
                        BuildJnl();
                    end;
                }
                field(ActionButton; ActionButton)
                {
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    local procedure BuildJnl()
    var
        TmpMobJNL: Record "NP Mobile NAV Item Jnl";
        DataTransSetup: Record "NP Data Transfer Setup";
        EmployeeContracts: Record "NP Employee Contracts";
        Locations: Record Location;
        UserSetup: Record "User Setup";
        User: Record User;
    begin
        if Rec.Quantity = 0 then exit;
        // Rec."Entry No." := GetEntryNo();
        Rec."Journal Template Name" := 'ITEM';
        User.Reset();
        User.SetRange("User Security ID", Rec.SystemCreatedBy);
        if User.FindFirst() then begin
            UserSetup.Reset();
            UserSetup.SetRange("User ID", User."User Name");
            if UserSetup.FindFirst() then begin
                Rec.Depot := UserSetup."NP Default Location";
                Rec."Journal Batch Name" := UserSetup."NP Mobile Batch";
                EmployeeContracts.Reset();
                EmployeeContracts.SetRange("Employee No.", Rec."Employee No.");
                if EmployeeContracts.FindFirst() then begin
                    Rec."Contract Code" := EmployeeContracts."Contract Code";
                    Rec."Workstream Code" := EmployeeContracts."Workstream Code";
                    Rec.Gang := EmployeeContracts."Gang Code";
                end;
            end;
        end;
        // Rec.Insert(false);
        DataTransSetup.Get();
        if DataTransSetup."NP Create Mobile Postings" = true then
            CreateItemJnl(Rec);
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
        UserSetup: Record "User Setup";
        Locations: Record Location;
    begin
        Rec."Entry No." := GetEntryNo();
        Rec.Insert(false);
    end;

    var
        BatchName: Text;
        FirstSerialNo: Code[50];
        LastSerialNo: Code[50];
        ActionButton: Text;
}

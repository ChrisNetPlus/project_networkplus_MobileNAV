page 50908 "NP Stock Take"
{
    ApplicationArea = All;
    Caption = 'Stock Take';
    PageType = Worksheet;
    SourceTable = "NP Stock Taking";
    InsertAllowed = false;
    DeleteAllowed = true;
    UsageCategory = Lists;
    Permissions = tabledata "Dimension Set Entry" = RIMD;
    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the journal is based on.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord();
                    ItemJournalLine.SetRange("Journal Template Name", 'PHYS. INVE');
                    if CurrentJnlBatchName = '' then
                        ItemJournalLine.SetRange("Journal Batch Name", 'DEFAULT')
                    else
                        ItemJournalLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
                    ItemJnlMgt.LookupName(CurrentJnlBatchName, ItemJournalLine);
                    Rec.SetFilter("Batch Name", CurrentJnlBatchName);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    ItemJnlMgt.CheckName(CurrentJnlBatchName, ItemJournalLine);
                    Rec.SetFilter("Batch Name", CurrentJnlBatchName);
                end;
            }
            field("For Review"; Rec."For Review")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'For Review';
                ToolTip = 'Specifies the batch has been sent to the Depot Manager for review';
                Editable = false;
            }
            field("Depot Manager"; Rec."Depot Manager")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Depot Manager';
                ToolTip = 'Specifies the batch Depot Manager for review';
                trigger OnValidate()
                var
                    Stocktake: Record "NP Stock Taking";
                begin
                    Stocktake.Reset();
                    Stocktake.SetRange("Batch Name", Rec."Batch Name");
                    if Stocktake.FindSet() then
                        repeat
                            Stocktake."Depot Manager" := Rec."Depot Manager";
                            Stocktake.ModifyAll("Depot Manager", Rec."Depot Manager");
                        until Stocktake.Next() = 0;
                    Page.Run(Page::"NP Stock Taking Sheet", Stocktake);
                end;
            }
            field("Stock Taken By"; Rec."Stock Taken By")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Stock Taken By';
                ToolTip = 'Specifies who sent the batch for review';
                Editable = false;
            }
            repeater(General)
            {
                field("Batch Name"; Rec."Batch Name")
                {
                    ToolTip = 'Specifies the value of the Batch Name field.';
                    Editable = false;
                }
                field("Depot Number"; Rec."Depot Number")
                {
                    ToolTip = 'Specifies the value of the Depot Number field.';
                    Editable = false;
                }
                field("Depot Name"; Rec."Depot Name")
                {
                    ToolTip = 'Specifies the value of the Depot Name field.';
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    Editable = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                    Editable = false;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ToolTip = 'The item category code for the related item';
                    Editable = false;
                }
                field("Product Type"; Rec."Product Type")
                {
                    ToolTip = 'Product Type';
                    Editable = false;
                }
                field("Serial Tracked"; Rec."Serial Tracked")
                {
                    ToolTip = 'Specifies if the item is Serial Tracked.';
                    Editable = false;
                }
                field("Quantity Counted"; Rec."Quantity Counted")
                {
                    ToolTip = 'Specifies the value of the Quantity Counted field.';
                    DecimalPlaces = 0 : 2;
                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        if Rec."For Review" = true then Error('You cannot enter a quantity when the journal is set for review - the journal must be re-opened first');
                        if Rec."Serial Tracked" then begin
                            if Rec."Qty. Calculated" <> Rec."Quantity Counted" then begin
                                Item.Get(Rec."Item No.");
                                Rec."Serial Numbers Required" := Rec."Quantity Counted";
                                Rec."Value Counted" := Rec."Quantity Counted" * Item."Unit Cost";
                                Rec."Qty. Variance" := Rec."Quantity Counted" - Rec."Qty. Calculated";
                                Rec."Value Variance" := (Rec."Quantity Counted" * Item."Unit Cost") - Rec."Value Calculated";
                                Rec.Modify();
                            end else begin
                                Item.Get(Rec."Item No.");
                                Rec."Serial Numbers Required" := 0;
                                Rec."Value Counted" := Rec."Quantity Counted" * Item."Unit Cost";
                                Rec."Qty. Variance" := Rec."Quantity Counted" - Rec."Qty. Calculated";
                                Rec."Value Variance" := (Rec."Quantity Counted" * Item."Unit Cost") - Rec."Value Calculated";
                                Rec.Modify();
                            end;
                        end else begin
                            Item.Get(Rec."Item No.");
                            Rec."Serial Numbers Required" := 0;
                            Rec."Value Counted" := Rec."Quantity Counted" * Item."Unit Cost";
                            Rec."Qty. Variance" := Rec."Quantity Counted" - Rec."Qty. Calculated";
                            Rec."Value Variance" := (Rec."Quantity Counted" * Item."Unit Cost") - Rec."Value Calculated";
                            Rec.Modify();
                        end;
                    end;
                }
                field("Serial Numbers Required"; Rec."Serial Numbers Required")
                {
                    ToolTip = 'Specifies the quantity of Serial Numbers required';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = false;
                }
                field("Contract Code"; Rec."Contract Code")
                {
                    ToolTip = 'Specifies the value of the Contract Code field.';
                    Visible = false;
                }
                field("Workstream Code"; Rec."Workstream Code")
                {
                    ToolTip = 'Specifies the value of the Workstream Code field.';
                    Visible = false;
                }
                field("Gang Code"; Rec."Gang Code")
                {
                    ToolTip = 'Specifies the value of the Gang Code field.';
                    Visible = false;
                }
                field("Qty. Calculated"; Rec."Qty. Calculated")
                {
                    ToolTip = 'Quantity Calculated at time of running populate function';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                    Visible = false;
                }
                field("Value Calculated"; Rec."Value Calculated")
                {
                    ToolTip = 'Value Calculated at time of running populate function';
                    Editable = false;
                    DecimalPlaces = 0 : 2;
                    Visible = false;
                }
                field("Value Counted"; Rec."Value Counted")
                {
                    ToolTip = 'Value Counted';
                    Editable = false;
                    DecimalPlaces = 0 : 2;
                    Visible = false;
                }
                field("Qty. Variance"; Rec."Qty. Variance")
                {
                    ToolTip = 'Qty. Variance';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                    Visible = false;
                }
                field("Value Variance"; Rec."Value Variance")
                {
                    ToolTip = 'Value Variance';
                    Editable = false;
                    DecimalPlaces = 0 : 2;
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Populate)
            {
                ApplicationArea = All;
                Caption = 'Populate';
                Image = Insert;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    FilterPage: Page "NP Stocktake Filters";
                begin
                    if Rec."Batch Name" = '' then
                        Error('You must enter a batch name first');
                    if Rec."For Review" = true then
                        Error('The journal is for review and must be reopened before this function can be used');
                    FilterPage.SetBatch(CurrentJnlBatchName);
                    FilterPage.Run();
                end;
            }
            action("Add Serial Numbers")
            {
                ApplicationArea = All;
                Caption = 'Add Serial Numbers';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "NP Serial Number Selection";
                RunPageLink = "Batch Name" = field("Batch Name"), "Item No." = field("Item No.");
                trigger OnAction()
                begin
                    if Rec."For Review" = true then begin
                        Error('The journal is for review and must be reopened before this function can be used');
                    end;
                    if Rec."Serial Tracked" = false then
                        Error('This Item is not Serial Tracked!');
                    if Rec."Serial Numbers Required" = 0 then
                        Error('You do not need to enter any serial numbers');
                end;
            }
            action("Send for Approval")
            {
                ApplicationArea = All;
                Caption = 'Send for Approval';
                Image = Approval;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    StockTaking: Record "NP Stock Taking";
                    SerialSelection: Record "NP Serial Number Selection";
                    User: Record User;
                    ZeroLineMessage: Label 'There are lines with zero quantity counted, do you wish to continue?';
                begin
                    if Rec."For Review" = true then
                        Error('The journal is for review and must be reopened before this function can be used');
                    if CheckTrackingExists(Rec."Batch Name", Rec."Depot Number") = true then begin
                        StockTaking.SetRange("Batch Name", Rec."Batch Name");
                        If StockTaking.FindSet() then
                            repeat
                                ForReview := true;
                                StockTaking."For Review" := true;
                                User.Get(UserSecurityId);
                                StockTaking."Stock Taken By" := User."User Name";
                                StockTaking.Modify();
                                Commit();
                            Until StockTaking.Next() = 0;
                        SendApprovalEmail(Rec);
                    end;
                end;
            }
            action(Reject)
            {
                ApplicationArea = All;
                Caption = 'Reject';
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    StockTaking: Record "NP Stock Taking";
                begin
                    if Rec."For Review" = false then
                        Error('The journal is already open');
                    StockTaking.SetRange("Batch Name", Rec."Batch Name");
                    If StockTaking.FindSet() then
                        repeat
                            ForReview := false;
                            StockTaking."For Review" := false;
                            StockTaking."Stock Taken By" := '';
                            StockTaking.Modify();
                            Commit();
                        Until StockTaking.Next() = 0;
                    SendReopenEmail(Rec);
                end;
            }
            action(Approve)
            {
                ApplicationArea = All;
                Caption = 'Approve';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    StockTaking: Record "NP Stock Taking";
                    SerialSelection: Record "NP Serial Number Selection";
                    Location: Record Location;
                    IJL: Record "Item Journal Line";
                    PostCU: Codeunit "Item Jnl.-Post Batch";
                    ExportInvData: Codeunit "NP ExportInventoryData";
                    ZeroLineMessage: Label 'There are lines with zero quantity counted, do you wish to continue?';
                begin
                    Location.Get(Rec."Depot Number");
                    if UserId <> Rec."Depot Manager" then
                        Error('You must be the Depot Manager for this Depot to run this function');
                    if Rec."For Review" = false then
                        Error('The journal must be for review before this function can be used');
                    if Confirm('Do you wish to post this journal?', false) then begin
                        CheckContractWorkstream(Rec."Batch Name", Rec."Depot Number");
                        StockTaking.Reset();
                        StockTaking.SetRange("Batch Name", Rec."Batch Name");
                        StockTaking.SetRange("Quantity Counted", 0);
                        if StockTaking.FindFirst() then begin
                            if Confirm(ZeroLineMessage, false) then begin
                                ExportInvData.BuildItemJournal(Rec."Batch Name", Rec."Depot Number");
                            end;
                        end else begin
                            ExportInvData.BuildItemJournal(Rec."Batch Name", Rec."Depot Number");
                        end;
                        IJL.SetRange("Journal Template Name", 'ITEM');
                        IJL.SetRange("Journal Batch Name", Rec."Batch Name");
                        if IJL.FindFirst() then begin
                            PostCU.Run(IJL);
                        end;
                    end;
                end;
            }
        }
    }
    local procedure CheckTrackingExists(BatchName: Code[20]; DepotNumber: Code[20]): Boolean
    var
        StockTaking: Record "NP Stock Taking";
        SerialSelection: Record "NP Serial Number Selection";
    begin
        StockTaking.Reset();
        StockTaking.SetRange("Batch Name", BatchName);
        StockTaking.SetRange("Serial Tracked", true);
        if StockTaking.FindSet() then begin
            SerialSelection.SetRange("Batch Name", StockTaking."Batch Name");
            SerialSelection.SetRange("Item No.", StockTaking."Item No.");
            SerialSelection.SetRange(Select, true);
            if SerialSelection.FindSet() then begin
                if SerialSelection.Count <> Abs(StockTaking."Serial Numbers Required") then
                    Error('Serial Numbers are missing for item ' + StockTaking."Item No.");
            end else
                Error('Serial Numbers are missing for item ' + StockTaking."Item No.");
        end;
        exit(true);
    end;

    local procedure CheckContractWorkstream(BatchName: Code[20]; DepotNumber: Code[20])
    var
        StockTaking: Record "NP Stock Taking";
    begin
        StockTaking.Reset();
        StockTaking.SetRange("Batch Name", BatchName);
        StockTaking.SetFilter("Contract Code", '%1', '');
        if StockTaking.FindFirst() then begin
            if StockTaking."Qty. Calculated" <> StockTaking."Quantity Counted" then
                Error('One or more line is missing a Contract Code');
        end;
        StockTaking.Reset();
        StockTaking.SetRange("Batch Name", BatchName);
        StockTaking.SetFilter("Workstream Code", '%1', '');
        if StockTaking.FindFirst() then
            if StockTaking."Qty. Calculated" <> StockTaking."Quantity Counted" then
                Error('One or more line is missing a Workstream Code');
    end;

    local procedure SendApprovalEmail(Rec: Record "NP Stock Taking")
    var
        UserSetup: Record "User Setup";
        ApprovalUser: Record "User Setup";
        User: Record User;
        Location: Record Location;
        EmailCU: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailSubject: Label 'A Stocktake Batch needs your review - ';
        EmailBody: Label 'Please review the stocktake batch and post';
    begin
        Location.Get(Rec."Depot Number");
        User.SetRange("User Name", Rec."Depot Manager");
        If User.FindFirst() then begin
            EmailMessage.Create(User."Contact Email", EmailSubject + Rec."Batch Name", EmailBody);
            EmailCU.Send(EmailMessage);
        end;
    end;

    local procedure SendReopenEmail(Rec: Record "NP Stock Taking")
    var
        UserSetup: Record "User Setup";
        ApprovalUser: Record "User Setup";
        User: Record User;
        Location: Record Location;
        EmailCU: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailSubject: Label 'Your Stocktake Batch has been rejected - ';
        EmailBody: Label 'For more info please contact your Depot Manager ';
    begin
        Location.Get(Rec."Depot Number");
        User.SetRange("User Name", Rec."Stock Taken By");
        If User.FindFirst() then begin
            EmailMessage.Create(User."Contact Email", EmailSubject + Rec."Batch Name", EmailBody + Rec."Depot Manager");
            EmailCU.Send(EmailMessage);
        end;
    end;

    trigger OnOpenPage()
    begin
        if UserSetup.Get(UserId) then begin
            CurrentJnlBatchName := UserSetup."NP Stocktake Batch";
            Rec.SetFilter("Batch Name", CurrentJnlBatchName);
        end;
    end;

    var
        ItemJournalLine: Record "Item Journal Line";
        UserSetup: Record "User Setup";
        Item: Record Item;
        Location: Record Location;
        CurrentJnlBatchName: Code[10];
        LocationSelection: Code[20];
        CalcQtyOnHand: Report "Calculate Inventory";
        ItemJnlMgt: Codeunit ItemJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        ItemJournalErrorsMgt: Codeunit "Item Journal Errors Mgt.";
        ItemDescription: Text[100];
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;
        EntryTypeErr: Label 'You cannot use entry type %1 in this journal.', Comment = '%1 - Entry Type';
        JnlSerialNo: Code[20];
        ForReview: Boolean;
        Post: Boolean;

}

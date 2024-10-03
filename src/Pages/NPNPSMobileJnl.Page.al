page 50904 "NP NPS Mobile Jnl"
{
    ApplicationArea = All;
    Caption = 'NPS Mobile Jnl';
    PageType = List;
    SourceTable = "NP Mobile NAV Item Journal";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Employee No."; Rec."Employee No.")
                {

                }
                field("User ID"; Rec."User ID")
                {

                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ToolTip = 'Specifies the value of the Journal Template field.', Comment = '%';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ToolTip = 'Specifies the value of the Journal Batch field.', Comment = '%';
                }
                field(Depot; Rec.Depot)
                {
                    ToolTip = 'Specifies the value of the Depot field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Contract Code"; Rec."Contract Code")
                {
                    ToolTip = 'Specifies the value of the Contract Code field.', Comment = '%';
                }
                field("Workstream Code"; Rec."Workstream Code")
                {
                    ToolTip = 'Specifies the value of the Workstream Code field.', Comment = '%';
                }
                field(Gang; Rec.Gang)
                {
                    ToolTip = 'Specifies the value of the Gang field.', Comment = '%';
                }
                field("Work / Job Reference"; Rec."Work / Job Reference")
                {
                    ToolTip = 'Specifies the value of the Work / Job Reference field.', Comment = '%';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("First Serial No."; Rec."First Serial No.")
                {
                    ToolTip = 'Specifies the value of the First Serial No. field.', Comment = '%';
                }
                field("Last Serial No."; Rec."Last Serial No.")
                {
                    ToolTip = 'Specifies the value of the First Serial No. field.', Comment = '%';
                }
                field("Jnl Created"; Rec."Jnl Created")
                {
                    ToolTip = 'Jnl Created';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Process)
            {
                ApplicationArea = All;
                Caption = 'Process';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    MobileFunctions: Codeunit "NP MobileFunctions";
                begin
                    if Rec."Jnl Created" = true then
                        Error('This entry has already been processed');
                    MobileFunctions.CreateItemJnl(Rec);
                end;
            }
        }
    }
}

page 50906 "NP Employee Contracts"
{
    ApplicationArea = All;
    Caption = 'Employee Contract Codes';
    PageType = List;
    SourceTable = "NP Employee Contracts";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Employee No."; Rec."Employee No.")
                {
                    ToolTip = 'Specifies the value of the Employee No. field.', Comment = '%';
                }
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field.', Comment = '%';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field.', Comment = '%';
                }
                field("Contract Code"; Rec."Contract Code")
                {
                    ToolTip = 'Specifies the value of the Contract Code field.', Comment = '%';
                }
                field("Contract Name"; Rec."Contract Name")
                {
                    ToolTip = 'Specifies the value of the Contract Name field.', Comment = '%';
                    Editable = false;
                }
                field("Workstream Code"; Rec."Workstream Code")
                {
                    ToolTip = 'Specifies the value of the Workstream Code field.', Comment = '%';
                }
                field("Workstream Name"; Rec."Workstream Name")
                {
                    ToolTip = 'Specifies the value of the Workstream Name field.', Comment = '%';
                    Editable = false;
                }
                field("Gang Code"; Rec."Gang Code")
                {
                    ToolTip = 'Specifies the value of the Gang Code field.', Comment = '%';
                }
                field("Gang Name"; Rec."Gang Name")
                {
                    ToolTip = 'Specifies the value of the Gang Name field.', Comment = '%';
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Import Employees")
            {
                ApplicationArea = All;
                Caption = 'Import Employees';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    MobFunct: Codeunit "NP MobileFunctions";
                begin
                    if Confirm('Do you wish to import records from Excel?', false) then
                        MobFunct.ImportEmployeeContracts();
                end;

            }
        }
    }
}

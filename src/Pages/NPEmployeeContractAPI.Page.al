page 50912 "NP Employee Contract API"
{
    APIGroup = 'npsAPI';
    APIPublisher = 'networkPlus';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'employeeContractAPI';
    DelayedInsert = true;
    ModifyAllowed = true;
    EntityName = 'employeeContract';
    EntitySetName = 'employeeContracts';
    PageType = API;
    SourceTable = "NP Employee Contracts";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(employeeNo; Rec."Employee No.")
                {
                    Caption = 'Employee No.';
                }
                field(firstName; Rec."First Name")
                {
                    Caption = 'First Name';
                }
                field(lastName; Rec."Last Name")
                {
                    Caption = 'Last Name';
                }
                field(gangCode; Rec."Gang Code")
                {
                    Caption = 'Gang Code';
                }
            }
        }
    }
}

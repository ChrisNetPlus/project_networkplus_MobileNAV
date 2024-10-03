table 50904 "NP Employee Contracts"
{
    Caption = 'Employee Contracts';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Employee No."; Code[30])
        {
            Caption = 'Employee No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Gang Code"; Code[20])
        {
            Caption = 'Gang Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code where("Dimension Code" = filter('GANG'));
        }
        field(3; "Contract Code"; Code[20])
        {
            Caption = 'Contract Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code where("Dimension Code" = filter('CONTRACT'));
        }
        field(4; "Workstream Code"; Code[20])
        {
            Caption = 'Workstream Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code where("Dimension Code" = filter('WORKSTREAM'));
        }
        field(5; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = SystemMetadata;
        }
        field(6; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            DataClassification = SystemMetadata;
        }
        field(7; "Gang Name"; Text[100])
        {
            Caption = 'Gang Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Value".Name where("Dimension Code" = filter('GANG'), Code = field("Gang Code")));
        }
        field(8; "Contract Name"; Text[100])
        {
            Caption = 'Contract Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Value".Name where("Dimension Code" = filter('CONTRACT'), Code = field("Contract Code")));
        }
        field(9; "Workstream Name"; Text[100])
        {
            Caption = 'Workstream Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Value".Name where("Dimension Code" = filter('WORKSTREAM'), Code = field("Workstream Code")));
        }
    }
    keys
    {
        key(PK; "Employee No.")
        {
            Clustered = true;
        }
    }
}

table 50902 "NP Mobile NAV Item Journal"
{
    Caption = 'Mobile NAV Item Journal';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; Depot; Code[20])
        {
            Caption = 'Depot';
            DataClassification = SystemMetadata;
        }
        field(3; "Item No."; Code[50])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Contract Code"; Code[20])
        {
            Caption = 'Contract Code';
            DataClassification = SystemMetadata;
        }
        field(5; "Workstream Code"; Code[20])
        {
            Caption = 'Workstream Code';
            DataClassification = SystemMetadata;
        }
        field(6; Gang; Code[20])
        {
            Caption = 'Gang';
            DataClassification = SystemMetadata;
        }
        field(7; "Work / Job Reference"; Text[50])
        {
            Caption = 'Work / Job Reference';
            DataClassification = SystemMetadata;
        }
        field(8; "Journal Batch Name"; Code[20])
        {
            Caption = 'Journal Batch';
            DataClassification = SystemMetadata;
        }
        field(9; "Journal Template Name"; Code[20])
        {
            Caption = 'Journal Template';
            DataClassification = SystemMetadata;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
        }
        field(12; "First Serial No."; Code[50])
        {
            Caption = 'First Serial No.';
            DataClassification = SystemMetadata;
        }
        field(11; "Last Serial No."; Code[50])
        {
            Caption = 'Last Serial No.';
            DataClassification = SystemMetadata;
        }

        field(14; "Employee No."; Code[30])
        {
            Caption = 'Employee No.';
            DataClassification = SystemMetadata;
        }
        field(15; "Jnl Created"; Boolean)
        {
            Caption = 'Jnl Created';
            DataClassification = SystemMetadata;
        }
        field(16; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = SystemMetadata;
        }
        field(17; "Return Reason"; Code[10])
        {
            Caption = 'Return Reason';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
    }
}

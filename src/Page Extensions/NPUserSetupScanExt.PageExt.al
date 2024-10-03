pageextension 50901 "NP UserSetupScanExt" extends "User Setup"
{
    layout
    {
        addafter("NP Stocktake Batch")
        {
            field("NP Default Location"; Rec."NP Default Location")
            {
                ApplicationArea = All;
                Caption = 'Default Depot';
                ToolTip = 'Default Depot';
            }
            field("NP Mobile Batch"; Rec."NP Mobile Batch")
            {
                ApplicationArea = All;
                Caption = 'Mobile Batch';
                ToolTip = 'Mobile Batch';
            }
        }
    }
}

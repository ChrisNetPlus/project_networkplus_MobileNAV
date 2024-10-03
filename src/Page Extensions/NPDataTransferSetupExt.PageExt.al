pageextension 50900 "NP DataTransferSetupExt" extends "NP Data Transfer Setup"
{
    layout
    {
        addafter("WS Username")
        {
            field("NP Create Mobile Postings"; Rec."NP Create Mobile Postings")
            {
                ApplicationArea = All;
                Caption = 'Create Mobile Postings';
                ToolTip = 'Create Mobile Postings';
            }
            field("NP Post Mobile Jnl"; Rec."NP Post Mobile Jnl")
            {
                ApplicationArea = All;
                Caption = 'Post Mobile Jnl';
                ToolTip = 'Post Mobile Jnl';
            }
        }
    }
}

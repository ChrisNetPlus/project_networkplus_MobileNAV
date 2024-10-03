tableextension 50900 "NP DataTransSetExt" extends "NP Data Transfer Setup"
{
    fields
    {
        field(50900; "NP Create Mobile Postings"; Boolean)
        {
            Caption = 'Create Mobile Postings';
            DataClassification = SystemMetadata;
        }
        field(50901; "NP Post Mobile Jnl"; Boolean)
        {
            Caption = 'Post Mobile Jnl';
            DataClassification = SystemMetadata;
        }
    }
}

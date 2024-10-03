tableextension 50901 "NP UserSetupScanExt" extends "User Setup"
{
    fields
    {
        field(50900; "NP Default Location"; Code[20])
        {
            Caption = 'Default Location';
            DataClassification = SystemMetadata;
            TableRelation = Location.Code;
        }
        field(50901; "NP Mobile Batch"; Code[20])
        {
            Caption = 'Mobile Batch';
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = filter('ITEM'));
        }
    }
}

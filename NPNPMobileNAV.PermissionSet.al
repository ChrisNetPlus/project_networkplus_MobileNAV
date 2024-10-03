permissionset 50900 "NP NP_Mobile_NAV"
{
    Assignable = true;
    Permissions = page "NP Item Journal MOB" = X,
        page "NP Stock Issue" = X,
        tabledata "NP Mobile NAV Item Journal" = RIMD,
        table "NP Mobile NAV Item Journal" = X,
        page "NP NPS Mobile Jnl" = X,
        tabledata "NP Mobile NAV Item Jnl" = RIMD,
        table "NP Mobile NAV Item Jnl" = X,
        page "NP NPS Mobile Tmp" = X,
        page "NP Stock Issue with SN" = X,
        page "NP Stock Take" = X,
        tabledata "NP Employee Contracts" = RIMD,
        table "NP Employee Contracts" = X,
        codeunit "NP MobileFunctions" = X,
        page "NP Employee Contracts" = X,
        page "NP Stock Issue by Gang" = X,
        page "NP Stock Issue New" = X;
}
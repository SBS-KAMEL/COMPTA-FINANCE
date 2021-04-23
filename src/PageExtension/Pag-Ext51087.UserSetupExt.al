pageextension 51087 "UserSetupExt" extends "User Setup"
{
    layout
    {
        addafter("User ID")
        {
            field(Name; Name)
            {
                ApplicationArea = All;
            }
        }
    }

}
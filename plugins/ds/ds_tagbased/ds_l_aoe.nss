/// ----------------------------------------------------------------------------
/// @file   ds_l_aoe.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Tagbased Scripting (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"
#include "util_i_data"


/*
void aoe_tag()
{
    string sEvent = GetCurrentEvent();
    object oPC, oAOE = OBJECT_SELF;

    if (sEvent == AOE_EVENT_ON_ENTER)
    {
        oPC = GetEnteringObject();

    }
    else if (sEvent == AOE_EVENT_ON_EXIT)
    {
        oPC = GetExitingObject();

    }
    else if (sEvent == AOE_EVENT_ON_HEARTBEAT)
    {

    }
}
*/

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    int n;
    // RegisterLibraryScript("aoe_tag", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            //if      (nEntry == n++) aoe_tag();
            //else if (nEntry == n++) something_else();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in ds_l_aoe.nss");
    }
}

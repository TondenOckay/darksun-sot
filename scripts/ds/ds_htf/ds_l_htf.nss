// -----------------------------------------------------------------------------
//    File: ds_l_htf.nss
//  System: Hunger Thirst Fatigue (Dark Sun) (library)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_c_htf"
#include "ds_k_htf"
#include "ds_e_htf"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("ds");

    // ----- Local Events -----
    if (HUNGERTHIRST_ACTIVE || FATIGUE_ACTIVE)
    {
        RegisterEventScripts(oPlugin, AREA_EVENT_ON_ENTER, "ds_htf_OnAreaEnter",                9.0);
        RegisterEventScripts(oPlugin, AREA_EVENT_ON_EXIT,  "ds_htf_OnAreaExit",                 9.0);
    }

    // ----- Timer Events -----
    if (HUNGERTHIRST_ACTIVE || FATIGUE_ACTIVE)
        RegisterEventScripts(oPlugin, DS_HTF_AREA_ON_TIMER_EXPIRE, "ds_htf_area_OnTimerExpire", 9.0);

    // ----- Local Events -----
    if (HUNGERTHIRST_ACTIVE || FATIGUE_ACTIVE)
    {
        RegisterLibraryScript("ds_htf_OnAreaEnter",        1);
        RegisterLibraryScript("ds_htf_OnAreaExit",         2);
    }

    // ----- Timer Events -----
    if (HUNGERTHIRST_ACTIVE || FATIGUE_ACTIVE)
        RegisterLibraryScript("ds_htf_area_OnTimerExpire", 3);
}

void OnLibraryScript(string sScript, int nEntry)
{
    if (!HUNGERTHIRST_ACTIVE && !FATIGUE_ACTIVE)
        {
            CriticalError("Library function called on inactive system (DS_HTF)");
            return;
        }

    switch (nEntry)
    {
        case 1: ds_htf_OnAreaEnter();        break;
        case 2: ds_htf_OnAreaExit();         break;
        case 3: ds_htf_area_OnTimerExpire(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}

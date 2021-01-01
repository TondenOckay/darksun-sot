// -----------------------------------------------------------------------------
//    File: ds_fug_i_events.nss
//  System: Fugue Death and Resurrection (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for DS Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
#include "ds_fug_i_main"
#include "util_i_data"
#include "core_i_framework"
#include "util_i_math"
#include "util_i_time"
#include "core_i_database"
#include "util_i_chat"
//
// ---< ds_fug_OnPlayerDeath >---
// Upon death, drop all henchmen, generate a random number between 0 and 100
// If it is below the Angel value, the PC goes to the Fugue
// If it is greater the PC goes to the Angel's Home
// TODO - Druids or Rangers who die cannot respawn their familiar until they clear a condition.
void ds_fug_OnPlayerDeath();

// ---< ds_fug_OnClientEnter >---
// When the Player Character enters the module, store the date / time they showed up.
// This will be used later on to see how long it has been since they last died.
// TODO - This will be replaced by the OnPlayerRegistration capability that tinygiant is producing
void ds_fug_OnClientEnter();

// ---< chat_die >---
// Used for testing.  When the PC types the command .die in chat, it kills the PC
void chat_die();

void ds_fug_OnClientEnter()
{
    Notice("Running the ds_fug_OnClientEnter script.");
    object oPC = GetEnteringObject();
    Notice(GetName(oPC) + " has entered the start area.");
    string sTime = GetGameTime();
    Notice("The current game time is " + sTime);
    SetDatabaseString("pc_enter_time", sTime, oPC);
    string sTimeRead = GetDatabaseString("pc_enter_time", oPC);
    Notice("The time read back from the database is " + sTimeRead);
}

void ds_fug_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    if (_GetLocalInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;  //PC ain't dead.  Return.

    // Generate a Random Number for Now
    // TODO -   Develop real rules based on many other things including recency of last death, alignment stray...
    int iRnd = d100();
    int iChance = clamp(DS_FUGUE_ANGEL_CHANCE, 0, 100);

    Notice("ds_fug_OnPlayerDeath: " +
            "\n  iChance = " + IntToString(iChance) +
            "\n  iRnd   = " + IntToString(iRnd));

    // Let the PW Fugue system take it from here.
    if (iRnd < (100-iChance))
    {
        Notice("Sending " + GetName(oPC) + " to the Fugue");
        return;
    }

	if (GetTag(GetArea(oPC)) == ANGEL_PLANE)
    {
		//If you're already at the Angel, just make sure you're alive and healed.
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
            return;
    }
    else
    {
		Notice("Sending " + GetName(oPC) + " to the Angel");
		h2_DropAllHenchmen(oPC);
        SendPlayerToAngel(oPC);   
    }
    SetEventState(EVENT_STATE_ABORT);
}

void chat_die()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;
    
    int iHP = GetCurrentHitPoints(oPC) + 11;
    effect eDam = EffectDamage(iHP);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oPC);
    SendChatResult("OK.  You're dead, then.", oPC);
}
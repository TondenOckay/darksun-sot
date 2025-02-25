// -----------------------------------------------------------------------------
//    File: pw_e_quest.nss
//  System: PC Corspe Loot (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "quest_i_const"
#include "quest_i_main"
#include "util_i_chat"
#include "util_i_argstack"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for OnModuleLoad.  Creates the module quest tables.
void quest_OnModuleLoad();

/// @brief Event handler for OnClientEnter.  Creates the player character
///     quest tables.
void quest_OnClientEnter();

/// @brief Event handler for OnAcquireItem.  Signals quest progress when
///    a player character acquires an item.
void quest_OnAcquireItem();

/// @brief Event handler for OnUnacquireItem.  Signals quest regress when
///    a player character loses an item.
void quest_OnUnacquireItem();

/// @brief Event handler for OnAreaEnter.  Signals quest progress when
///     a player character enters an area.
void quest_OnAreaEnter();

/// @brief Event handler for OnTriggerEnter.  Signals quest progress when
///     a player character enters a trigger.
void quest_OnTriggerEnter();

/// @brief Event handler for OnPlayerChat.
void quest_OnPlayerChat();


// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void quest_OnModuleLoad()
{
    // put dialog into library load routine
       // LoadLibrary("quest_l_dialog");
    CreateModuleQuestTables(TRUE);
}

void quest_OnClientEnter()
{
//    object oPC = GetEnteringObject();
//    CreatePCQuestTables(oPC);
//    UpdatePCQuestTables(oPC);
//    CleanPCQuestTables(oPC);
//    UpdateJournalQuestEntries(oPC);
}

void quest_OnAcquireItem()
{
//    object oItem = GetModuleItemAcquired();
//    object oPC = GetModuleItemAcquiredBy();

//    if (GetIsPC(oPC))
//        SignalQuestStepProgress(oPC, GetTag(oItem), QUEST_OBJECTIVE_GATHER);
}

void quest_OnUnacquireItem()
{
    object oItem = GetModuleItemLost();
    object oPC = GetModuleItemLostBy();

//    if (GetIsPC(oPC))
//        SignalQuestStepRegress(oPC, GetTag(oItem), QUEST_OBJECTIVE_GATHER);
}

void quest_OnAreaEnter()
{
    object oPC = GetEnteringObject();
    string sArea = GetTag(OBJECT_SELF);

//    if (GetIsPC(oPC))
//        SignalQuestStepProgress(oPC, sArea, QUEST_OBJECTIVE_DISCOVER);
}

void quest_OnTriggerEnter()
{
    object oPC = GetEnteringObject();
    string sTrigger = GetTag(OBJECT_SELF);

//    if (GetIsPC(oPC))
//        SignalQuestStepProgress(oPC, sTrigger, QUEST_OBJECTIVE_DISCOVER);
}

void QUEST_GetQuestString()
{
//    string sQuestTag = PopString();
//    int nStep = PopInt();

//    string sMessage = GetQuestWebhookMessage(sQuestTag, nStep);
//    PushString(sMessage);
}

void QUEST_GetCurrentQuest()
{
//    string sQuestTag = GetCurrentQuest();
//    PushString(sQuestTag);
}

void QUEST_GetCurrentQuestStep()
{
//    int nStep = GetCurrentQuestStep();
//    PushInt(nStep);
}

void QUEST_GetCurrentQuestEvent()
{
//    PushInt(GetCurrentQuestEvent());
}

void QUEST_GetCurrentWebhookMessage()
{
//    string sQuestTag = GetCurrentQuest();
//    int nEvent = GetCurrentQuestEvent();
//    int nStep, nQuestID = GetQuestID(sQuestTag);

//    if (nEvent == QUEST_EVENT_ON_ASSIGN)
//        nStep = 0;
//    else if (nEvent == QUEST_EVENT_ON_ACCEPT)
//        nStep = 0;
//    else if (nEvent == QUEST_EVENT_ON_ADVANCE)
//        nStep = GetCurrentQuestStep();
//    else if (nEvent == QUEST_EVENT_ON_COMPLETE)
//        nStep = GetQuestCompletionStep(nQuestID, QUEST_ADVANCE_SUCCESS);
//    else if (nEvent == QUEST_EVENT_ON_FAIL)
//        nStep = GetQuestCompletionStep(nQuestID, QUEST_ADVANCE_FAIL);

//    string sMessage = GetQuestWebhookMessage(sQuestTag, nStep);
//    PushString(sMessage);
}

void quest_OnPlayerChat()
{
//    object oPC = GetPCChatSpeaker();
//    if (HasChatOption(oPC, "dump"))
//    {
//        string sQuery;
//        int nQuestCount;
//
//        string sQuestTag = GetChatArgument(oPC);
//        
//        if (HasChatOption(oPC, "pc"))
//        {
//            if (sQuestTag == "")
//                sQuery = "SELECT quest_tag " +
//                         "FROM quest_pc_data;";
//            else
//                sQuery = "SELECT quest_tag " +
//                         "FROM quest_pc_data " +
//                         "WHERE quest_tag = @sQuestTag;";
//
//            sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
//            if (sQuestTag != "")
//                SqlBindString(sql, "@sQuestTag", sQuestTag);
//            
//            Debug(ColorTitle("Starting PC quest data dump..."));
//
//            while (SqlStep(sql))
//            {
//                nQuestCount++;
//                ResetIndent();
//                sQuestTag = SqlGetString(sql, 0);
//                DumpPCQuestData(oPC, sQuestTag);
//                DumpPCQuestVariables(oPC, sQuestTag);
//            }
//
//            if (nQuestCount == 0)
//            {
//                string s = Indent(TRUE);
//                Debug(ColorFail(s + "No quest data found on " + PCToString(oPC)));
//            }
//        }
//        else
//        {        
//            if (sQuestTag == "")
//                sQuery = "SELECT sTag " +
//                        "FROM quest_quests;";
//            else
//                sQuery = "SELECT sTag " +
//                        "FROM quest_quests " +
//                        "WHERE sTag = @sQuestTag;";
//
//            sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
//            if (sQuestTag != "")
//                SqlBindString(sql, "@sQuestTag", sQuestTag);
//
//            Debug(ColorTitle("Starting quest data dump..."));
//
//            while(SqlStep(sql))
//            {
//                nQuestCount++;
//                ResetIndent();
//                sQuestTag = SqlGetString(sql, 0);
//                DumpQuestData(sQuestTag);
//                DumpQuestVariables(sQuestTag);
//            }
//
//            if (nQuestCount == 0)
//            {
//                string s = Indent(TRUE);
//                Debug(ColorFail(s + "No quests loaded into module database"));
//            }
//        }
//
//        return;
//    }
//
//    if (HasChatOption(oPC, "reset"))
//    {
//        if (HasChatOption(oPC, "pc"))
//        {
//            CreatePCQuestTables(oPC, TRUE);
//            SendChatResult("Quest tables for " + PCToString(oPC) + " have been reset", oPC);
//        }
//        else
//        {
//            CreateModuleQuestTables(TRUE);
//            RunLibraryScript("ds_quest_OnModuleLoad");
//            SendChatResult("Module quest tables have been reset", oPC);
//        }
//
//        return;
//    }
}

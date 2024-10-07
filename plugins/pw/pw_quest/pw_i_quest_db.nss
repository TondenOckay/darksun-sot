// -----------------------------------------------------------------------------
//    File: quest_i_database.nss
//  System: Quest Control System
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

/*
    This file contains all the database-related code to support the quest system.
    All sqlite formations and calls should be in this file.  NWN-organic sqlite
    database for the PC (persistent) and the module (volatile) are used.  The
    campaign sqlite db (persistent) is not used in this implementation.  Generally,
    this file should not be modified in any way unless you know exactly what you
    are doing.  All SQL sequences are built as strings and the compiler has no
    way of verifying their veracity until they are run against an sqlite database.

    This is an internal-use file, so very few function prototypes are provided, and
    they are provided in the primary quest system file.
*/

string sQuery;
sqlquery sql;

void CreateModuleQuestTables(int bReset = FALSE)
{
    // Define the tables
    string sQuests = "CREATE TABLE IF NOT EXISTS quest_quests (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "sTag TEXT NOT NULL default '~' UNIQUE ON CONFLICT IGNORE, " +
                        "nActive TEXT NOT NULL default '1', " +
                        "sJournalTitle TEXT default NULL, " +
                        "nRepetitions TEXT default '1', " +
                        "sScriptOnAssign TEXT default NULL, " +
                        "sScriptOnAccept TEXT default NULL, " +
                        "sScriptOnAdvance TEXT default NULL, " +
                        "sScriptOnComplete TEXT default NULL, " + 
                        "sScriptOnFail TEXT default NULL, " +
                        "sTimeLimit TEXT default NULL, " +
                        "sCooldown TEXT default NULL, " +
                        "nJournalHandler TEXT default '1', " +
                        "nRemoveJournalOnComplete TEXT default '0', " +
                        "nAllowPrecollectedItems TEXT default '1', " +
                        "nRemoveQuestOnCompleted TEXT default '0', " +
                        "nQuestVersion TEXT default '0', " +
                        "nQuestVersionAction TEXT default '0');";

    string sQuestPrerequisites = "CREATE TABLE IF NOT EXISTS quest_prerequisites (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "quests_id INTEGER NOT NULL default '0', " +
                        "nValueType INTEGER NOT NULL default '0', " +
                        "sKey TEXT NOT NULL default '', " +
                        "sValue TEXT NOT NULL default '', " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON UPDATE CASCADE ON DELETE CASCADE);";

    string sQuestSteps = "CREATE TABLE IF NOT EXISTS quest_steps (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "quests_id INTEGER NOT NULL default '0', " +
                        "nStep INTEGER NOT NULL default '0', " +
                        "sJournalEntry TEXT default NULL, " +
                        "sTimeLimit TEXT default NULL, " +
                        "nPartyCompletion TEXT default '0', " +
                        "nProximity INTEGER default '1', " +
                        "nStepType INTEGER default '0', " +
                        "nObjectiveMinimumCount INTEGER default '-1', " +
                        "nRandomObjectiveCount INTEGER default '-1', " +
                        "UNIQUE (quests_id, nStep) ON CONFLICT IGNORE, " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON DELETE CASCADE ON UPDATE CASCADE);";

    string sQuestStepProperties = "CREATE TABLE IF NOT EXISTS quest_step_properties (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "quest_steps_id INTEGER NOT NULL, " +
                        "nCategoryType INTEGER NOT NULL, " +
                        "nValueType INTEGER NOT NULL, " +
                        "sKey TEXT NOT NULL COLLATE NOCASE, " +
                        "sValue INTEGER default '', " +
                        "sData TEXT default '', " +
                        "bParty INTEGER default '0', " +
                        "FOREIGN KEY (quest_steps_id) REFERENCES quest_steps (id) " +
                            "ON DELETE CASCADE ON UPDATE CASCADE);";

    // Destroy if required
    if (bReset)
    {
        string sTable, sTables = "quests,prerequisites,steps,step_properties";
        int n, nCount = CountList(sTables);  
    
        for (n = 0; n < nCount; n++)
        {
            sTable = GetListItem(sTables, n);
            sQuery = "DROP TABLE IF EXISTS quest_" + sTable + ";";
            sql = SqlPrepareQueryObject(GetModule(), sQuery);
            SqlStep(sql);
        }
    }

    sql = SqlPrepareQueryObject(GetModule(), sQuests);              SqlStep(sql);
    sql = SqlPrepareQueryObject(GetModule(), sQuestPrerequisites);  SqlStep(sql);
    sql = SqlPrepareQueryObject(GetModule(), sQuestSteps);          SqlStep(sql);
    sql = SqlPrepareQueryObject(GetModule(), sQuestStepProperties); SqlStep(sql);
}

void CreatePCQuestTables(object oPC, int bReset = FALSE)
{
    string sQuest = "CREATE TABLE IF NOT EXISTS quest_pc_data (" +
        "quest_tag TEXT UNIQUE ON CONFLICT IGNORE, " +
        "nStep INTEGER default '0', " +
        "nAttempts INTEGER default '0', " +
        "nCompletions INTEGER default '0', " +
        "nFailures INTEGER default '0', " +
        "nQuestStartTime INTEGER default '0', " +
        "nStepStartTime INTEGER default '0', " +
        "nLastCompleteTime INTEGER default '0', " +
        "nLastCompleteType INTEGER default '0', " +
        "nQuestVersion INTEGER default '0');";

    string sQuestStep = "CREATE TABLE IF NOT EXISTS quest_pc_step (" +
        "quest_tag TEXT, " +
        "nObjectiveType INTEGER, " +
        "sTag TEXT default '' COLLATE NOCASE, " +
        "sData TEXT default '' COLLATE NOCASE, " +
        "nRequired INTEGER, " +
        "nAcquired INTEGER default '0', " +
        "FOREIGN KEY (quest_tag) REFERENCES quest_pc_data (quest_tag) " +
            "ON UPDATE CASCADE ON DELETE CASCADE);";

    // Destroy if required
    if (bReset)
    {
        string sTable, sTables = "data,step";
        int n, nCount = CountList(sTables);  
    
        for (n = 0; n < nCount; n++)
        {
            sTable = GetListItem(sTables, n);
            sQuery = "DROP TABLE IF EXISTS quest_pc_" + sTable + ";";
            sql = SqlPrepareQueryObject(oPC, sQuery);
            SqlStep(sql);
        }
    }

    sql = SqlPrepareQueryObject(oPC, sQuest);     SqlStep(sql);
    sql = SqlPrepareQueryObject(oPC, sQuestStep); SqlStep(sql);
}

void CreateQuestVariablesTable(int bReset = FALSE)
{
    string sQuestVariables = "CREATE TABLE IF NOT EXISTS quest_variables (" +
                        "quests_id INTEGER NOT NULL, " +
                        "sType TEXT NOT NULL, " +
                        "sName TEXT NOT NULL, " +
                        "sValue TEXT NOT NULL, " +
                        "UNIQUE (quests_id, sType, sName) ON CONFLICT REPLACE, " +
                        "FOREIGN KEY (quests_id) REFERENCES quest_quests (id) " +
                            "ON UPDATE CASCADE ON DELETE CASCADE);";
    
    if (bReset)
    {
        sQuery = "DROP TABLE IF EXISTS quest_variables;";
        sql = SqlPrepareQueryObject(GetModule(), sQuery);
        SqlStep(sql);
    }
    
    sql = SqlPrepareQueryObject(GetModule(), sQuestVariables);
    SqlStep(sql);
}

void CreatePCVariablesTable(object oPC, int bReset = FALSE)
{
    string sPCVariables = "CREATE TABLE IF NOT EXISTS quest_pc_variables (" +
                        "quest_tag TEXT NOT NULL, " +
                        "nStep INTEGER NOT NULL default '0', " +
                        "sType TEXT NOT NULL, " +
                        "sName TEXT NOT NULL, " +
                        "sValue TEXT NOT NULL, " +
                        "UNIQUE (quest_tag, nStep, sType, sName) ON CONFLICT REPLACE, " +
                        "FOREIGN KEY (quest_tag) REFERENCES quest_pc_data (quest_tag) " +
                            "ON UPDATE CASCADE ON DELETE CASCADE);";

    if (bReset)
    {
        sQuery = "DROP TABLE IF EXISTS quest_pc_variables;";
        sql = SqlPrepareQueryObject(oPC, sQuery);
        SqlStep(sql);
    }

    sql = SqlPrepareQueryObject(oPC, sPCVariables);
    SqlStep(sql);
}

int GetLastInsertedID(string sTable)
{
    sQuery = "SELECT seq FROM sqlite_sequence WHERE name = @name;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@name", sTable);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

string GetQuestTag(int nQuestID)
{
    sQuery = "SELECT sTag FROM quest_quests " +
             "WHERE id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

int CountRowChanges(object oTarget)
{
    sQuery = "SELECT CHANGES();";
    sql = SqlPrepareQueryObject(oTarget, sQuery);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

/*
string GetTimeStamp()
{
    //sQuery = "SELECT strftime('%s', 'now')";
    sQuery = "SELECT CURRENT_TIMESTAMP;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);
    
    return SqlGetString(sql, 0);
}

int GetUnixTimeStamp()
{
    sQuery = "SELECT strftime('%s', 'now')";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    return SqlGetInt(sql, 0);
}
*/

string GetGreaterTimeStamp(string sTime1, string sTime2)
{
    sQuery = "SELECT strftime('%s', '" + sTime1 + "');";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    int nTime1 = SqlGetInt(sql, 0);

    sQuery = "SELECT strftime('%s', '" + sTime2 + "');";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    int nTime2 = SqlGetInt(sql, 0);

    if (nTime1 == nTime2)
        return sTime1;
    else if (nTime1 < nTime2)
        return sTime2;
    else if (nTime1 > nTime2)
        return sTime1;
    else 
        return "";
}

int GetGreaterUnixTimeStamp(int nTime1, int nTime2 = 0)
{
    if (nTime2 == 0)
        nTime2 = GetUnixTimeStamp();

    if (nTime1 == nTime2 || nTime1 > nTime2)
        return nTime1;
    else
        return nTime2;
}

int GetModifiedUnixTimeStamp(int nTimeStamp, string sTimeVector)
{
    string sUnit, sUnits = "years, months, days, hours, minutes, seconds";
    string sTime, sResult;

    int n, nTime, nCount = CountList(sTimeVector);
    for (n = 0; n < nCount; n++)
    {
        sUnit = GetListItem(sUnits, n);         // units
        sTime = GetListItem(sTimeVector, n);    // time vector value
        nTime = StringToInt(sTime);

        if (nTime != 0)
        {
            if (nTime < 0)
                sTime = "-" + sTime;
            else if (nTime > 0)
                sTime = "+" + sTime;
            else
                break;

            sResult += (sResult == "" ? "" : ",") + "'" + sTime + " " + sUnit + "'";
        }
    }

    if (sResult == "")
        return nTimeStamp;

    sQuery = "SELECT strftime('%s', datetime(" + IntToString(nTimeStamp) + ",'unixepoch', " + sResult + "));";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    return SqlGetInt(sql, 0);   
}

string GetModifiedTimeStamp(string sTimeStamp, string sTimeVector)
{
    string sUnit, sUnits = "years, months, days, hours, minutes, seconds";
    string sTime, sResult;

    int n, nTime, nCount = CountList(sTimeVector);
    for (n = 0; n < nCount; n++)
    {
        sUnit = GetListItem(sUnits, n);         // units
        sTime = GetListItem(sTimeVector, n);    // time vector value
        nTime = StringToInt(sTime);

        if (nTime != 0)
        {
            if (nTime < 0)
                sTime = "-" + sTime;
            else if (nTime > 0)
                sTime = "+" + sTime;
            else
                break;

            sResult += (sResult == "" ? "" : ",") + "'" + sTime + " " + sUnit + "'";
        }
    }

    if (sResult == "")
        return sTimeStamp;

    sQuery = "SELECT datetime('" + sTimeStamp + "', " + sResult + ");";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    return SqlGetString(sql, 0);
}

string QuestToString(int nQuestID)
{
    string sTag = GetQuestTag(nQuestID);

    if (sTag == "")
        return "[NOT FOUND]";

    return HexColorString(sTag + " (ID " + IntToString(nQuestID) + ")", COLOR_ORANGE_LIGHT);
}

int GetQuestID(string sQuestTag)
{
    sQuery = "SELECT id FROM quest_quests WHERE sTag = @sQuestTag;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sQuestTag", sQuestTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

void AddQuestPrerequisite(int nQuestID, int nValueType, string sKey, string sValue)
{
    sQuery = "INSERT INTO quest_prerequisites (quests_id, nValueType, sKey, sValue) " +
             "VALUES (@quests_id, @nValueType, @key, @sValue);";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@quests_id", nQuestID);
    SqlBindInt(sql, "@nValueType", nValueType);
    SqlBindString(sql, "@key", sKey);
    SqlBindString(sql, "@sValue", sValue);

    SqlStep(sql);
}

int _AddQuest(string sQuestTag, string sJournalTitle)
{
    string sQuery = "INSERT INTO quest_quests (sTag, sJournalTitle) " +
                    "VALUES (@sTag, @sTitle);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sTag", sQuestTag);
    SqlBindString(sql, "@sTitle", sJournalTitle);

    SqlStep(sql);

    return GetLastInsertedID("quest_quests");
}

void _DeleteQuest(int nQuestID)
{
    sQuery = "DELETE FROM quest_quests " +
             "WHERE id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlStep(sql);                
}

void _AddQuestStep(int nQuestID, int nStep)
{
    string sQuest = "INSERT INTO quest_steps (quests_id, nStep) " +
                    "VALUES (@quests_id, @nStep);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuest);
    SqlBindInt(sql, "@quests_id", nQuestID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlStep(sql);

    /*
    if (CountRowChanges(GetModule()) == 0)
        QuestError(StepToString(nStep) + " for " + QuestToString(nQuestID) +
            " already exists and cannot overwritten.  Check quest definitions " +
            "to ensure the same step number is not being assigned to different " +
            "steps.");
    */
}

sqlquery GetQuestPrerequisites(int nQuestID)
{
    sQuery = "SELECT nPropertyType, sKey, sValue " +
             "FROM quest_prerequisites " + 
             "WHERE quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

sqlquery GetQuestPrerequisiteTypes(int nQuestID)
{
    sQuery = "SELECT nValueType, COUNT(sKey) " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id " +
             "GROUP BY nValueType " +
             "ORDER BY nValueType;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

sqlquery GetQuestPrerequisitesByType(int nQuestID, int nValueType)
{
    sQuery = "SELECT sKey, sValue " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id " +
                "AND nValueType = @type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@type", nValueType);

    return sql;
}

int GetIsQuestActive(int nQuestID)
{
    sQuery = "SELECT nActive " +
             "FROM quest_quests " +
             "WHERE id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int CountActiveQuestSteps(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);

    sQuery = "SELECT COUNT(*) " +
             "FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStepType = @type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_PROGRESS);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int CountAllQuestSteps(int nQuestID)
{
    sQuery = "SELECT COUNT(*) " +
             "FROM quest_steps " +
             "WHERE quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int CountQuestPrerequisites(string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);

    sQuery = "SELECT COUNT(id) " +
             "FROM quest_prerequisites " +
             "WHERE quests_id = @id;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

sqlquery GetQuestData(int nQuestID)
{
    sQuery = "SELECT * FROM quest_quests WHERE id = @nQuestID;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@nQuestID", nQuestID);

    return sql;
}

sqlquery GetQuestProperties(int nQuestID)
{
    sQuery = "SELECT * FROM quest_properties WHERE quest_id = @nQuestID;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@nQuestID", nQuestID);

    return sql;
}

int GetTableExists(object oTarget, string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master " +
                "WHERE type='table' " +
                "AND name='" + sTable + "';";
    
    sqlquery sql = SqlPrepareQueryObject(oTarget, sQuery);
    return SqlStep(sql);
}

int CountQuestVariables(object oTarget, string sTable)
{
    string sQuery = "SELECT COUNT(*) " +
                    "FROM " + sTable + ";";
    sqlquery sql = SqlPrepareQueryObject(oTarget, sQuery);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int GetQuestExists(string sTag)
{
    sQuery = "SELECT COUNT(id) FROM quest_quests " +
             "WHERE sTag = @tag;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@tag", sTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int GetQuestHasMinimumNumberOfSteps(int nQuestID)
{
    sQuery = "SELECT COUNT(id) FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStepType != @type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_PROGRESS);

    return SqlStep(sql) ? SqlGetInt(sql, 0) > 0 : FALSE;
}

int GetQuestStepID(int nQuestID, int nStep)
{
    sQuery = "SELECT id FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStep = @step;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

sqlquery GetQuestStepPropertySets(int nQuestID, int nStep, int nCategoryType)
{
    string sQuery = "SELECT nValueType, sKey, sValue, sData, bParty " +
                    "FROM quest_step_properties " +
                    "WHERE nCategoryType = @category " +
                        "AND quest_steps_id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));

    return sql;
}

sqlquery GetQuestStepPropertyPairs(int nQuestID, int nStep, int nCategoryType, int nValueType)
{
    sQuery = "SELECT quest_step_properties.sKey, " +
                    "quest_step_properties.sValue " +
                    "quest_step_properties.sData " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_steps.id = @id " +
                "AND quest_steps.nStep = @step " +
                "AND quest_step_properties.nCategoryType = @category " +
                "AND quest_step_properties.nValueType = @value_type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@value_type", nValueType);

    return sql;
}

void DeleteQuestStepPropertyPair(int nQuestID, int nStep, int nCategoryType, int nValueType)
{
    string sQuery = "DELETE FROM quest_step_properties " +
             "WHERE nCategoryType = @category " +
                "AND nValueType = @type " +
                "AND quest_steps_id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindInt(sql, "@type", nValueType);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));

    SqlStep(sql);
}

string GetQuestStepPropertyValue(int nQuestID, int nStep, 
                                 int nCategoryType, int nValueType)
{
    string sQuery = "SELECT sValue " +
             "FROM quest_step_properties " +
             "WHERE quest_steps_id = @id " +
                "AND nCategoryType = @category_type " +
                "AND nValueType = @value_type;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));
    SqlBindInt(sql, "@category_type", nCategoryType);
    SqlBindInt(sql, "@value_type", nValueType);

    string sValue = SqlStep(sql) ? SqlGetString(sql, 0) : "";
    return sValue;
}

sqlquery GetQuestStepObjectiveData(int nQuestID, int nStep)
{
    sQuery = "SELECT quest_step_properties.id, " +
                    "quest_step_properties.nValueType, " +
                    "quest_step_properties.sKey, " +
                    "quest_step_properties.sValue, " +
                    "quest_step_properties.sData " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

sqlquery GetRandomQuestStepObjectiveData(int nQuestID, int nStep, int nRecords)
{
    sQuery = "SELECT quest_step_properties.id, " +
                    "quest_step_properties.nValueType, " +
                    "quest_step_properties.sKey, " +
                    "quest_step_properties.sValue, " +
                    "quest_step_properties.sData " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id " +
             "ORDER BY RANDOM() LIMIT " + IntToString(nRecords) + ";";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);

    return sql;
}

int GetQuestStepObjectiveType(int nQuestID, int nStep)
{
    sQuery = "SELECT quest_step_properties.nValueType " +
             "FROM quest_steps INNER JOIN quest_step_properties " +
                "ON quest_steps.id = quest_step_properties.quest_steps_id " +
             "WHERE quest_step_properties.nCategoryType = @category " +
                "AND quest_steps.nStep = @step " +
                "AND quest_steps.quests_id = @id " +
            "LIMIT 1;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@step", nStep);
    SqlBindInt(sql, "@id", nQuestID);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int CountQuestStepObjectives(int nQuestID, int nStep)
{
    string sQuery = "SELECT COUNT(quest_steps_id) " +
                    "FROM quest_step_properties " +
                    "WHERE nCategoryType = @category " +
                        "AND quest_steps_id = @id;";

    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@category", QUEST_CATEGORY_OBJECTIVE);
    SqlBindInt(sql, "@id", GetQuestStepID(nQuestID, nStep));
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

void _AddQuestToPC(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "INSERT INTO quest_pc_data (quest_tag) " +
             "VALUES (@tag);";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);
}

void DeletePCQuest(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "DELETE FROM quest_pc_data " + 
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);
}

int GetPCHasQuest(object oPC, string sQuestTag)
{
    sQuery = "SELECT COUNT(quest_tag) FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

int GetIsPCQuestComplete(object oPC, string sQuestTag)
{
    sQuery = "SELECT COUNT(*) FROM quest_pc_step " +
                "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) == 0 : FALSE;
}

int GetPCQuestCompletions(object oPC, string sQuestTag)
{
    sQuery = "SELECT nCompletions FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int GetPCQuestFailures(object oPC, string sQuestTag)
{
    sQuery = "SELECT nFailures FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

void ResetPCQuestData(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string sQuery = "UPDATE quest_pc_data " +
                    "SET nStep = @step, " +
                        "nQuestStartTime = @quest_start, " +
                        "nStepStartTime = @step_start " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@step", 0);
    SqlBindInt(sql, "@quest_start", 0);
    SqlBindInt(sql, "@step_start", 0);

    SqlStep(sql);
}

void IncrementPCQuestField(object oPC, int nQuestID, string sField)
{
    string sQuestTag = GetQuestTag(nQuestID);
    sQuery = "UPDATE quest_pc_data " + 
             "SET " + sField + " = " + sField + " + 1 " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);
}

void IncrementPCQuestCompletions(object oPC, int nQuestID, int nTimeStamp)
{
    ResetPCQuestData(oPC, nQuestID);

    string sQuestTag = GetQuestTag(nQuestID);
    sQuery = "UPDATE quest_pc_data " +
             "SET nCompletions = nCompletions + 1, " +
                 "nLastCompleteTime = @time, " +
                 "nLastCompleteType = @type " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@time", nTimeStamp);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_SUCCESS);
    SqlStep(sql);
}

void IncrementPCQuestFailures(object oPC, int nQuestID, int nTimeStamp)
{
    ResetPCQuestData(oPC, nQuestID);

    string sQuestTag = GetQuestTag(nQuestID);
    sQuery = "UPDATE quest_pc_data " +
             "SET nFailures = nFailures + 1, " +
                 "nLastCompleteTime = @time " +
                 "nLastCompleteType = @type " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@time", nTimeStamp);
    SqlBindInt(sql, "@type", QUEST_STEP_TYPE_FAIL);
    SqlStep(sql);
}

sqlquery GetStepObjectivesByTarget(object oPC, string sTarget)
{
    string sQuery = "SELECT quest_pc_step.sTag, " +
                        "quest_pc_data.quest_tag, " +
                        "quest_pc_data.nStep " +
                    "FROM quest_pc_data INNER JOIN quest_pc_step " +
                        "ON quest_pc_data.quest_tag = quest_pc_step.quest_tag " +
                    "WHERE quest_pc_step.sTag = @target;";

    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@target", sTarget);

    return sql;
}

sqlquery GetTargetQuestData(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "SELECT quest_pc_data.quest_tag, " +
                    "quest_pc_data.nStep " +
             "FROM quest_pc_data INNER JOIN quest_pc_step " +
                "ON quest_pc_data.quest_tag = quest_pc_step.quest_tag " +
             "WHERE quest_pc_step.nObjectiveType = @type " +
                "AND quest_pc_step.sTag = @tag" +
                (sData == "" ? ";" : " AND quest_pc_step.sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    return sql;
}

sqlquery GetPCIncrementableSteps(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "SELECT quest_tag FROM quest_pc_step " +
             "WHERE sTag = @target_tag " +
                "AND nObjectiveType = @objective_type" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@target_tag", sTargetTag);
    SqlBindInt(sql, "@objective_type", nObjectiveType);
    if (sData != "") SqlBindString(sql, "@data", sData);

    return sql;
}

int CountPCIncrementableSteps(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "SELECT COUNT(quest_tag) FROM quest_pc_step " +
             "WHERE sTag = @target_tag " +
                "AND nObjectiveType = @objective_type" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@target_tag", sTargetTag);
    SqlBindInt(sql, "@objective_type", nObjectiveType);
    if (sData != "") SqlBindString(sql, "@data", sData);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

//void IncrementQuestStepQuantity(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
int IncrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "UPDATE quest_pc_step " +
             "SET nAcquired = nAcquired + 1 " +
             "WHERE nObjectiveType = @type " +
                //"AND quest_tag = @quest_tag " +
                "AND sTag = @tag" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    //SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    return CountRowChanges(oPC);
}

int IncrementQuestStepQuantityByQuest(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "UPDATE quest_pc_step " +
             "SET nAcquired = nAcquired + 1 " +
             "WHERE nObjectiveType = @type " +
                "AND quest_tag = @quest_tag " +
                "AND sTag = @tag" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    return CountRowChanges(oPC);
}

int DecrementQuestStepQuantity(object oPC, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "UPDATE quest_pc_step " +
             "SET nAcquired = max(0, nAcquired - 1) " +
             "WHERE nObjectiveType = @type " +
                //"AND quest_tag = @quest_tag " +
                "AND sTag = @tag" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    //SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    SqlStep(sql);
    return CountRowChanges(oPC);
}

void DecrementQuestStepQuantityByQuest(object oPC, string sQuestTag, string sTargetTag, int nObjectiveType, string sData = "")
{
    sQuery = "UPDATE quest_pc_step " +
             "SET nAcquired = max(0, nAcquired - 1) " +
             "WHERE nObjectiveType = @type " +
                "AND sTag = @tag" +
                "AND quest_tag = @quest_tag" +
                (sData == "" ? ";" : " AND sData = @data;");
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    if (sData != "")
        SqlBindString(sql, "@data", sData);

    SqlStep(sql);
}

int CountPCStepObjectivesCompleted(object oPC, int nQuestID, int nStep)
{
    string sQuestTag = GetQuestTag(nQuestID);
    int nCount;

    sQuery = "SELECT COUNT(quest_tag) " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @quest_tag " +
                "AND nAcquired >= nRequired;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

sqlquery GetQuestStepSums(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT quest_tag, SUM(nRequired), SUM(nAcquired) " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @tag " +
                "AND nRequired > @zero " +
             "GROUP BY quest_tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@zero", 0);
    return sql;
}

sqlquery GetQuestStepSumsFailure(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT quest_tag, SUM(nRequired), SUM(nAcquired) " +
             "FROM quest_pc_step " +
             "WHERE quest_tag = @tag " +
                "AND nRequired = @zero " +
             "GROUP BY quest_tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlBindInt(sql, "@zero", 0);
    return sql;
}

void DeletePCQuestProgress(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "DELETE FROM quest_pc_step " + 
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    SqlStep(sql);
}

int GetPCQuestStep(object oPC, string sQuestTag)
{
    sQuery = "SELECT nStep FROM quest_pc_data " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

int GetNextPCQuestStep(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    int nCurrentStep = GetPCQuestStep(oPC, sQuestTag);

    sQuery = "SELECT nStep FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStep > @step " +
                "AND nStepType = @step_type " +
             "ORDER BY nStep ASC LIMIT 1;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nCurrentStep);
    SqlBindInt(sql, "@step_type", QUEST_STEP_TYPE_PROGRESS);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

sqlquery GetPCQuestData(object oPC)
{
    sQuery = "SELECT quest_tag, nStep, nCompletions, nLastCompleteType " +
             "FROM quest_pc_data;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    return sql;
}

void AddQuestStepObjectiveData(object oPC, int nQuestID, int nObjectiveType, 
                               string sTargetTag, int nQuantity, string sData = "")
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "INSERT INTO quest_pc_step (quest_tag, nObjectiveType, " +
                "sTag, sData, nRequired) " +
             "VALUES (@quest_tag, @type, @tag, @data, @qty);";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@quest_tag", sQuestTag);
    SqlBindInt(sql, "@type", nObjectiveType);
    SqlBindString(sql, "@tag", sTargetTag);
    SqlBindInt(sql, "@qty", nQuantity);
    SqlBindString(sql, "@data", sData);

    SqlStep(sql);
}

int GetQuestCompletionStep(int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS)
{
    sQuery = "SELECT nStep FROM quest_steps " +
             "WHERE quests_id = @id " +
                "AND nStepType = @step_type;";
    sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step_type", nRequestType == QUEST_ADVANCE_SUCCESS ? 
                                                    QUEST_STEP_TYPE_SUCCESS :
                                                    QUEST_STEP_TYPE_FAIL);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

int GetPCQuestStepAcquired(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    sQuery = "SELECT nAcquired FROM quest_pc_step " +
             "WHERE quest_tag = @tag;";
    sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}


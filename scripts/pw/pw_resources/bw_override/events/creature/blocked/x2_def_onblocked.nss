
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_BLOCKED, "x2_def_onblocked:last");
    ExecuteScript("hook_creature01", OBJECT_SELF);
}

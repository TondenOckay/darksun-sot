
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_DEATH, "x2_def_ondeath:last");
    ExecuteScript("hook_creature05", OBJECT_SELF);
}

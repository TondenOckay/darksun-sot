
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_SPELL_CAST_AT, "nw_c2_defaultb:last");
    ExecuteScript("hook_creature12", OBJECT_SELF);
}

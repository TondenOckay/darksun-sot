
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_SPELL_CAST_AT, "nw_ochrejlly_osc:last");
    ExecuteScript("hook_creature12", OBJECT_SELF);
}

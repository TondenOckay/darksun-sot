
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, PLACEABLE_EVENT_ON_HEARTBEAT, "nw_o2_skeleton:last");
    ExecuteScript("hook_placeable05", OBJECT_SELF);
}

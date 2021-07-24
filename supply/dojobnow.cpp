/*
 * autocorpses plugin.
 * Creates a new Workshop Order setting, automatically cutting rough gems.
 * For best effect, include "enable autocorpses" in your dfhack.init configuration.
 */

#include <fstream>

#include "uicommon.h"

#include "modules/Maps.h"
#include "modules/Gui.h"
#include "modules/Job.h"
#include "modules/World.h"

#include "df/job.h"
#include "df/job_item.h"
#include "df/job_list_link.h"
#include "df/viewscreen_dwarfmodest.h"
#include "df/viewscreen_joblistst.h"

using namespace DFHack;

DFHACK_PLUGIN("dojobnow");
DFHACK_PLUGIN_IS_ENABLED(enabled);

REQUIRE_GLOBAL(ui);
REQUIRE_GLOBAL(world);

const char *tagline = "Actually do construction and hauling on a reasonable timeframe.";
const char *usage = (
    "  enable dojobnow\n"
    "    Enable the plugin.\n"
    "  disable dojobnow\n"
    "    Disable the plugin.\n"
    "\n"
    "While enabled, the jobs screen (j) will have a new option:\n"
    "  n: Do Task Now!\n"
		"or:\n"
		"  n: Set Priority Normal\n"
    "\n"
    "When Do Task Now is triggered, the selected job will be set to high priority\n"
);




/*
 * Interface hooks
 */
struct dojobnow_hook : public df::viewscreen_joblistst {
    typedef df::viewscreen_joblistst interpose_base;

    bool handleInput(std::set<df::interface_key> *input) {

        if (input->count(interface_key::CUSTOM_N)) {
        		df::job *job = vector_get(jobs, cursor_pos);
						if (job) {
								job->flags.bits.do_now = !job->flags.bits.do_now;
						}

            return true;
        }

        return false;
    }

    DEFINE_VMETHOD_INTERPOSE(void, feed, (std::set<df::interface_key> *input)) {
        if (!handleInput(input)) {
            INTERPOSE_NEXT(feed)(input);
        }
    }

    DEFINE_VMETHOD_INTERPOSE(void, render, ()) {
        INTERPOSE_NEXT(render)();
        int x = 32;
        auto dim = Screen::getWindowSize();
        int y = dim.y - 2;
				bool do_now = false;

				df::job *job = vector_get(jobs, cursor_pos);
				if (job) {
						do_now = job->flags.bits.do_now;
				}

        OutputHotkeyString(x, y, (!do_now? "Do task now!": "Set priority normal"),
            interface_key::CUSTOM_N, false, x, COLOR_WHITE, COLOR_LIGHTRED);
    }
};


IMPLEMENT_VMETHOD_INTERPOSE(dojobnow_hook, feed);
IMPLEMENT_VMETHOD_INTERPOSE(dojobnow_hook, render);



DFhackCExport command_result plugin_enable(color_ostream& out, bool enable) {
    if (enable != enabled) {
        if (!INTERPOSE_HOOK(dojobnow_hook, feed).apply(enable) || !INTERPOSE_HOOK(dojobnow_hook, render).apply(enable)) {
            out.printerr("Could not %s dojobnow hooks!\n", enable? "insert": "remove");
            return CR_FAILURE;
        }

        enabled = enable;
    }

    return CR_OK;
}

DFhackCExport command_result plugin_init(color_ostream &out, std::vector <PluginCommand> &commands) {
    return CR_OK;
}

DFhackCExport command_result plugin_shutdown(color_ostream &out) {
    return plugin_enable(out, false);
}
### SDL header part

scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 111;

no_logfile = false;

response_matching = simple_matching;
active_buttons = 2;
button_codes = 11,12;

default_background_color = 128,128,128;
default_font_size = 96;

### SDL part

begin;

TEMPLATE "./stories/trials.tem";

# PCL part

begin_pcl;

string condition = parameter_manager.get_string("Group");
string stimulus_file = "./stories/stimuli/stories_R3_" + condition + ".txt";

wait_for_scanner_trial.present();
include "./stories/core.pcl"
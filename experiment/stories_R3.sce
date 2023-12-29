### SDL header part

scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 111;

no_logfile = false;

response_matching = simple_matching;
active_buttons = 3;
button_codes = 11,12,13;

default_background_color = 68, 81, 95;
default_text_color = 250, 243, 240;
default_font_size = 36;
default_font = "Helvetica";

### SDL part

begin;

TEMPLATE "./stories/stories.tem";

# PCL part

begin_pcl;

string condition = parameter_manager.get_string("Group");
string stimulus_file = "./stories/stimuli/stories_R3_" + condition + ".txt";

wait_for_scanner_trial.present();

include "./stories/stories.pcl";

the_end_trial.present()
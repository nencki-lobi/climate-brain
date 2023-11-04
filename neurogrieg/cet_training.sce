### SDL header part

no_logfile = true;

response_matching = simple_matching;
active_buttons = 2;
button_codes = 11,12;

default_background_color = 68, 81, 95;
default_text_color = 68, 81, 95;
default_font_size = 42;
default_font = "Helvetica";

### SDL part

begin;

TEMPLATE "./cet/cet.tem";

# PCL part

begin_pcl;

input_file cet_file = new input_file;
cet_file.open("./cet/stimuli/cet_training.txt");
cet_file.set_delimiter('\t');

include "./cet/cet.pcl"

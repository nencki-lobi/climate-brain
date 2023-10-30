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

## Simple objects

picture {
	text {
		caption = "Czekam na sygnał skanera...";
		font_size = 36;
	};
	x = 0; y = 0;
} wait_for_scanner;

picture {
	text {
		caption = "+"; 
	};
	x = 0; y = 0;
} fix_pic;

picture {
	text{
		caption = "This is going to be replaced by a story...";
		font_size = 36;
		max_text_width = 1500; 
		max_text_height = 700;
	} story_txt; # updated in `core.pcl`
	x = 0; y = 0;
} story_pic;

picture {
	text {
		caption = "Koniec!";
		font_size = 36;
	};
	x = 0; y = 0;
} the_end_pic;

## Trial objects

trial {
	picture wait_for_scanner;
	
	nothing{};
	time = 0;
	mri_pulse = 1;
} wait_for_scanner_trial;

trial{
	
	stimulus_event {
		picture fix_pic;
		time = 0;
		duration = 500;
	};
	
	stimulus_event {
		picture story_pic;
		time = 500;
		duration = 15000;
	} story_stimev;
	
	stimulus_event {
		picture fix_pic;
		time = 15500;
		duration = 500;
	};

} main_trial;

trial {
	trial_duration = 3000;
	stimulus_event {
		picture the_end_pic;
	};
} the_end_trial;

# PCL part

begin_pcl;

string stimulus_file = "./stories/stimuli/stories_R1_ANG.txt";

# Stimuli

input_file stories_file = new input_file;
stories_file.open(stimulus_file);
stories_file.set_delimiter('\t');

# Begin procedure

wait_for_scanner_trial.present();

loop
	string story = stories_file.get_line();
	string story_code = stories_file.get_string();
	bool is_story = stories_file.last_succeeded();
until
	! is_story
begin
	
	# Set story to be displayed
	story_txt.set_caption(story);
	story_txt.redraw();
	
	# Set event code
	story_stimev.set_event_code(story_code);
	
	# Display trial
	main_trial.set_start_delay(stories_file.get_int()); # jitter
	main_trial.present();
	
	# Prepare for the next trial
	story = stories_file.get_line();
	story_code = stories_file.get_string();
	is_story = stories_file.last_succeeded();
	
end;

the_end_trial.present();
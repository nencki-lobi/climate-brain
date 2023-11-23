### SDL header part

no_logfile = true;

response_matching = simple_matching;
active_buttons = 3;
button_codes = 11,12,13;

default_background_color = 68, 81, 95;
default_text_color = 68, 81, 95;
default_font_size = 42;
default_font = "Helvetica";

### SDL part

begin;

array {				
TEMPLATE "cet/instructions.tem"{				
PIC				CODE		TRIAL_NAME;
"cet/instructions/i-0001.jpg"	"I1"			I1;
"cet/instructions/i-0002.jpg"	"I2"			I2;
"cet/instructions/i-0003.jpg"	"I3"			I3;
"cet/instructions/i-0004.jpg"	"I4"			I4;
"cet/instructions/i-0005.jpg"	"I5"			I5;
"cet/instructions/i-0006.jpg"	"I6"			I6;
"cet/instructions/i-0007.jpg"	"I7"			I7;
"cet/instructions/i-0008.jpg"	"I8"			I8;
"cet/instructions/i-0009.jpg"	"I9"			I9;
"cet/instructions/i-0010.jpg"	"I10"			I10;
"cet/instructions/i-0011.jpg"	"I11"			I11;
"cet/instructions/i-0012.jpg"	"I12"			I12;
"cet/instructions/i-0013.jpg"	"I13"			I13;
"cet/instructions/i-0014.jpg"	"I14"			I14;
"cet/instructions/i-0015.jpg"	"I15"			I15;
"cet/instructions/i-0016.jpg"	"I16"			I16;
"cet/instructions/i-0017.jpg"	"I17"			I17;
"cet/instructions/i-0018.jpg"	"I18"			I18;
"cet/instructions/i-0019.jpg"	"I19"			I19;
"cet/instructions/i-0020.jpg"	"I20"			I20;
"cet/instructions/i-0021.jpg"	"I21"			I21;
"cet/instructions/i-0022.jpg"	"I22"			I22;
"cet/instructions/i-0023.jpg"	"I23"			I23;
"cet/instructions/i-0024.jpg"	"I24"			I24;
"cet/instructions/i-0025.jpg"	"I25"			I25;
"cet/instructions/i-0026.jpg"	"I26"			I26;
"cet/instructions/i-0027.jpg"	"I27"			I27;
"cet/instructions/i-0028.jpg"	"I28"			I28;
"cet/instructions/i-0029.jpg"	"I29"			I29;
"cet/instructions/i-0030.jpg"	"I30"			I30;
}; 				
}ins;	

TEMPLATE "./cet/cet.tem";		

### PCL part

begin_pcl;

loop int i = 1 until i > 30

	begin
	ins[i].present();
   	
	int type = stimulus_manager.last_stimulus_data().type();

	if (type == stimulus_incorrect) then
		i = i + 1;
	elseif (type == stimulus_hit) then
		i = i - 1;	
	end;
		
	if i < 1 then
		i = 1
	end;
end;

wait_for_researcher_trial.present();

input_file cet_file = new input_file;
cet_file.open("./cet/stimuli/cet_training.txt");
cet_file.set_delimiter('\t');

include "./cet/cet.pcl"

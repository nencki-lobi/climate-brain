### SDL header part

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
		caption = "Za chwilę przeczytasz kilka historii, opisujących różne sytuacje. Wszystkie historie oparte są na prawdziwych zdarzeniach i powstały na podstawie wypowiedzi osób, które zgodziły się opowiedzieć nam o swoich doświadczeniach.
\n Twoim zadaniem będzie czytanie historii, a następnie ocenianie nasilenia własnych emocji.";
		font_size = 36;
		max_text_width = 1500; 
		max_text_height = 700;
	};
	x = 0; y = 0;
} instruction1;

picture {
	text {
		caption = "Swoje emocje będziesz oceniać za pomocą opisanych poniżej skal: \n
- Czy opisana sytuacja budzi w Tobie raczej negatywne, czy pozytywne emocje?
- W jakim stopniu opisana sytuacja pobudza Cię emocjonalnie? Czy czujesz zupełny brak pobudzenia, czy też silne pobudzenie, wzburzenie lub ekscytację?
\n Zwóć szczególną uwagę na emocje, które czujesz po przeczytaniu danej historii.";
		font_size = 36;
		max_text_width = 1500; 
		max_text_height = 700;
	};
	x = 0; y = 0;
} instruction2;

picture {
	text {
		caption = "Odpowiedzi będziesz udzielać za pomocą dwóch guzików, znajdujących się na trzymanym przez Ciebie urządzeniu. Lewy guzik będzie służył zmianie odpowiedzi w lewo, a prawy - w prawo. 
\n Na udzielenie odpowiedzi będziesz mieć zawsze tyle samo czasu, tj. 5 sekund na każde z pytań. Po upływie tego czasu, Twoja odpowiedź zostanie zapisana i nastąpi przejście do kolejnego ekranu.";
		font_size = 36;
		max_text_width = 1500; 
		max_text_height = 700;
	};
	x = 0; y = 0;
} instruction3;

picture {
	text {
		caption = "Pamiętaj, że kolejne ekrany będą wyświetlać się i znikać automatycznie. Guziki na urządzeniu NIE służą zmianie ekranu.
\n Udzielając odpowiedzi, staraj się wykorzystywać cały zakres skali ocen. Nie ma dobrych, ani złych odpowiedzi, odpowiadaj zgodnie z pierwszym skojarzeniem.
\n Na początek weźmiesz udział w krótkiej sesji treningowej.";
		font_size = 36;
		max_text_width = 1500; 
		max_text_height = 700;
	};
	x = 0; y = 0;
} instruction4;

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
	
	picture instruction1;
	time = 0;
	duration = response;
	
	picture instruction2;
	deltat = 0; # show as soon as instruction1 is done
	duration = response;
	
	picture instruction3;
	deltat = 0; # show as soon as instruction2 is done
	duration = response;
	
	picture instruction4;
	deltat = 0; # show as soon as instruction3 is done
	duration = response;
   
} instruction_trial;

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

string stimulus_file = "./stories/stimuli/stories_training.txt";

# Stimuli

input_file stories_file = new input_file;
stories_file.open(stimulus_file);
stories_file.set_delimiter('\t');

# Begin procedure

instruction_trial.present();

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
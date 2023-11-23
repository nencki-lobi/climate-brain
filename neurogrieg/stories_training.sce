### SDL header part

no_logfile = true;

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

picture {
	text {
		caption = "Czy ten tekst wyświetla się wyraźnie?";
		max_text_width = 1500; 
		max_text_height = 700;
	};
	x = 0; y = 0;
} can_you_see;

picture {
	text {
		caption = "Za chwilę przeczytasz kilka historii, opisujących różne sytuacje. Wszystkie historie oparte są na prawdziwych zdarzeniach i powstały na podstawie wypowiedzi osób, które zgodziły się opowiedzieć nam o swoich doświadczeniach.
\n Twoim zadaniem będzie czytanie historii, a następnie ocenianie nasilenia własnych emocji.";
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
		max_text_width = 1500; 
		max_text_height = 700;
	};
	x = 0; y = 0;
} instruction2;

picture {
	text {
		caption = "Odpowiedzi będziesz udzielać za pomocą dwóch guzików, znajdujących się na trzymanym przez Ciebie urządzeniu. Lewy guzik będzie służył zmianie odpowiedzi w lewo, a prawy - w prawo. 
\n Na udzielenie odpowiedzi będziesz mieć zawsze tyle samo czasu, tj. 5 sekund na każde z pytań. Po upływie tego czasu, Twoja odpowiedź zostanie zapisana i nastąpi przejście do kolejnego ekranu.";
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
		max_text_width = 1500; 
		max_text_height = 700;
	};
	x = 0; y = 0;
} instruction4;

trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 3;
	picture can_you_see;
} can_you_see_trial;

trial {	
	picture instruction1;
	deltat = 0;
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

# PCL part

begin_pcl;

string stimulus_file = "./stories/stimuli/stories_training.txt";

can_you_see_trial.present();

instruction_trial.present();

wait_for_researcher_trial.present();

include "./stories/stories.pcl"

lay_still_trial.present();


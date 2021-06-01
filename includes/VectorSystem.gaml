/***
* Name: VectorSystem
* Author: Linda
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model VectorSystem

import "../includes/EnvironmentalSystem.gaml"
import "../includes/HumanSystem.gaml"

/**
* Name: SIR without ODE
* Author: Linda Menk
* :)
* Description: A simple SIR model without Ordinary Differential Equations showing agents 
* 	moving randomly among a grid and becoming infected then resistant to a disease
* Tags: grid
*/
global {
//Ecology of Anopheles Gambiae
	int adultAnopheles;
	int number_breeders;
	int number_healthyBiters;
	int number_infectedNotInfectiousBiters;
	int number_infectiousBiters;
	int number_non_breeders;
	int number_larvae;
	int number_anopheles;
	int number_notInfected;
	int number_infectedNotInfectious;
	int number_infectious;
	float deathRate <- 0.1;
	float deathRateAnopheles <- 0.1;
	int maturation_period;
	float bites_per_day_is1;
	float bites_per_day_is2;
	float bites_per_day_is3;
	float bitesTotal;
	int incubation_period;
	//	bool notInfected;
	//	bool infectedNotInfectious;
	list<Anopheles> Breeders update: (Anopheles where (each.breeder = true));
	list<Anopheles> Biters update: (Anopheles where (each.biter = true));
	//	bool incubationStart;
	//	list<Anopheles> Incubators update: (Anopheles where (each.incubationStart = true));

	//int ageHuman;
	init {
		create Larvae number: 200 {
		}

		create Anopheles number: 200 {
		}

	}

	reflex compute_breeding_status {
		number_breeders <- Anopheles count (each.breeder);
		number_non_breeders <- Anopheles count (each.nonBreeder);
		write "Number breeders: " + number_breeders;
		//		write "Number non breeders: " + number_non_breeders;
	}

	reflex compute_Larvae_and_Anopheles {
		number_larvae <- length(Larvae);
		number_anopheles <- length(Anopheles);
	}

	reflex compute_infection_status_Anopheles {
		number_notInfected <- Anopheles count (each.notInfected);
		number_infectedNotInfectious <- Anopheles count (each.infectedNotInfectious);
		number_infectious <- Anopheles count (each.infectious);
		write "Number not infected: " + number_notInfected;
		write "Number infectious but not infected: " + number_infectedNotInfectious;
		write "Number infectious: " + number_infectious;
	}

	reflex mortalityAnopheles {
		int A_mortal <- length(Anopheles);
		loop times: A_mortal * deathRateAnopheles {
			ask one_of(Anopheles) {
				do die;
			}

		}

	}

	//Create new Larvae according to the number of breeders. This should generally be 100 eggs per breeder. Now it is a 1:1 ratio. 
	//Implemented natural death rate of Larvae to be 10%. That too high, but later other causes of death will be added - then the natural death rate will be adjustet. 
	reflex popchangeLarvae {
		int pop <- length(Larvae);
		int birthRate <- number_breeders;
		create Larvae number: number_breeders {
			ageLarvae <- 0;
		}

		loop times: pop * deathRate {
		//write "larvae died of natural causes";
			ask one_of(Larvae) {
				do die;
			}

		}

	}

	//		write "Baby Larvae: " + birthRate;
	//		write "New number of Larvae: " + number_larvae;
	//		write "New number of Anopheles: " + number_anopheles;


	//Length of the maturation period of the Larvae
	reflex compute_maturation_period {
		float e <- exp(-0.095 * temp);
		if (temp >= 20) {
			maturation_period <- max([round(134.9 * e), 6]);
			write "maturation Period length:  " + maturation_period;
		} else if (temp >= 15 and temp < 20) {
			maturation_period <- max([round(134.9 * e), 6]);
		} else {
			ask Larvae {
				do die;
			}

		}

	}

	reflex biters_health {
		if (cycle >= 1) {
			number_healthyBiters <- Anopheles count (each.notInfected and each.biter);
			number_infectedNotInfectiousBiters <- Anopheles count (each.infectedNotInfectious and each.biter);
			number_infectiousBiters <- Anopheles count (each.infectious and each.biter);
			//			write "healthy Breeders: " + number_healthyBreeders;
			//			write "healthy Breeders: " + number_infectedNotInfectiousBreeders;
			//			write "healthy Breeders: " + number_infectiousBreeders;
		}

	}

	// Newly infected Mosquitos per timestep.
	//The "catchInfection which is currently commented out is the version proposed by Flessa. But I'll first test with this one, though.
	//	reflex catchInfection {
	//		if (cycle >= 1) {
	//		//int popAno <- length(Anopheles);
	//			float anophelesInfectedRate <- (number_healthyBreeders * ((0.8 * number_health_3) / unprotected_all)) / length(Anopheles);
	//			float newlyInfected <- length(Breeders) * anophelesInfectedRate;
	//			write "Infected Anopheles: " + anophelesInfectedRate;
	//			write "Newly Infected Anopheles: " + newlyInfected;
	//			loop times: newlyInfected {
	//				ask one_of(Anopheles where (each.notInfected = true)) {
	//					notInfected <- false;
	//					infectedNotInfectious <- true;
	//					infectious <- false;
	//					lastBloodmeal <- 1;
	//					//incubationStart <- true;
	//				}
	//
	//			}
	//
	//			//write "incubation starters" + length(Incubators);
	//		}
	//
	//	}
	reflex catchInfection {
		if (cycle >= 1) {
			float anophelesInfectedRate <- (length(Biters) * ((0.8 * number_health_3) / unprotected_all));
			write "Newly Infected Anopheles: " + anophelesInfectedRate;
			loop times: anophelesInfectedRate {
				ask one_of(Biters where (each.notInfected = true)) {
					notInfected <- false;
					infectedNotInfectious <- true;
					infectious <- false;
					lastBloodmeal <- 1;
					biter<-false;
				}

			}

		}

	}

	reflex compute_incubation_period {
	//float e <- exp(-0.095 * temp);
		if (temp >= 16) {
			incubation_period <- round(max([(270 * exp(-0.11 * temp)), 5]));
			write "incubation Period length:  " + incubation_period;
		} else {
		//What to write for "endless"?
			incubation_period <- nil;
		}

	}

	reflex innocentBite {
		if (cycle >= 1) {
		//int popAno <- length(Anopheles);
			float innocentBites <- (length(Biters) * (1 - ((0.8 * (number_health_3)) / unprotected_all)));
			//float just_a_bite <- length(Biters) * innocentBiteRate;
			write "Innocent Bites: " + innocentBites;
			write "How many biters? "+ length(Biters);
			loop times: innocentBites {
				ask one_of(Biters where (each.infectedNotInfectious = true or each.infectious=true)) {
					lastBloodmeal <- 1;
					biter<-false;
				}

			}

			//write "incubation starters" + length(Incubators);
		}

	}

}

//-------------------
species Larvae {
//int ageLarvae;
	list<Larvae> Transformers update: (Larvae where (each.transformer = true));
	bool transformer;
	sir_grid myPlaceLarvae;
	int ageLarvae <- rnd(0, maturation_period);

	init {
	//Place the agent randomly among the grid
		myPlaceLarvae <- one_of(sir_grid as list);
		location <- myPlaceLarvae.location;
	}

	reflex update_Larvae_age {
		if (cycle >= 1) {
			ageLarvae <- ageLarvae + 1;
			//write "Age Larvae +1: " + ageLarvae;
		}

	}

	reflex becomeTransformer {
	//ageLarvae <- ageLarvae + 1;
		if (self.ageLarvae > maturation_period) {
			transformer <- true;
			//write "Wuhuu,someone transformed";
		}

	}

	reflex transformAnopheles {
		int newAnopheles <- length(Transformers);
		//write "Length Transformers" + length(Transformers);
		//write "New Anopheles: " + newAnopheles;
		create Anopheles number: newAnopheles {
			notInfected <- true;
			infectedNotInfectious <- false;
			infectious <- false;
			lastBloodmeal <- 1;
			//			write "New Anopheles created: " + length(Anopheles);
			//			write "And how many Larvae do we have?: " + length(Larvae);
		}

		ask (Transformers) {
		//write "Old transformers died";
			do die;
		}

	}

	aspect basic {
		draw square(1) color: #green;
	}

}

//---------------------------------------------------------
species Anopheles {
	int lastBloodmeal <- rnd(1, 9);
	int infectionStatus <- rnd(1, 3);
	bool breeder;
	bool nonBreeder;
	bool notInfected;
	bool infectedNotInfectious;
	bool infectious;
	//bool incubationStart;
	float anophelesInfectedRate;
	sir_grid myPlaceAnopheles;
	int countDays <- 0;
	bool biter;

	init {
	//Place the agent randomly among the grid
		myPlaceAnopheles <- one_of(sir_grid as list);
		location <- myPlaceAnopheles.location;
	}

	reflex compute_lastBloodmeal {
		if (lastBloodmeal = 2 or lastBloodmeal = 5 or lastBloodmeal = 8) {
			breeder <- true;
			nonBreeder <- false;
			//write "Last bloodmeal: "+lastBloodmeal;
			//write "Length Breeders: " + length(Breeders); //length(Breeders);

		} else {
			breeder <- false;
			nonBreeder <- true;
			//write "Length non Breeders: " + length(nonBreeders); //length(Breeders);

		}

	}

	reflex update_craveBlood {
		lastBloodmeal <- lastBloodmeal + 1;
		if (lastBloodmeal = 7 or lastBloodmeal = 8 or lastBloodmeal = 9) {
			biter<-true;
			//lastBloodmeal <- 1;
		}

	}
	
//	reflex bite_or_die {
//		
//		if (lastBloodmeal > 9) {
//			do die;
//			//lastBloodmeal <- 1;
//		}
//
//	}

	reflex compute_infection_status {
		if (infectionStatus = 1) {
			notInfected <- true;
		}

		if (infectionStatus = 2) {
			infectedNotInfectious <- true;
		}

		if (infectionStatus = 3) {
			infectious <- true;
		}
		//write "infectionStatus: "+infectionStatus;
	}

	//Each time a Mosquito becomes infected, it starts counting days, until days equals the length of the incubation period. Then the mosquito becomes fully infected. 
	reflex becomeSick {
		if (self.infectedNotInfectious = true) {
			countDays <- countDays + 1;
			if (countDays = incubation_period) {
				notInfected <- false;
				infectedNotInfectious <- false;
				infectious <- true;
				write "INFECTED";
			}

		}

		if (self.notInfected = true) {
			notInfected <- true;
			infectedNotInfectious <- false;
			infectious <- false;
		}

		if (self.infectious = true) {
			notInfected <- false;
			infectedNotInfectious <- false;
			infectious <- true;
		}

	}

	aspect basic {
		draw circle(1) color: #red;
	}

}
//----------------grid
grid sir_grid width: 100 height: 100 {
}
//Experiment Section-------------------------------------------------------------------------
experiment Simulation type: gui {
	parameter "Larvae mortality rate" var: deathRate; // The number of susceptible
	parameter "Anopheles mortality rate" var: deathRateAnopheles; // The number of susceptible
	output {
		display sir_display {
			grid sir_grid;
			species Larvae aspect: basic;
			species Anopheles aspect: basic;
		}

		display chart refresh: every(1 #cycles) {
			chart "Temperature" type: series background: rgb(255, 255, 204) style: exploded {
			//data "t_min" value: t_min color: #green;
			//data "t_max" value: t_max color: #red;
			//				data "temp" value: temp color: #blue;
			//				data "temp2" value: temp_r2 color: #black;
			//				data "precipitation" value: prec color: #yellow;
				data "breeders" value: number_breeders color: #salmon;
				//				data "non breeders" value: number_non_breeders color: #cyan;
				//				data "maturation period" value: maturation_period color: #gold;
				//				data "Number ac_1" value: number_age_class_1 color: #cyan;
				//				data "Number Anopheles" value: length(Anopheles) color: #green;
				//				data "Number Larvae" value: length(Larvae) color: #green;
				//				data "bite (a)" value: bites_per_day_ac1 color: #green;
				//				data "bite (b)" value: bites_per_day_ac2 color: #blue;
				//				data "bite (c)" value: bites_per_day_ac3 color: #yellow;
				//				data "bite (d)" value: bites_per_day_ac4 color: #cyan;
				data "Healthy Anos" value: number_notInfected color: #green;
				data "Incubators" value: number_infectedNotInfectious color: #orange;
				data "Sick Anos" value: number_infectious color: #red;
			}

		}

	}

}

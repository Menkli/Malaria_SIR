/***
* Name: VectorSystem
* Author: Linda
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model HumanSystem

import "../includes/EnvironmentalSystem.gaml"
import "../includes/VectorSystem.gaml"
/**
* Name: SIR without ODE
* Author: Linda Menk
* :)
* Description: A simple SIR model without Ordinary Differential Equations showing agents 
* 	moving randomly among a grid and becoming infected then resistant to a disease
* Tags: grid
*/
global {
//Declaration of variables related to species "Humans"
	int infectionStatus;
	int infectionsSurvived;
	int timesHumanBitten;
	int timesAnophelesBites;
	int ageClass;
	int number_age_class_1;
	int number_age_class_2;
	int number_age_class_3;
	int number_age_class_4;
	int number_health_1;
	int number_health_2;
	int number_health_3;
	//	bool ageClass_1;
	//	bool ageClass_2;
	//	bool ageClass_3;
	//	bool ageClass_4;
	bool notImmune;
	float humanOffspring;
	int number_humans;
	float mortality_age_class_1;
	float mortality_age_class_2;
	float mortality_age_class_3;
	float mortality_age_class_4;
	float migrationRate <- 0.1;
	
	float bites_per_day_ac1;
	float bites_per_day_ac2;
	float bites_per_day_ac3;
	float bites_per_day_ac4;
	bool unprotected_age_1;
	bool unprotected_age_2;
	bool unprotected_age_3;
	bool unprotected_age_4;
	int number_age_class_1_unpro;
	int number_age_class_2_unpro;
	int number_age_class_3_unpro;
	int number_age_class_4_unpro;
	int unprotected_all;

	//	int ageHuman;
	//	int healthStatus;
	//	int immunityStatus;


	//int ageHuman;
	init {
		create Humans number: 2000 {
		//infectionsSurvived<-rnd(0,20);
		}

	}

	reflex compute_number_Age {
		number_age_class_1 <- Humans count (each.ageClass_1);
		number_age_class_2 <- Humans count (each.ageClass_2);
		number_age_class_3 <- Humans count (each.ageClass_3);
		number_age_class_4 <- Humans count (each.ageClass_4);
//		write "Number 0-5 year olds: " + number_age_class_1;
//		write "Number 5-12 year olds: " + number_age_class_2;
//		write "Number 12-43 year olds: " + number_age_class_3;
//		write "Number 43-80 year olds: " + number_age_class_4;
	}

	reflex compute_unprotected_per_age_class {
		number_age_class_1_unpro <- Humans count (each.unprotected_age_1);
		number_age_class_2_unpro <- Humans count (each.unprotected_age_2);
		number_age_class_3_unpro <- Humans count (each.unprotected_age_3);
		number_age_class_4_unpro <- Humans count (each.unprotected_age_4);
		unprotected_all <- (number_age_class_1_unpro + number_age_class_2_unpro + number_age_class_3_unpro + number_age_class_4_unpro);
//		write "Number 0-5 year olds AND unprotected: " + number_age_class_1_unpro;
//		write "Number 5-12 year olds AND unprotected: " + number_age_class_2_unpro;
//		write "Number 12-43 year olds AND unprotected: " + number_age_class_3_unpro;
//		write "Number 43-80 year olds AND unprotected: " + number_age_class_4_unpro;
		write "Number Unprotected: " + unprotected_all;
	}

// Computes the chance for an individual to die of natural causes during a cycle. 
	reflex compute_natural_mortality {
		mortality_age_class_1 <- ((1 / 22500) * number_age_class_1);
		write "Mortality in A: " + mortality_age_class_1;
		if (flip(mortality_age_class_1)){
			ask one_of(Humans where (each.ageClass_1=true)) {
				do die;
			}
		}
		mortality_age_class_2 <- (1 / 84000) * number_age_class_2;
		if (flip(mortality_age_class_2)){
			ask one_of(Humans where (each.ageClass_2=true)) {
				do die;
			}
		}
		mortality_age_class_3 <- (1 / 56575) * number_age_class_3;
		if (flip(mortality_age_class_3)){
			ask one_of(Humans where (each.ageClass_3=true)) {
				do die;
			}
		}
		mortality_age_class_4 <- (1 / 13320) * number_age_class_4;
		if (flip(mortality_age_class_4)){
			ask one_of(Humans where (each.ageClass_4=true)) {
				do die;
			}
		}
	}

	reflex compute_health_status {
		number_health_1 <- Humans count (each.notInfected);
		number_health_2 <- Humans count (each.incubationPeriod);
		number_health_3 <- Humans count (each.sickness);
		write "Number not infected: " + number_health_1;
		write "Number incubation period: " + number_health_2;
//		write "Number sick: " + number_health_3;
	}

	//Add newborn humans with a ratio of 5% per year
	reflex createBabyHumans {
		float humanBirthRate <- ((0.05 / 360) * length(Humans));
		if flip(humanBirthRate) {
			create Humans number: 1 {
				ageClass_1 <- true;
				infectionStatus <- 1;
				healthStatus <- 1;
				immunityStatus <- 1;
			}

		}

		write "Birth Rate: " + humanBirthRate;
		write "Number humans: " + length(Humans);
	}

	//Compute migration outflow --they should be migrating between region1 and 2: not implemented yet
	reflex compute_migration_share {
		float migration <- length(Humans) * (migrationRate / 360);
		write "Migrating humans: " + migration;
	}

	reflex bites_per_human {
		if (cycle >= 1) {
			bites_per_day_ac1 <- ((0.1 * number_age_class_1) / unprotected_all) * min([number_breeders, 30 * unprotected_all]);
			bites_per_day_ac2 <- ((0.3 * number_age_class_2) / unprotected_all) * min([number_breeders, 30 * unprotected_all]);
			bites_per_day_ac3 <- ((0.8 * number_age_class_3) / unprotected_all) * min([number_breeders, 30 * unprotected_all]);
			bites_per_day_ac4 <- ((0.6 * number_age_class_4) / unprotected_all) * min([number_breeders, 30 * unprotected_all]);
			write "Bites per day (0-5yo): " + bites_per_day_ac1;
			write "Bites per day (5-12yo): " + bites_per_day_ac2;
			write "Bites per day (12-43yo): " + bites_per_day_ac3;
			write "Bites per day (43-80yo): " + bites_per_day_ac4;
		}

	}

}

//-------------------
species Humans {
	float ageHuman <- rnd(0.0, 80.0);
	int healthStatus <- rnd(1, 3);
	int immunityStatus <- rnd(1, 2);
	bool ageClass_1;
	bool ageClass_2;
	bool ageClass_3;
	bool ageClass_4;
	bool notInfected;
	bool incubationPeriod;
	bool sickness;
	//int healtStatus;
	bool notImmune;
	bool immune;
	bool unprotected_age_1;
	bool unprotected_age_2;
	bool unprotected_age_3;
	bool unprotected_age_4;
	bool protected;
	int infectionsSurvived;
	float unprotected_all;

	//Classify age into 4 groups
	reflex compute_age {
		if (self.ageHuman >= 0 and self.ageHuman < 5) {
			ageClass_1 <- true;
			float rateUnprotected <- 0.1;
			unprotected_age_1 <- flip(rateUnprotected);
			//write "Age Human: "+ageHuman;
		}

		if (self.ageHuman >= 5 and self.ageHuman < 12) {
			ageClass_2 <- true;
			float rateUnprotected <- 0.3;
			unprotected_age_2 <- flip(rateUnprotected);
		}

		if (self.ageHuman >= 12 and self.ageHuman < 43) {
			ageClass_3 <- true;
			float rateUnprotected <- 0.8;
			unprotected_age_3 <- flip(rateUnprotected);
		}

		if (self.ageHuman >= 43 and self.ageHuman <= 80) {
			ageClass_4 <- true;
			float rateUnprotected <- 0.6;
			unprotected_age_4 <- flip(rateUnprotected);
		}

	}

//	reflex do_compute_age {
//		do compute_age;
//	}
	
	reflex human_ageing {
	ageHuman<-ageHuman+(1/360);
	}

	reflex compute_health_status {
		if (self.healthStatus = 1) {
			notInfected <- true;
			incubationPeriod <- false;
			sickness <- false;
		}

		if (self.healthStatus = 2) {
			notInfected <- false;
			incubationPeriod <- true;
			sickness <- false;
		}

		if (self.healthStatus = 3) {
			notInfected <- false;
			incubationPeriod <- false;
			sickness <- true;
		}

	}

	reflex compute_immunity_status {
		if (self.immunityStatus = 1) {
			notImmune <- true;
			immune <- false;
		}

		if (self.immunityStatus = 2) {
			notImmune <- false;
			immune <- true;
		}

	}



}
//----------------------------------------------------









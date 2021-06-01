/***
* Name: EnvironmentalSystem
* Author: Linda
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Master

import "../includes/EnvironmentalSystem.gaml"
import "../includes/VectorSystem.gaml"
import "../includes/HumanSystem.gaml"

global{
	geometry shape<-square(100);
	init {
		
	}
} 

/* Insert your model definition here */
experiment Simulation type: gui {
	parameter "Larvae mortality rate" var: deathRate; // The number of susceptible
	parameter "Anopheles mortality rate" var: deathRateAnopheles; // The number of susceptible
	output {
		display chart refresh: every(1 #cycles) {
			chart "Temperature" type: series background: rgb(255, 255, 204) style: exploded {
			//data "t_min" value: t_min color: #green;
			//data "t_max" value: t_max color: #red;
//				data "temp" value: temp color: #blue;
//				data "temp2" value: temp_r2 color: #black;
//				data "precipitation" value: prec color: #yellow;
//				data "breeders" value: number_breeders color: #salmon;
//				//data "non breeders" value: number_non_breeders color: #cyan;
				data "maturation period" value: maturation_period color: #gold;
//				data "Number ac_1" value: number_age_class_1 color: #cyan;
				data "Number Anopheles" value: length(Anopheles) color: #green;
				data "Number Larvae" value: length(Larvae) color: #green;
			}

		}

	}

}

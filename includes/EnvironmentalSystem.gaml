/**
* Name: SIR without ODE
* Author: Linda Menk
* :)
* Description: A simple SIR model without Ordinary Differential Equations showing agents 
* 	moving randomly among a grid and becoming infected then resistant to a disease
* Tags: grid
*/
model Flessa

global {
//Temperature Variables
	float t_min;
	float t_max;
	float temp;
	float temp_r2;
	float t_av <- 27.06;
	float t_var <- 7.1;

	//Precipitation Variables
	float n_min_1;
	float n_max_1;
	float n_min_2;
	float n_max_2;
	float prec;
	float n_total <- 1000.0;
	float n_var <- 100.0;
	float prec_r2;
	float d; // <- date("2015-january-30", 'yyyy-MMMM-dd', 'en'); date den <- date("2017-12-30", 'yyyy-MM-dd'); 
	float step;

	init {
		create region1 number: 1;
		write "region1 created";
		create region2 number: 1;
		write "region1 created";
	}

	reflex write_cycle1 {
		if (cycle >= 2) {
			if (step >= 1.0) {
				step <- step + 1;
				write "step: " + step;
			}
			//		if (cycle >= 2 or step >= 2.0) {
			//			step <- step + 1;
			//			write "step: " + step;
			//		}
			if (cycle = 361 or step = 361.0) {
				step <- 1.0;
				write "step: " + step;
			}

		}

	}

	reflex write_cycle {
		write cycle;
	}

	//Compute mix and max temperatures
	reflex compute_t_min {
		t_min <- t_av * (1 - (t_var / 100));
		write "t min" + t_min;
	}

	reflex compute_t_max {
		t_max <- t_av * (1 + (t_var / 100));
		write "t max" + t_max;
	}

	//Compute temperatures for 3 phases of the year
	reflex compute_temperature {
		if (step >= 1 and step < 45) {
			temp <- t_min + ((t_max - t_min) / 180) * (step + 135);
			write "Temp Phase 1: " + temp;
		}

		//16.2-15.8
		if (step >= 45 and step < 255) {
			temp <- t_max - ((t_max - t_min) / 180) * (step - 45);
			write "Temp Phase 2: " + temp;
		}

		if (step >= 255 and step <= 360) {
			temp <- t_min + ((t_max - t_min) / 180) * (step - 225);
			write "Temp Phase 3: " + temp;
		}

	}

	reflex compute_temp_r2 {
		temp_r2 <- temp - 6;
	}

	// Compute min and max precipitation 
	reflex compute_n_max_1 {
		n_max_1 <- (n_total / 360) * (1 + (n_var / 100));
	}

	reflex compute_n_min_1 {
		n_min_1 <- (n_total / 360) * (1 - (t_var / 100));
	}

	reflex compute_n_max_2 {
		n_max_2 <- (n_total / 360) * (1 + (t_var / 200));
	}

	reflex compute_n_min_2 {
		n_min_2 <- (n_total / 360) * (1 - (t_var / 200));
	}

	//Compute precipitation for 5 phases of the year
	reflex compute_precipitation {
		if (step >= 1 and step < 16) {
			prec <- n_max_2 - ((n_max_2 - n_min_1) / 90) * (step + 75);
			write "Prec Phase 1: " + prec;
		}

		if (step > 15 and step < 105) {
			prec <- n_min_1 + ((n_max_1 - n_min_1) / 90) * (step - 15);
			write "Prec Phase 2: " + prec;
		}

		if (step > 104 and step < 196) {
			prec <- n_max_1 - ((n_max_1 - n_min_2) / 90) * (step - 105);
			write "Prec Phase 3: " + prec;
		}

		if (step > 195 and step < 286) {
			prec <- n_min_2 + ((n_max_2 - n_min_2) / 90) * (step - 195);
			write "Prec Phase 4: " + prec;
		}

		if (step > 285 and step < 360) {
			prec <- n_max_2 - ((n_max_2 - n_min_1) / 90) * (step - 285);
			write "Prec Phase 5: " + prec;
		}

	}

	reflex compute_prec_r2 {
		prec_r2 <- 1.5 * prec;
	}

}

species region1 {
	float temp;
	float prec;
}

species region2 {
	float temp_r2;
	float prec_r2;
}

//Experiment Section------------------------------------------
experiment Simulation type: gui {
	output {
		display chart refresh: every(1 #cycles) {
			chart "Temperature" type: series background: rgb(255, 255, 204) style: exploded {
				data "t_min" value: t_min color: #green;
				data "t_max" value: t_max color: #red;
				data "temp" value: temp color: #blue;
				data "temp2" value: temp_r2 color: #black;
				data "precipitation" value: prec color: #yellow;
			}

		}

	}

}






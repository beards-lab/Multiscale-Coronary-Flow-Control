This repository contains the codes to simulate myocardial perfusion in rest and exercise in pigs and comparison with experimental data.

The main sript to run is ExerciseSimulation\ExerciseModelRun.m

Three main folders are:

ExerciseSimulation

	This folder includes the scripts and functions for reading the parameters/data and integration of the two models.
	BloodGasMeasurementReading.m: 	Blood gas measurements for Pig C, used for exercise simulation
	ComplianceResistance.m: 	Computes the microvascular compliance based on equivalent diameter 
	ControlPigC.mat:		Data corresponding to Pig C in control conditions
	CycleAvg_Exercise.m:		Finds the cycle-to-cyle average of hemodynamics and resistances
	DisplayRequiredFunctions.m:	Shows the dependencies of function called by the main function (not mine)
	ExerciseModelEvalFun.m:		Reads the exercise input data and couples models 
	ExerciseModelRun.m:		Main script to run rest/exercise simulation
	MetabolicSignalCalc_Exercise.m:	Computes the metabolic signal
	Params.txt:			Calibrated parameters for the rest/exercisesimulation
	ReadDataParams.m:		Reads data and parameters for rest/exercisesimulation
	ReadExerciseInput.m:		Reads excel files that contains pressure and flow data in exercise
	TuneExercisePig.xlsx:		Excel file containing pressure and flow data in rest/exercise

SRC_Perfusion

	This folder includes the functions related to lumped parameter myocardial circulation model.
	DataPzf.m:			Class defined for zero-flow pressure data, used in PigC.mat		
	dXdT_myocardium.m:		Lumped parameter model ODEs
	LeftVenPerssure.m:		Finds the LV and cardaic cycle duration (T) pressure if it is not available from data 
	PerfusionModel.m:		Runs the myocardial circulatiol model
	PerfusionModel_ParamSet.m:	Sets the intial parameters for the myocardial circulatiol model
	PostProcessing.m:		Finds the solution for different points on the lumped parameter model
	TwoPtDeriv.m:			Finds the derivative of input

SRC_RepVessel

	This folder includes the functions related to representative vessel model.
	Calculations.m: 		Evaluates the steady state hemodynamics and resistances
	Calculations_Exercise.m:	Evaluates the steady state hemodynamics and resistances (used in rest/exercise simulations)
	CarlsonModelTime.m:		Constructs the model of representative vessel model
	dXdt_RepVessel.m:		ODEs corresponding to solving the mechanical equilibrium in representative vessel model
	RepModel_Exercise.m:		Prepares and intializes the representative vessel model
	RepVessel.m:			Finds the representative vessel diameter (used in rest/exercise simulation)			
	Tension.m:			Finds the vascular tension given the diameter of vessel
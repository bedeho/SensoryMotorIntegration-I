#!/usr/bin/perl

	#
	#  ParamSearch.pl
	#  SensoryMotorIntegration-I
	#
	#  Created by Bedeho Mender on 21/11/11.
	#  Copyright 2011 OFTNAI. All rights reserved.
	#

	use strict;
    use warnings;
    use POSIX;
	use File::Copy "cp";
	use Data::Dumper;
	use Cwd 'abs_path';
	use myConfig;
	use myLib;

	#############################################################################
	# Input
    #############################################################################
	
	# Run values
	
	my $experiment	 					= "orthogonalize_2"; # trace-10h, classic-30-1E-3H-2S-1O
	
	my $stim							= "random-mod-Tar=4.00-Ord=1.00-Sim=1.00-fD=0.05-sA=10.00-vpD=4.00-epD=4.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00";
	
	# 2,2
	#my $stim							= "random-mod-Tar=2.00-Ord=1.00-Sim=1.00-fD=0.05-sA=90.00-vpD=4.00-epD=4.00-gS=8.00-sS=0.06-vF=200.00-eF=150.00";
	
	#my $stim							= "random-mod-Tar=2.00-Ord=1.00-Sim=1.00-fD=0.05-sA=90.00-vpD=1.00-epD=2.00-gS=8.00-sS=0.06-vF=200.00-eF=150.00";
	
	# 4,4 resolution, 4H,13E
	#my $stim 							= "random-mod-Tar=4.00-Ord=10.00-Sim=1.00-fD=0.05-sA=10.00-vpD=4.00-epD=4.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00";
	
	#my $stim							= "random-mod-Tar=4.00-Ord=10.00-Sim=1.00-fD=0.05-sA=10.00-vpD=1.00-epD=2.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00";
	
	# 10H, 13E
	#my $stim							= "random-classic-Tar=10.00-Ord=10.00-Sim=1.00-fD=0.05-sA=10.00-vpD=1.00-epD=2.00-gS=3.00-sS=10.00-vF=200.00-eF=110.00";
	
	# 4H, 13E, O=10, dense, sharp gauss, shallow sigmoid
	#my $stim							= "random-gausssharp-Ord=10.00-Sim=1.00-fD=0.05-sA=10.00-vpD=1.00-epD=2.00-gS=3.00-sS=0.06-vF=200.00-eF=125.00";
	
	# 4H, 13E, O=10, dense, sharp sigmoid, big sigma
	#my $stim							= "random-sigsharp-Ord=10.00-Sim=1.00-fD=0.05-sA=10.00-vpD=1.00-epD=2.00-gS=8.00-sS=10.00-vF=200.00-eF=125.00";
	
	# 4H, 13E, O =10, DENSE+sejnowski
	#my $stim							= "random-dense-Ord=10.00-Sim=1.00-fD=0.05-sA=10.00-vpD=1.00-epD=2.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00";

	# 4H, 13E, ORD = 4 << 10
	#my $stim							= "random-sejnowski-Ord=4.00-Sim=1.00-fD=0.05-sA=10.00-vpD=8.00-epD=6.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00";

	# 4H,13E, control 1 = back to sejnowski world!
	#my $stim							 = "random-sejnowski-Ord=10.00-Sim=1.00-fD=0.05-sA=10.00-vpD=8.00-epD=6.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00";

	# 4H,13E, classic one, the shocker
	#my $stim 							= "random-classic-Ord=10.00-Sim=1.00-fD=0.05-sA=10.00-vpD=1.00-epD=2.00-gS=3.00-sS=10.00-vF=200.00-eF=125.00";
	
	#my $stim							= "simple-sejnowski-fD=0.05-sA=60.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00"; # 3E, 4H

	#my $stim							= "simple-sejnowski-fD=0.05-sA=10.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00"; # 13E, 4H

	#my $stim							= "simple-sejnowski-fD=0.05-sA=30.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00"; # 5E, 4H

	#my $stim							= "random-sejnowski-ord=6-fD=0.05-sA=30.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00"; # 5E, 4H
	
	#my $stim							= "random-sejnowski-ord=10-fD=0.05-sA=10.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00"; # 13E,4H,

	#my $stim							= "random-sejnowski-ord=4-fD=0.05-sA=10.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00"; # 13E,4H

	#my $stim							= "random-sejnowski-ord=10-fD=0.05-sA=10.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=112.50"; # 12E, 8H

	#my $stim							= "random-sejnowski-ord=23-fD=0.05-sA=5.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=110.00"; # 23E, 10H

	#my $stim 							= "random-sejnowski-ord=4-fD=0.05-sA=30.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00"; # 5E, 4H

	#my $stim							= "random-sejnowski-Ord=4-Sim=2-fD=0.05-sA=80.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=133.33"; # S2,4O,2E,3H, 

	#my $stim							= "random-sejnowski-Ord=10.00-Sim=2.00-fD=0.05-sA=80.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=110.00"; # 2E,10H,S2,10O
	
	#my $stim							= "random-sejnowski-Ord=1.00-Sim=2.00-fD=0.05-sA=150.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=110.00"; # 1E,10H,S2,1O
	
	#my $stim							= "random-classic-Ord=1.00-Sim=2.00-fD=0.05-sA=150.00-vpD=1.00-epD=2.00-gS=2.00-sS=10.00-vF=200.00-eF=110.00"; #
	
	#my $stim							= "random-classic-Ord=1.00-Sim=2.00-fD=0.05-sA=150.00-vpD=1.00-epD=2.00-gS=2.00-sS=10.00-vF=200.00-eF=120.00"; # 5H
	
	# simle
	#my $stim							= "random-classic-Ord=1.00-Sim=2.00-fD=0.05-sA=150.00-vpD=1.00-epD=2.00-gS=4.00-sS=10.00-vF=200.00-eF=125.00"; #

	# 8h
	#my $stim							= "random-classic-Ord=1.00-Sim=2.00-fD=0.05-sA=150.00-vpD=1.00-epD=2.00-gS=3.00-sS=10.00-vF=200.00-eF=112.50";
	
	# 10h
	#my $stim							= "random-classic-Ord=1.00-Sim=2.00-fD=0.05-sA=150.00-vpD=1.00-epD=2.00-gS=3.00-sS=10.00-vF=200.00-eF=110.00";
	
	# 10h, 2e
	#my $stim							= "random-classic-Ord=1.00-Sim=2.00-fD=0.05-sA=60.00-vpD=1.00-epD=2.00-gS=3.00-sS=10.00-vF=200.00-eF=110.00";
	
	# 10h, 2e, ord = 3
	#my $stim							= "random-classic-Ord=3.00-Sim=2.00-fD=0.05-sA=60.00-vpD=1.00-epD=2.00-gS=3.00-sS=10.00-vF=200.00-eF=110.00";
	
	# 10h, 4e, ord = 5
	#my $stim 							= "random-classic-Ord=5.00-Sim=2.00-fD=0.05-sA=30.00-vpD=1.00-epD=2.00-gS=3.00-sS=10.00-vF=200.00-eF=110.00";
	
	#my $stim							= "random-classic-Ord=10.00-Sim=2.00-fD=0.05-sA=30.00-vpD=1.00-epD=2.00-gS=3.00-sS=10.00-vF=200.00-eF=110.00";
	
	my $stimuliTraining 				= $stim."-training";
	#my $stimuliTesting 					= $stim."-testOnTrained";
	my $stimuliTesting 					= $stim."-stdTest";
	my $xgrid 							= LOCAL_RUN; # LOCAL_RUN, XGIRD_RUN

	# Load params from stimuli name
	my $visualPreferenceDistance;
	my $eyePositionPrefrerenceDistance;
	my $gaussianSigma;
	my $sigmoidSlope;
	my $horVisualFieldSize;
	my $horEyePositionFieldSize;
	loadLIPParams($stimuliTraining);
	
	# FIXED PARAMS - non-permutable
	my $neuronType						= CONTINOUS; # CONTINOUS, DISCRETE
    my $learningRule					= TRACE; # TRACE, HEBB
    
    my $nrOfEpochs						= 1; # 30,100
    my $saveNetworkAtEpochMultiple 		= 777;
	my $outputAtTimeStepMultiple		= 1;
	
    my $lateralInteraction				= NONE; # NONE, COMP, SOM
    my $sparsenessRoutine				= GLOBAL; # NONE, HEAP, GLOBAL
    
    my $resetTrace						= "true"; # "false", Reset trace between objects of training
    my $resetActivity					= "true"; # "false", Reset activation between objects of training
    
    # RANGE PARAMS - permutable
    my @sigmoidSlopes					= (
										#["3000000000.0","3000000000.0","3000000000.0","3000000000.0","3000000000.0"]
										#"3000000000.0","3000000000.0","3000000000.0","3000000000.0"]
										#["3000000000.0","3000000000.0","3000000000.0"],
										#["3000000000.0","3000000000.0"]
										#["3000000000.0"]
										#["0010.0"]
										#["0050.0"],
										#["0100.0"]
										#["0100.0","0100.0"]
										#["0200.0"]
										#["1000.0"],
										#["10000.0"],
										#["100000.0"],
										#["1000000.0"],
										#["10000000.0"],
										#["100000000.0"]
										["100000000.0","100000000.0"]
										
										#["3000000000.0","3000000000.0","300000000.0"],
										#["3000000000.0","3000000000.0","30000000.0"],
										#["3000000000.0","3000000000.0","3000000.0"],
										#["3000000000.0","3000000000.0","300000.0"],
										#["3000000000.0","3000000000.0","30000.0"],
										#["3000000000.0","3000000000.0","3000.0"],
										#["3000000000.0","3000000000.0","300.0"],
										#["3000000000.0","3000000000.0","30.0"],
										#["3000000000.0","3000000000.0","3.0"],
										#["3000000000.0","3000000000.0","0.3"]
    									);
    die "Invalid array: sigmoidSlopes" if !validateArray(\@sigmoidSlopes);
    
    my @sigmoidThresholds				= (
										#["0.0","0.0","0.0"],
										["0.0","0.0"]
										#["0.0"]
										#["0.001"],
										#["0.010"],
										#["0.100"],
										#["0.800"],
										#["3.000"],
										#["2.900"],
										#["2.800"],
										#["2.700"],
										#["2.600"],
										#["2.500"],
										#["2.400"],
										#["2.300"],
										#["2.200"],
										#["2.100"],
										#["2.000"],
										#["1.900"],
										#["1.800"],
										#["1.700"],
										#["1.600"],
										#["1.500"],
										#["1.400"],
										#["1.300"],
										#["1.200"],
										#["1.100"],
										#["1.000"],
										#["0.900"],
										#["0.800"],
										#["0.700"],
										#["0.600"],
										#["0.500"],
										#["0.400"],
										#["0.300"],
										#["0.200"],
										#["0.100"]
										#["1.000","1.000"]
										#["1.200"]
										#["0.0"],
										#["0.0"],
    									);
    die "Invalid array: sigmoidThreshold" if !validateArray(\@sigmoidThresholds);
     
    my @globalInhibitoryConstants		= (
    									#["0.0","0.0","0.0"],
										#["0.0000"],
										#["0.0001"],
										#["0.0010"],
										#["0.0030"],
										#["0.0050"],
										#["0.0100"],
										#["0.0200"],
										#["0.0500"],
										#["0.1000"]
										#["0.5000"]
										#["0.7000"],
										#["1.0000"]
										["0.1000","0.1000"],
										["0.1000","0.0500"],
										["0.1000","0.0100"],
										["0.1000","0.0050"],
										["0.1000","0.0001"]
										#
										#["0.0000","0.0000"],
										#["0.0010","0.0010"],
										#["0.0030","0.0030"],
										#["0.0050","0.0050"],
										#["0.0100","0.0100"],
										#["0.0200","0.0200"],
										#["0.0500","0.0500"],
										#["0.1000","0.1000"],
										#["0.5000","0.5000"],
										#["0.7000","0.7000"],
										#["1.0000","1.0000"]
										#["0.0100"],
										#["0.1000"]
										);
	die "Invalid array: globalInhibitoryConstants" if !validateArray(\@globalInhibitoryConstants);
	
    my @externalStimulations		= (
    									#["0.0","0.0","0.0"],
										#["0.0"]
										["0.0","0.0"]
										);
	die "Invalid array: externalStimulations" if !validateArray(\@externalStimulations);
										
    # Notice, layer one needs 3x because of small filter magnitudes, and 5x because of
    # number of afferent synapses, total 15x.
    my @learningRates 					= (

#["0.0","0.0"],    
##["0.0","0.00037"],
#["0.0","0.00075"],
##["0.0","0.00150"],
##["0.0","0.00337"],
#["0.0","0.00675"],
#["0.0","0.00775"],
##["0.0","0.00875"],
#["0.0","0.00975"],
##["0.0","0.01075"],
#["0.0","0.01575"],
#["0.0","0.05575"],
#["0.0","0.10750"],
#["0.0","0.20000"],
#["0.0","0.30000"]
#["0.0","0.40000"]

#["0.0","0.0","0.0","0.0","0.05000"]
#["0.0","0.0","0.0","0.05000"]
#["0.0","0.0","0.05000"]
#["0.0","0.05000"]

#["0.0","0.0","0.0050"],
#["0.0","0.0","0.0100"],
#["0.0","0.0","0.0500"],
#["0.0","0.0","0.5000"]
#["0.0","0.0","05.0000"],
#["0.0","0.0","50.0000"]

# Sinle level input!
#["0.00000"]
["0.00000","0.00000"]
#["0.00500"],
#["0.05000"],
#["0.10000"],
#["1.00000"],
#["1.50000"]
#["1.00000"]
#["10.0000"],
#["100.000"],
#["1000.00"]
#["10000.00"]
#["100000.00"],
#["1000000.00"],
#["10000000.00"],
#["100000000.00"],
#["1000000000.00"],
#["10000000000.00"]


#["0.0","0.0","0.0","0.01000"],
#["0.0","0.0","0.0","0.10000"]
#["0.0"]
#["0.0","0.0","0.0"],
#["0.0","0.0","0.00675"],
#["0.0","0.0","0.02575"]
#["0.0","0.0","0.03575"],
#["0.0","0.0","0.05000"]
#["0.0","0.0","0.05575"],
#["0.0","0.0","0.10000"]
#["0.0","0.0","0.10750"],
#["0.0","0.0","0.30000"],
#["0.0","0.0","1.00000"]						
);								
 	die "Invalid array: learningRates" if !validateArray(\@learningRates);

    my @sparsenessLevels				= (
# 10
#["0.98"],
#["0.80"],
#["0.50"],
#["0.0"],
#["-4.0"],
#["-9.0"],
#["-99.0"]
# 30
#["0.997"],
#["0.97"],
#["0.94"],
#["0.88"],
#["0.44"]
#["-0.11"],
#["-10.11"]
# 50
#["0.998"],
#["0.992"],
#["0.98"],
#["0.96"],
#["0.8"],
#["0.6"]
#["-3.0"]
# 100
#["0.9998"],
#["0.998"],
#["0.995"],
#["0.99"],
#["0.95"],
#["0.90"],
#["0.00"]
# 200
#["0.9998"],
#["0.998"],
#["0.995"],
#["0.99"],
#["0.95"],
#["0.90"],
#["0.00"]
# TRACE 100
#["0.9998","0.90"],
#["0.99","0.90"],
#["0.98","0.90"],
#["0.97","0.90"],
#["0.96","0.90"],
#["0.95","0.90"],
#["0.94","0.90"],
#["0.90","0.90"],
#
#["0.99","0.93"],
#["0.98","0.93"],
#["0.97","0.93"],
#["0.96","0.93"],
#["0.95","0.93"],
#["0.94","0.93"],
#["0.90","0.93"],
#
#["0.99","0.96"],
#["0.98","0.96"],
#["0.97","0.96"],
#["0.96","0.96"],
#["0.95","0.96"],
#["0.94","0.96"],
#["0.90","0.96"]
#["0.99","0.99","0.95"],
#["0.99","0.99","0.99"],
#["0.90","0.90","0.99"]

#["0.99","0.99","0.99","0.99","0.90"]
#["0.99","0.99","0.99","0.90"]
#["0.99","0.99","0.90"]
["0.99","0.90"]
#["0.90"]

# 1 HEBB
#["0.9998","0.90"],
#["0.999","0.90"],
#["0.99","0.90"],
#["0.98","0.90"],
#["0.97","0.90"],
#["0.96","0.90"],
#["0.95","0.90"],
#["0.90","0.90"]

#orthogonalization
#["0.95"],
#["0.99"],
#["0.995"],
#["0.998"],
#["0.999"],
#["0.9993"],
#["0.9998"]

# orthognalization 2
#["0.999","0.999"],
#["0.999","0.99"],
#["0.999","0.95"],
#["0.999","0.90"],

#["0.99","0.999"],
#["0.99","0.95"],
#["0.99","0.90"],

#["0.90","0.999"],
#["0.90","0.99"],
#["0.90","0.95"],
#["0.90","0.90"]

# orthognalization 3
#["0.999","0.999","0.999"],
#["0.99","0.99","0.99"],
#["0.95","0.95","0.95"],
#["0.90","0.90","0.90"]

# trace 3
#["0.99","0.99","0.98"],
#["0.99","0.99","0.95"],
#["0.99","0.99","0.90"],
#["0.99","0.99","0.80"],

#["0.99","0.99","0.95"]
);

    die "Invalid array: sparsenessLevels" if !validateArray(\@sparsenessLevels);
    
    my @timeConstants					= (
    									#["0.010","0.010","0.010","0.010"]
    									#["0.010","0.010","0.010"]
										["0.010","0.010"]
    									#["0.010"]
    									);
    die "Invalid array: timeConstants" if !validateArray(\@timeConstants);
 	
    my @stepSizeFraction				= ("0.1");  #0.1 = 1/10, 0.05 = 1/20, 0.02 = 1/50
    die "Invalid array: stepSizeFraction" if !validateArray(\@stepSizeFraction);
    
    my @traceTimeConstant				= ("0.100");  # ("0.300","0.800","1.600","2.600"); 
	die "Invalid array: traceTimeConstant" if !validateArray(\@traceTimeConstant);
	
	my @sigmoidModulationPercentage     = ("1.00"); # ("0.00","0.05","0.10","0.20","0.30","0.40","0.50","0.60","0.70","0.80","0.90","1.00");
	
    ## 0
    #my $pathWayLength					= 1;
    #my @dimension					= (30);
    #my @depth						= (1);
    #my @connectivity					= (SPARSE_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    #my @fanInRadius 					= (6); # not used
    #my @fanInCountPercentage 				= ("0.10"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    #my @learningrate					= ("0.1"); # < === is permuted below
    #my @eta						= ("0.8");
    #my @timeConstant					= ("0.1"); # < === is permuted below
    #my @sparsenessLevel					= ("0.1"); # < === is permuted below
    #my @sigmoidSlope 					= ("30.0"); # < === is permuted below
    #my @sigmoidThreshold				= ("0.0"); # < === is permuted below
    #my @globalInhibitoryConstant		= ("0.0"); # < === is permuted below
    #my @externalStimulation				= ("0.0"); # < === is permuted below
    
    #my @inhibitoryRadius				= ("6.0");
    #my @inhibitoryContrast				= ("1.4");
    #my @somExcitatoryRadius				= ("0.6");
    #my @somExcitatoryContrast				= ("120.12");
    #my @somInhibitoryRadius				= ("6.0");
    #my @somInhibitoryContrast				= ("1.4");
    #my @filterWidth					= (7);
    #my @epochs						= (10); # only used in discrete model
    #my @saveHistory					= (SINGLE_CELLS); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    #my @recordedSingleCells				= ("( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,14)   , (14,15), (16,14), (13,13), (19,15), (1,18), (17,14) )"); # 1-based indexing, as in inspector/MATLAB, not 0-based as 
    
    ## 1
    my $pathWayLength					= 2;
    my @dimension					= (30,30);
    my @depth						= (1,1);
    my @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    my @fanInRadius 					= (6,6); # not used
    my @fanInCountPercentage 				= ("0.1","0.1"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    my @learningrate					= ("0.1","0.1"); # < === is permuted below
    my @eta						= ("0.8","0.8");
    my @timeConstant					= ("0.1","0.1"); # < === is permuted below
    my @sparsenessLevel					= ("0.1","0.1"); # < === is permuted below
    my @sigmoidSlope 					= ("30.0","30.0"); # < === is permuted below
    my @sigmoidThreshold				= ("0.0","0.0"); # < === is permuted below
    my @globalInhibitoryConstant		= ("0.0","0.0"); # < === is permuted below
    my @externalStimulation				= ("0.0","0.0"); # < === is permuted below
    
    my @inhibitoryRadius				= ("6.0","6.0");
    my @inhibitoryContrast				= ("1.4","1.4");
    my @somExcitatoryRadius				= ("0.6","0.6");
    my @somExcitatoryContrast				= ("120.12","120.12");
    my @somInhibitoryRadius				= ("6.0","6.0");
    my @somInhibitoryContrast				= ("1.4","1.4");
    my @filterWidth					= (7,7);
    my @epochs						= (10,10); # only used in discrete model
    my @saveHistory					= (NO_HISTORY, SINGLE_CELLS); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    my @recordedSingleCells				= ("()", "( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,14))");  # 1-based indexing, as in inspector/MATLAB, not 0-based as
    
    ## 2
  	#my $pathWayLength					= 3;
    #my @dimension					= (30,30,30);
    #my @depth						= (1,1,1);
    #my @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY, FULL_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    #my @fanInRadius 					= (6,6,6); # not used
    #my @fanInCountPercentage 				= ("0.1","0.1","0.1"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    #my @learningrate					= ("0.1","0.1","0.1"); # < === is permuted below
    #my @eta						= ("0.8","0.8","0.8");
    #my @timeConstant					= ("0.1","0.1","0.1"); # < === is permuted below
    #my @sparsenessLevel					= ("0.1","0.1","0.1"); # < === is permuted below
    #my @sigmoidSlope 					= ("30.0","30.0","30.0"); # < === is permuted below
    #my @sigmoidThreshold				= ("0.0","0.0","0.0"); # < === is permuted below    
    #my @globalInhibitoryConstant		= ("0.0","0.0","0.0"); # < === is permuted below
    #my @externalStimulation				= ("0.0","0.0","0.0"); # < === is permuted below
    
    #my @inhibitoryRadius				= ("6.0","6.0","6.0");
    #my @inhibitoryContrast				= ("1.4","1.4","1.4");
    #my @somExcitatoryRadius				= ("0.6","0.6","0.6");
    #my @somExcitatoryContrast				= ("120.12","120.12","120.12");
    #my @somInhibitoryRadius				= ("6.0","6.0","6.0");
    #my @somInhibitoryContrast				= ("1.4","1.4","1.4");
    #my @filterWidth					= (7,7,7);
    #my @epochs						= (10,10,10); # only used in discrete model
    #my @saveHistory					= (NO_HISTORY, NO_HISTORY, NO_HISTORY); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    #my @recordedSingleCells				= ("()", "( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,14))", "()");  # 1-based indexing, as in inspector/MATLAB, not 0-based as 
    
    ## 3
    #my $pathWayLength					= 4;
    #my @dimension					= (60,60,60,30);
    #my @depth						= (1,1,1,1);
    #my @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY, FULL_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    #my @fanInRadius 					= (6,6,6,6); # not used
    #my @fanInCountPercentage 				= ("0.1","0.1","0.1","0.1"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    #my @learningrate					= ("0.1","0.1","0.1","0.1"); # < === is permuted below
    #my @eta						= ("0.8","0.8","0.8","0.8");
    #my @timeConstant					= ("0.1","0.1","0.1","0.1"); # < === is permuted below
    #my @sparsenessLevel					= ("0.1","0.1","0.1","0.1"); # < === is permuted below
    #my @sigmoidSlope 					= ("30.0","30.0","30.0","30.0"); # < === is permuted below
    #my @sigmoidThreshold				= ("0.0","0.0","0.0","0.0"); # < === is permuted below
    #my @globalInhibitoryConstant		= ("0.0","0.0","0.0","0.0"); # < === is permuted below
    #my @externalStimulation			= ("0.0","0.0","0.0","0.0"); # < === is permuted below
    
    #my @inhibitoryRadius				= ("6.0","6.0","6.0","6.0");
    #my @inhibitoryContrast				= ("1.4","1.4","1.4","1.4");
    #my @somExcitatoryRadius				= ("0.6","0.6","0.6","0.6");
    #my @somExcitatoryContrast				= ("120.12","120.12","120.12","120.12");
    #my @somInhibitoryRadius				= ("6.0","6.0","6.0","6.0");
    #my @somInhibitoryContrast				= ("1.4","1.4","1.4","1.4");
    #my @filterWidth					= (7,7,7,7);
    #my @epochs						= (10,10,10,10); # only used in discrete model
    #my @saveHistory					= (NO_HISTORY, NO_HISTORY, NO_HISTORY, NO_HISTORY); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    #my @recordedSingleCells				= ("()", "( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,14))","()","()");  # 1-based indexing, as in inspector/MATLAB, not 0-based as 

    ## 4
    #my $pathWayLength					= 5;
    #my @dimension					= (60,60,60,60,30);
    #my @depth						= (1,1,1,1,1);
    #my @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY , SPARSE_CONNECTIVITY, FULL_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    #my @fanInRadius 					= (6,6,6,6,6); # not used
    #my @fanInCountPercentage 				= ("0.1","0.1","0.1","0.1","0.1"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    #my @learningrate					= ("0.1","0.1","0.1","0.1","0.1"); # < === is permuted below
    #my @eta						= ("0.8","0.8","0.8","0.8","0.8");
    #my @timeConstant					= ("0.1","0.1","0.1","0.1","0.1"); # < === is permuted below
    #my @sparsenessLevel					= ("0.1","0.1","0.1","0.1","0.1"); # < === is permuted below
    #my @sigmoidSlope 					= ("30.0","30.0","30.0","30.0","30.0"); # < === is permuted below
    #my @sigmoidThreshold				= ("0.0","0.0","0.0","0.0","0.0"); # < === is permuted below
    #my @globalInhibitoryConstant		= ("0.0","0.0","0.0","0.0","0.0"); # < === is permuted below
    #my @externalStimulation			= ("0.0","0.0","0.0","0.0","0.0"); # < === is permuted below
    
    #my @inhibitoryRadius				= ("6.0","6.0","6.0","6.0","6.0");
    #my @inhibitoryContrast				= ("1.4","1.4","1.4","1.4","1.4");
    #my @somExcitatoryRadius				= ("0.6","0.6","0.6","0.6","0.6");
    #my @somExcitatoryContrast				= ("120.12","120.12","120.12","120.12","120.12");
    #my @somInhibitoryRadius				= ("6.0","6.0","6.0","6.0","6.0");
    #my @somInhibitoryContrast				= ("1.4","1.4","1.4","1.4","1.4");
    #my @filterWidth					= (7,7,7,7,7);
    #my @epochs						= (10,10,10,10,10); # only used in discrete model
    #my @saveHistory					= (NO_HISTORY, NO_HISTORY, NO_HISTORY, NO_HISTORY, NO_HISTORY); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    #my @recordedSingleCells				= ("()", "( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,14))","()","()","()");  # 1-based indexing, as in inspector/MATLAB, not 0-based as         
    
    #############################################################################
	# Preprocessing
    #############################################################################
    
    # Do some validation
    print "Uneven parameter length." if 
    	$pathWayLength != scalar(@dimension) || 
    	$pathWayLength != scalar(@depth) || 
    	$pathWayLength != scalar(@connectivity) || 
    	$pathWayLength != scalar(@fanInRadius) || 
    	$pathWayLength != scalar(@fanInCountPercentage) || 
    	$pathWayLength != scalar(@learningrate) || 
    	$pathWayLength != scalar(@eta) || 
    	$pathWayLength != scalar(@timeConstant) ||
    	$pathWayLength != scalar(@sparsenessLevel) ||
    	$pathWayLength != scalar(@sigmoidSlope) ||
    	$pathWayLength != scalar(@sigmoidThreshold) ||
    	$pathWayLength != scalar(@globalInhibitoryConstant) ||
    	$pathWayLength != scalar(@externalStimulation) ||
    	$pathWayLength != scalar(@inhibitoryRadius) ||
    	$pathWayLength != scalar(@inhibitoryContrast) ||
    	$pathWayLength != scalar(@somExcitatoryRadius) ||
    	$pathWayLength != scalar(@somExcitatoryContrast) ||
    	$pathWayLength != scalar(@somInhibitoryRadius) ||
    	$pathWayLength != scalar(@somInhibitoryContrast) ||
    	$pathWayLength != scalar(@filterWidth) ||
    	$pathWayLength != scalar(@epochs) ||
    	#$pathWayLength != scalar(@outputHistory) ||
    	$pathWayLength != scalar(@saveHistory) ||
    	$pathWayLength != scalar(@recordedSingleCells);
    
    # Build template parameter file from these    	    	    	    	    
    my @esRegionSettings;
   	for(my $r = 0;$r < $pathWayLength;$r++) {

     	my %region   	= ('dimension'       	=>      $dimension[$r],
                         'depth'             	=>      $depth[$r],
                         'connectivity'			=>		$connectivity[$r],
                         'fanInRadius'       	=>      $fanInRadius[$r],
                         'fanInCountPercentage' =>      $fanInCountPercentage[$r],
                         'learningrate'      	=>      $learningrate[$r],
                         'eta'               	=>      $eta[$r],
                         'timeConstant'      	=>      $timeConstant[$r],
                         'sparsenessLevel'   	=>      $sparsenessLevel[$r],
                         'sigmoidSlope'      	=>      $sigmoidSlope[$r],
                         'sigmoidThreshold'    	=>      $sigmoidThreshold[$r],
                         'globalInhibitoryConstant' => 	$globalInhibitoryConstant[$r],
                         'externalStimulation' 	=> 		$externalStimulation[$r],
                         'inhibitoryRadius'  	=>      $inhibitoryRadius[$r],
                         'inhibitoryContrast'	=>      $inhibitoryContrast[$r],
                         'somExcitatoryRadius'  =>      $somExcitatoryRadius[$r],
                         'somExcitatoryContrast'=>      $somExcitatoryContrast[$r],
                         'somInhibitoryRadius'  =>      $somInhibitoryRadius[$r],
                         'somInhibitoryContrast'=>      $somInhibitoryContrast[$r],
                         'filterWidth'   		=>      $filterWidth[$r],
                         'epochs'   		 	=>      $epochs[$r],
                         #'outputHistory'  		=>      $outputHistory[$r],
                         'saveHistory'  		=>      $saveHistory[$r],
                         'recordedSingleCells'	=>      $recordedSingleCells[$r]
                         );
                         
         #if($outputHistory[$r] eq "true" && $xgrid == XGIRD_RUN) {
         #	print("Error: Outputting history in layer " . $outputHistory[$r] . " ... not possible while on grid\n");
         #	#my $input = <STDIN>;
         #	exit;
         #} 

         push @esRegionSettings, \%region;
    }
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $firstTime = 1;
    
	my $experimentFolder 		= $BASE."Experiments/".$experiment."/";
	my $sourceFolder			= $BASE."Source";	
	my $stimuliFolder 			= $BASE."Stimuli/".$stimuliTraining."/";
    my $xgridResult 			= $BASE."Xgrid/".$experiment."/";
    my $untrainedNet 			= $experimentFolder."BlankNetwork.txt";
    
    # Check if experiment folder exists
	if(-d $experimentFolder) {
		
		print "Experiment folder already exists, do you want to remove it ? (y/n): ";
		my $input = <STDIN>;
		chomp($input); # remove trailing CR

		if($input eq "y") {
			system("rm -r $experimentFolder");
		} else {
			die("Well played.\n"); 
		}
	}
	
	# Make experiment folder
	mkdir($experimentFolder);
	
	# Copy source code folder to experiment, perl cp command cant do folders
	system("cp -R ${BASE}Source ${experimentFolder}") == 0 or die "Cannot make copy of source code folder: $!\n";

	# Compress source code folder
	system("tar -cjvf ${experimentFolder}source.tbz ${experimentFolder}Source") == 0 or die "Cannot tar source code folder: $!\n";
	
	# Delete source code folder
	system("rm -f -r ${experimentFolder}Source") == 0 or die "Cannot tar source code folder: $!\n";

    # Make blank network #################
	
	# Make temporary parameter file
	my $tmpParameterFile = $experimentFolder."Parameters.txt";
	my $paramResult = makeParameterFile(\@esRegionSettings, "0.1", "0.1", "0.1");
	open (PARAMETER_FILE, '>'.$tmpParameterFile) or die "Could not open file '$tmpParameterFile'. $!\n";
	print PARAMETER_FILE $paramResult;
	close (PARAMETER_FILE);
	
	# Run build command
	system($PERL_RUN_SCRIPT, "build", $experiment) == 0 or exit;
	
	# Remove temporary file
	unlink($tmpParameterFile);	
	# Make blank network #################
	
	# Prepare for xgrid
	if($xgrid == XGIRD_RUN) {
		
        # Make xgrid file
        open (XGRID_FILE, '>'.$experimentFolder.'xgrid.txt') or die "Could not open file '${experimentFolder}xgrid.txt'. $!\n";
        print XGRID_FILE '-in '.substr($experimentFolder, 0, -1).' -files '.$stimuliFolder.'xgridPayload.tbz ';
        
        # Make simulation file
        open (SIMULATIONS_FILE, '>'.$experimentFolder.'simulations.txt') or die "Could not open file '${experimentFolder}simulations.txt'. $!\n";
        
        # Copy SMI binary, if this is xgrid run
		cp($PROGRAM, $experimentFolder.$BINARY) or die "Cannot make copy of binary: $!\n";
		
		# Copy xgrid worker script
		cp($PERL_WORKER_SCRIPT, "${experimentFolder}xGridDiagnosticWorker.pl") or die "Cannot make copy of worker script: $!\n";
		
		# Make result directory
        mkdir($xgridResult);
	}
	
	# Make copy of this script as summary of parameter space explored
    my $thisScript = abs_path($0);
	cp($thisScript, $experimentFolder."ParametersCopy.pl") or die "Cannot make copy of parameter file: $!\n";
	
    #############################################################################
	# Permuting
    #############################################################################
    
    for my $sMP (@sigmoidModulationPercentage) {
    for my $sS (@sigmoidSlopes) {
    for my $sT (@sigmoidThresholds) {
    for my $gIC (@globalInhibitoryConstants) {
    for my $eS (@externalStimulations) {
	for my $tC (@timeConstants) {
	for my $sSF (@stepSizeFraction) {
	for my $ttC (@traceTimeConstant) {
	for my $l (@learningRates) {
	for my $s (@sparsenessLevels) {
						
						# Layer spesific parameters
						my @sigmoidSlopeArray 			= @{ $sS };
						my @sigmoidThresholdArray		= @{ $sT };
						my @globalInhibitoryConstantArray = @{ $gIC };
						my @externalStimulationArray 	= @{ $eS };
						my @timeConstantArray 			= @{ $tC };
						my @learningRateArray 			= @{ $l };
						my @sparsityArray 				= @{ $s };
						
						print "Uneven parameter length found while permuting." if
							$pathWayLength != scalar(@sigmoidSlopeArray) ||
							$pathWayLength != scalar(@sigmoidThresholdArray) ||
							$pathWayLength != scalar(@globalInhibitoryConstantArray) ||
							$pathWayLength != scalar(@externalStimulationArray) ||
							$pathWayLength != scalar(@timeConstantArray) ||
   							$pathWayLength != scalar(@learningRateArray) || 
   							$pathWayLength != scalar(@sparsityArray);
						
						# Smallest eta value, it is used with ssF
						my $layerCounter = 0;
						my $minTc = LONG_MAX;
						
						for my $region ( @esRegionSettings ) {
							
							$region->{'sigmoidSlope'} 			= $sigmoidSlopeArray[$layerCounter];
							$region->{'sigmoidThreshold'}		= $sigmoidThresholdArray[$layerCounter];
							$region->{'globalInhibitoryConstant'} = $globalInhibitoryConstantArray[$layerCounter];
							$region->{'externalStimulation'} 	= $externalStimulationArray[$layerCounter];
							$region->{'timeConstant'} 			= $timeConstantArray[$layerCounter];
							$region->{'learningrate'} 			= $learningRateArray[$layerCounter];
							$region->{'sparsenessLevel'} 		= $sparsityArray[$layerCounter];
							
							# Find the smallest eta, it is the what sSF is calculated out of
							$minTc = $region->{'timeConstant'} if $minTc > $region->{'timeConstant'};
							
							$layerCounter++;
						}
						
						my $sSPstr = "@sigmoidSlopeArray";
						$sSPstr =~ s/\s/-/g;
												
						my $sTstr = "@sigmoidThresholdArray";
						$sTstr =~ s/\s/-/g;
						
						my $gICstr = "@globalInhibitoryConstantArray";
						$gICstr =~ s/\s/-/g;
						
						my $eSstr = "@externalStimulationArray";
						$eSstr =~ s/\s/-/g;
						
						my $tCstr = "@timeConstantArray";
						$tCstr =~ s/\s/-/g;
						
						my $Lstr = "@learningRateArray";
						$Lstr =~ s/\s/-/g;
						
						my $Sstr = "@sparsityArray";
						$Sstr =~ s/\s/-/g;

						# Build name so that only varying parameters are included.
						my $simulationCode = "";
						$simulationCode .= "tC=${tCstr}_" if ($neuronType == CONTINOUS) && scalar(@timeConstants) > 1;
						$simulationCode .= "sSF=${sSF}_" if ($neuronType == CONTINOUS) && scalar(@stepSizeFraction) > 1;
						$simulationCode .= "ttC=${ttC}_" if ($neuronType == CONTINOUS) && scalar(@traceTimeConstant) > 1;
						$simulationCode .= "L=${Lstr}_" if scalar(@learningRates) > 1;
						$simulationCode .= "S=${Sstr}_" if scalar(@sparsenessLevels) > 1;
						$simulationCode .= "sS=${sSPstr}_" if scalar(@sigmoidSlopes) > 1;
						$simulationCode .= "sT=${sTstr}_" if scalar(@sigmoidThresholds) > 1;
						$simulationCode .= "gIC=${gICstr}_" if scalar(@globalInhibitoryConstants) > 1;
						$simulationCode .= "eS=${eSstr}_" if scalar(@externalStimulations) > 1;
						$simulationCode .= "sMPs=${sMP}_" if scalar(@sigmoidModulationPercentage) > 1;
						
						# If there is only a single parameter combination being explored, then just give a long precise name,
						# it's essentially not a parameter search.
						if($simulationCode eq "") {
							$simulationCode = "tC=${tCstr}_sSF=${sSF}_ttC=${ttC}_" if ($neuronType == CONTINOUS);
							$simulationCode = "L=${Lstr}_S=${Sstr}_sS=${sSPstr}_sT=${sTstr}_gIC=${gICstr}_eS=${eSstr}_"; #_F=${ficPstr}
						}
						
						if($xgrid) {
							
							my $parameterFile = $experimentFolder.$simulationCode.".txt";
							
							# Make parameter file
							print "\tWriting new parameter file: ". $simulationCode . " \n"; # . $timeStepStr . 
							
							my $result = makeParameterFile(\@esRegionSettings, $sSF, $ttC, $sMP);
							
							open (PARAMETER_FILE, '>'.$parameterFile) or die "Could not open file '$parameterFile'. $!\n";
							print PARAMETER_FILE $result;
							close (PARAMETER_FILE);
							
							# Add reference to simulation name file
							print SIMULATIONS_FILE $simulationCode.".txt\n";
							
							# Add line to batch file
							print XGRID_FILE "\n" if !$firstTime;
							print XGRID_FILE "xGridDiagnosticWorker.pl $BINARY --xgrid train ${simulationCode}.txt BlankNetwork.txt";
							
							$firstTime = 0;
						} else {
							
							# New folder name for this iteration
							my $simulation = $simulationCode;
							
							my $simulationFolder = $experimentFolder.$simulation."/";
							my $parameterFile = $simulationFolder."Parameters.txt";
							
							my $blankNetworkSRC = $experimentFolder."BlankNetwork.txt";
							my $blankNetworkDEST = $simulationFolder."BlankNetwork.txt";
						
							if(!(-d $simulationFolder)) {
								
								# Make simulation folder
								#print "Making new simulation folder: " . $simulationFolder . "\n";
								mkdir($simulationFolder, 0777) || print "$!\n";
								
								# Make parameter file and write to simulation folder
								print "Writing new parameter file: ". $simulationCode . " \n"; # . $timeStepStr .
								my $result = makeParameterFile(\@esRegionSettings, $sSF, $ttC, $sMP);
								
								open (PARAMETER_FILE, '>'.$parameterFile) or die "Could not open file '$parameterFile'. $!\n";
								print PARAMETER_FILE $result;
								close (PARAMETER_FILE);
								
								# Run training
								system($PERL_RUN_SCRIPT, "train", $experiment, $simulation, $stimuliTraining) == 0 or exit;
								
								# Copy blank network into folder so that we can do control test automatically
								#print "Copying blank network: ". $blankNetworkSRC . " \n";
								cp($blankNetworkSRC, $blankNetworkDEST) or die "Copying blank network failed: $!\n";
								
								# Run test
								system($PERL_RUN_SCRIPT, "test", $experiment, $simulation, $stimuliTesting) == 0 or exit;
								
							} else {
								print "Could not make folder (already exists?): " . $simulationFolder . "\n";
								exit;
							}
						}
					}
	}
	}
	}
	}
    }
    }
    }
    }
    }
    
	# If we just setup xgrid parameter search
	if($xgrid) {
		
		# close xgrid batch file
		close(XGRID_FILE);
		
		# close simulation name file
		close(SIMULATIONS_FILE);
		
		# submit job to grid
		# is manual for now!
		
		# start listener
		# is manual for now! #system($PERL_XGRIDLISTENER_SCRIPT, $experiment, $counter);
	}
	else {
		# Call matlab to plot all
		system($MATLAB . " -r \"cd('$MATLAB_SCRIPT_FOLDER');plotExperiment('$experiment','$stimuliTesting');\"");	
	}
	
	sub loadLIPParams {
		
		my ($sName) = @_;
		
		# simple-fD=0.20-sA=50.00-vpD=8.00-epD=6.00-gS=18.00-sS=0.06-vF=200.00-eF=125.00-testOnTrained
		# random-sejnowski-Ord=4-Sim=2-fD=0.05-sA=30.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=110.00
		my @res = ($sName =~ m/(\d+\.\d+)/g);

		#$Tar 							= $res[0];
		#$Ord 							= $res[1];
		#$Sim 							= $res[2];
		#$fD 							= $res[3];
		#$sA 							= $res[4];
		$visualPreferenceDistance		= $res[5];
		$eyePositionPrefrerenceDistance	= $res[6];
		$gaussianSigma					= $res[7];
		$sigmoidSlope					= $res[8];
		$horVisualFieldSize				= $res[9];
		$horEyePositionFieldSize		= $res[10];
	}
	
	sub makeParameterFile {
		
		my ($a, $stepSizeFraction, $traceTimeConstant, $sigmoidModulationPercentage) = @_;

		@esRegionSettings = @{$a}; # <== 2h of debuging to find, I have to frkn learn PERL...
		
        my @timeData = localtime(time);
		my $stamp = join(' ', @timeData);

	    my $str = <<"TEMPLATE";
/*
*
* GENERATED IN ParamSearch.pl on $stamp
*
* SMI parameter file
*
* Created by Bedeho Mender on 21/11/11.
* Copyright 2011 OFTNAI. All rights reserved.
*
* Note:
* This parameter file follows the libconfig hierarchical
* configuration file format, see:
* http://www.hyperrealm.com/libconfig/libconfig_manual.html#Introducion
* The values of some parameters may cause
* other parameters to not be used, but ALL must
* always be present for parsing.
* New content adhering to the libconfig standard
* is not harmful.
*/

/*
* What type of neuron type to use:
* 0 = discrete, 1 = continous
*/
neuronType = $neuronType;

continuous : {
	/*
	* This fraction of timeConstant is the step size of the forward euler solver
	*/
	stepSizeFraction = $stepSizeFraction;

	/*
	* Time constant for trace term
	*/
	traceTimeConstant = $traceTimeConstant;
	
	/*
	* Whether or not to reset activity across objects in training
	*/
	resetActivity = $resetActivity;
	
	/* Only continous neurons, may lead to no output both in training and testing!*/
	outputAtTimeStepMultiple = $outputAtTimeStepMultiple; 
};

training: {
	/*
	* What type of learning rule to apply.
	* 0 = trace, 1 = hebbian
	*/
	rule = $learningRule;
	
	/*
	* Whether or not to reset trace term across objects in training
	*/
	resetTrace = $resetTrace;
	
	/*
	* Saving intermediate network states
	* as independent network files
	*/
	saveNetwork = true;
	saveNetworkAtEpochMultiple = $saveNetworkAtEpochMultiple;
	
	/* 
	* Only used in continouys models:
	* An epoch is one run through the file list.
	*/
	nrOfEpochs = $nrOfEpochs; 
};

/*
* Only used in build command:
* No feedback = 0 
* symmetric feedback = 1 
* probabilistic feedback = 2
*/
feedback = 0;

/*
* Only used in build command:
* The initial weight set on synapses
* 0 = zero 
* 1 = same [0,1] uniform random weight used feedbackorward&backward
* 2 = two independent [0,1] uniform random weights used forward&backward
*/
initialWeight = 1;

/*
* What type of weight normalization will be applied after learning.
* 0 = NONE
* 1 = CLASSIC
*/
weightNormalization = 1;

/*
* What type of sparsification routine to apply.
* 0 = NONE 
* 1 = HEAP
*/
sparsenessRoutine = $sparsenessRoutine;

/*
* What type of lateral interaction to use.
* 0 = NONE
* 1 = COMP
* 2 = SOM
*/
lateralInteraction = $lateralInteraction;

/*
* What percent of orignal speed should model be exposed to data.
* playAtPrcntOfOriginalSpeed = 1.0   : live speed
* playAtPrcntOfOriginalSpeed = 1.7 : 70% faster then live speed
* playAtPrcntOfOriginalSpeed = 0.7 : 30% slower then live speed
*/
playAtPrcntOfOriginalSpeed = 1.0;

/*
* Only used in build command:
* Random seed used to setup initial weight strength
* and setup connectivity based on radii parameter.
*/
seed = 55;

area7a: {
	/*
	* The distance between consecutive neuron preferences in visual space
	*/
	visualPreferenceDistance = $visualPreferenceDistance;
	
	/*
	* The distance between consecutive neuron preferences in eye position space
	*/	
	eyePositionPrefrerenceDistance = $eyePositionPrefrerenceDistance;
	      
	/*
	* Size of visual field in degrees
	*/
	horVisualFieldSize = $horVisualFieldSize;
	
	/*
	* Size of movement field in degrees
	*/
	horEyePositionFieldSize = $horEyePositionFieldSize;
	
	/*
	* Spread of gaussian component
	*/
	gaussianSigma = $gaussianSigma; 
	
	/*
	* Slope of eye position sigmoid component
	*/
	sigmoidSlope = $sigmoidSlope;
		
	/*
	* Percent of input layer neurons that will be sigmoid in eye modulation component of their response
	*/
	sigmoidModulationPercentage = $sigmoidModulationPercentage
};

extrastriate: (
TEMPLATE
		
		for my $region ( @esRegionSettings ) {
			
			my %tmp = %{ $region }; # <=== perl bullshit

			$str .= "\n{\n";
			$str .= "\tdimension         		= ". $tmp{"dimension"} .";\n";
			$str .= "\tdepth             		= ". $tmp{"depth"} .";\n";
			$str .= "\tconnectivity        		= ". $tmp{"connectivity"} .";\n";
			$str .= "\tfanInRadius       		= ". $tmp{"fanInRadius"} .";\n";
			$str .= "\tfanInCountPercentage     = ". $tmp{"fanInCountPercentage"} .";\n";
			$str .= "\tlearningrate      		= ". $tmp{"learningrate"} .";\n";
			$str .= "\teta               		= ". $tmp{"eta"} .";\n";
			$str .= "\ttimeConstant				= ". $tmp{"timeConstant"} .";\n";
			$str .= "\tsparsenessLevel   		= ". $tmp{"sparsenessLevel"} .";\n";
			$str .= "\tsigmoidSlope      		= ". $tmp{"sigmoidSlope"} .";\n";
			$str .= "\tsigmoidThreshold    		= ". $tmp{"sigmoidThreshold"} .";\n";
			$str .= "\tglobalInhibitoryConstant	= ". $tmp{"globalInhibitoryConstant"} .";\n";
			$str .= "\texternalStimulation		= ". $tmp{"externalStimulation"} .";\n";
			$str .= "\tinhibitoryRadius  		= ". $tmp{"inhibitoryRadius"} .";\n";
			$str .= "\tinhibitoryContrast		= ". $tmp{"inhibitoryContrast"} .";\n";
			$str .= "\tsomExcitatoryRadius		= ". $tmp{"somExcitatoryRadius"} .";\n";
            $str .= "\tsomExcitatoryContrast	= ". $tmp{"somExcitatoryContrast"} .";\n";
			$str .= "\tsomInhibitoryRadius		= ". $tmp{"somInhibitoryRadius"} .";\n";
            $str .= "\tsomInhibitoryContrast	= ". $tmp{"somInhibitoryContrast"} .";\n";
            $str .= "\tfilterWidth   			= ". $tmp{"filterWidth"} .";\n";
            $str .= "\tepochs					= ". $tmp{"epochs"} .";\n";
            # $str .= "\toutputHistory			= ". $tmp{"outputHistory"} .";\n";
            $str .= "\tsaveHistory				= ". $tmp{"saveHistory"} .";\n";
            $str .= "\trecordedSingleCells		= ". $tmp{"recordedSingleCells"} .";\n";
                        
			$str .= "},";
		}
        # Cut away last ',' and add on closing paranthesis and semi-colon
        chop($str);
        return $str." );";
	}

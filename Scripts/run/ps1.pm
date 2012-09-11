        #
        #  ps1.pm
        #  SMI
        #
        #  Created by Bedeho Mender on 04/08/12.
        #  Copyright 2012 OFTNAI. All rights reserved.
        #

        package ps1;
	
	use myLib;
        use strict;
        use warnings FATAL => 'all';
        use base qw(Exporter);

        our @EXPORT = qw(
			$pathWayLength
			@dimension
			@depth
			@connectivity
			@fanInRadius
			@fanInCountPercentage
			@learningrate
			@eta
			@timeConstant
			@sparsenessLevel
			@sigmoidSlope
			@sigmoidThreshold
			@globalInhibitoryConstant	
			@externalStimulation
			@inhibitoryRadius
			@inhibitoryContrast
			@somExcitatoryRadius
			@somExcitatoryContrast
			@somInhibitoryRadius
			@somInhibitoryContrast
			@filterWidth
			@epochs
			@saveHistory
			@recordedSingleCells

			@sigmoidSlopes
			@sigmoidThresholds
			@globalInhibitoryConstants
			@externalStimulations
			@learningRates
			@sparsenessLevels
			@timeConstants
			@stepSizeFraction
			@traceTimeConstant
			);
			#@sigmoidModulationPercentage

 	# RANGE PARAMS - permutable
    	our @sigmoidSlopes					= (
									#["00000001.0"]
									#["00000000.8"],								
									#["00000000.7"],								
									#["00000000.6"],
									#["00000000.5"],								
									["00000000.4"]
									#["00000000.3"],
									#["00000000.2"]
									#["00000000.15"]
									#["00000000.10"]
									#["00000000.05"]
									#,
									#["00000000.1"],
									#["0000000.01"]
									#["000000.001"]
    								#["00000001.0"],
    								#["00000010.0"],
									#["00000100.0"],
									#["00001000.0"]
									#["00010000.0"],
									#["00100000.0"],
									#["01000000.0"],
									#["10000000.0"]
									#["100000000.0"]
    									);
    die "Invalid array: sigmoidSlopes" if !validateArray(\@sigmoidSlopes);
    
    our @sigmoidThresholds				= (
									["0.000"]
    									);
    die "Invalid array: sigmoidThreshold" if !validateArray(\@sigmoidThresholds);
     
    our @globalInhibitoryConstants		= (
									["0.0500"]
										);
	die "Invalid array: globalInhibitoryConstants" if !validateArray(\@globalInhibitoryConstants);
	
    our @externalStimulations		= (
    									["0.0"]
										);
	die "Invalid array: externalStimulations" if !validateArray(\@externalStimulations);
										
    # Notice, layer one needs 3x because of small filter magnitudes, and 5x because of
    # number of afferent synapses, total 15x.
    our @learningRates 					= (
#learningrate
#["0.00001"],
#["0.00010"],
#["0.00100"],
#["0.01000"],
#["0.10000"],
#["1.00000"],
#["10.0000"],
#["100.000"],
#["1000.00"]

#["0.00100"],
#["0.00200"],
#["0.00300"],
#["0.00400"],
#["0.00500"],
#["0.00600"],
#["0.00700"],
#["0.00800"],
#["0.00900"],

#["0.01000"],
#["0.02000"],
#["0.03000"],
#["0.04000"],
#["0.05000"],
#["0.06000"],
#["0.07000"],
#["0.08000"],
#["0.09000"],

["0.10000"]
#["0.20000"],
#["0.30000"],
#["0.40000"],
#["0.50000"],
#["0.60000"],
#["0.70000"],
#["0.80000"],
#["0.90000"],

#["1.00000"],
#["2.00000"],
#["3.00000"],
#["4.00000"],
#["5.00000"],
#["6.00000"],
#["7.00000"],
#["8.00000"],
#["9.00000"]

);								
 	die "Invalid array: learningRates" if !validateArray(\@learningRates);

    our @sparsenessLevels				= (
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
#["0.98"],
#["0.95"],
#["0.90"],
#["0.00"]
# 200
#["0.98"],
#["0.96"],
#["0.94"],
#["0.92"],
#["0.90"],
#["0.88"],
#["0.86"],
#["0.84"],
#["0.82"]
#["0.80"],
#["0.78"],
#["0.76"],
#["0.74"],
#["0.72"],
#["0.70"],
#["0.68"],
#["0.66"],
#["0.64"],
#["0.62"],
#["0.60"]
["0.85"]
#orthogonalization
#["0.95"],
#["0.99"],
#["0.995"],
#["0.998"],
#["0.999"],
#["0.9993"],
#["0.9998"]
);

    die "Invalid array: sparsenessLevels" if !validateArray(\@sparsenessLevels);
    
    our @timeConstants					= (    							
										["0.100"]
    									);
    die "Invalid array: timeConstants" if !validateArray(\@timeConstants);
 	
    our @stepSizeFraction				= ("0.1");  #0.1 = 1/10, 0.05 = 1/20, 0.02 = 1/50
    die "Invalid array: stepSizeFraction" if !validateArray(\@stepSizeFraction);
    
    our @traceTimeConstant				= ("0.400");  # ("0.300","0.800","1.600","2.600"); 
	die "Invalid array: traceTimeConstant" if !validateArray(\@traceTimeConstant);

	#our @sigmoidModulationPercentage     = ("0.00"); # ("0.00","0.05","0.10","0.20","0.30","0.40","0.50","0.60","0.70","0.80","0.90","1.00");
	
    ## 0
    our $pathWayLength					= 1;
    our @dimension					= (30);
    our @depth						= (1);
    our @connectivity					= (SPARSE_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    our @fanInRadius 					= (6); # not used
    our @fanInCountPercentage 				= ("0.2"); # 0.2 # Not easily permutble due to a variety of issues - generating different blank networks etc.
    our @learningrate					= ("0.1"); # < === is permuted below
    our @eta						= ("0.8");
    our @timeConstant					= ("0.1"); # < === is permuted below
    our @sparsenessLevel					= ("0.1"); # < === is permuted below
    our @sigmoidSlope 					= ("30.0"); # < === is permuted below
    our @sigmoidThreshold				= ("0.0"); # < === is permuted below
    our @globalInhibitoryConstant		= ("0.0"); # < === is permuted below
    our @externalStimulation				= ("0.0"); # < === is permuted below
    
    our @inhibitoryRadius				= ("6.0");
    our @inhibitoryContrast				= ("1.4");
    our @somExcitatoryRadius				= ("0.6");
    our @somExcitatoryContrast			= ("120.12");
    our @somInhibitoryRadius				= ("6.0");
    our @somInhibitoryContrast			= ("1.4");
    our @filterWidth						= (7);
    
    our @epochs						= (10); # only used in discrete model

#our @saveHistory					= (SINGLE_CELLS); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
#our @recordedSingleCells				= ("( (14,17), (19,16), (4,18) )"); # 1-based indexing, as in inspector/MATLAB, not 0-based as 

our @saveHistory					= (NO_HISTORY); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS    
our @recordedSingleCells				= ("()"); # 1-based indexing, as in inspector/MATLAB, not 0-based as 

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

	1;
   

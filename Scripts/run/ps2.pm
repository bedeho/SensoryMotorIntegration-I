    #
    #  ps2.pm
    #  SMI
    #
    #  Created by Bedeho Mender on 04/08/12.
    #  Copyright 2012 OFTNAI. All rights reserved.
    #

    package ps2;
	
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
					#@$sigmoidModulationPercentage

 	# RANGE PARAMS - permutable
    our @sigmoidSlopes					= (
										["10.0","10.0"]
    									);
    die "Invalid array: sigmoidSlopes" if !validateArray(\@sigmoidSlopes);
    
    our @sigmoidThresholds				= (
										["0.000","0.000"]
    									);
    die "Invalid array: sigmoidThreshold" if !validateArray(\@sigmoidThresholds);
     
    our @globalInhibitoryConstants		= (
										["0.0500","0.05000"]
									);
	die "Invalid array: globalInhibitoryConstants" if !validateArray(\@globalInhibitoryConstants);
	
    our @externalStimulations		= (
										["0.0","0.0"]
										);
	die "Invalid array: externalStimulations" if !validateArray(\@externalStimulations);
										
    # Notice, layer one needs 3x because of small filter magnitudes, and 5x because of
    # number of afferent synapses, total 15x.
    our @learningRates 					= (
										["0.00000","0.05000"]						
										);								
 	die "Invalid array: learningRates" if !validateArray(\@learningRates);

    our @sparsenessLevels				= (
										#["0.9998","0.90"],
										["0.999","0.90"],
										["0.99","0.90"],
										["0.98","0.90"],
										["0.97","0.90"],
										["0.96","0.90"],
										["0.95","0.90"],
										["0.90","0.90"]
										
										# orthognalization 2
										#["0.999","0.999"],
										#["0.999","0.99"],
										#["0.999","0.95"],
										#["0.999","0.90"],
										
										#["0.99","0.999"],
										#["0.99","0.95"],
										
										#["0.99","0.90"]
										
										#["0.90","0.999"],
										#["0.90","0.99"],
										#["0.90","0.95"],
										#["0.90","0.90"]
										);

    die "Invalid array: sparsenessLevels" if !validateArray(\@sparsenessLevels);
    
    our @timeConstants					= (
    									["0.100","0.100"]
    									);
    die "Invalid array: timeConstants" if !validateArray(\@timeConstants);
 	
    our @stepSizeFraction				= ("0.1");  #0.1 = 1/10, 0.05 = 1/20, 0.02 = 1/50
    die "Invalid array: stepSizeFraction" if !validateArray(\@stepSizeFraction);
    
    our @traceTimeConstant				= ("0.400");  # ("0.300","0.800","1.600","2.600"); 
	die "Invalid array: traceTimeConstant" if !validateArray(\@traceTimeConstant);
    
    ## 2
    our $pathWayLength					= 2;
    our @dimension						= (50,30);
    our @depth							= (1,1);
    our @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    our @fanInRadius 					= (6,6); # not used
    our @fanInCountPercentage 			= ("0.1","0.3"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    our @learningrate					= ("0.1","0.1"); # < === is permuted below
    our @eta								= ("0.8","0.8");
    our @timeConstant					= ("0.1","0.1"); # < === is permuted below
    our @sparsenessLevel					= ("0.1","0.1"); # < === is permuted below
    our @sigmoidSlope 					= ("30.0","30.0"); # < === is permuted below
    our @sigmoidThreshold				= ("0.0","0.0"); # < === is permuted below
    our @globalInhibitoryConstant		= ("0.0","0.0"); # < === is permuted below
    our @externalStimulation				= ("0.0","0.0"); # < === is permuted below
    
    our @inhibitoryRadius				= ("6.0","6.0");
    our @inhibitoryContrast				= ("1.4","1.4");
    our @somExcitatoryRadius				= ("0.6","0.6");
    our @somExcitatoryContrast			= ("120.12","120.12");
    our @somInhibitoryRadius				= ("6.0","6.0");
    our @somInhibitoryContrast			= ("1.4","1.4");
    our @filterWidth						= (7,7);
    our @epochs							= (10,10); # only used in discrete model
    our @saveHistory						= (NO_HISTORY, NO_HISTORY); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    our @recordedSingleCells				= ("()", "()");  # 1-based indexing, as in inspector/MATLAB, not 0-based as
    
    ## 2
  	#our $pathWayLength					= 3;
    #our @dimension					= (30,30,30);
    #our @depth						= (1,1,1);
    #our @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY, FULL_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    #our @fanInRadius 					= (6,6,6); # not used
    #our @fanInCountPercentage 				= ("0.1","0.1","0.3"); # Not easily permutble due to a variety of issues - generating different blank networks etc#.
    #our @learningrate					= ("0.1","0.1","0.1"); # < === is permuted below
    #our @eta						= ("0.8","0.8","0.8");
    #our @timeConstant					= ("0.1","0.1","0.1"); # < === is permuted below
    #our @sparsenessLevel					= ("0.1","0.1","0.1"); # < === is permuted below
    #our @sigmoidSlope 					= ("30.0","30.0","30.0"); # < === is permuted below
    #our @sigmoidThreshold				= ("0.0","0.0","0.0"); # < === is permuted below    
    #our @globalInhibitoryConstant		= ("0.0","0.0","0.0"); # < === is permuted below
    #our @externalStimulation				= ("0.0","0.0","0.0"); # < === is permuted below
    
    #our @inhibitoryRadius				= ("6.0","6.0","6.0");
    #our @inhibitoryContrast				= ("1.4","1.4","1.4");
    #our @somExcitatoryRadius				= ("0.6","0.6","0.6");
    #our @somExcitatoryContrast				= ("120.12","120.12","120.12");
    #our @somInhibitoryRadius				= ("6.0","6.0","6.0");
    #our @somInhibitoryContrast				= ("1.4","1.4","1.4");
    #our @filterWidth					= (7,7,7);
    #our @epochs						= (10,10,10); # only used in discrete model
    #our @saveHistory					= (NO_HISTORY, NO_HISTORY, ALL); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    #our @recordedSingleCells				= ("()", "( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,14))", "()");  # 1-based indexing, as in inspector/MATLAB, not 0-based as 
    
    ## 3
    #our $pathWayLength					= 4;
    #our @dimension					= (60,60,60,30);
    #our @depth						= (1,1,1,1);
    #our @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY, FULL_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    #our @fanInRadius 					= (6,6,6,6); # not used
    #our @fanInCountPercentage 				= ("0.1","0.1","0.1","0.1"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    #our @learningrate					= ("0.1","0.1","0.1","0.1"); # < === is permuted below
    #our @eta						= ("0.8","0.8","0.8","0.8");
    #our @timeConstant					= ("0.1","0.1","0.1","0.1"); # < === is permuted below
    #our @sparsenessLevel					= ("0.1","0.1","0.1","0.1"); # < === is permuted below
    #our @sigmoidSlope 					= ("30.0","30.0","30.0","30.0"); # < === is permuted below
    #our @sigmoidThreshold				= ("0.0","0.0","0.0","0.0"); # < === is permuted below
    #our @globalInhibitoryConstant		= ("0.0","0.0","0.0","0.0"); # < === is permuted below
    #our @externalStimulation			= ("0.0","0.0","0.0","0.0"); # < === is permuted below
    
    #our @inhibitoryRadius				= ("6.0","6.0","6.0","6.0");
    #our @inhibitoryContrast				= ("1.4","1.4","1.4","1.4");
    #our @somExcitatoryRadius				= ("0.6","0.6","0.6","0.6");
    #our @somExcitatoryContrast				= ("120.12","120.12","120.12","120.12");
    #our @somInhibitoryRadius				= ("6.0","6.0","6.0","6.0");
    #our @somInhibitoryContrast				= ("1.4","1.4","1.4","1.4");
    #our @filterWidth					= (7,7,7,7);
    #our @epochs						= (10,10,10,10); # only used in discrete model
    #our @saveHistory					= (NO_HISTORY, NO_HISTORY, NO_HISTORY, NO_HISTORY); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    #our @recordedSingleCells				= ("()", "( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,14))","()","()");  # 1-based indexing, as in inspector/MATLAB, not 0-based as 

    ## 4
    #our $pathWayLength					= 5;
    #our @dimension					= (60,60,60,60,30);
    #our @depth						= (1,1,1,1,1);
    #our @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY , SPARSE_CONNECTIVITY, FULL_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    #our @fanInRadius 					= (6,6,6,6,6); # not used
    #our @fanInCountPercentage 				= ("0.1","0.1","0.1","0.1","0.1"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    #our @learningrate					= ("0.1","0.1","0.1","0.1","0.1"); # < === is permuted below
    #our @eta						= ("0.8","0.8","0.8","0.8","0.8");
    #our @timeConstant					= ("0.1","0.1","0.1","0.1","0.1"); # < === is permuted below
    #our @sparsenessLevel					= ("0.1","0.1","0.1","0.1","0.1"); # < === is permuted below
    #our @sigmoidSlope 					= ("30.0","30.0","30.0","30.0","30.0"); # < === is permuted below
    #our @sigmoidThreshold				= ("0.0","0.0","0.0","0.0","0.0"); # < === is permuted below
    #our @globalInhibitoryConstant		= ("0.0","0.0","0.0","0.0","0.0"); # < === is permuted below
    #our @externalStimulation			= ("0.0","0.0","0.0","0.0","0.0"); # < === is permuted below
    
    #our @inhibitoryRadius				= ("6.0","6.0","6.0","6.0","6.0");
    #our @inhibitoryContrast				= ("1.4","1.4","1.4","1.4","1.4");
    #our @somExcitatoryRadius				= ("0.6","0.6","0.6","0.6","0.6");
    #our @somExcitatoryContrast				= ("120.12","120.12","120.12","120.12","120.12");
    #our @somInhibitoryRadius				= ("6.0","6.0","6.0","6.0","6.0");
    #our @somInhibitoryContrast				= ("1.4","1.4","1.4","1.4","1.4");
    #our @filterWidth					= (7,7,7,7,7);
    #our @epochs						= (10,10,10,10,10); # only used in discrete model
    #our @saveHistory					= (NO_HISTORY, NO_HISTORY, NO_HISTORY, NO_HISTORY, NO_HISTORY); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
    #our @recordedSingleCells				= ("()", "( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,14))","()","()","()");  # 1-based indexing, as in inspector/MATLAB, not 0-based as 



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
   

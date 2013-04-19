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
			
			@blockageLeakTime
			@blockageRiseTime
			@blockageTimeWindow
			);
			#@sigmoidModulationPercentage

 	# RANGE PARAMS - permutable
    our @sigmoidSlopes					= (
     
     									#["00000000.0000000001"],
     									#["00000000.000000001"],
     									#["00000000.00000001"],
            							#["00000000.0000001"],
            							#["00000000.000001"],
        								#["00000000.00001"],
        								#["00000000.0001"],
        								#["00000000.001"],
        								#["00000000.01"],
        								
    									#["00000000.001"],
    									#["00000000.002"],
    									#["00000000.003"],
    									#["00000000.004"],
    									#["00000000.005"]
    									#["00000000.006"],
    									#["00000000.007"],
    									#["00000000.008"],
    									#["00000000.009"],
    									
    									#["00000000.01"],
    									#["00000000.02"],
    									#["00000000.03"],
    									#["00000000.04"],
    									#["00000000.05"],
    									#["00000000.06"],
    									#["00000000.07"],
    									#["00000000.08"],
    									#["00000000.09"],
    									
										#["00000000.1"],
										#["00000000.2"],
										#["00000000.3"],
										#["00000000.4"],
										#["00000000.5"],
										#["00000000.6"],
										#["00000000.7"],
										#["00000000.8"],
										#["00000000.9"],
										#
	    								#["00000001.0"]
	    								#["00000002.0"],
	    								#["00000003.0"],
	    								#["00000003.25"],
	    								#["00000003.50"],
	    								#["00000003.75"],
	    								#["00000004.0"],
	    								#["00000004.25"],
	    								["00000004.50"], #classic , seems important, larger values infact destroy performance with single target simulations, they dont clean up!!!!
	    								#["00000004.75"],
	    								#["00000006.0"]
	    								#["00000006.0"], # varyingfixation_, # use with (0.15 -w)
										#["00000007.0"],
										########### planar ? 
										#["00000008.0"]
										#["00000009.0"],
	    								#["00000010.0"],
	    								#["00000011.0"],
	    								#["00000012.0"],
	    								#["00000013.0"]
	    								#["00000014.0"],
	    								#["00000015.0"] # multitargettraining, varyingfixationduration 1.0
										#["00000020.0"],
										
										#["00000030.0"],
										#["00000040.0"]
										
										 
										#["00000050.0"]  # sigma = 19,covariance_th = 0.9
										#["00000100.0"]
										#["00000150.0"],
										#["00000200.0"],
										#["00000250.0"],
										#["00000300.0"],
										#["00000350.0"],								
										#["00000400.0"]
										#["00000600.0"]
										#["00010000.0"]
										#["00100000.0"],
										#["01000000.0"]
    									);
    die "Invalid array: sigmoidSlopes" if !validateArray(\@sigmoidSlopes);
    
    our @sigmoidThresholds				= (
										["0.00"]# classic
									
										#["0.01"],
										#["0.02"], # sigma = 19,covariance_th = 0.9
										#["0.03"],
										#["0.04"],
										##["0.05"]
										#["0.06"],
										#["0.07"],
										#["0.08"],
										#["0.09"],
										
										#["0.10"],  # multitargettraining, variable duration 1.0, fixedduration
										#["0.15"]  # multitargettraining
										#["0.20"]   # classic
										#["0.30"], # nonspesific
										#"0.40"] # # use with (0.1 -w)
										#["0.50"],
										#["0.60"],
										#["0.70"]
										#["0.80"],
										#["0.90"]
										
										#["1.00"],
										#["1.20"]
										#["2.00"]
										#["3.00"],
										#["4.00"]
										#["5.00"],
										#["6.00"],
										#["7.00"],
										#["8.00"],
										#["9.00"]
										
										#["10.0"]
										#["11.0"],
										#["12.0"],
										#["13.0"],
										#["14.0"],
										#["15.0"],
										#["16.0"],
										#["17.0"],
										#["18.0"],
										#["19.0"]
    									);
    									
    die "Invalid array: sigmoidThreshold" if !validateArray(\@sigmoidThresholds);
     
    our @globalInhibitoryConstants		= (
    									["0.0000"]
    									##["0.0010"],
    									##["0.0020"],
    									##["0.0030"],
    									##["0.0040"],
    									##["0.0045"],
    									#["0.0050"],
    									##["0.0055"],
    									#["0.0060"],
    									##["0.0065"],
    									#["0.0070"]
    									#["0.0075"]
    									#["0.0080"]
    									#["0.0085"],
    									#["0.0090"],
    									#["0.0095"],
    									#["0.0100"],
    									#["0.0105"],
    									#["0.0110"],
    									#["0.0115"],
    									#["0.0120"]

										#["0.5000"] # not in use?
										);
	die "Invalid array: globalInhibitoryConstants" if !validateArray(\@globalInhibitoryConstants);
	
    our @externalStimulations		= (
    									["0.0"]
										);
	die "Invalid array: externalStimulations" if !validateArray(\@externalStimulations);
										
    # Notice, layer one needs 3x because of small filter magnitudes, and 5x because of
    # number of afferent synapses, total 15x.
    our @learningRates 					= (
										#["0.00010"],
										#["0.00020"],
										#["0.00030"],
										#["0.00040"],
										#["0.00050"],
										#["0.00060"],
										#["0.00070"],
										#["0.00080"],
										#["0.00090"], 
										# <= not typically used for a classif fanin
										#["0.00100"],
										#["0.00200"],
										#["0.00300"],
										#["0.00400"],
										#["0.00500"],
										#["0.00600"],
										#["0.00700"],
										#["0.00800"],
										#["0.00900"],
										#
										######["0.01000"]
										#["0.02000"],
										#["0.03000"],
										#["0.04000"],
										["0.05000"] # classic and everything else
										#["0.06000"],
										#["0.07000"],
										#["0.08000"],
										#["0.09000"],
										#
										#["0.10000"] # using with sigmoi to test!!
										#["0.20000"], # using with sigmoi to test!!
										#["0.30000"],
										#["0.40000"]
										#["0.50000"], 
										#["0.60000"],
										#["0.70000"],
										#["0.80000"],
										#["0.90000"] # use with (0.1 -w) fixation duration
										#
										#["1.00000"]
										#["1.50000"]
										#["2.00000"],
										#["3.00000"],
										#["4.00000"],
										#["5.00000"]
										#["6.00000"],
										#["7.00000"],
										#["8.00000"],
										#["9.00000"],
										
										#["10.0000"],
										
										#["50.0000"]
										
										#["100.000"]
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
										#["0.95"],
										#["0.99"],
										#["0.995"],
										#["0.998"],
										#["0.999"],
										#["0.9993"],
										#["0.9998"]
										##############
										#["0.98"],
										#["0.96"],
										#["0.94"],
										#["0.92"],
										["0.90"]#, # classic? or is it 0.88?
										
										#["0.88"]
										#["0.86"],
										#["0.84"]
										#["0.82"],
										#["0.80"]
										#["0.78"]
										#["0.76"],
										#["0.74"],
										#["0.72"],
										#["0.70"]
										
										#["0.68"],
										#["0.66"],
										#["0.64"],
										#["0.62"],
										#["0.60"]
										
										#["0.58"],
										#["0.56"],
										#["0.54"],
										#["0.52"],
										#["0.50"]
										#["0.48"],
										#["0.46"]
										#["0.44"],
										#["0.42"],
										#["0.40"],
										#["0.38"],
										#["0.36"]
										#["0.34"],
										#["0.32"],
										#["0.30"]
										);

    die "Invalid array: sparsenessLevels" if !validateArray(\@sparsenessLevels);
    
    our @timeConstants					= (    							
										 ["0.100"]
										
										 #["0.010"], ["0.020"], ["0.030"], ["0.040"], ["0.050"], ["0.060"], ["0.070"], ["0.080"], ["0.090"],
										 #["0.100"], ["0.200"], ["0.300"], ["0.400"], ["0.500"], ["0.600"], ["0.700"], ["0.800"], ["0.900"],
										 #["1.000"], ["2.000"], ["3.000"], ["4.000"], ["5.000"], ["6.000"], ["7.000"], ["8.000"], ["9.000"]
										   # 0.100
    									);
    die "Invalid array: timeConstants" if !validateArray(\@timeConstants);
 	
    our @stepSizeFraction				= ("0.1");#,"0.05","0.02","0.01");  #"0.1",0.1 = 1/10, 0.05 = 1/20, 0.02 = 1/50, 0.01
    die "Invalid array: stepSizeFraction" if !validateArray(\@stepSizeFraction);
    
    our @traceTimeConstant				= (
									    #"0.010",
									    #"0.020",
									    #"0.030",
									    #"0.040",
									    #"0.050",
									    #"0.060",
									    #"0.070",
									    #"0.080",
									    #"0.090",
									    #
									    #"0.100",
									    #"0.200",
									    #"0.300",
									    "0.400", # classic
									    #"0.500",
									    #"0.600",
									    #"0.700",
									    #"0.800",
									    #"0.900",
									    #
									    #"1.000",
									    #"2.000",
									    #"3.000",
									    #"4.000",
									    #"5.000",
									    #"6.000"
									    #"7.000",
									    #"8.000",
									    #"9.000",
									    #
									    #"10.000",
									    #"20.000",
									    #"30.000",
									    #"40.000",
									    #"50.000",
									    #"60.000",
									    #"70.000",
									    #"80.000",
									    #"90.000",
									    #
									    #"100.00",
									    #"200.00",
									    #"300.00",
									    #"400.00",
									    #"500.00",
									    #"600.00",
									    #"700.00",
									    #"800.00",
									    #"900.00"
									    );  # classic: "0.400"
	die "Invalid array: traceTimeConstant" if !validateArray(\@traceTimeConstant);
	
	our @blockageLeakTime				= ("0.0"); #"10.1","10.1", "10.0","1.0","0.1"
    die "Invalid array: blockageLeakTime" if !validateArray(\@blockageLeakTime);
 
	our @blockageRiseTime				= ("0.0"); 
	
	# "0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1.0","2.0","3.0","4.0","5.0","6.0","7.0","8.0","9.0","10.0"
	#"0.0","400.0","1000.0" ,"300.0","600.0","1000.0 #"600.0", ,"1000.0" #"500.0","400.0","300.0","200.0", "1.0","50.0","200.0",
	
	# for 0.5 window, none work: "130.0","125.0","120.0","115.0","110.0","105.0","100.0","95.0","90.0","85.0","80.0","75.0","70.0","65.0","60.0","55.0"
	
    die "Invalid array: blockageRiseTime" if !validateArray(\@blockageRiseTime);
    
    our @blockageTimeWindow				= ("0.0");
    die "Invalid array: blockageTimeWindow" if !validateArray(\@blockageTimeWindow);

    ## 0
    our $pathWayLength					= 1;
    our @dimension						= (30);
    our @depth							= (1);
    our @connectivity					= (SPARSE_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    our @fanInRadius 					= (6); # not used
    our @fanInCountPercentage 			= ("0.1"); #0.1, classic=0.1,05 #0.2 # Not easily permutble due to a variety of issues - generating different blank networks etc.
    our @learningrate					= ("0.1"); # < === is permuted below
    our @eta							= ("0.8");
    our @timeConstant					= ("0.1"); # < === is permuted below
    our @sparsenessLevel				= ("0.1"); # < === is permuted below
    our @sigmoidSlope 					= ("30.0"); # < === is permuted below
    our @sigmoidThreshold				= ("0.0"); # < === is permuted below
    our @globalInhibitoryConstant		= ("0.0"); # < === is permuted below
    our @externalStimulation			= ("0.0"); # < === is permuted below
    
    our @inhibitoryRadius				= ("6.0");
    our @inhibitoryContrast				= ("1.4");
    our @somExcitatoryRadius			= ("0.6");
    our @somExcitatoryContrast			= ("120.12");
    our @somInhibitoryRadius			= ("6.0");
    our @somInhibitoryContrast			= ("1.4");
    our @filterWidth					= (7);
    
    our @epochs							= (10); # only used in discrete model

	#our @saveHistory					= (SINGLE_CELLS); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS
	our @saveHistory					= (NO_HISTORY); #  NO_HISTORY, ALL, NO_SYNAPSE, SINGLE_CELLS   
	
	# 1-based indexing, as in inspector/MATLAB, not 0-based as
	#our @recordedSingleCells			= ("( (18,20), (8,24), (8,20), (6,1), (8,25), (11,16), (8,27), (11,11), (17,11), (22,1), (16,11), (11,23), (21,21) , (10,10), (19,19) , (29,6) , (9,6) , (#
	#our @recordedSingleCells			= ("( (18,20), (8,24), (8,20), (6,1), (8,25), (11,16), (8,27), (11,11), (17,11), (22,1))");
	#our @recordedSingleCells			= ("( (11,5), (11,20), (23,7), (27,8), (28,2))");	
	our @recordedSingleCells			= ("()"); # 1-based indexing, as in inspector/MATLAB, not 0-based as 

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
   

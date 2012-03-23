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
	
	my $experiment	 					= "entireLayer"; # inputpercentiletest-l0.2-fiC50-tC100-hebb-classic
	my $stim							= "simple-sejnowski-fD=0.20-sA=10.00-vpD=4.00-epD=3.00-gS=8.00-sS=0.06-vF=200.00-eF=125.00";

	
	my $stimuliTraining 				= $stim."-training";
	my $stimuliTesting 					= $stim."-testOnTrained";
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
    
    my $nrOfEpochs						= 2; #100
    my $saveNetworkAtEpochMultiple 		= 1000000;
	my $outputAtTimeStepMultiple		= 1;
	
    my $lateralInteraction				= NONE; # NONE, COMP, SOM
    my $sparsenessRoutine				= HEAP; # NONE, HEAP
    
    my $resetTrace						= "true"; # "false", Reset trace between objects of training
    my $resetActivity					= "true"; # "false", Reset activation between objects of training
    
    # RANGE PARAMS - permutable
    my @sigmoidSlopes					= (
										["3000000000.0","3000000000.0"]
										#["3000000000.0"]
    									);
    die "Invalid array: sigmoidSlopes" if !validateArray(\@sigmoidSlopes);
    
    # Notice, layer one needs 3x because of small filter magnitudes, and 5x because of
    # number of afferent synapses, total 15x.
    my @learningRates 					= (

#["0.0","0.00000"],    
#["0.0","0.00037"],
#["0.0","0.00075"],
#["0.0","0.00150"],
#["0.0","0.00337"],
#["0.0","0.00675"],
#["0.0","0.00775"],
#["0.0","0.00875"],
#["0.0","0.00975"],
#["0.0","0.01075"],
#["0.0","0.01575"],
#["0.0","0.05575"],
#["0.0","0.10750"],
["0.0","0.20750"]
#["0.0","0.50750"]
#["0.0","0.01250"],
#["0.0","0.02500"],
#["0.0","0.05000"],
#["0.0","0.10000"]
#["0.0","0.20000"]
#["0.0","0.30000"],
#["0.0","0.50000"]
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
#["0.999","0.90"],
#["0.99","0.90"],
#["0.98","0.90"],
#["0.97","0.90"],
#["0.96","0.90"],
#["0.95","0.90"],
#["0.94","0.90"],
#["0.93","0.90"],
#["0.90","0.90"],
#["0.85","0.90"]

# 1 HEBB
#["0.9998","0.90"],
#["0.999","0.90"],
#["0.99","0.90"],
#["0.98","0.90"],
#["0.97","0.90"],
#["0.96","0.90"],
#["0.95","0.90"],
#["0.90","0.90"]

# orthognalization test
#["0.98","0.90"],
["0.99","0.85"],
#["0.999","0.90"],

["0.99","0.90"],
["0.99","0.95"],
#["0.999","0.95"],

#["0.90","0.90"]

#["0.85","0.90"],
#["0.80","0.90"],
#["0.75","0.90"],
#["0.70","0.90"],
#["0.65","0.90"],
#["0.60","0.90"],
#["0.55","0.90"],
#["0.50","0.90"],
#["0.45","0.90"],
#["0.40","0.90"],
#["0.35","0.90"],
#["0.30","0.90"]

#["0.94"],
#["0.93"],
#["0.90"],
#["0.85"],
#["0.80"],
#["0.75"],
#["0.70"],
#["0.65"],
#["0.60"]

    									);
    die "Invalid array: sparsenessLevels" if !validateArray(\@sparsenessLevels);
    
    my @timeConstants					= (
    									["0.100","0.100"]
    									#["0.100"]
    									);
    die "Invalid array: timeConstants" if !validateArray(\@timeConstants);
 	
    my @stepSizeFraction				= ("0.50");  #0.1 = 1/10, 0.05 = 1/20, 0.02 = 1/50
    die "Invalid array: stepSizeFraction" if !validateArray(\@stepSizeFraction);
    
    my @traceTimeConstant				= ("0.500");  # ("0.300","0.800","1.600","2.600"); 
	die "Invalid array: traceTimeConstant" if !validateArray(\@traceTimeConstant);
	

	## orthogonalization
    #my $pathWayLength					= 1;
    #my @dimension						= (100);
    #my @depth							= (1);
    #my @connectivity					= (SPARSE_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    #my @fanInRadius 					= (6); # not used
    #my @fanInCountPercentage 			= ("0.1"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    #my @learningrate					= ("0.1"); # < === is permuted below
    #my @eta								= ("0.8");
    #my @timeConstant					= ("0.1"); # < === is permuted below
    #my @sparsenessLevel					= ("0.1"); # < === is permuted below
    #my @sigmoidSlope 					= ("30.0"); # < === is permuted below
    #my @inhibitoryRadius				= ("6.0");
    #my @inhibitoryContrast				= ("1.4");
    #my @somExcitatoryRadius				= ("0.6");
    #my @somExcitatoryContrast			= ("120.12");
    #my @somInhibitoryRadius				= ("6.0");
    #my @somInhibitoryContrast			= ("1.4");
    #my @filterWidth						= (7);
    #my @epochs							= (10); # only used in discrete model

    #my @saveHistory						= (NO_HISTORY, SINGLE_CELLS); #  NO_HISTORY, ALL, SYNAPSE, SINGLE_CELLS
    #my @recordedSingleCells				= ("()", "((3,13), (6,8))"); # 1-based indexing, as in inspector/MATLAB, not 0-based as 
        
	# Two layer trace
    my $pathWayLength					= 2;
    my @dimension						= (100,30);
    my @depth							= (1,1);
    my @connectivity					= (SPARSE_CONNECTIVITY, SPARSE_CONNECTIVITY);  # FULL_CONNECTIVITY, SPARSE_CONNECTIVITY, SPARSE_BIASED
    my @fanInRadius 					= (6,6); # not used
    my @fanInCountPercentage 			= ("0.1","0.05"); # Not easily permutble due to a variety of issues - generating different blank networks etc.
    my @learningrate					= ("0.1","0.1"); # < === is permuted below
    my @eta								= ("0.8","0.8");
    my @timeConstant					= ("0.1","0.1"); # < === is permuted below
    my @sparsenessLevel					= ("0.1","0.1"); # < === is permuted below
    my @sigmoidSlope 					= ("30.0","30.0"); # < === is permuted below
    my @inhibitoryRadius				= ("6.0","6.0");
    my @inhibitoryContrast				= ("1.4","1.4");
   	my @somExcitatoryRadius				= ("0.6","0.6");
    my @somExcitatoryContrast			= ("120.12","120.12");
   	my @somInhibitoryRadius				= ("6.0","6.0");
    my @somInhibitoryContrast			= ("1.4","1.4");
    my @filterWidth						= (7,7);
    my @epochs							= (10,10); # only used in discrete model
    my @saveHistory						= (NO_HISTORY, ALL); #  NO_HISTORY, ALL, SYNAPSE, SINGLE_CELLS
    my @recordedSingleCells				= ("()", "( (3,9), (6,8), (2,3), (4,5), (8,4), (3,8), (1,5), (6,4), (3,3), (9,5), (13,8), (7,22), (22,26), (12,28), (23,23))");  # 1-based indexing, as in inspector/MATLAB, not 0-based as 
    
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
		cp($PROGRAM, $experimentFolder.$BINARY) or die "Cannot make copy of binary: $!\n" if ($xgrid);
		
		# Make result directory
        mkdir($xgridResult);
	}
	
	# Make copy of this script as summary of parameter space explored
    my $thisScript = abs_path($0);
	cp($thisScript, $experimentFolder."ParametersCopy.pl") or die "Cannot make copy of parameter file: $!\n";
	
    #############################################################################
	# Permuting
    #############################################################################
    
    for my $sS (@sigmoidSlopes) {
	for my $tC (@timeConstants) {
	for my $sSF (@stepSizeFraction) {
	for my $ttC (@traceTimeConstant) {
	for my $l (@learningRates) {
	for my $s (@sparsenessLevels) {
						
						# Layer spesific parameters
						my @sigmoidSlopeArray 			= @{ $sS };
						my @timeConstantArray 			= @{ $tC };
						my @learningRateArray 			= @{ $l };
						my @sparsityArray 				= @{ $s };
						
						print "Uneven parameter length found while permuting." if
							$pathWayLength != scalar(@sigmoidSlopeArray) ||
							$pathWayLength != scalar(@timeConstantArray) ||
   							$pathWayLength != scalar(@learningRateArray) || 
   							$pathWayLength != scalar(@sparsityArray);
						
						# Smallest eta value, it is used with ssF
						my $layerCounter = 0;
						my $minTc = LONG_MAX;
						
						for my $region ( @esRegionSettings ) {
							
							$region->{'sigmoidSlope'} 			= $sigmoidSlopeArray[$layerCounter];
							$region->{'timeConstant'} 			= $timeConstantArray[$layerCounter];
							$region->{'learningrate'} 			= $learningRateArray[$layerCounter];
							$region->{'sparsenessLevel'} 		= $sparsityArray[$layerCounter];
							
							# Find the smallest eta, it is the what sSF is calculated out of
							$minTc = $region->{'timeConstant'} if $minTc > $region->{'timeConstant'};
							
							$layerCounter++;
						}
						
						my $sSPstr = "@sigmoidSlopeArray";
						$sSPstr =~ s/\s/-/g;
						
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
						
						# If there is only a single parameter combination being explored, then just give a long precise name,
						# it's essentially not a parameter search.
						if($simulationCode eq "") {
							$simulationCode = "tC=${tCstr}_sSF=${sSF}_ttC=${ttC}_" if ($neuronType == CONTINOUS);
							$simulationCode = "L=${Lstr}_S=${Sstr}_sS=${sSPstr}_"; #_F=${ficPstr}
						}
						
						if($xgrid) {
							
							my $parameterFile = $experimentFolder.$simulationCode.".txt";
							
							# Make parameter file
							print "\tWriting new parameter file: ". $simulationCode . " \n"; # . $timeStepStr . 
							
							my $result = makeParameterFile(\@esRegionSettings, $sSF, $ttC);
							
							open (PARAMETER_FILE, '>'.$parameterFile) or die "Could not open file '$parameterFile'. $!\n";
							print PARAMETER_FILE $result;
							close (PARAMETER_FILE);
							
							# Add reference to simulation name file
							print SIMULATIONS_FILE $simulationCode.".txt\n";
							
							# Add line to batch file
							print XGRID_FILE "\n" if !$firstTime;
							print XGRID_FILE "$BINARY --xgrid train ${simulationCode}.txt BlankNetwork.txt";
							
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
								my $result = makeParameterFile(\@esRegionSettings, $sSF, $ttC);
								
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
		my @res = ($sName =~ m/(\d+\.\d+)/g);

		#$fD 							= $res[0];
		#$sA 							= $res[1];
		$visualPreferenceDistance		= $res[2];
		$eyePositionPrefrerenceDistance	= $res[3];
		$gaussianSigma					= $res[4];
		$sigmoidSlope					= $res[5];
		$horVisualFieldSize				= $res[6];
		$horEyePositionFieldSize		= $res[7];
	}
	
	sub makeParameterFile {
		
		my ($a, $stepSizeFraction, $traceTimeConstant) = @_;

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

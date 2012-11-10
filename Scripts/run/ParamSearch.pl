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

	use ps1; # ps1, ps2 # <-------- only change this to change to different number of layers!! jippi
	
	my $imported = "ps1"; # psi1,ps2

	####################################################################
	# Input
   	####################################################################
   	
   	# "1.00","2.00","3.00",
   	
   	#our @ftCArray				= ("1.00","2.00","3.00","4.00","5.00","6.00","7.00","8.00","9.00","10.00","11.00","12.00","13.00","14.00","15.00","16.00","17.00","18.00","19.00","20.00","21.00","22.00","23.00","24.00","25.00","26.00","27.00","28.00","29.00","30.00");
   	
   	#for my $ftC (@ftCArray) {
   		
   	my $experiment						= "base6"; #fanin10-reset, baseline-H5-S6
   	
   	# final
   	#my $stim							= "narrowtest-visualfield=200.00-eyepositionfield=40.00-fixations=600.00-targets=1.00-fixduration=0.30-fixationsequence=30.00-seed=72.00-samplingrate=1000.00";
   	my $stim							= "visualfield=200.00-eyepositionfield=40.00-fixations=600.00-targets=1.00-fixduration=0.30-fixationsequence=30.00-seed=72.00-samplingrate=1000.00";
   	
	# 0MOVESTIM
	#my $nTP 							= ceil((2 * 4 * 10)/$ftC);
	#$nTP								= "${nTP}.00";
	#my $experiment						= "sparsitycheck-0MOVESTIM_${ftC}";
	#my $stim							= "0MOVESTIM-Tar=4.00-nTP=${nTP}-ftC=${ftC}-Sim=1.00-fD=0.50-nF=10.00-vpD=1.00-epD=2.00-gS=8.00-sS=0.06-vF=200.00-eF=122.00-sE=44.00";
	
	# sigm=6, works at 01 fanin
	# worked
	#my $stim							= "H3-sigma6-Tar=0.00-nTP=0.00-nOF=90.00-Sim=1.00-fD=0.20-fSL=30.00-vpD=1.00-epD=1.00-gS=6.00-sS=0.06-vF=200.00-eF=116.00-sE=70.00-sR=100.00";
	#my $stim							= "H4-sigma6-Tar=0.00-nTP=0.00-nOF=120.00-Sim=1.00-fD=0.20-fSL=30.00-vpD=1.00-epD=1.00-gS=6.00-sS=0.06-vF=200.00-eF=116.00-sE=70.00-sR=100.00";
	#my $stim							= "mod-H4-sigma6-Tar=0.00-nTP=0.00-nOF=120.00-Sim=1.00-fD=0.20-fSL=30.00-vpD=1.00-epD=1.00-gS=6.00-sS=0.06-vF=200.00-eF=116.00-sE=70.00-sR=100.00";
	#my $stim							= "mod-H8-sigma6-Tar=0.00-nTP=0.00-nOF=240.00-Sim=1.00-fD=0.20-fSL=30.00-vpD=1.00-epD=1.00-gS=6.00-sS=0.06-vF=200.00-eF=116.00-sE=70.00-sR=100.00";
	#my $stim							= "mod-H30-sigma6-Tar=0.00-nTP=0.00-nOF=900.00-Sim=1.00-fD=0.20-fSL=30.00-vpD=1.00-epD=1.00-gS=6.00-sS=0.06-vF=200.00-eF=116.00-sE=70.00-sR=100.00";
	
	# sigma=18, 05 fanIn
	#my $stim							= "H3-sigma18-Tar=0.00-nTP=0.00-nOF=90.00-Sim=1.00-fD=0.20-fSL=30.00-vpD=1.00-epD=1.00-gS=18.00-sS=0.06-vF=200.00-eF=116.00-sE=70.00-sR=100.00";
	#my $stim							= "H4-sigma18-Tar=0.00-nTP=0.00-nOF=120.00-Sim=1.00-fD=0.20-fSL=30.00-vpD=1.00-epD=1.00-gS=18.00-sS=0.06-vF=200.00-eF=116.00-sE=70.00-sR=100.00";
	
	my $xgrid 							= LOCAL_RUN; # LOCAL_RUN, XGIRD_RUN
	my $learningRule					= TRACE; # TRACE, HEBB

	my $nrOfEpochs						= 1; #50; # 30,100
	my $saveNetworkAtEpochMultiple 		= 22;
	my $outputAtTimeStepMultiple		= 1;

	my $lateralInteraction				= COMP; # NONE, COMP, SOM
	my $sparsenessRoutine				= HEAP; # NONE, HEAP, GLOBAL

	my $resetActivity					= "false"; # "false", Reset activation between objects of training
	my $resetTrace						= "false"; # "false", Reset trace between objects of training
	
	my $sigmoidModulationPercentage		= "0.0";
	my $weightVectorLength				= "1.0"; # classic = 1.0
	my $seed							= 55; # 55 is standard
	
	my $visualPreferenceDistance		= "1.0";
	my $eyePositionPrefrerenceDistance 	= "1.0";
	my $gaussianSigma					= "6.0"; 
	my $sigmoidSlope					= "0.0625"; #1/16
	
	my $stimuliTraining 				= $stim."-training";
	my $stimuliTesting 					= $stim."-stdTest";

    ###################################################################
	# Preprocessing
    ###################################################################
    
	# Load params from stimuli name	
	# fixations=100.00-targets=1.00-fixduration=0.30-fixationsequence=20.00-visualfield=200.00-eyepositionfield=100.00-seed=72.00-samplingrate=1000.00-training
	
	my @res 							= ($stimuliTraining =~ m/(\d+\.\d+)/g);
	
	my $horVisualFieldSize				= $res[0];
	my $horEyePositionFieldSize			= $res[1];

	print "Visual Field Size: 			$horVisualFieldSize\n";
	print "Eye Position Field: 			$horEyePositionFieldSize\n\n";
    
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
	my $paramResult = makeParameterFile(\@esRegionSettings, "0.1", "0.1",$sigmoidModulationPercentage); # "0.1");
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
	
	my $importScript = $PERL_SCRIPT_FOLDER.$imported.".pm";
	cp($importScript, $experimentFolder.$imported.".pm") or die "Cannot make copy of parameter file: $!\n";
	
	#############################################################################
	# Permuting
    #############################################################################


    #for my $sMP (@sigmoidModulationPercentage) {
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
						$simulationCode .= "tC=${tCstr}_" if scalar(@timeConstants) > 1;
						$simulationCode .= "sSF=${sSF}_" if scalar(@stepSizeFraction) > 1;
						$simulationCode .= "ttC=${ttC}_" if scalar(@traceTimeConstant) > 1;
						$simulationCode .= "L=${Lstr}_" if scalar(@learningRates) > 1;
						$simulationCode .= "S=${Sstr}_" if scalar(@sparsenessLevels) > 1;
						$simulationCode .= "sS=${sSPstr}_" if scalar(@sigmoidSlopes) > 1;
						$simulationCode .= "sT=${sTstr}_" if scalar(@sigmoidThresholds) > 1;
						$simulationCode .= "gIC=${gICstr}_" if scalar(@globalInhibitoryConstants) > 1;
						$simulationCode .= "eS=${eSstr}_" if scalar(@externalStimulations) > 1;
						#$simulationCode .= "sMPs=${sMP}_" if scalar(@sigmoidModulationPercentage) > 1;
						
						# If there is only a single parameter combination being explored, then just give a long precise name,
						# it's essentially not a parameter search.
						if($simulationCode eq "") {
							$simulationCode = "tC=${tCstr}_sSF=${sSF}_ttC=${ttC}_"; # if ($neuronType == CONTINOUS);
							$simulationCode = "L=${Lstr}_S=${Sstr}_sS=${sSPstr}_sT=${sTstr}_gIC=${gICstr}_eS=${eSstr}_"; #_F=${ficPstr}
						}
						
						if($xgrid) {
							
							my $parameterFile = $experimentFolder.$simulationCode.".txt";
							
							# Make parameter file
							print "\tWriting new parameter file: ". $simulationCode . " \n"; # . $timeStepStr . 
							
							my $result = makeParameterFile(\@esRegionSettings, $sSF, $ttC, $sigmoidModulationPercentage); #, $sMP);
							
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

								my $result = makeParameterFile(\@esRegionSettings, $sSF, $ttC, $sigmoidModulationPercentage); #, $sMP);
								
								open (PARAMETER_FILE, '>'.$parameterFile) or die "Could not open file '$parameterFile'. $!\n";
								print PARAMETER_FILE $result;
								close (PARAMETER_FILE);

								# Run training -  redirect output to log
								#system("$PERL_RUN_SCRIPT train $experiment $simulation $stimuliTraining > ${simulationFolder}log.dat") == 0 or exit;
								system("$PERL_RUN_SCRIPT train $experiment $simulation $stimuliTraining 2>&1 | tee -a ${simulationFolder}log.dat") == 0 or exit;

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
    #}
    
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
		system($MATLAB . " -r \"cd('$MATLAB_SCRIPT_FOLDER');plotExperiment('$experiment','$stimuliTesting');quit;\"");	
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
* Euclidean length of weight vector of each synapse,
* classic = 1.0
*/
weightVectorLength = $weightVectorLength;

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
* Only used in build command:
* Random seed used to setup initial weight strength
* and setup connectivity based on radii parameter.
*/
seed = $seed;

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
	* Spread of gaussian component
	*/
	gaussianSigma = $gaussianSigma;
	
	/*
	* Horizontal visual field size
	*/	
	horVisualFieldSize = $horVisualFieldSize;

	/*
	* Horizontal eye position field size
	*/		
	horEyePositionFieldSize = $horEyePositionFieldSize;
	
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


#}

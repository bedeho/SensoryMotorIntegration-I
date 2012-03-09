#!/usr/bin/perl

	#
	#  xGridCleanup.pl
	#  SMI
	#
	#  Created by Bedeho Mender on 21/11/11.
	#  Copyright 2011 OFTNAI. All rights reserved.
	#

	use strict;
    use warnings;
    use POSIX;
	use File::Copy "cp";
	use Data::Dumper;
	use myConfig;

	if($#ARGV < 0) {

		print "To few arguments passed.\n";
		print "Usage:\n";
		print "Arg. 1: experiment name\n";
		print "Arg. 2: stimuli name\n";
		exit;
	}
	
	my $experiment;
	if($#ARGV >= 0) {
        $experiment = $ARGV[0];
	}
	else {
		die "No experiment name provided\n";
	}
	
	my $stimuli;
	if($#ARGV >= 1) {
        $stimuli = $ARGV[1];
	} else {
        die "No stimuli name provided\n";
	}
	
	#my $nrOfEyePositionsInTesting;
	#if($#ARGV >= 2) {
    #    $nrOfEyePositionsInTesting = $ARGV[2];
	#} else {
    #    die "No eye position name provided\n";
	#}
	
    my $experimentFolder 		= $BASE."Experiments/".$experiment."/";
    my $experimentFolderBackup	= $BASE."Experiments/".$experiment."_backup/";
    
    # Make safe copy of experiment folder
	print "Making backup of experiment folder...\n";
	system("cp -r $experimentFolder $experimentFolderBackup") == 0 or die "Copying experiment folder $experimentFolder content into $experimentFolderBackup failed: $!\n";
	
    my $xgridResult = $BASE."/Xgrid/".$experiment."/";
    my $xgridResultBackup = $BASE."/Xgrid/".$experiment."_backup/";
    
	# Make safe copy of xgrid result folder
	print "Making backup of xgrid result folder...\n";
	system("cp -r ${xgridResult} $xgridResultBackup") == 0 or die "Copying xgrid results $xgridResult content into $xgridResultBackup failed: $!\n";

	open (F, "${experimentFolder}simulations.txt") || die "Could not open ${experimentFolder}simulations.txt: $!\n";
	my @lines = <F>;
	close F;
	
	# Move from result folder to xgrid working directory
	system("mv ${xgridResult}* $experimentFolder") == 0 or die "Moving xgrid results $xgridResult content into $experimentFolder failed: $!\n";
	
	for(my $i = 0;$i < $#lines+1;$i++) {
		
		# Perhaps simulation never finished, or is not finished yet, if so skip it
		next if not (-d "${experimentFolder}${i}");
		
		# Get name of parameter file
		my $file = $lines[$i];
		
		# Check for trailing new line
		chomp($file) if (substr($file, -1, 1) eq "\n");
		
		print "\nProcessing job $i: $file\n";
		print "****************************************************************************************************\n";
		
		# Move it into dir
		system("mv ${experimentFolder}$file ${experimentFolder}${i}/Parameters.txt") == 0 or die "Moving parameter file $file failed: $!\n";
					
		# Make /Training subdirectory
		mkdir("${experimentFolder}${i}/Training") or die "Could not make training dir ${experimentFolder}${i}/Training dir: $!\n";
		
		# Untar result.tgz
		system("tar -xjf ${experimentFolder}${i}/result.tbz -C ${experimentFolder}${i}") == 0 or die "Could not untar ${experimentFolder}${i}/result.tbz: $!\n";
		
		# Move results into /Training
		system("mv ${experimentFolder}${i}/*.dat ${experimentFolder}${i}/Training") == 0 or print "Unable to save training data: $!\n";
		
		# Copy blank network into folder so that we can do control test automatically
		my $blankNetworkSRC = $experimentFolder."BlankNetwork.txt";
		my $blankNetworkDEST = $experimentFolder.$i."/BlankNetwork.txt";
		cp($blankNetworkSRC, $blankNetworkDEST) or die "Copying blank network failed: $!\n";
		
		# Rename dir
		my $simulation = substr($file, 0, -4);
		system("mv ${experimentFolder}$i ${experimentFolder}$simulation") == 0 or die "Renaming folder ${experimentFolder}${simulation} failed: $!\n";
		
		# Run test
		system($PERL_RUN_SCRIPT, "test", $experiment, $simulation, $stimuli);
	}
	
	# Call matlab to plot all
	system($MATLAB . " -r \"cd('$MATLAB_SCRIPT_FOLDER');plotExperiment('$experiment','$stimuli');\"");
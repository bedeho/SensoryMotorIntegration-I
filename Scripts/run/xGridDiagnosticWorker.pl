#!/usr/bin/perl

	#
	#  xGridDiagnosticWorker.pl
	#  SMI
	#
	#  Created by Bedeho Mender on 21/11/11.
	#  Copyright 2011 OFTNAI. All rights reserved.
	#
	
	# This intermediary script worker calls the program
	# we wish to run, however since it is the entry point
	# for xgrid and it cannot fail we are sure to see all 
	# failures that may arise in the simulator itself.
	# If we simply call the simulator directly,then if it
	# fails to start, then we get no diagnostics from the grid.
	# It also does an ls for us.

	use strict;
    use warnings;
    #use POSIX;
	#use File::Copy "cp";
	#use Data::Dumper;
	
	print("***Files in sandbox***\n");
	system("ls -al");
	
	print("***Arguments***\n");
	my $runCommand = ""; # because we know we are running a local binary
	my $counter = 1;
	foreach my $var (@ARGV)
	{
		if($counter == 1) {
			$runCommand = "./$var";
		} else {
			$runCommand = $runCommand . " $var";
		}
		
		print "arg #${counter}: $var \n";
		$counter++;
	}
	
	print("***Starting***\n");
	print("COMMAND: $runCommand\n");
	system($runCommand);
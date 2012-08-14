
	package myLib;
	
	use strict;
	use warnings FATAL => 'all';
	use base qw(Exporter);

	our @EXPORT = qw(compare 
			trim 
			validateArray
			FULL_CONNECTIVITY
			SPARSE_CONNECTIVITY
			SPARSE_BIASED
			NO_HISTORY
			ALL
			NO_SYNAPSE 
			SINGLE_CELLS 
			);

        # Connectivity
        use constant FULL_CONNECTIVITY => 0;
        use constant SPARSE_CONNECTIVITY => 1;
        use constant SPARSE_BIASED => 2;

        # saveHistory
        use constant NO_HISTORY => 0;
        use constant ALL => 1;
        use constant NO_SYNAPSE => 2;
        use constant SINGLE_CELLS => 3;
	
	# WE MUST MAKE SURE THAT THERE ARE NO DUPLICATES IN THE
	# PARAMTER RANGES, OTHERWISE WE WILL OVERWRITE EXPERIMENT NAMES
	sub validateArray {
		
		my ($input) = @_;

		my @arr = @{$input};
		my $length = scalar (@arr);
		
	   	for(my $i = 0;$i < $length;$i++) {
	   		for(my $j = 0;$j < $length;$j++) {
	   			
	   			# Dont compare with itself
	   			next if ($i == $j);
	   			
	   			# compare (supports both scalar and references)
	   			return 0 if compare($arr[$i], $arr[$j]);
	    	}
	    }

		return 1;
	}

	# Data::Compare, but it was impossible to install
	# on lab machines.
	# compare numbers or array of numbers
	sub compare {
		
		my ($elm_1, $elm_2) = @_;
		
		die("incompatible types being compared.\n") if (ref($elm_1) ne ref($elm_2));
			
		if(ref($elm_1) eq 'ARRAY') {
			my @arr_1 = @{$elm_1};
			my @arr_2 = @{$elm_2};
			
			my $length_1 = scalar (@arr_1);
			my $length_2 = scalar (@arr_2);
			
			die("unequal length.\n") if ($length_1 != $length_2);
			
			# compare two arrays
		   	for(my $i = 0;$i < $length_1;$i++) {
		   		return 0 if $arr_1[$i] != $arr_2[$i];
		    }
		    
		    return 1;
			
		} else {
			
			# compare scalars
			return $elm_1 == $elm_2;
		}
	}
	
	# http://www.somacon.com/p114.php
	# Perl trim function to remove whitespace from the start and end of the string
	sub trim($)
	{
		my $string = shift;
		$string =~ s/^\s+//;
		$string =~ s/\s+$//;
		return $string;
	}

	1;

#!/usr/bin/perl
use warnings;
use strict;

# Need to edit file/dir paths to wherever these are living.
my $transport = '~/mfem/miniapps/plasma/transport2d';
my $root_dir = '~/mfem/miniapps/plasma/';
my $input_path = '../input-files/';
my $mesh_path = '~/mfem/data/';

my @chi = qw(1.0e3 1.0e4);
#my @chi = qw(1.0e6);
foreach my $chi (@chi) {
	my $filename = 'input-files/transport2d_ecs.inp';
	my $newfile = "$filename.new";
	my $backup = "$filename~";

	open my $in, '<', $filename or die $!;
	open my $out, '>', $newfile or die $!;

	while(<$in>) {
		s/.*/ConstantCoefficient ${chi} / if $.==20;
		print {$out} $_;
		print if ($.==19 || $.==20);
	}

	close $out or die $!;
	rename $filename, $backup or die $!;
	rename $newfile, $filename or die $!;

	my $folder = "chi".$chi;
        mkdir($folder, 0755);
        chdir($folder) or die "can't chdir $folder\n";
        open (my $file, ">", "output.out") or die "Could not open file: $!";

        my $command = "mpirun -np 16 ".$transport." -rs 1 -o 3 -m ".$mesh_path."inline-quad.mesh"." -bc ".$input_path."transport2d_bcs.inp"." -ic ".$input_path."transport2d_ics.inp"." -ec ".$input_path."transport2d_ecs.inp"." -op 2 -l 1 -visit -dt 1.0e-2 -tf 100 -eqn-w '1 1 1 1 1' -term-flags '-1 17 -1 -1 -1' -vs 4 -p 0 -es ".$input_path."transport2d_ess.inp"." -srtol 1.0e-8 -satol 1.0e-8 -natol 1.0e-10 -nrtol 1.0e-10 -latol 1.0e-6 -lrtol 1.0e-6 -lmaxit 500 -pt 1 -no-amr -nmaxit 10";
 
	my $output = `$command`;
 	
        print $file $output;
	#die "$!" if $?;
 
	if ($output) {
		print "Done.\n";
	}
	else {
		die $!;
		next;
	}
       
#	next;
	chdir("../");

}

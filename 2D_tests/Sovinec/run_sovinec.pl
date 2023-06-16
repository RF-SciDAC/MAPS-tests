#!/usr/bin/perl
use strict;
use warnings;

my $r = 1;
my $o = 1;

my $transport = '~/Documents/git-repos/RF-SciDAC/mfem/build/miniapps/plasma/transport2d';
my $root_dir = '~/Documents/git-repos/RF-SciDAC/mfem/build/miniapps/plasma/';
my $input_path = '~/Documents/git-repos/RF-SciDAC/mfem-analysis/2D_tests/Sovinec/';
my $mesh_path = '~/Documents/git-repos/RF-SciDAC/mfem/build/data/';

for ($o = 3; $o < 6; $o = $o + 1) {
	for ($r = 0; $r < 4; $r = $r + 1) {
		
		next if($o == 5 && ($r == 3 || $r == 2));
                #next if($o == 2 && ($r == 4 || $r == 5));
                next if($o == 4 && ($r == 3));
                #next if($o == 3 && ($r == 3 || $r == 4 || $r == 5));
				
		my $folder = "r".$r."_o".$o."";
		mkdir($folder, 0755);
		chdir($folder) or die "can't chdir $folder\n";	
		open (my $file, ">", "output.out") or die "Could not open file: $!";
	
		my $command = "mpirun -np 1 ".$transport." -rs ".$r." -o ".$o." -m ".$mesh_path."inline-quad.mesh"." -bc ".$input_path."transport2d_bcs.inp"." -ic ".$input_path."transport2d_ics.inp"." -ec ".$input_path."transport2d_ecs.inp"." -op 2 -term-flags '-1 17 -1 -1 -1' -l 1 -visit -dt 1.0e-2 -tf 100 -eqn-w '1 1 1 1 1' -vs 4 -p 0 -es ".$input_path."transport2d_ess.inp"." -natol 1.0e-10 -nrtol 1.0e-10 -latol 1.0e-6 -lrtol 1.0e-6 -satol 1.0e-8 -srtol 1.0e-8 -nmaxit 1 -lmaxit 500 -pt 1 -no-amr -fld-m '1 1 1 1 1' ";	

		my $output = `$command`;

		#die "$!" if $?;
		print $file $output;

		if ($output) {
			print "Done.\n";
		}
		else {
			print "Error.\n";
			die $!;
			next;
		}
		
		chdir("../");
		
	}
}

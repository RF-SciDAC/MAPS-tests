#!/usr/bin/perl
#use strict;
use warnings;

$r = 1;
$o = 1;

$transport = '~/mfem/miniapps/plasma/transport2d';
$root_dir = '~/mfem/miniapps/plasma/';
#$prefix = 'Transport2D-Parallel';
$input_path = '~/mfem-analysis/input-files/';
$mesh_path = '~/mfem/data/';

for ($o = 1; $o < 5; $o = $o + 1) {
	for ($r = 0; $r < 6; $r = $r + 1) {
		
		next if($o == 4 && ($r == 3 || $r == 4 || $r == 5));
		next if($o == 3 && ($r == 4 || $r == 5));
		next if($o == 2 && ($r == 5));
		next if($o == 1 && ($r == 0 || $r == 1 || $r == 2));

		my $folder = "r".$r."_o".$o."";
		mkdir($folder, 0755);
		chdir($folder) or die "can't chdir $folder\n";	
		open (my $file, ">", "output.out") or die "Could not open file: $!";
	
		$command = "mpirun -np 1 ".$transport." -rs ".$r." -o ".$o." -m ".$mesh_path."inline-quad.mesh"." -bc ".$input_path."transport2d_bcs.inp"." -ic ".$input_path."transport2d_ics.inp"." -ec ".$input_path."transport2d_ecs.inp"." -op 8 -l 1 -visit -dt 1.0e-2 -tf 200 -eqn-w '1 1 1 1 1' -vs 4 -p 0 -es ".$input_path."transport2d_ess.inp"." -srtol 1.0e-8 -satol 1.0e-8 -natol 1.0e-10 -nrtol 1.0e-10 -latol 1.0e-6 -lrtol 1.0e-6 -pt 2 -no-amr -dgk 100 -nmaxit 1";	

		$output = `$command`;

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

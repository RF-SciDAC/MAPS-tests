#!/usr/bin/perl
#use strict;
use warnings;

$r = 1;
$o = 1;

$transport = '~/mfem/miniapps/plasma/transport2d';
$root_dir = '~/mfem/miniapps/plasma/';
$input_path = '../../input-files/';
$mesh_path = '~/mfem/data/';

for ($o = 1; $o < 4; $o = $o + 1) {
	for ($r = 0; $r < 4; $r = $r + 1) {
		
		my $folder = "r".$r."_o".$o."";
		mkdir($folder, 0755);
		chdir($folder) or die "can't chdir $folder\n";	
		open (my $file, ">", "output.out") or die "Could not open file: $!";
	
		$command = "mpirun -np 16 ".$transport." -rs ".$r." -o ".$o." -m ".$mesh_path."inline-quad.mesh"." -bc ".$input_path."transport2d_bcs.inp"." -ic ".$input_path."transport2d_ics.inp"." -ec ".$input_path."transport2d_ecs.inp"." -op 2 -term-flags '-1 1 -1 -1 -1' -l 1 -visit -dt 1.0e-2 -tf 0.03 -eqn-w '1 1 1 1 1' -vs 1 -p 0 -es ".$input_path."transport2d_ess.inp"." -natol 1.0e-10 -nrtol 1.0e-10 -latol 1.0e-6 -lrtol 1.0e-6 -pt 1 -no-amr";	

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

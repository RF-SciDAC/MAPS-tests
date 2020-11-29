#!/usr/bin/perl
#use strict;
use warnings;

$r = 1;
$o = 1;

$transport = '../mfem/miniapps/plasma/transport2d';
$root_dir = '..//mfem/miniapps/plasma/';
#$prefix = 'Transport2D-Parallel';
$mesh_path = '../mfem/data/';

for ($r = 1; $r < 2; $r = $r + 1) {
	for ($o = 1; $o < 2; $o = $o + 1) {
		
		open (my $file, ">", "".$r."_".$o."_output.out") or die "Could not open file: $!";
	
		$command = "mpirun -np 16 ".$transport." -rs ".$r." -o ".$o." -m ".$mesh_path."inline-quad.mesh"." -bc ".$root_dir."transport2d_bcs.inp"." -ic ".$root_dir."transport2d_ics.inp"." -ec ".$root_dir."transport2d_ecs.inp"." -op 8 -l 1 -visit -dt 1.0e-2 -tf 100 -eqn-w '1 1 1 1 1' -vs 1 -p 0 -es ".$root_dir."transport2d_ess.inp"." -srtol 1.0e-8 -satol 1.0e-8 -natol 1.0e-10 -nrtol 1.0e-10 -latol 1.0e-6 -lrtol 1.0e-6 -lmaxit 500";	

		$output = `$command`;
		
		die "$!" if $?;
		print $file $output;	
		
	}
}

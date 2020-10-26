#!/usr/bin/perl
#use strict;
use warnings;

$r = 1;
$o = 1;

$transport = '~/Documents/MFEM/mfem/miniapps/plasma/transport2d';
$root_dir = '~/Documents/MFEM/mfem/miniapps/plasma/';
$prefix = 'Transport2D-Parallel';
$mesh_path = '~/Documents/MFEM/mfem/data/';

for ($r = 1; $r < 2; $r = $r + 1) {
	for ($o = 1; $o < 2; $o = $o + 1) {
		
		open (my $file, '>', 'output.txt') or die "Could not open file: $!";
	
		$command = $transport." -rs ".$r." -o ".$o." -m ".$mesh_path."inline-quad.mesh"." -bc ".$root_dir."transport2d_bcs.inp"." -ic ".$root_dir."transport2d_ics.inp"." -ec ".$root_dir."transport2d_ecs.inp"." -op 8 -l 1 -visit -dt 1.0e-2 -tf 100 -eqn-w '1 1 1 1 1' -vs 1 -p 0 -es ".$root_dir."transport2d_ess.inp"." -srtol 1.0e-8 -satol 1.0e-8 -natol 1.0e-7 -nrtol 1.0e-7";	

        	$output = `$command`;
		
		die "$!" if $?;
		print $file $output;	
		
	}
}

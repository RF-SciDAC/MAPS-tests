#!/usr/bin/perl
use warnings;
use strict;

my @chi = qw(1.0e3 1.0e4 1.0e5 1.0e6 1.0e7 1.0e8 1.0e9);
foreach my $chi (@chi) {
	my $filename = 'input-files/transport2d_ecs.inp';
	my $newfile = "$filename.new";
	my $backup = "$filename~";

	open my $in, '<', $filename or die $!;
	open my $out, '>', $newfile or die $!;

	while(<$in>) {
		s/.*/ConstantCoefficient ${chi} / if $.==22;
		print {$out} $_;
		print if ($.==21 || $.==22);
	}

	close $out or die $!;
	rename $filename, $backup or die $!;
	rename $newfile, $filename or die $!;
}

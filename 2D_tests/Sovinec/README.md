Suggested command line:

transport2d -rs 1 -o 1 -m inline-quad.mesh -bc transport2d_bcs.inp -ic transport2d_ics.inp -ec transport2d_ecs.inp -op 2 -term-flags '-1 17 -1 -1 -1' -l 1 -visit -dt 1.0e-2 -tf 100 -eqn-w '1 1 1 1 1' -vs 4 -p 0 -es transport2d_ess.inp -natol 1.0e-10 -nrtol 1.0e-10 -latol 1.0e-6 -lrtol 1.0e-6 -satol 1.0e-8 -srtol 1.0e-8 -nmaxit 10 -lmaxit 500 -pt 1 -no-amr -fld-m '1 1 1 1 1'

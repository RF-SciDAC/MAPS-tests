Command to run sol1d comparison in MAPS

path/to/transport2d -m-sol1d '50 1.0 1.03' -ic transport2d_ics.inp -bc transport2d_bcs.inp -ec transport2d_ecs.inp -es transport2d_ess.inp -eqn-w '1 1 1 1 1' -fld-m '1e15 1e19 1e4 1 1' -op 6 -term-flags '-1 -1 -1 0 0' -vs 100 -tf 1.0e-4 -o 3 -visit -no-amr -l 1 -dt 1.0e-6 -pt 2 -vis -s 0 -vis-flags '-1 -1 -1 -1 -1 511'

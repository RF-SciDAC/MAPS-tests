
###############################
1D Tests: Comparison with Sol1D
###############################

These setup files are intened to run a case similar to that
implemented by Jin Myung Park in:

https://github.com/ORNL-Fusion/sol1d

A suitable command line for this test problem would be:

transport2d -m slab_256.mesh -ic transport2d_ics.inp -bc transport2d_bcs.inp -ec transport2d_ecs.inp -es transport2d_ess.inp -eqn-w '1 1 1 1 1' -fld-m '1e15 1e17 1e4 1 1' -term-flags '-1 -1 -1 -1 -1' -vs 1 -tf 1.0e-5 -dt 1e-9 -o 3 -visit -no-amr -l 1 -op 31 -pt 2

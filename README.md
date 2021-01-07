# Analysis scripts for MFEM `transport2d` output #

Running the script `run_chiscans.pl` will produce directories with outputs for a chi parallel scan over 10^3 <= chi parallel <= 10^9, for an 8x8 grid and order 3 polynomial. This set of refinement and order was chosen as it is used in all of the Sovinec benchmark cases (10^3, 10^6, 10^9), providing a good idea for where we expect the code to converge for both high and low anisotropies, although the error is large for chi parallel = 10^9.

Running the script `read_convdata.m` should produce the figure

![plot](./output-files/chi_scan.png)

where missing values in the figure indicate where the MPI Abort error occured.  

Dependencies: Perl v5.26.1
	      Matlab 2018b

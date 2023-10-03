We aim to benchmark the MAPS code against the results in
``Mesh refinement for anisotropic diffusion in magnetized plasmas'', Vogl et. al, 2023. This study
uses adaptive mesh refinement (AMR) as an approach to resolving a narrow boundary layer on the interior
of the last closed flux surface (LCFS) of a fusion device. This type of boundary layer is also routinely
observed at fusion device boundaries.

There are three magnetic flux functions defined: single null (Eq. 10); double null (Eq 12); 
and magnetic island (Eq. 14). We focus on the single and double null orientations.

For the single and double null configurations, A heat source s(x,y) is placed inside the LCFS, 

s(x,y) = exp[-1/2*(((x - 1/2)/(1/8))^2 + ((y - 1/2)/(1/8))^2)]

with 0 <= x <= 1 and 0 <= y <= 1. The boundary conditions are given by T(0,y)=T(x,0)=T(1,y)=T(x,1) = 0. This
paper solves the steady state heat equation, however MAPS is time dependent, and we set the initial condition
to zero. 

We use anisotropy ratio values of 10^2, 10^4, and 10^6. Example input files are given in the chi1e2
directory. 

A possible command line for this test would be

./transport2d -amr -visit -vs 1 -et transport_ets.inp -ec transport2d_ecs.inp -ic transport2d_ics.inp -bc transport2d_bcs.inp -vis-flags '-1 -1 -1 4095 -1' -pt 2 -s 1 -srtol 1e-6 -nrtol 1.0e-8 -lrtol 1.0e-10 -dt 1e-2 -tf 100 -o 2 -m inline-quad.mesh -rp 1 -p # 
 
where the relative Newton and GMRES solver tolerances -nrtol and -lrtol may need to be adjusted. The -p argument will set the desired background field orientation. 

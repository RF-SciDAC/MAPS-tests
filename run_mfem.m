get_values = '~/mfem/miniapps/tools/get-values';
transport = '~/mfem/miniapps/plasma/transport2d';
input_dir = '~/mfem-analysis/mom_test/';
prefix = 'Transport2D-Parallel';

[status,git_hash] = system('git rev-parse HEAD');
s1 = '# Created from matlab git hash ';
s2 = git_hash;
header = [s1 s2];

anisoTest = 0;
mmsTest = 1;

npArray = ["032","064","128","256","512"];

if anisoTest

    mkdir(['/Volumes/DATA/postdoc/mfem/benchmarking/sovinec_' num2str(jj-1) '_' num2str(kk)])
    cd(['/Volumes/DATA/postdoc/mfem/benchmarking/sovinec_',num2str(jj-1),'_',num2str(kk)])

    fprintf('Running transport2d for refinement %d and order %d\n',jj-1,kk)

    strcat(transport," -rs ",num2str(jj-1)," -o ",num2str(kk),...
        " -m ",strcat(mesh_path,'inline-quad.mesh')," -bc ",strcat(input_dir,"/transport2d_bcs.inp"),...
        " -ic ",strcat(input_dir,"/transport2d_ics.inp"), " -ec ",strcat(input_dir,"/transport2d_ecs.inp"),...
        " -op 8 -l 1 -visit -dt 1.0e-2 -tf 100 -eqn-w '1 1 1 1 1' -vs 1 -p 0 -es ",...
        strcat(input_dir,"/transport2d_ess.inp"),...
        " -srtol 1e-8 -satol 1e-8 -natol 1e-7 -nrtol 1e-7 -latol 1e-8 -lrtol 1e-8 > output.out");

elseif mmsTest

    for ii=1:length(npArray)

        dirName = strcat(input_dir,"run-test/O3_N",npArray(ii));
        mkdir([dirName])
        cd([dirName])

        order = 3;

        fprintf('Running transport2d for NP %s and order %d\n',npArray(ii),order)

        mesh_path = '~/mfem-analysis/mom_test/';

        strcat(transport," -o ",num2str(order),...
        " -m ",strcat(mesh_path,'inline-quad.mesh')," -bc ",strcat(input_dir,"/transport2d_bcs.inp"),...
        " -ic ",strcat(input_dir,"/transport2d_ics.inp"), " -ec ",strcat(input_dir,"/transport2d_ecs.inp"),...
        " -op 4 -l 1 -visit -dt 1.0e-12 -tf 1.0e-12 -eqn-w '1 1 1 1 1' -vs 1 -p 0 -es ",...
        strcat(input_dir,"/transport2d_ess.inp"),...
        " -term-flags '-1 -1 11 -1 -1' -natol 1e-12 -nrtol 1e-12 -latol 1e-12 ",...
        "-lrtol 1e-12 -dza 0 -dzb 1e20 -fld-m '1 1 1 1 1' -no-amr > output.out")

        cd('../')
            
%         system(command);
%     [status,output] = system(command);

    end


end

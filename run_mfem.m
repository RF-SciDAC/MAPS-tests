root = '/home/gz6';
get_values = [root,'/mfem/miniapps/tools/get-values'];
transport = [root,'/mfem/miniapps/plasma/transport2d'];
input_dir = [root,'/mfem-analysis/testing/mom_test/'];
prefix = 'Transport2D-Parallel';

[status,git_hash] = system('git rev-parse HEAD');
s1 = '# Created from matlab git hash ';
s2 = git_hash;
header = [s1 s2];

anisoTest = 0;
mmsTest = 1;

npArray = ["8","16","32","64","128","256","512"];

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

% Save library paths
MatlabPath = getenv('LD_LIBRARY_PATH');
% Make Matlab use system libraries
setenv('LD_LIBRARY_PATH',getenv('PATH'));

order_vals = [2,3,4];

for order=order_vals
    for ii=1:length(npArray)

        old_dir = pwd();
        dirName = strcat("run-test/O3_N",npArray(ii));
        mkdir([dirName])
        cd([dirName])

        %order = 3;
        %dt = 1e-12;

        fprintf('Running transport2d for NP %s and order %d\n',npArray(ii),order)

        mesh_path = [root,'/mfem-analysis/testing/mom_test/slab_',char(npArray(ii)),'.mesh'];
        %mesh_path = [root,'/mfem/data/'];

        %/home/gz6/mfem-analysis/testing/mom_test/slab_64.mesh

        command = strcat(transport," -o ",num2str(order),...
        " -m ",string(mesh_path)," -bc ",strcat(input_dir,"/transport2d_bcs.inp"),...
        " -ic ",strcat(input_dir,"/transport2d_ics.inp"), " -ec ",strcat(input_dir,"/transport2d_ecs.inp"),...
        " -op 4 -l 1 -visit -dt 1.0e-16 -tf 1.0e-16 -eqn-w '1 1 1 1 1' -vs 1 -p 0 -es ",...
        strcat(input_dir,"/transport2d_ess.inp"),...
        " -term-flags '-1 -1 11 -1 -1' -natol 1e-12 -nrtol 1e-12 -latol 1e-12 ",...
        string(['-lrtol 1e-12 -dza 0 -dzb 1e20 -fld-m "1 1 1 1 1" -no-amr ','-rs ',num2str(-1),' > output.out']));
            
       system(command);
       t = table2array(readtable('transport2d_err.out','FileType','text'));
       error(order,ii) = t(2,7);
       cd(old_dir);
%     [status,output] = system(command);

    end
end
% Reassign old library paths
setenv('LD_LIBRARY_PATH',MatlabPath)

for i=1:numel(npArray)
    num_points(i) = str2num(npArray(i));
end
figure()
for order=order_vals
loglog(num_points,error(order,:),'Marker','o','DisplayName',['Order=',num2str(order)])
hold on
end
hold off
legend
title('Error(resolution)');
ylabel('Error');
xlabel('num grid points');
end

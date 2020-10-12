get_values = '~/Documents/MFEM/mfem/miniapps/tools/get-values';
transport = '~/Documents/MFEM/mfem/miniapps/plasma/transport2d';
root_dir = '~/Documents/MFEM/mfem/miniapps/plasma';
prefix = 'Transport2D-Parallel';
mesh_path = '~/Documents/MFEM/mfem/data/';

NP = 2;
[status,git_hash] = system('git rev-parse HEAD');
s1 = '# Created from matlab git hash ';
s2 = git_hash;
header = [s1 s2];

% dir_data = dir(root_dir);

%%
for jj=1:5
    for kk=1:5
        
        mkdir(['/Volumes/DATA/postdoc/mfem/benchmarking/sovinec_' num2str(jj-1) '_' num2str(kk)])
        cd(['/Volumes/DATA/postdoc/mfem/benchmarking/sovinec_',num2str(jj-1),'_',num2str(kk)])
        
        fprintf('Running transport2d for refinement %d and order %d\n',jj-1,kk)
        
        command = strcat(transport," -rs ",num2str(jj-1)," -o ",num2str(kk),...
            " -m ",strcat(mesh_path,'inline-quad.mesh')," -bc ",strcat(root_dir,"/transport2d_bcs.inp"),...
            " -ic ",strcat(root_dir,"/transport2d_ics.inp"), " -ec ",strcat(root_dir,"/transport2d_ecs.inp"),...
            " -op 8 -l 1 -visit -dt 1.0e-2 -tf 100 -eqn-w '1 1 1 1 1' -vs 1 -p 0 -srtol 1e-1 -satol 1e-1");
%         system(command);
        [status,output] = system(command);
        
        dlmwrite('log_output.txt',output,'delimiter','');
        dlmwrite('log_status.txt',status,'delimiter','');
        
        dir_data = dir(pwd);
        
        %% Initial settings
        fprintf('\nUsing dir = %s with prefix = %s\n',pwd,prefix)

        %%  Parse dir to get nt
        nt = 0;
        for ii = 1:length(dir_data)
            if dir_data(ii).isdir
                % Check if prefix_######
                if regexp(dir_data(ii).name, regexptranslate('wildcard', strcat(prefix,'_******')))
                    nt = nt + 1;
                end
            end
        end

        if nt == 0
            error('Could not find any time steps using prefix: %s',prefix)
        else
            fprintf('Found nt = %d timesteps\n',nt)
        end

        %% Parse mfem_root files to get times
        time = nan(1,nt);
        for ii = 0:nt-1
            fname = fullfile(strcat(prefix,'_',num2str(ii,'%06.f'),'.mfem_root'));
            fid = fileread(fname);
            time_loc = regexp(fid,'"time"');
            ind_col = strfind(fid(time_loc:time_loc+10),': ');
            ind_com = strfind(fid(time_loc:time_loc+30),',');
            time(ii+1) = str2double(fid(time_loc+ind_col+1:time_loc+ind_com-1));
        end

        %% Parse output file to get convergence information
        
        fname = ('log_output.txt');
        fid = fileread(fname);
        nlines = textscan(fid,'%s','delimiter','\n');
%         newton_loc = regexp(fid,'Newton iteration');
        count = 1;
        for ii=1:length(nlines{1})
            line = char(nlines{1}(ii));
%             if isempty(line)
%             elseif ~isempty(line)
                newton_loc = regexp((line),'Newton iteration');
                if ~isempty(newton_loc)
                    newton_data = textscan(line,'%s %s %d : %s = %f, %s = %f');
                    newton_iter(1,count) = newton_data{3};
                    newton_res(1,count) = newton_data{5};

                    if ~isempty(newton_data{7})
                        newton_res_norm(1,count) = newton_data{7};
                        count = count + 1;
                    else
                        newton_res_norm(1,count) = NaN;
                        count = count + 1;
                    end   

                end
%             end
            
        end
        
        save(strcat('newton_iter_',num2str(jj-1),'_',num2str(kk),'.mat'),'newton_iter');
        save(strcat('newton_res_',num2str(jj-1),'_',num2str(kk),'.mat'),'newton_res');
        save(strcat('newton_res__norm',num2str(jj-1),'_',num2str(kk),'.mat'),'newton_res_norm');
        
        clear newton_iter newton_res newton_res_norm
        
        %% Call get-values
        npoints_want = 2;
        Xwant = 0.5;
        Ywant = 0.5;
        infilename = 'points.in';
        fid = fopen(fullfile(root_dir,infilename),'w');
        fprintf(fid,'%d %d \n',npoints_want,2);
        % for ii = 1:npoints_want
        %     fprintf(fid,'%f %f\n',Xwant(ii),Ywant(ii));
        % end
        fclose(fid);
        % adsf

        % index = 0
        % point = [0.5,0.221,0.,0.221,0.5,0];
        outfilename = 'myoutput.out';
        
        fprintf('\nUsing dir = %s with prefix = %s\n',pwd,prefix)

        % command = strcat("mpirun -np ",num2str(NP)," ",get_values," -r ",fullfile(root_dir,prefix)," -c ",num2str(index)," -p ","""",num2str(point),""""," -o ",fullfile(root_dir,outfilename))
        for ii = 0:nt - 1
            fprintf('Requesting output for index %d of %d\n',ii,nt-1)
            index = ii;
%             command = strcat("mpirun -np ",num2str(NP)," ",get_values," -r ",fullfile(root_dir,prefix)," -c ",num2str(index)," -p ",'"',num2str(Xwant)," ",num2str(Ywant),'"'," -o ",fullfile(root_dir,outfilename));
            command = strcat(get_values," -r ",fullfile(prefix)," -c ",num2str(index)," -p ",'"',num2str(Xwant)," ",num2str(Ywant),'"'," -o ",fullfile(outfilename));
            [status,output] = system(command);

            %% parse output
            % fields: [ B Poloidal, B Toroidal, Electron Temperature, Ion Density, Ion Parallel Velocity, Ion Temperature, Neutral Density, n_e Chi_e Parallel, n_e Chi_e Perpendicular ]
%             data = dlmread(fullfile(root_dir,outfilename),'',7,0);
            data = dlmread(fullfile(outfilename),'',7,0);
            npoints = size(data,1);
            X(:,ii+1) = data(:,2);
            Y(:,ii+1) = data(:,3);
            Bpx(:,ii+1) = data(:,4);
            Bpy(:,ii+1) = data(:,5);
            Bt(:,ii+1) = data(:,6);
            Te(:,ii+1) = data(:,7);
            ni(:,ii+1) = data(:,8);
            vi(:,ii+1) = data(:,9);
            T_source(:,ii+1) = data(:,10);
            Ti(:,ii+1) = data(:,11);
            n0(:,ii+1) = data(:,12);
            chii_prl(:,ii+1) = data(:,12);
            chii_perp(:,ii+1) = data(:,13);
            
            clear data
            

        end
        
        data_struct.X = X;
        data_struct.Y = Y;
        data_struct.Bpx = Bpx;
        data_struct.Bpy = Bpy;
        data_struct.Bt = Bt;
        data_struct.Te = Te;
        data_struct.ni = ni;
        data_struct.vi = vi;
        data_struct.T_source = T_source;
        data_struct.Ti = Ti;
        data_struct.n0 = n0;
        data_struct.chii_prl = chii_prl;
        data_struct.chii_perp = chii_perp;
        data_struct.direc = pwd;
        data_struct.header = header;
        save('data.mat','-struct','data_struct')
        
        clear data_struct
        clear X Y Bpx Bpy Bt Te ni vi T_source Ti n0 chii_prl chii_perp 

        cd ../
        
    end
end







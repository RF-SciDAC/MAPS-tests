dir_path = '/Volumes/DATA/postdoc/mfem/convergence_tests/GMRES/output-files/';
prefix = 'Transport2D-Parallel';
refine = [0,1,2,3,4,5];
order = [1,2,3,4,5];
chiPara = [3,4,5,6,7,8,9];

noconv_arr = zeros(length(refine),length(order),length(chiPara));
abort_arr = zeros(length(refine),length(order),length(chiPara));
err_arr = zeros(length(refine),length(order),length(chiPara));

for jj=1:length(refine)
    for kk=1:length(order)
        for ll=1:length(chiPara)
            
%             if jj==4 && kk==4
%                 noconv_arr(jj,kk,ll) = NaN;
%                 abort_arr(jj,kk,ll) = NaN;
%                 continue
%             end
            
            filepath = strcat(dir_path,'/chi',num2str(chiPara(ll)),'/r',...
                num2str(refine(jj)),'_o',num2str(order(kk)),'/');

            dir_data = dir(filepath);
            if ~isfolder(filepath)
                noconv_arr(jj,kk,ll) = NaN;
                abort_arr(jj,kk,ll) = NaN;
                err_arr(jj,kk,ll) = NaN;
                fprintf('Directory does not exist: %s\n',filepath)
                continue
            end
            
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
                noconv_arr(jj,kk,ll) = NaN;
                abort_arr(jj,kk,ll) = NaN;
                err_arr(jj,kk,ll) = NaN;
                fprintf('Could not find any time steps using prefix: %s\n',prefix)
                fprintf('Empty directory: %s\n',filepath)
                continue
            else
                fprintf('Found nt = %d timesteps\n',nt)
            end

            %% Parse mfem_root files to get times
            time = nan(1,nt);
            for ii = 0:nt-1
                fname = fullfile(strcat(filepath,prefix,'_',num2str(ii,'%06.f'),'.mfem_root'));
                fid = fileread(fname);
                time_loc = regexp(fid,'"time"');
                ind_col = strfind(fid(time_loc:time_loc+10),': ');
                ind_com = strfind(fid(time_loc:time_loc+30),',');
                time(ii+1) = str2double(fid(time_loc+ind_col+1:time_loc+ind_com-1));
            end

            %% Parse output file to get convergence information

            fname = strcat(filepath,'output.out');
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

                noconv_loc = regexp((line),'GMRES:');
                abort_loc = regexp((line),'MPI_ABORT');
                if ~isempty(noconv_loc)
                    noconv_arr(jj,kk,ll) = 1;
                end
                if ~isempty(abort_loc)
                    abort_arr(jj,kk,ll) = 1;
                    noconv_arr(jj,kk,ll) = 1;
                end

            end
            
            fid = strcat(filepath,'transport2d_err.out');

            err_data = load(fid);
            time_arr = err_data(:,1);
            err_nneut = err_data(:,2);
            err_nion = err_data(:,3);
            err_momion = err_data(:,4);
            err_Ti = err_data(:,5);
            err_Te = err_data(:,6);

%             time_final(ii,jj) = time_arr(end,1);
%             Ti_err_final(ii,jj) = err_Ti(end,1);

            err_arr(jj,kk,ll) = err_Ti(end,1);
        
            clear err_data time_arr err_nneut err_nion err_momion err_Ti err_Te
        end
    end
end

%%

refineMesh = meshgrid(refine)';
refineMesh(:,end) = [];
orderMesh = meshgrid(order);
orderMesh(end+1,:) = orderMesh(end,:);

for ii=1:length(chiPara)
    
    chiMesh = chiPara(ii)*ones(5,5);
    
    ncIdx = noconv_arr(:,:,ii) == 1;
    coIdx = noconv_arr(:,:,ii) == 0;
    abIdx = abort_arr(:,:,ii) == 1;

    figure(2)
    stem3(refineMesh(coIdx),orderMesh(coIdx),chiMesh(coIdx),':k',...
        'markerfacecolor','b','markersize',10)
    hold on
    stem3(refineMesh(ncIdx),orderMesh(ncIdx),chiMesh(ncIdx),':k',...
        'markerfacecolor','r','markersize',10)
    stem3(refineMesh(abIdx),orderMesh(abIdx),chiMesh(abIdx),':kx',...
        'markerfacecolor','k','markersize',20)
    
end

figure(2)
xlim([0 5])
ylim([1 5])
zlim([3 9])
xticks(refine)
yticks(order)
zticks(chiPara)
xlabel('Mesh refinement','interpreter','latex')
ylabel('Order','interpreter','latex')
zlabel('$\log_{10}(\chi_{\parallel}$)','interpreter','latex')
legend('Converged','Not converged','MPI abort','location','northwest','interpreter','latex')











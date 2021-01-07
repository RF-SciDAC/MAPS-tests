dir_path = '.';
prefix = 'Transport2D-Parallel';
refine = [1];
order = [3];
chiPara = [3,4,5,6];

noconv_arr = zeros(length(refine),length(order),length(chiPara));
abort_arr = zeros(length(refine),length(order),length(chiPara));
err_arr = zeros(length(refine),length(order),length(chiPara));
wallTime = NaN(length(refine),length(order),length(chiPara));
dof = NaN(length(refine),length(order),length(chiPara));

for jj=1:length(refine)
    for kk=1:length(order)
        for ll=1:length(chiPara)
            
%             if jj==4 && kk==4
%                 noconv_arr(jj,kk,ll) = NaN;
%                 abort_arr(jj,kk,ll) = NaN;
%                 continue
%             end
            
            if length(order)~=1
                filepath = strcat(dir_path,'/chi',num2str(chiPara(ll)),'/r',...
                num2str(refine(jj)),'_o',num2str(order(kk)),'/');
            elseif length(order)==1
                filepath = strcat(dir_path,'/chi1.0e',num2str(chiPara(ll)),'/');
            end

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
                fprintf('for chiPara = %d, refine = %d, order = %d\n',chiPara(ll),...
                    refine(jj),order(kk));
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
                
                finalTime_loc = regexp((line),'Time stepping done after ');
                if ~isempty(finalTime_loc)
                    wallTime_data = textscan(line, '%s %s %s %s %f%s');
                    if ~isempty(wallTime_data{5})
                        wallTime(jj,kk,ll) = wallTime_data{5};
                    else 
                        wallTime(jj,kk,ll) = NaN;
                    end
                end

                noconv_loc = regexp((line),'GMRES:');
                abort_loc = regexp((line),'MPI_ABORT');
                sluabort_loc = regexp((line),'MPI_ERR_INTERN:');
                if ~isempty(noconv_loc)
                    noconv_arr(jj,kk,ll) = 1;
                end
                if ~isempty(abort_loc)
                    abort_arr(jj,kk,ll) = 1;
%                     noconv_arr(jj,kk,ll) = 1;
                end
                if ~isempty(sluabort_loc)
                    noconv_arr(jj,kk,ll) = 1;
                end
                
                dof_loc = regexp(line,"Number of unknowns per field: ");
                if ~isempty(dof_loc)
                    dof_data = textscan(line,'%s %s %s %s %s %f'); 
                    if ~isempty(dof_data)
                        dof(jj,kk,ll) = dof_data{6};
                    else
                    end
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

            time_final(jj,kk,ll) = time_arr(end,1);
%             Ti_err_final(ii,jj) = err_Ti(end,1);

            err_arr(jj,kk,ll) = err_Ti(end,1);
        
            clear err_data time_arr err_nneut err_nion err_momion err_Ti err_Te
        end
    end
end

%%

if length(order)~=1
    refineMesh = meshgrid(refine)';
    refineMesh(:,end) = [];
    orderMesh = meshgrid(order);
    orderMesh(end+1,:) = orderMesh(end,:);

    C = colormap(plasma(numel(orderMesh)));


    for ii=7:-1:1

        chiMesh = chiPara(ii)*ones(length(refine),length(order));
        temp_err = err_arr(:,:,ii);

        ncIdx = noconv_arr(:,:,ii) == 1;
        coIdx = ((noconv_arr(:,:,ii) == 0) & (abort_arr(:,:,ii) == 0));
        abIdx = abort_arr(:,:,ii) == 1;

        figure(1)
        stem3(refineMesh(coIdx),orderMesh(coIdx),chiMesh(coIdx),':k',...
            'markeredgecolor','k','markersize',15)
        hold on
        stem3(refineMesh(ncIdx),orderMesh(ncIdx),chiMesh(ncIdx),'dk',...
            'markeredgecolor','k','markersize',15)
        hold on
        if numel(refineMesh(coIdx))~=0
            scatter3(refineMesh(coIdx),orderMesh(coIdx),chiMesh(coIdx),...
            150,temp_err(coIdx),'filled','markerfacecolor','flat',...
            'HandleVisibility','off');
        end
        if numel(refineMesh(ncIdx))~=0
            scatter3(refineMesh(ncIdx),orderMesh(ncIdx),chiMesh(ncIdx),...
            170,temp_err(ncIdx),'d','filled','markerfacecolor','flat',...
            'HandleVisibility','off');
        end
        stem3(refineMesh(abIdx),orderMesh(abIdx),chiMesh(abIdx),'dk',...
            'markerfacecolor','k','markeredgecolor','k','markersize',15)
    end

    colormap(plasma);
    c = colorbar;
    caxis([5.0e-9,0.31])
    set(gca,'ColorScale','log')
    set(gcf,'color','w')
    ylabel(c, '$L^2$ Error','interpreter','latex')
    xlim([0 5])
    ylim([1 5])
    zlim([3 9])
    xticks(refine)
    yticks(order)
    zticks(chiPara)
    % set(gca, 'XDir','reverse')
    % set(gca, 'YDir','reverse')
    xlabel('Mesh refinement','interpreter','latex')
    ylabel('Order','interpreter','latex')
    zlabel('$\log_{10}(\chi_{\parallel}$)','interpreter','latex')
    legend('Converged','Not converged','MPI abort','location','northwest','interpreter','latex')

    %%

    figure(2)
    set(gcf,'color','w')
    subplot(3,1,1)
    semilogy(refine, wallTime(1:6),'k*-','linewidth',2)
    hold on
    semilogy(refine, wallTime(7:12), 'ro-','linewidth',2)
    semilogy(refine, wallTime(13:18), 'bx-','linewidth',2)
    xlim([0 4])
    xticks([])
    legend('O1','O2','O3','interpreter','latex')
    ylabel('Time (s)','interpreter','latex')
    text(0.005,0.98,'$\chi_{\parallel}=10^3$','Units', 'Normalized', 'VerticalAlignment',...
        'Top','Fontsize',30,'color','black','interpreter','latex')

    subplot(3,1,2)
    semilogy(refine, wallTime(91:96),'k*-','linewidth',2)
    hold on
    semilogy(refine, wallTime(97:102), 'ro-','linewidth',2)
    semilogy(refine, wallTime(103:108), 'bx-','linewidth',2)
    semilogy(refine, wallTime(109:114), 'c+-','linewidth',2)
    xlim([0 4])
    xticks([])
    legend('O1','O2','O3','O4','interpreter','latex')
    ylabel('Time (s)','interpreter','latex')
    text(0.005,0.98,'$\chi_{\parallel}=10^6$','Units', 'Normalized', 'VerticalAlignment',...
        'Top','Fontsize',30,'color','black','interpreter','latex')

    subplot(3,1,3)
    semilogy(refine, wallTime(193:198),'bx-','linewidth',2)
    hold on
    semilogy(refine, wallTime(199:204), 'c+-','linewidth',2)
    semilogy(refine, wallTime(204:209), 'md-','linewidth',2)
    xlim([0 4])
    legend('O3','O4','O5','interpreter','latex')
    xlabel('Number of refinements','interpreter','latex')
    ylabel('Time (s)','interpreter','latex')
    text(0.005,0.98,'$\chi_{\parallel}=10^9$','Units', 'Normalized', 'VerticalAlignment',...
        'Top','Fontsize',30,'color','black','interpreter','latex')


    %%

    figure(3)
    set(gcf,'color','w')
    loglog(dof(1:30),wallTime(1:30),'k*-','linewidth',1)
    hold on
    loglog(dof(90:120),wallTime(90:120),'ro-','linewidth',1)
    loglog(dof(180:210),wallTime(180:210),'bx-','linewidth',1)
    xlabel('DoF','interpreter','latex')
    ylabel('Time (s)','interpreter','latex')
    legend('$\chi_{\parallel} = 10^3$','$\chi_{\parallel} = 10^6$',...
        '$\chi_{\parallel} = 10^9$','interpreter','latex','location',...
        'northwest')
end







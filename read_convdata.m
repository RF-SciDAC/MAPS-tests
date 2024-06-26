
% dir_path = '/Volumes/DATA/postdoc/mfem/convergence_tests/SLU/sovinec-NFpreprint/dgk100';
% dir_path = '.';
prefix = 'Transport2D-Parallel';
refine = [0,1,2,3,4,5];
order = [1,2,3,4,5];
chiPara = [3,6,9];

noconv_arr = zeros(length(refine),length(order),length(chiPara));
abort_arr = zeros(length(refine),length(order),length(chiPara));
err_arr = zeros(length(refine),length(order),length(chiPara));
wallTime = NaN(length(refine),length(order),length(chiPara));
time_final = zeros(length(refine),length(order),length(chiPara));
dof = NaN(length(refine),length(order),length(chiPara));

anisoTest = 1;
chiTest = 0;
iondiffTest = 0;
neutdiffTest = 0;

for jj=1:length(refine)
    for kk=1:length(order)
        for ll=1:length(chiPara)
            
            if anisoTest
%                 if ll==1
%                     dir_path = '/Volumes/DATA/postdoc/mfem/convergence_tests/SLU/';
%                 elseif ll==2
%                     dir_path = '/Volumes/DATA/postdoc/mfem/convergence_tests/SLU/sovinec-NFpreprint/dgk100';
%                 elseif ll==3
%                     dir_path = '/Volumes/DATA/postdoc/mfem/convergence_tests/SLU/sovinec-NFpreprint/dgk100';
%                 end
                dir_path = '/Volumes/DATA/postdoc/mfem/benchmarking/sovinec_updatedint/SLU';
                filepath = strcat(dir_path,'/chi1.0e',num2str(chiPara(ll)),'/r',...
                num2str(refine(jj)),'_o',num2str(order(kk)),'/');
            elseif chiTest
                if jj == 2 && kk == 3
                    dir_path = strcat(pwd,'/chi-test/namr-tenniter/');
                    filepath = strcat(dir_path,'/chi1.0e',num2str(chiPara(ll)),'/');
                else
%                     fprintf('Case not run: %d, %d\n',refine(jj),order(kk))
                    continue 
                end
            elseif iondiffTest
                dir_path = strcat(pwd,'/diff-test/ion-diff');
                filepath = strcat(dir_path,'/r',...
                num2str(refine(jj)),'_o',num2str(order(kk)),'/');
            elseif neutdiffTest
                dir_path = '/diff-test/neut-diff'
                filepath = strcat(dir_path,'/r',...
                num2str(refine(jj)),'_o',num2str(order(kk)),'/');
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
            elseif nt >= 10
                fprintf('Greater than 10 timesteps, check output for: \n')
                fprintf('chiPara = %d, refine = %d, order = %d\n',chiPara(ll),...
                    refine(jj),order(kk))
%                 continue
            else
                fprintf('Found nt = %d timesteps\n',nt)
                fprintf('for chiPara = %d, refine = %d, order = %d\n',chiPara(ll),...
                    refine(jj),order(kk));
            end

            %% Parse mfem_root files to get times
            time = nan(1,nt);
            for ii = 0:nt-1
                fname = fullfile(strcat(filepath,prefix,'_',num2str(ii,'%06.f'),'.mfem_root'));
                if ~isfile(fname)
                    continue
                else
                    fid = fileread(fname);
                end
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
%                 if ~isempty(sluabort_loc)
%                     noconv_arr(jj,kk,ll) = 1;
%                 end
                
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
            if anisoTest || chiTest
                err_arr(jj,kk,ll) = err_nion(end,1);
            elseif iondiffTest
                err_arr(jj,kk,ll) = err_nion(end,1);
            elseif neutdiffTest
                err_arr(jj,kk,ll) = err_nneut(end,1);
            end
        
            clear err_data time_arr err_nneut err_nion err_momion err_Ti err_Te
        end
    end
end

%%

if anisoTest
    x0 = 0;
    y0 = 0;
    width = 252*2;
    height = 252/1.5;

    dx = zeros(1,length(refine));
    dx(1) = 0.25;

    for ii = 2:length(refine)

        dx(ii) = dx(ii-1)/2.0;

    end

    figure(1)
    subplot(1,4,1)
    set(gcf,'Position',[x0 y0 width height],'color','w')
    loglog(dx,squeeze(err_arr(:,1,1)),'k+-','linewidth',1.5)
    hold on
    loglog(dx,squeeze(err_arr(:,2,1)),'kx-','linewidth',1.5)
    loglog(dx,squeeze(err_arr(:,3,1)),'ko-','linewidth',1.5)
    loglog(dx,(max(err_arr(:,1,1)/max(dx(2:6).^2)))*dx.^2,'r--')
    loglog(dx,(max(err_arr(:,2,1)/max(dx(1:4).^3)))*dx.^3,'r--')
    loglog(dx,(max(err_arr(:,3,1)/max(dx(1:3).^4)))*dx.^4,'r--')
    set(gca,'Fontsize',10)
    % ylim([5e-7,1e-1])
    xlabel('$\Delta x$','interpreter','latex')
    ylabel('$L^2$ Error','interpreter','latex')
    xlim([min(dx) max(dx)])
    % legend({'O1','O2','O3'},'interpreter','latex','location','northwest',...
    %     'NumColumns',3)
    text(0.07,0.98,'a)','Units', 'Normalized', 'VerticalAlignment', 'Top','FontWeight','bold',...
        'Fontsize',12,...
                    'color','black')
    hold off

    subplot(1,4,2)
    line1 = loglog(dx,squeeze(err_arr(:,1,2)),'k+-','linewidth',1.5);
    hold on
    line2 = loglog(dx,squeeze(err_arr(:,2,2)),'kx-','linewidth',1.5);
    line3 = loglog(dx,squeeze(err_arr(:,3,2)),'ko-','linewidth',1.5);
    line4 = loglog(dx,squeeze(err_arr(:,4,2)),'ks-','linewidth',1.5);
    loglog(dx,(max(err_arr(:,1,2)/max(dx(4:6).^2)))*dx.^2,'r--')
    loglog(dx,(max(err_arr(:,2,2)/max(dx(1:5).^3)))*dx.^3,'r--')
    loglog(dx,(max(err_arr(:,3,2)/max(dx(1:4).^4)))*dx.^4,'r--')
    loglog(dx,(max(err_arr(:,4,2)/max(dx(1:3).^5)))*dx.^5,'r--')
    set(gca,'Fontsize',10)
    xlabel('$\Delta x$','interpreter','latex')
    xlim([min(dx) max(dx)])
    % ah1=axes('position',get(gca,'position'),'visible','off');
    % loglog(dx,squeeze(err_arr(:,5,3)),'kd-')
    % ylabel('$L^2$ Error','interpreter','latex')
    % legend({'O1','O2','O3','O4','O5'},'interpreter','latex','location','north')
    text(0.6,0.98,'b)','Units', 'Normalized', 'VerticalAlignment', 'Top','FontWeight','bold',...
        'Fontsize',12,...
                    'color','black')
    hold off

    subplot(1,4,3)
    % loglog(dx,squeeze(err_arr(:,1,3)),'k+-')
    loglog(dx,squeeze(err_arr(:,3,3)),'ko-','linewidth',1.5)
    hold on
    % loglog(dx,squeeze(err_arr(:,2,3)),'kx-')
    loglog(dx,squeeze(err_arr(:,4,3)),'ks-','linewidth',1.5)
    line5 = loglog(dx,squeeze(err_arr(:,5,3)),'kd-','linewidth',1.5);
    loglog(dx,(max(err_arr(1,3,3)/max(dx(1:4).^4)))*dx.^4,'r--')
    loglog(dx,(max(err_arr(1,4,3)/max(dx(1:3).^5)))*dx.^5,'r--')
    loglog(dx,(max(err_arr(1,5,3)/max(dx(1:2).^6)))*dx.^6,'r--')
    set(gca,'Fontsize',10)
    xlim([min(dx) max(dx)])
    xlabel('$\Delta x$','interpreter','latex')
    text(0.07,0.98,'c)','Units', 'Normalized', 'VerticalAlignment', 'Top','FontWeight','bold',...
        'Fontsize',12,...
                    'color','black')

    subplot(1,4,4)
    xlim([min(dx) max(dx)])
    axis off

    hL = legend([line1,line2,line3,line4,line5],...
        {'O1','O2','O3','O4','O5'});

    refineMesh = meshgrid(refine)';
    refineMesh(:,end) = [];
    orderMesh = meshgrid(order);
    orderMesh(end+1,:) = orderMesh(end,:);

    C = colormap(plasma(numel(orderMesh)));


    for ii=3:-1:1

        chiMesh = chiPara(ii)*ones(length(refine),length(order));
        temp_err = err_arr(:,:,ii);

        ncIdx = noconv_arr(:,:,ii) == 1;
        coIdx = ((noconv_arr(:,:,ii) == 0) & (abort_arr(:,:,ii) == 0));
        abIdx = abort_arr(:,:,ii) == 1;

        figure(2)
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

    figure(3)
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

    figure(4)
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

elseif chiTest
    
    ab_ind = find(abort_arr(2,3,:));
    nc_ind = find((noconv_arr(2,3,:)) & ~(abort_arr(2,3,:)));
    co_ind = find(~noconv_arr(2,3,:));
    
    figure(5)
    set(gcf,'color','w','Position',[0 0 900 400])
    semilogy(chiPara(co_ind),squeeze(err_arr(2,3,co_ind)),'k*',...
        'markersize',15,'linewidth',2)
    hold on
    semilogy(chiPara(nc_ind),squeeze(err_arr(2,3,nc_ind)),'xb',...
        'markersize',15,'linewidth',2)
    xlim([min(chiPara), max(chiPara)])
%     ylim([min(err_arr(1,1,:)) max(err_arr(1,1,nc_ind)+1.0e-3)])
    xlabel('log$_{10} \chi_{\parallel}$','interpreter','latex')
    ylabel('$L^2$ Error','interpreter','latex')
    legend('Converged to SS','GMRES: No convergence!','location',...
        'northwest','interpreter','latex')
    title('Error for $\chi_{\parallel}$ scan with 1 mesh refinement (8x8) and order 3',...
        'interpreter','latex')
    

end







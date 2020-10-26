filepath = '/Volumes/DATA/postdoc/mfem/benchmarking/';

num_refine = 5;
num_order = 5;

time_final = zeros(5,5);
Ti_err_final = zeros(5,5);

for ii = 1:num_refine
    for jj = 1:num_order
        
        if ii==num_refine && jj==num_order
            
        else
        
            fid = strcat(filepath,'sovinec_',num2str(ii-1),'_',...
                num2str(jj),'/transport2d_err.out');

            err_data = load(fid);
            time_arr = err_data(:,1);
            err_nneut = err_data(:,2);
            err_nion = err_data(:,3);
            err_momion = err_data(:,4);
            err_Ti = err_data(:,5);
            err_Te = err_data(:,6);

            time_final(ii,jj) = time_arr(end,1);
            Ti_err_final(ii,jj) = err_Ti(end,1);
        end
        
        clear err_data time_arr err_nneut err_nion err_momion err_Ti err_Te
              
    end
end

xmin = 0.0;
xmax = 1.0;
npts_arr = zeros(1,num_refine);
npts_arr(1,1) = 4; 

for ii=2:num_refine
    npts_arr(1,ii) = 2*npts_arr(1,ii-1);
end

dx = (xmax - xmin)./(npts_arr);

%%

figure(1)
set(gcf,'Color','white')
loglog(dx,Ti_err_final(:,1),'s-','linewidth',1.2)
hold on
loglog(dx,Ti_err_final(:,2),'^-','linewidth',1.2)
loglog(dx,Ti_err_final(:,3),'o-','linewidth',1.2)
loglog(dx,Ti_err_final(:,4),'d-','linewidth',1.2)
loglog(dx,Ti_err_final(:,5),'+-','linewidth',1.2)
% xlim([5.0e-2 0.3])
title('$\chi_{\parallel} = 10^3$','interpreter','latex')
xlabel('$dx$','interpreter','latex')
ylabel('L$^2$ Error', 'interpreter','latex')
legend('O1','O2','O3','O4','O5')

%% 
figure(2)
set(gcf,'Color','white')
semilogx(dx,time_final(:,1),'o-','linewidth',1.2)
hold on
semilogx(dx,time_final(:,2),'*-','linewidth',1.2)
semilogx(dx,time_final(:,3),'v-','linewidth',1.2)
semilogx(dx,time_final(:,4),'d-','linewidth',1.2)
semilogx(dx,time_final(:,5),'+-','linewidth',1.2)
% xlim([5.0e-2 0.3])
title('$\chi_{\parallel} = 10^6$','interpreter','latex')
xlabel('$dx$','interpreter','latex')
ylabel('Time taken for SS (s)', 'interpreter','latex')
legend('O1','O2','O3','O4','O5')
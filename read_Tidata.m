num_refine = 5;
num_order = 5;

Ti_arr = zeros(num_refine,num_order);

file_path = '/Volumes/DATA/postdoc/mfem/benchmarking/';

for ii=1:num_refine
    
    for jj=1:num_order
        
        if ii==num_refine && jj==num_order
            
        else
        
            fid = strcat(file_path,'sovinec_',num2str(ii-1),'_',num2str(jj),'/data.mat');        
            data = load(fid);
            Ti_arr(ii,jj) = data.Ti(1,end);
            clear data
            
        end
        
    end
    
end

err_arr = abs((1.0./Ti_arr) - 1.0);

refine = [1,2,3,4,5];
xmin = 0.0;
xmax = 1.0;
ymin = 0.0;
ymax = 1.0;

npts_arr = zeros(1,length(refine));
npts_arr(1,1) = 4; 

for ii=2:length(refine)
    npts_arr(1,ii) = 2*npts_arr(1,ii-1);
end

dx = (xmax - xmin)./(npts_arr);

%%

sov_arr = zeros(5,4);
sov_arr(3,1) = 4.e2;
sov_arr(4,1) = 1.e2;
sov_arr(5,1) = 2.e1;
sov_arr(1,2) = 1.1e1;
sov_arr(2,2) = 5.e-1;
sov_arr(3,2) = 1.1e-1;
sov_arr(4,2) = 4.e-2;
sov_arr(5,2) = 5.5e-3;
sov_arr(1,3) = 4.e-4;
sov_arr(2,3) = 1.e-3;
sov_arr(3,3) = 6.e-4;
sov_arr(4,3) = 4.5e-5;
sov_arr(1,4) = 4.e-4;
sov_arr(2,4) = 1.e-4;
sov_arr(3,4) = 2.e-6;

figure(1)
set(gcf,'Color','white')
loglog(dx(3:5),err_arr(3:5,1),'s-','linewidth',1.2)
hold on
loglog(dx,err_arr(:,2),'^-','linewidth',1.2)
loglog(dx(1:4),err_arr(1:4,3),'o-','linewidth',1.2)
loglog(dx(1:3),err_arr(1:3,4),'d-','linewidth',1.2)
loglog(dx(3:5),sov_arr(3:5,1),'ks--','linewidth',1.2)
loglog(dx,sov_arr(:,2),'k^--','linewidth',1.2)
loglog(dx(1:4),sov_arr(1:4,3),'ko--','linewidth',1.2)
loglog(dx(1:3),sov_arr(1:3,4),'kd--','linewidth',1.2)
% loglog(dx,err_arr(:,5),'+-')
% xlim([5.0e-2 0.3])
title('$\chi_{\parallel} = 10^6$','interpreter','latex')
xlabel('$dx$','interpreter','latex')
ylabel('Error ($|T^{-1}(0,0) - 1|$)', 'interpreter','latex')
legend('O1','O2','O3','O4')

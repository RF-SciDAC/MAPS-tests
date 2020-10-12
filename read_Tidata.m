num_refine = 5;
num_order = 5;

Ti_arr = zeros(num_refine,num_order);

file_path = '/Volumes/DATA/postdoc/mfem/benchmarking/';

for ii=1:num_refine
    
    for jj=1:num_order
        
        fid = strcat(file_path,'sovinec_',num2str(ii-1),'_',num2str(jj),'/data.mat');        
        data = load(fid);
        Ti_arr(ii,jj) = data.Ti(1,end);
        clear data
        
    end
    
end

err_arr = abs((1.0./Ti_arr) - 1.0);

refine = [1,2,3];
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

figure(1)
set(gcf,'Color','white')
loglog(dx,err_arr(:,1),'o-')
hold on
loglog(dx,err_arr(:,2),'*-')
loglog(dx,err_arr(:,3),'v-')
loglog(dx,err_arr(:,4),'d-')
loglog(dx,err_arr(:,5),'+-')
% xlim([5.0e-2 0.3])
title('$\chi_{\parallel} = 10^3$','interpreter','latex')
xlabel('$dx$','interpreter','latex')
ylabel('Error ($|T^{-1}(0,0) - 1|$)', 'interpreter','latex')
legend('O1','O2','O3','O4','O5')

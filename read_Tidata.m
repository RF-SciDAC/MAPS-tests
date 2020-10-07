num_refine = 5;
num_order = 5;

Ti_arr = zeros(num_refine,num_order);

file_path = '/Volumes/DATA/postdoc/codes/decreased-newtoniter/';

for ii=1:num_refine
    
    for jj=1:num_order
        
        fid = strcat(file_path,'sovinec_',num2str(ii-1),'_',num2str(jj),'/data.mat');        
        data = load(fid);
        Ti_arr(ii,jj) = data.Ti(1,end);
        
    end
    
end

err_arr = abs((1.0./Ti_arr) - 1.0);

refine = [1,2,3,4,5];
xmin = 0.0;
xmax = 1.0;
ymin = 0.0;
ymax = 1.0;

npts = 4; 

dx = (xmax - xmin)./(npts.*refine);

figure(1)
loglog(dx,err_arr(:,1),'o-')
hold on
loglog(dx,err_arr(:,2),'*-')
loglog(dx,err_arr(:,3),'v-')
loglog(dx,err_arr(:,4),'d-')
loglog(dx,err_arr(:,5),'+-')
xlim([5.0e-2 0.3])
legend('O1','O2','O3','O4','O5')

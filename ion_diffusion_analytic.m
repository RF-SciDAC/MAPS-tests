A = 1.0;
sigx = 0.02;
sigy = 0.02;
mux = 0.5;
muy = 0.5;
D = 1.0;
npts = 101;
tE = 0.02;

x = linspace(0,1,npts);
y = linspace(0,1,npts);
[X,Y] = meshgrid(x,y);

centrex = X - mux;
centrey = Y - muy;
widthx = 2.0*sigx^2;
widthy = 2.0*sigy^2;



Gauss2D = A*exp(-((centrex.^2/widthx) + (centrey.^2/widthy)));

Gauss1Dx = Gauss2D(round(npts/2),:);

t = [0.000299307,0.00134925];

Gauss2D_exact = (A/sqrt(4.0*D*pi*t(1)))*exp(-...
    (((centrex.^2) + (centrey.^2)))/(4.0*t(1)*D));

Gauss1D_exact = Gauss2D_exact(round(npts/2),:);

figure(1)
set(gcf,'color','white')
contourf(X,Y,Gauss2D,'linestyle','none')
colormap(flipud(gray))
colorbar;
caxis([0 1])

figure(2)
subplot(1,3,1)
set(gcf,'color','white')
plot(x,Gauss1Dx,'k-')

subplot(1,3,2)
set(gcf,'color','white')
plot(x,Gauss1D_exact,'k-')


Gauss2D_exact = (A/sqrt(4.0*D*pi*t(2))).*exp(-...
    (((centrex.^2) + (centrey.^2)))/(4.0*t(2)*D));

Gauss1D_exact = Gauss2D_exact(round(npts/2),:);

subplot(1,3,3)
set(gcf,'color','white')
plot(x,Gauss1D_exact,'k-')






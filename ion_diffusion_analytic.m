
sigx = 0.02;
sigy = 0.02;
mux = 0.5;
muy = 0.5;
D = 1.0;
npts = 101;
t = 0;
tE = 0.0002;
A = 1.0/(sqrt(4.0*D*pi*(t + tE)));

x = linspace(0,1,npts);
y = linspace(0,1,npts);
[X,Y] = meshgrid(x,y);

centrex = X - mux;
centrey = Y - muy;
% widthx = 2.0*sigx^2;
% widthy = 2.0*sigy^2;
widthx = 4.0*D*tE;
widthy = widthx;

% GaussInit = A*exp(-((centrex^2 + centrey^2)/(4.0*D*(t+tE))));

Gauss2D = A*exp(-((centrex.^2/(4.0*D*(t+tE))) + (centrey.^2/(4.0*D*(t+tE)))));

Gauss1Dx = Gauss2D(round(npts/2),:);

%%

t = [0.000299307,0.00134925];

A = 1.0/(sqrt(4.0*D*pi*(t(1) + tE)));

Gauss2D_exact = A*exp(-((centrex.^2/(4.0*D*(t(1)+tE))) +...
    (centrey.^2/(4.0*D*(t(1)+tE)))));

Gauss1D_exact = Gauss2D_exact(round(npts/2),:);

figure(1)
set(gcf,'color','white')
contourf(X,Y,Gauss2D,'linestyle','none')
colormap(flipud(gray))
colorbar;
caxis([0 20])

figure(2)
subplot(1,3,1)
set(gcf,'color','white')
plot(x,Gauss1Dx,'k-')
ylim([0 20])

subplot(1,3,2)
set(gcf,'color','white')
plot(x,Gauss1D_exact,'k-')
ylim([0 20])

%%

A = 1.0/(sqrt(4.0*D*pi*(t(2) + tE)));

Gauss2D_exact = A*exp(-((centrex.^2/(4.0*D*(t(2)+tE))) +...
    (centrey.^2/(4.0*D*(t(2)+tE)))));

Gauss1D_exact = Gauss2D_exact(round(npts/2),:);

subplot(1,3,3)
set(gcf,'color','white')
plot(x,Gauss1D_exact,'k-')
ylim([0 20])






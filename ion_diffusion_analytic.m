
mux = 0.5;
muy = 0.5;
D = 1.0;
npts = 501;
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
sigx = sqrt(2.0*D*(t+tE));
sigy = sigx;
widthx = 2.0*sigx^2;
widthy = widthx;

% Gauss2D = A*exp(-(centrex.^2 + centrey.^2)/(4.0*D*(t+tE)));

Gauss2D = A*exp(-((centrex.^2/widthx) + (centrey.^2/widthy)));

Gauss1Dx = Gauss2D(round(npts/2),:);

%%

t = [1.96565e-4,6.76079e-4,1.69351e-3];

A = 1.0/(sqrt(4.0*D*pi*(t(1) + tE)));
sigx = sqrt(2.0*D*(t(1)+tE));
sigy = sigx;
widthx = 2.0*sigx^2;
widthy = widthx;

Gauss2D_exact = A*exp(-((centrex.^2/widthx) + (centrey.^2/widthy)));

Gauss1D_exact = Gauss2D_exact(round(npts/2),:);

figure(1)
set(gcf,'color','white')
contourf(X,Y,Gauss2D_exact,'linestyle','none')
colormap(flipud(gray))
colorbar;
caxis([0 20])

figure(2)
subplot(1,3,1)
set(gcf,'color','white')
plot(x,Gauss1Dx,'k-')
ylim([0 20])
ylabel('$n_i$','interpreter','latex')
xlabel('Position','interpreter','latex')
text(0.07,0.98,'$t=0$','Units', 'Normalized', 'VerticalAlignment', 'Top','FontWeight','bold',...
    'Fontsize',16,...
                'color','black','interpreter','latex')

subplot(1,3,2)
set(gcf,'color','white')
plot(x,Gauss1D_exact,'k-')
ylim([0 20])
yticks([])
xlabel('Position','interpreter','latex')
text(0.07,0.98,'$t=3\Delta t$','Units', 'Normalized', 'VerticalAlignment', 'Top','FontWeight','bold',...
    'Fontsize',16,...
                'color','black','interpreter','latex')
            
Sin2D_exact = ((2.0*pi^2)*exp(-2.0*pi^2*0.0492602))*sin(pi.*X).*sin(pi.*Y);

%%

A = 1.0/(sqrt(4.0*D*pi*(t(2) + tE)));
sigx = sqrt(2.0*D*(t(2)+tE));
sigy = sigx;
widthx = 2.0*sigx^2;
widthy = widthx;

Gauss2D_exact = A*exp(-((centrex.^2/widthx) + (centrey.^2/widthy)));

Gauss1D_exact = Gauss2D_exact(round(npts/2),:);

subplot(1,3,3)
set(gcf,'color','white')
plot(x,Gauss1D_exact,'k-')
ylim([0 20])
yticks([])
xlabel('Position','interpreter','latex')
text(0.07,0.98,'$t=6\Delta t$','Units', 'Normalized', 'VerticalAlignment', 'Top','FontWeight','bold',...
    'Fontsize',16,...
                'color','black','interpreter','latex')
            
%%








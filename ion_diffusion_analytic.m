
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

visit_init = load('/Volumes/DATA/postdoc/mfem/ion_diffusion-unitySin2D/line-data/visit_ex_db_0dt.curve');

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

% t = [0,0.01,0.03,0.07,0.115204,0.174623];
t = [0.0,0.01,0.03];
levels = linspace(0,1,50);

x0 = 0;
y0 = 0;
width = 252*2;
height = 252/1.5;

for ii=1:length(t)
    
    Sin2D_exact = ((1.0)*exp(-2.0*pi^2*t(ii)))*sin(pi.*X).*sin(pi.*Y);
    Sin1D_exact = Sin2D_exact(round(npts/2),:);
    max(Sin2D_exact(:))
    
    filename = strcat('/Volumes/DATA/postdoc/mfem/ion_diffusion-unitySin2D/line-data/visit_ex_db_',...
        num2str(ii-1),'dt.curve');
    visit = load(filename);
    
    figure(3)
    set(gcf,'Position',[x0 y0 width height],'color','white')
    subplot(1,3,ii)
    plot(x,Sin1D_exact,'r-','linewidth',1)
    hold on
    plot(visit(:,1),visit(:,2),'k--')
    xlabel('Position','interpreter','latex')
    ylim([0 1])
    set(gca,'Fontsize',10)
%     text(0.02,0.98,['$t =$ ',num2str(t(ii)),' s'],'Units', 'Normalized', 'VerticalAlignment', 'Top','FontWeight','bold',...
%     'Fontsize',12,...
%                 'color','black','interpreter','latex')
    
    if ii==1
        ylabel('Amplitude','interpreter','latex')
    else
        yticks([])
    end
    
    if ii==3
        legend('Exact','Numerical','interprete','latex')
    end
    
    figure(4)
    set(gcf,'Position',[x0 y0 width height],'color','white')
    subplot(1,3,ii)
    contourf(x,y,Sin2D_exact,levels,'linestyle','none')
    colormap(flipud(gray))
    caxis([0 1])
    hold on
    plot(x,0.5*ones(1,npts),'r-')
    
    xlabel('Position','interpreter','latex')
    ylim([0 1])
    set(gca,'Fontsize',10) 
    
    if ii==1
        ylabel('Amplitude','interpreter','latex')
    else
        yticks([])
    end
    
    if ii==3
        colorbar;
    else
    end
    
end

%%

x0 = 0;
y0 = 0;
width = 252;
height = 252;

Sin2D_exact = ((1.0)*exp(-2.0*pi^2*t(3)))*sin(pi.*X).*sin(pi.*Y);
Sin1D_exact = Sin2D_exact(round(npts/2),:);

figure(5)
set(gcf,'Position',[x0 y0 width height],'color','white')
plot(x,Sin1D_exact,'r-','linewidth',1)
xlabel('Position','interpreter','latex')
ylim([0 1])
set(gca,'Fontsize',10)
ylabel('Amplitude','interpreter','latex')









%% Reference frame
%{
figure;
hold on

E=180;
R=180;

% head-centered
plot([-E/2 E/2], 10-[-E/2 E/2],'g','LineWidth',3,'Color',[0 0.5 0]);

% eye-centered
plot([-E/2 E/2], [-40 -40],'b','LineWidth',3,'Color',[0 0 0.5]);
%plot([-E/2 E/2], [-5 -5],'b');

% head-centered
plot([-E/2 E/2], -40-[-E/2 E/2],'g','LineWidth',3,'Color',[0 0.5 0]);

xlim([-E/2 E/2]);
ylim([-R/2 R/2]);
axis square
box on

hYLabel = ylabel('Retinal Location (deg)');
hXLabel = xlabel('Eye Position (deg)');


%}

%% reference frames

H=-60:1:60;

%eye
E = [-30 0 30];

sigma = 6;
response_r1 = exp((-(H-0).^2)./(2*sigma^2));
response_r2 = response_r1*0.5
response_r3 = response_r2*0.2

%response_r1 = exp((-(H-(-30)).^2)./(2*sigma^2));
%response_r2 = exp((-(H-(-0)).^2)./(2*sigma^2))*0.5
%response_r3 = exp((-(H-(30)).^2)./(2*sigma^2))*0.2

figure
hold on



%plot(H,response_r1,'+','MarkerSize',10,'Color',[0.8 0 0]);
%plot(H,response_r2,'o','MarkerSize',10,'Color',[0 0.5 0]);
%plot(H,response_r3,'*','MarkerSize',10,'Color',[0 0 0.5]);

plot(H,response_r1,'-','LineWidth',4,'Color',[0.8 0 0]);
plot(H,response_r2,':','LineWidth',4,'Color',[0 0.5 0]);
plot(H,response_r3,'--','LineWidth',4,'Color',[0 0 0.5]);

axis tight

hYLabel = ylabel('Response');
hXLabel = xlabel('Head-Centered Location');
%hLegend = legend('-30^\circ Fixation','0^\circ Fixation','30^\circ Fixation');
hLegend = legend('Left','Center','Right');

legend('boxoff');
set([hYLabel hXLabel], 'FontSize', 20);
set([gca hLegend], 'FontSize', 18);

set(gca,'YTick',[],'XTick',[])

YLim([-0.1 1])
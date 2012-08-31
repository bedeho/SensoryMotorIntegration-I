
declareGlobalVars();

global base;
    
expFolder = [base 'Experiments/' 'test_1' '/']; % 'trace_orth_4_small'

% Save all experiments to include  
experiments(1).Name = 'Untrained';
experiments(1).Folder = 'L=0.00500_/BlankNetwork';
experiments(2).Name = 'Trained';
experiments(2).Folder = 'L=0.00500_/TrainedNetwork';
legends = ['Untrained';'Trained  '];

% Start figures
singleCellPlot = figure(); % Single cell
multiplCellPlot = figure(); % Multiple cell
linestyle = {'-', '--', ':', '-.'};
markstyle = {'o', '*', '.','x', 's', 'd'};
%colors = {'r', 'k', 'b', 'c', 'm', 'y', 'g', 'w'};


maxY = 0;
nrOfBins = 0;
errorBarHandles = zeros(1,length(experiments));

% Iterate experiments and plot
for e = 1:length(experiments),
    
    % Load analysis file for experiments
    collation = load([expFolder experiments(e).Folder '/collation.mat']);
    
    % color
    c = mod(e-1,length(linestyle)) +1;
    
    % Add line plot to single cell plot
    figure(singleCellPlot);
    hold on;
    plot(collation.singleCell(:), ['k' linestyle{c}],'LineWidth',2,'MarkerSize',8); % ['-' colors{c}]
    axis tight
    
    % Do multi cell plot
    figure(multiplCellPlot);
    hold on;
    dist = collation.multiCell;
    upper = dist(3,:) - dist(2,:);
    lower = dist(2,:) - dist(1,:);
    X = 1:length(dist);
    Y = dist(2,:);
    h = errorbar(X,Y,lower,upper,['k' linestyle{c}],'LineWidth',2,'MarkerSize',8);
    
    % Save for post-processing
    maxY = max(maxY,dist(3,:));
    nrOfBins = length(dist);
    errorBarHandles(e) = h;
    
    %set(h,'Color',colors{c});
    %set(h,'Color','k');
    %set(h,'LineWidth',1);
end

% Pretty up plots
% http://blogs.mathworks.com/loren/2007/12/11/making-pretty-graphs/

% Single cell -------------------------------------
figure(singleCellPlot);
hLegend = legend(legends);
legend('boxoff')
hTitle = title('');
hXLabel = xlabel('Cell Rank');
hYLabel = ylabel('Head-centerdness');

set( gca                       , ...
    'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel], ...
    'FontName'   , 'AvantGarde');
set([hLegend, gca]             , ...
    'FontSize'   , 14           );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 18          );
set( hTitle                    , ...
    'FontSize'   , 24          , ...
    'FontWeight' , 'bold'      );

set(gca, ...
  'Box'         , 'on'     , ...
  'TickDir'     , 'in'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'YTick'       , 0:0.2:1, ...
  'LineWidth'   , 1         );

% Multicell ---------------------------------------
figure(multiplCellPlot);
legend(legends);

hLegend = legend(legends);
legend('boxoff')
hTitle = title('');
hXLabel = xlabel('Bin');
hYLabel = ylabel('Frequency');

set( gca                       , ...
    'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel], ...
    'FontName'   , 'AvantGarde');
set([hLegend, gca]             , ...
    'FontSize'   , 14           );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 18          );
set( hTitle                    , ...
    'FontSize'   , 24          , ...
    'FontWeight' , 'bold'      );

dY = floor(maxY/5);

set(gca, ...
  'Box'         , 'on'     , ...
  'TickDir'     , 'in'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'YTick'       , 0:dY:maxY, ...
  'LineWidth'   , 1         );

  %'XColor'      , [.3 .3 .3], ...
  %'YColor'      , [.3 .3 .3], ...


set(gca,'XTick',1:nrOfBins);
%set(gca,'XTickLabel',['0';' ';'1';' ';'2';' ';'3';' ';'4'])

buff = 3;
ylim([-buff (max(maxY)+buff)])

for e=1:length(experiments),
    set(errorBarHandles(e)        , ...
  'LineWidth'       , 2           , ...
  'Marker'          , markstyle{e} , ...
  'MarkerSize'      , 8           );
end

 % 'MarkerEdgeColor' , colors{e}  , ...
 % 'MarkerFaceColor' , [.7 .7 .7]  


declareGlobalVars();

global base;
    
expFolder = [base 'Experiments/' 'trace_orth_4' '/']; % 'trace_orth_4_small'

% Save all experiments to include  
experiments(1).Name = 'Untrained';
experiments(1).Folder = 'L=0.05000_S=0.95_sS=10000000.0_sT=0.000_gIC=0.0500_eS=0.0_/BlankNetwork';
experiments(2).Name = 'Trained';
experiments(2).Folder = 'L=0.05000_S=0.95_sS=10000000.0_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork';
legends = ['Untrained';'Trained  '];

% Start figures
singleCellPlot = figure(); % Single cell
multiplCellPlot = figure(); % Multiple cell
%markerSpecifiers = {'r', 'k', 'b', 'c', 'm', 'y', 'g', 'w>','r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>', 'r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>','r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>'};
colors = {'r', 'k', 'b', 'c', 'm', 'y', 'g', 'w'};

maxY = 0;
nrOfBins = 0;
errorBarHandles = zeros(1,length(experiments));

% Iterate experiments and plot
for e = 1:length(experiments),
    
    % Load analysis file for experiments
    collation = load([expFolder experiments(e).Folder '/collation.mat']);
    
    % color
    c = mod(e-1,length(colors)) +1;
    
    % Add line plot to single cell plot
    figure(singleCellPlot);
    hold on;
    plot(collation.singleCell(:), ['-' colors{c}],'LineWidth',1);
    
    % Do multi cell plot
    figure(multiplCellPlot);
    hold on;
    dist = collation.multiCell;
    upper = dist(3,:) - dist(2,:);
    lower = dist(2,:) - dist(1,:);
    X = 1:length(dist);
    Y = dist(2,:);
    h = errorbar(X,Y,lower,upper);
    
    % Save for post-processing
    maxY = max(maxY,dist(3,:));
    nrOfBins = length(dist);
    errorBarHandles(e) = h;
    
    set(h,'Color',colors{c});
    set(h,'LineWidth',1);
end

% Pretty up plots
% http://blogs.mathworks.com/loren/2007/12/11/making-pretty-graphs/

% Single cell -------------------------------------
figure(singleCellPlot);
hLegend = legend(legends);
hTitle = title('Head-centerdness');
hXLabel = xlabel('Cell Rank');
hYLabel = ylabel('\Omega');

set( gca                       , ...
    'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel], ...
    'FontName'   , 'AvantGarde');
set([hLegend, gca]             , ...
    'FontSize'   , 8           );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 10          );
set( hTitle                    , ...
    'FontSize'   , 12          , ...
    'FontWeight' , 'bold'      );

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'YTick'       , 0:0.2:1, ...
  'LineWidth'   , 1         );

% Multicell ---------------------------------------
figure(multiplCellPlot);
legend(legends);

hLegend = legend(legends);
hTitle = title('Representation');
hXLabel = xlabel('Bin');
hYLabel = ylabel('Frequency');

set( gca                       , ...
    'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel], ...
    'FontName'   , 'AvantGarde');
set([hLegend, gca]             , ...
    'FontSize'   , 8           );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 10          );
set( hTitle                    , ...
    'FontSize'   , 12          , ...
    'FontWeight' , 'bold'      );

dY = floor(maxY/5);

set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'YTick'       , 0:dY:maxY, ...
  'LineWidth'   , 1         );

set(gca,'XTick',1:nrOfBins);
%set(gca,'XTickLabel',['0';' ';'1';' ';'2';' ';'3';' ';'4'])

for e=1:length(experiments),
    set(errorBarHandles(e)        , ...
  'LineWidth'       , 1           , ...
  'Marker'          , 'o'         , ...
  'MarkerSize'      , 6           , ...
  'MarkerEdgeColor' , colors{e}  , ...
  'MarkerFaceColor' , [.7 .7 .7]  );
end

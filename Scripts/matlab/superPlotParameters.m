
function superPlotParameters()

    declareGlobalVars();

    global base;
    
    expName = 'peaked_learningrate2';
    expFolder = [base 'Experiments/' expName '/']; % 'trace_orth_4_small'

    % Save all experiments to include
    
    experiments(1).Folder =     'L=0.00100_/TrainedNetwork';
    experiments(2).Folder =     'L=0.00200_/TrainedNetwork';
    experiments(3).Folder =     'L=0.00300_/TrainedNetwork';
    experiments(4).Folder =     'L=0.00400_/TrainedNetwork';
    experiments(5).Folder =     'L=0.00500_/TrainedNetwork';
    experiments(6).Folder =     'L=0.00600_/TrainedNetwork';
    experiments(7).Folder =     'L=0.00700_/TrainedNetwork';
    experiments(8).Folder =     'L=0.00800_/TrainedNetwork';
    experiments(9).Folder =     'L=0.00900_/TrainedNetwork';
    experiments(10).Folder =    'L=0.01000_/TrainedNetwork';
    experiments(11).Folder =    'L=0.02000_/TrainedNetwork';
    experiments(12).Folder =    'L=0.03000_/TrainedNetwork';
    experiments(13).Folder =    'L=0.04000_/TrainedNetwork';
    experiments(14).Folder =    'L=0.05000_/TrainedNetwork';
    experiments(15).Folder =    'L=0.06000_/TrainedNetwork';
    experiments(16).Folder =    'L=0.07000_/TrainedNetwork';
    experiments(17).Folder =    'L=0.08000_/TrainedNetwork';
    experiments(18).Folder =    'L=0.09000_/TrainedNetwork';
    experiments(19).Folder =    'L=0.10000_/TrainedNetwork';
    %experiments(19).Folder =    'L=0.00100_/TrainedNetwork';
    %experiments(20).Folder =    'L=0.00100_/TrainedNetwork';
    
    
    experiments(1).tick =     1;
    experiments(2).tick =     2;
    experiments(3).tick =     3;
    experiments(4).tick =     4;
    experiments(5).tick =     5;
    experiments(6).tick =     6;
    experiments(7).tick =     7;
    experiments(8).tick =     8;
    experiments(9).tick =     9;
    experiments(10).tick =    10;
    experiments(11).tick =    20;
    experiments(12).tick =    30;
    experiments(13).tick =    40;
    experiments(14).tick =    50;
    experiments(15).tick =    60;
    experiments(16).tick =    70;
    experiments(17).tick =    80;
    experiments(18).tick =    90;
    experiments(19).tick =    100;
    %experiments(20).tick =    98;
    
    numExperiments = length(experiments);
    
    label_x = 'Sparseness Percentile - \pi (%)';
    label_y = 'Number of Head-centered Cells'; % add ERRORBAR ?!
    
    % Dialogs
    %answer = inputdlg('Qualifier')
    %
    %if ~isempty(answer)
    %    qualifier = ['-' answer{1}];
    %else
    %    qualifier = '';
    %end

    % Start figures
    
    linestyle = {'-', '--', ':', '-.'};
    markstyle = {'o', '*', '.','x', 's', 'd'};
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};
    
    ticks = zeros(1,numExperiments)
    multiUpper = zeros(1,numExperiments);
    multiLower = zeros(1,numExperiments);
    multiMean = zeros(1,numExperiments);
    
    %tickLabels = cell(1,numExperiments);
    %numPerfectCells = zeros(1,numExperiments);
    % Iterate experiments and plot
    for e = 1:numExperiments,
        
        % Load analysis file for experiments
        collation = load([expFolder experiments(e).Folder '/collation.mat']);
        
        % Find Number of Perfect cells
        %numPerfectCells(e) = nnz(collation.singleCell(:) > 0.8); % change to multi error bar thing!!
        
        % Save ticks
        ticks(e) = experiments(e).tick;
        
        % Save tick label
        %tickLabels(e) = [num2str(ticks(e)) '']; % add units?
        
        % Error bars
        dist = collation.multiCell;
        multiUpper(e) = dist(3,end) - dist(2,end);
        multiLower(e) = dist(2,end) - dist(1,end);
        multiMean(e) = dist(2,end);
    end
    
    f = figure();
    
    errorbar(ticks,multiMean,multiLower,multiUpper,'LineWidth',2,'MarkerSize',8)
    
    %plot(ticks,numPerfectCells,'LineWidth',2,'MarkerSize',8);
    axis tight;
    ylim([max(multiUpper)*-0.1 max(multiUpper)*1.1]);
    
    legend('boxoff')
    hTitle = title('')%; title('Varying Sparseness Percentile');
    hXLabel = xlabel(label_x);
    hYLabel = ylabel(label_y);

    set( gca                       , ...
        'FontName'   , 'Helvetica' );
    set([hTitle, hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');
    set(gca             , ...
        'FontSize'   , 14           );
    set(hYLabel  , ...
        'FontSize'   , 18          );
    set(hXLabel  , ...
        'FontSize'   , 12          );
    set( hTitle                    , ...
        'FontSize'   , 24          , ...
        'FontWeight' , 'bold'      );
    
    %set(hLegend        , ...
    %  'LineWidth'       , 2  );

    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'YGrid'       , 'off'      , ...
      'LineWidth'   , 2         , ...
      'XTick'       , ticks);
  
  
  set(gca,'xscale','log'); axis tight; grid on
  
       % Make it prettier
     function s = fixLeadingZero(d)

      s = num2str(d);

      if s(1) == '0' && length(s) > 1
          s = s(2:end);
      end

     end
end
  

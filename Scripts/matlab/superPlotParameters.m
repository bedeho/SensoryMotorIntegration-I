
function superPlotParameters()

    declareGlobalVars();

    global base;
    global THESIS_FIGURE_PATH;
    
    expName = 'peaked_sparseness';
    expFolder = [base 'Experiments/' expName '/']; % 'trace_orth_4_small'

    % Save all experiments to include  
    experiments(1).Folder =     'S=0.60_/TrainedNetwork';
    experiments(2).Folder =     'S=0.62_/TrainedNetwork';
    experiments(3).Folder =     'S=0.64_/TrainedNetwork';
    experiments(4).Folder =     'S=0.66_/TrainedNetwork';
    experiments(5).Folder =     'S=0.68_/TrainedNetwork';
    experiments(6).Folder =     'S=0.70_/TrainedNetwork';
    experiments(7).Folder =     'S=0.72_/TrainedNetwork';
    experiments(8).Folder =     'S=0.74_/TrainedNetwork';
    experiments(9).Folder =     'S=0.76_/TrainedNetwork';
    experiments(10).Folder =    'S=0.78_/TrainedNetwork';
    experiments(11).Folder =    'S=0.80_/TrainedNetwork';
    experiments(12).Folder =    'S=0.82_/TrainedNetwork';
    experiments(13).Folder =    'S=0.84_/TrainedNetwork';
    experiments(14).Folder =    'S=0.86_/TrainedNetwork';
    experiments(15).Folder =    'S=0.88_/TrainedNetwork';
    experiments(16).Folder =    'S=0.90_/TrainedNetwork';
    experiments(17).Folder =    'S=0.92_/TrainedNetwork';
    experiments(18).Folder =    'S=0.94_/TrainedNetwork';
    experiments(19).Folder =    'S=0.96_/TrainedNetwork';
    experiments(20).Folder =    'S=0.98_/TrainedNetwork';
    
    experiments(1).tick =     60;
    experiments(2).tick =     62;
    experiments(3).tick =     64;
    experiments(4).tick =     66;
    experiments(5).tick =     68;
    experiments(6).tick =     70;
    experiments(7).tick =     72;
    experiments(8).tick =     74;
    experiments(9).tick =     76;
    experiments(10).tick =    78;
    experiments(11).tick =    80;
    experiments(12).tick =    82;
    experiments(13).tick =    84;
    experiments(14).tick =    86;
    experiments(15).tick =    88;
    experiments(16).tick =    90;
    experiments(17).tick =    92;
    experiments(18).tick =    94;
    experiments(19).tick =    96;
    experiments(20).tick =    98;
    
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
    %tickLabels = cell(1,numExperiments);
    numPerfectCells = zeros(1,numExperiments);
    % Iterate experiments and plot
    for e = 1:numExperiments,
        
        % Load analysis file for experiments
        collation = load([expFolder experiments(e).Folder '/collation.mat']);
        
        % Find Number of Perfect cells
        numPerfectCells(e) = nnz(collation.singleCell(:) > 0.8); % change to multi error bar thing!!
        
        % Save ticks
        ticks(e) = experiments(e).tick;
        
        % Save tick label
        %tickLabels(e) = [num2str(ticks(e)) '']; % add units?
        
    end

    f = figure();
    
    plot(ticks,numPerfectCells,'LineWidth',2,'MarkerSize',8);
    axis tight;
    
    legend('boxoff')
    hTitle = title('');
    hXLabel = xlabel(label_x);
    hYLabel = ylabel(label_y);

    set( gca                       , ...
        'FontName'   , 'Helvetica' );
    set([hTitle, hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');
    set(gca             , ...
        'FontSize'   , 14           );
    set([hXLabel, hYLabel]  , ...
        'FontSize'   , 18          );
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

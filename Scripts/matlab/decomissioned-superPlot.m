
function superPlot()

    error('Decomissioned');

    declareGlobalVars();

    global base;
    global THESIS_FIGURE_PATH;
    
    save_filename = 'test';


    % Save all experiments to include  
    experiment(1).Name = '2 fixations';
    experiment(1).Folder = expFolder('peaked_movementstatistics_2.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    experiment(2).Name = '3 fixations';
    experiment(2).Folder = expFolder('peaked_movementstatistics_3.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(3).Name = '4 fixations';
    %experiment(3).Folder = expFolder('peaked_movementstatistics_4.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(2).Name = '5 fixations';
    %experiment(2).Folder = expFolder('peaked_movementstatistics_5.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(5).Name = '6 fixations';
    %experiment(5).Folder = expFolder('peaked_movementstatistics_6.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(6).Name = '7 fixations';
    %experiment(6).Folder = expFolder('peaked_movementstatistics_7.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(3).Name = '8 fixations';
    %experiment(3).Folder = expFolder('peaked_movementstatistics_8.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(8).Name = '9 fixations';
    %experiment(8).Folder = expFolder('peaked_movementstatistics_9.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(9).Name = '10 fixations';
    %experiment(9).Folder = expFolder('peaked_movementstatistics_10.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');    
    %experiment(4).Name = '11 fixations';
    %experiment(4).Folder = expFolder('peaked_movementstatistics_11.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(11).Name = '12 fixations';
    %experiment(11).Folder = expFolder('peaked_movementstatistics_12.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(12).Name = '13 fixations';
    %experiment(12).Folder = expFolder('peaked_movementstatistics_13.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    experiment(3).Name = '14 fixations';
    experiment(3).Folder = expFolder('peaked_movementstatistics_14.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    %experiment(14).Name = '15 fixations';
    %experiment(14).Folder = expFolder('peaked_movementstatistics_15.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    experiment(4).Name = 'Untrained   ';
    experiment(4).Folder = expFolder('peaked_movementstatistics_2.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/BlankNetwork');

    legends = ['2 fixations '; '3 fixations '; '14 fixations'; 'Blank networ'];
    %legends = ['2 fixations '; '5 fixations '; '8 fixations '; '11 fixations'; '14 fixations'; 'Blank networ'];
    %legends = ['2 fixations '; '3 fixations '; '4 fixations '; '5 fixations '; '6 fixations '; '7 fixations '; '8 fixations '; '9 fixations '; '10 fixations'; '11 fixations'; '12 fixations'; '13 fixations'; '14 fixations'; '15 fixations';'16 fixations'];
    %legends = ['Sigmoid  ';'Peaked   '];
    
    % Start figures
    singleCellPlot = figure(); % Single cell
    multiplCellPlot = figure(); % Multiple cell
    confusionPlot = figure(); % Theta cell
    
    linestyle = {'-', '--', ':', '-.','-'};
    markstyle = {'o', '*', '.','x', 's', 'd'};
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};

    maxY = 0;
    nrOfBins = 0;
    errorBarHandles = zeros(1,length(experiment));
    singleCellMinY = 0;
    thetaMaxY = 0;
    numCells = 0;
    numPerfectCells = zeros(1,length(experiment));
    % Iterate experiments and plot
    for e = 1:length(experiment),

        % Load analysis file for experiments
        collation = load([experiment(e).Folder '/collation.mat']);

        % color
        c = mod(e-1,length(linestyle)) + 1;

        % Add line plot to single cell plot
        figure(singleCellPlot);
        hold on;
        sortedData = sort(collation.singleCell(:),'descend');
        singleCellMinY = min(singleCellMinY,min(sortedData));
        plot(sortedData, [colors{c} linestyle{c}],'LineWidth',2,'MarkerSize',8); % ['-' colors{c}]
        numCells = length(sortedData);
        
        % Do multi cell plot
        figure(multiplCellPlot);
        hold on;
        dist = collation.multiCell;
        upper = dist(3,:) - dist(2,:);
        lower = dist(2,:) - dist(1,:);
        X = 1:length(collation.omegaBins);
        Y = dist(2,:);
        h = errorbar(X,Y,lower,upper,[colors{c} linestyle{c}],'LineWidth',2,'MarkerSize',8);
        
        % Do confusion plot
        figure(confusionPlot);
        hold on;
        theta = sort(collation.thetaMatrix(:),'descend');
        plot(theta, [colors{c} linestyle{c}],'LineWidth',2,'MarkerSize',8);
        thetaMaxY = max(thetaMaxY,max(theta));
        
        % Find Number of Perfect cells
        numPerfectCells(e) = nnz(sortedData > 0.8);

        % Save for post-processing
        maxY = max(maxY,max(dist(3,:)));
        nrOfBins = length(dist);
        errorBarHandles(e) = h;

        %set(h,'Color',colors{c});
        %set(h,'Color','k');
        %set(h,'LineWidth',1);
        
        % Output stats
        disp(['Experiment' experiment(e).Name]);
        disp(['Perfect Head-centered: ' num2str(nnz(collation.singleCell(:) == 1))]);
        disp(['Last bin:' num2str(dist(4:end,end)')]);
        
    end

    % Pretty up plots
    % http://blogs.mathworks.com/loren/2007/12/11/making-pretty-graphs/

    %% Single cell -------------------------------------
    f = figure(singleCellPlot);
    hLegend = legend(legends);
    legend('boxoff')
    hTitle = title('')%; title('Head-centerdness Analysis');
    hXLabel = xlabel('Neuron Rank');
    hYLabel = ylabel('\Omega');

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
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'YGrid'       , 'off'      , ...
      'YTick'       , 0:0.2:1, ...
      'LineWidth'   , 2         );
  
    %plot([1 numCells],[0 0], 'k.-');
    axis tight;
    ylim([singleCellMinY 1.1]);
    
    % SAVE
    chap = 'chap-2';
    fname = [THESIS_FIGURE_PATH chap '/' save_filename '_singleCell.eps'];
    set(gcf,'renderer','painters');
    print(f,'-depsc2','-painters',fname);

    %% Multicell ---------------------------------------
    f = figure(multiplCellPlot);
    legend(legends);

    hLegend = legend(legends);
    legend('boxoff')
    hTitle = title(''); % title('Representation Analysis');
    hXLabel = xlabel('\Omega Bin');
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
    
    set(hLegend        , ...
      'LineWidth'       , 2  );

    dY = floor(maxY/5);

    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'YGrid'       , 'off'      , ...
      'YTick'       , 0:dY:maxY, ...
      'LineWidth'   , 2         );

      %'XColor'      , [.3 .3 .3], ...
      %'YColor'      , [.3 .3 .3], ...

      tickLabels = cell(1,nrOfBins);
      binEdges = [0 collation.omegaBins];
      for b=1:(length(binEdges)-1),
          tickLabels{b} = ['(' fixLeadingZero(binEdges(b)) ',' fixLeadingZero(binEdges(b+1)) ']'];
      end

    set(gca,'XTick',1:nrOfBins);
    set(gca,'XTickLabel',tickLabels)

    Y = max(maxY);
    dY = 0.05*Y;
    %xlim([0.85 (nrOfBins-1.85)]);
    xlim([0.75 (nrOfBins+ 0.25)]);
    ylim([-dY (Y+dY)])

    for e=1:length(experiment),
        set(errorBarHandles(e)        , ...
      'LineWidth'       , 2           , ...
      'Marker'          , markstyle{e} , ...
      'MarkerSize'      , 8           );
    end
    
    %% SAVE
    chap = 'chap-2';
    fname = [THESIS_FIGURE_PATH chap '/' save_filename '_multiCell.eps'];
    set(gcf,'renderer','painters');
    print(f,'-depsc2','-painters',fname);

     % 'MarkerEdgeColor' , colors{e}  , ...
     % 'MarkerFaceColor' , [.7 .7 .7]  
     
    %% confusion plot
    
    f = figure(confusionPlot);
    hLegend = legend(legends);
    legend('boxoff')
    hTitle = title('')%; title('Head-centerdness Analysis');
    hXLabel = xlabel('Neuron Rank');
    hYLabel = ylabel('\Theta');

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

    yticklabel = cell(1,2);
    yticklabel{1} = '0';
    yticklabel{2} = 'max';
    
    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'YGrid'       , 'off'      , ...
      'YTick'       , [0 thetaMaxY], ...
      'YTickLabel'  , yticklabel, ...
      'LineWidth'   , 2         );
  
    %plot([1 numCells],[0 0], 'k.-');
    axis tight;
    ylim([0 thetaMaxY]);
    xlim([-0.1 numCells]);
    
    % SAVE
    chap = 'chap-2';
    fname = [THESIS_FIGURE_PATH chap '/' save_filename '_retinalconfusion.eps'];
    set(gcf,'renderer','painters');
    print(f,'-depsc2','-painters',fname);
    
    % Make it prettier
    function s = fixLeadingZero(d)

        s = num2str(d);

        if s(1) == '0' && length(s) > 1
          s = s(2:end);
        end

    end

    function folder = expFolder(name)
        folder = [base 'Experiments/' name];
    end

end

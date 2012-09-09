
function superPlot()

    declareGlobalVars();

    global base;
    global THESIS_FIGURE_PATH;
    
    expName = 'exp1';
    expFolder = [base 'Experiments/' expName '/']; % 'trace_orth_4_small'

    % Save all experiments to include  
    experiments(1).Name = 'Trained';
    experiments(1).Folder = 'L=0.05000_S=0.85_sS=00000001.0_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork';
    experiments(2).Name = 'Untrained';
    experiments(2).Folder = 'L=0.05000_S=0.85_sS=00000001.0_sT=0.000_gIC=0.0500_eS=0.0_/BlankNetwork';

    legends = ['Trained  ';'Untrained'];

    % Start figures
    singleCellPlot = figure(); % Single cell
    multiplCellPlot = figure(); % Multiple cell
    
    linestyle = {'-', '--', ':', '-.'};
    markstyle = {'o', '*', '.','x', 's', 'd'};
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};

    maxY = 0;
    nrOfBins = 0;
    errorBarHandles = zeros(1,length(experiments));
    singleCellMinY = 0;
    numCells = 0;
    % Iterate experiments and plot
    for e = 1:length(experiments),

        % Load analysis file for experiments
        collation = load([expFolder experiments(e).Folder '/collation.mat']);

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

        % Save for post-processing
        maxY = max(maxY,dist(3,:));
        nrOfBins = length(dist);
        errorBarHandles(e) = h;

        %set(h,'Color',colors{c});
        %set(h,'Color','k');
        %set(h,'LineWidth',1);
        
        % Output stats
        disp(['Experiment' experiments(e).Name]);
        disp(['Perfect Head-centered: ' num2str(nnz(collation.singleCell(:) == 1))]);
        disp(['Last bin:' num2str(dist(4:end,end)')]);
        
    end

    % Pretty up plots
    % http://blogs.mathworks.com/loren/2007/12/11/making-pretty-graphs/

    %% Single cell -------------------------------------
    f = figure(singleCellPlot);
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
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'YGrid'       , 'off'      , ...
      'YTick'       , 0:0.2:1, ...
      'LineWidth'   , 2         );
  
    %plot([1 numCells],[0 0], 'k.-');
    axis tight;
    ylim([singleCellMinY 1.1]);
    
    %% SAVE
    chap = 'chap-2';
    fname = [THESIS_FIGURE_PATH chap '/' expName '_singleCell.eps'];
    set(gcf,'renderer','painters');
    print(f,'-depsc2','-painters',fname);

    %% Multicell ---------------------------------------
    f = figure(multiplCellPlot);
    legend(legends);

    hLegend = legend(legends);
    legend('boxoff')
    hTitle = title('');
    hXLabel = xlabel('Head-centerdness Bin');
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
    dY = 0.1*Y;
    ylim([-dY (Y+dY)])

    for e=1:length(experiments),
        set(errorBarHandles(e)        , ...
      'LineWidth'       , 2           , ...
      'Marker'          , markstyle{e} , ...
      'MarkerSize'      , 8           );
    end
    
    %% SAVE
    chap = 'chap-2';
    fname = [THESIS_FIGURE_PATH chap '/' expName '_multiCell.eps'];
    set(gcf,'renderer','painters');
    print(f,'-depsc2','-painters',fname);

     % 'MarkerEdgeColor' , colors{e}  , ...
     % 'MarkerFaceColor' , [.7 .7 .7]  

     % Make it prettier
     function s = fixLeadingZero(d)

      s = num2str(d);

      if s(1) == '0' && length(s) > 1
          s = s(2:end);
      end

     end
end

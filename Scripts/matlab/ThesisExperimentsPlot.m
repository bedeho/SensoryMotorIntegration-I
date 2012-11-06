%
%  ThesisExperimentsPlot.m
%  SMI
%
%  Created by Bedeho Mender on 06/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function ThesisExperimentsPlot()

    declareGlobalVars();

    global base;
    global THESIS_FIGURE_PATH;
    
    save_filename = 'test';

    % Save all experiments to include  
    experiment(1).Name = '2 fixations';
    experiment(1).Folder = expFolder('peaked_movementstatistics_2.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    experiment(2).Name = '3 fixations';
    experiment(2).Folder = expFolder('peaked_movementstatistics_3.00/L=0.05000_S=0.70_sS=00000000.4_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    
    % Setup buffers
    headCenteredNess_X  = [];
    headCenteredNess_Y  = [];
    RFSize_Linear_Clean = [];

    % Iterate experiments and plot
    for e = 1:length(experiment),

        % Load analysis file for experiments
        analysisResults = load([experiment(e).Folder '/analysisResults.mat']);
        
        % Project out data
        headCenteredNess_X{e}  = analysisResults.RFLocation_Linear_Clean;
        headCenteredNess_Y{e}  = analysisResults.headCenteredNess_Linear_Clean;
        RFSize_Linear_Clean{e} = analysisResults.RFSize_Linear_Clean;
        
        %analysisResults.RFSize_Confidence_Linear_Clean;
        %analysisResults.RFLocation_Confidence_Linear_Clean;

        %{
        
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
        %}
        
        %{
        % Save for post-processing
        maxY = max(maxY,max(dist(3,:)));
        nrOfBins = length(dist);
        errorBarHandles(e) = h;

        %set(h,'Color',colors{c});
        %set(h,'Color','k');
        %set(h,'LineWidth',1);
        %}
        
        % Output stats
        %disp(['Experiment' experiment(e).Name]);
        %disp(['Perfect Head-centered: ' num2str(nnz(collation.singleCell(:) == 1))]);
        %disp(['Last bin:' num2str(dist(4:end,end)')]);
        
    end
    
    % Put in discarded
    % ...
    
    % 'XLim', XLim, 'YLim', YLim,
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(headCenteredNess_X, headCenteredNess_Y, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness (\lambda)', 'Legends', {'Untrained','Trained'});
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    % Start figures
    
    %singleCellPlot = figure();  % Single cell
    %multiplCellPlot = figure(); % Multiple cell
    %confusionPlot = figure();   % Theta cell
    
    %linestyle = {'-', '--', ':', '-.','-'};
    %markstyle = {'o', '*', '.','x', 's', 'd'};
    %colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};

    %nrOfBins = 0;
    
    %{

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
    
    % Save
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
    
    % Save
    chap = 'chap-2';
    fname = [THESIS_FIGURE_PATH chap '/' save_filename '_multiCell.eps'];
    set(gcf,'renderer','painters');
    print(f,'-depsc2','-painters',fname);

     % 'MarkerEdgeColor' , colors{e}  , ...
     % 'MarkerFaceColor' , [.7 .7 .7]  
     
    %% confusion plot
    %{
    
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
    %}
    
    %}
    
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

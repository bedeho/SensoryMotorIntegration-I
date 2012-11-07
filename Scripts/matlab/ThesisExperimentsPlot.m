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
    experiment(1).Folder = expFolder('test/S=0.60_/TrainedNetwork');
    experiment(2).Name = '3 fixations';
    experiment(2).Folder = expFolder('test/S=0.90_/TrainedNetwork');
    
    % Setup buffers
    headCenteredNess_X  = [];
    headCenteredNess_Y  = [];
    RFSize = [];

    % Iterate experiments and plot
    for e = 1:length(experiment),

        % Load analysis file for experiments
        data = load([experiment(e).Folder '/analysisResults.mat']);
        
        % Project out data
        headCenteredNess_X{e}  = data.analysisResults.RFLocation_Linear_Clean;
        headCenteredNess_Y{e}  = data.analysisResults.headCenteredNess_Linear_Clean;
        RFSize{e}              = data.analysisResults.RFSize_Linear_Clean;
        
        % Check that we have non-empty dataset
        if(isempty(headCenteredNess_X{e})),
            error(['Empty data set found' experiment(e).Name]);
        end
        
        % Output key numbers
        %disp(['Experiment: ' experiment(e).Name]);
        %disp(['Fraction discarded due to DISCONTINOUS: ' num2str(analysisResults.fractionDiscarded)]);
        %disp(['Fraction discarded due to EDGE: ' num2str(analysisResults.fractionDiscarded_Edge)]);
        %disp(['Fraction discarded due to MULTIPEAK: ' num2str(analysisResults.fractionDiscarded_MultiPeak)]);
    end
    
    % Put in discarded
    % ...
    
    % lambda/h plot
    % 'XLim', XLim, 'YLim', YLim,
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(headCenteredNess_X, headCenteredNess_Y, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness (\lambda)', 'Legends', {'Trained','Untrained'});
    
    % lambda/psi plot
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(RFSize, headCenteredNess_Y, 'XTitle', 'Receptive Field Size (deg)', 'YTitle', 'Head-Centeredness (\lambda)');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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


%% metrics.m

    %{
    % Lambda
    lambdaPlot = figure();
    plot(sort(headCenteredNess_LIN,'descend'));
    axis([0 numel(headCenteredNess_LIN) -1.1 1.1]);
    xlabel('Cell Rank');
    ylabel('\lambda');
    saveFigureAndDelete(lambdaPlot, 'headCenteredNess');
    
    % Psi
    psiPlot = figure();
    plot(sort(RFSize_LIN,'descend'));
    %axis([0 numel(psi) -1.1 1.1]);
    xlabel('Cell Rank');
    ylabel('\psi');
    saveFigureAndDelete(psiPlot, 'RFSize');
    
    % h-value
    hValuePlot = figure();
    hTOP = RFLocation_LIN;
    hTOP(headCenteredNess_LIN < 0.8) = [];     % shave out bottom
    hist(hTOP,50);
    xlabel('Head-centered Space (deg)');
    ylabel('h-value');
    saveFigureAndDelete(hValuePlot, 'RFLocation_LIN');
    %}


%{
    % Get dimensions
    %[networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    %numCells = networkDimensions(end).y_dimension * networkDimensions(end).x_dimension;
    
    % Fill in missing arguments    
    if nargin < 5,
        depth = 1;                                  % pick top layer
        
        if nargin < 4,
            region = length(networkDimensions);     % pick last region
        end
    end
    
    if region < 2,
        error('Region is to small');
    end
    
%}
    %numTargets = length(info.targets);
    %nrOfEyePositionsInTesting = length(info.eyePositions);
    
    % analysis
    % (1) = \lambda^a
    % (2) = \psi^a
    % (3) = \Omega^a
    % (4) = best match target
    % (5...[5+#targets]) = \chi
    

    %{
    % regionOrthogonalizationPlot
    saveas(regionOrthogonalizationPlot, [netDir '/orthogonality.eps']);
    saveas(regionOrthogonalizationPlot, [netDir '/orthogonality.png']);
    delete(regionOrthogonalizationPlot);

    % outputPatternsPlot
    saveas(outputPatternsPlot, [netDir '/outputOrthogonality.eps']);
    saveas(outputPatternsPlot, [netDir '/outputOrthogonality.png']);
    delete(outputPatternsPlot);

    %}

    % outputPatternsPlot
    %saveas(invariancePlot, [netDir '/invariance.eps']);
    %saveas(invariancePlot, [netDir '/invariance.png']);
    %print(invariancePlot, '-depsc2', '-painters', [netDir '/' experiment '_invariance.eps']);
    %delete(invariancePlot);

    % distributionPlot
    %saveas(distributionPlot, [netDir '/dist.eps']);
    %saveas(distributionPlot, [netDir '/dist.png']);
    %delete(distributionPlot);

    % thetaPlot
    %saveas(thetaPlot, [netDir '/theta.eps']);
    %saveas(thetaPlot, [netDir '/theta.png']);
    %delete(thetaPlot);

    % Save results for summary

    %summary(counter).nrOfHeadCenteredCells = nnz(singleCell > 0); % Count number of cells with positive correlation
    %summary(counter).orthogonalityIndex = orthogonalityIndex;
    %summary(counter).MeanObjects = MeanObjects;
    %summary(counter).MeanTransforms = MeanTransforms;

    %summary(counter).fullInvariance = fullInvariance;
    %summary(counter).meanInvariance = meanInvariance;
    %summary(counter).multiCell = multiCell;
    %summary(counter).nrOfSingleCell = nrOfSingleCell;
    
    % Plot Omega/preference
    %figure();
    %subplot(1,2,1);
    %imagesc(omegaMatrix);
    %subplot(1,2,2);
    %imagesc(preferenceMatrix);
    %title('region');
    
    % Head distribution
    %[distributionPlot, dist, omegaBins] = doDistributionPlot(omegaMatrix,preferenceMatrix);
    
    % IMAGESC CORRELATION
    %correlationVector = corr{region-1}(:);
    %sortedCorrelations = sort(correlationVector,'descend');
    %plot(sortedCorrelations,'-ob');
    %axis([0 length(correlationVector) -1.1 1.1]);
    
    %% Theta plot
    %thetaPlot = figure();
    %theta = thetaMatrix(:);
    %plot(sort(theta,'descend'));
    %title('Retinal Confusion');
    %ylim([0 0.005]);
    %axis([0 numel(theta) -1.1 1.1]);
    %xlabel('Cell Rank');
    %ylabel('\Omega_a');
    
    
    %% ORTHOGONALITY
    %{
    
    % Multiple indexes
    regionOrthogonalizationPlot = figure();
    
    % Compute orthogonalization
    [outputPatterns, orthogonalityIndex, inputCorrelations, outputCorrelations] = regionOrthogonality(filename, nrOfEyePositionsInTesting, dotproduct, region);
        
    scatter(inputCorrelations,outputCorrelations);
    xlabel('Input Correlations');
    ylabel('Output Correlations');
    
    axis([-0.1 1.1 -0.1 1.1]);
    line([0,1],[0,1], 'linewidth',1,'color',[1,0,0]);
    
    % Plot
    outputPatternsPlot = figure();
    imagesc(outputPatterns);
    colorbar;
    %}
    
    %{
    outputPatternsPlot = 0;
    regionOrthogonalizationPlot = 0;
    outputPatterns = 0;
    orthogonalityIndex = 0;
    inputCorrelations = 0;
    outputCorrelations = 0;
    %}
    
    %{
    %% Invariance & Selectivity
    [MeanObjects, MeanTransforms] = regionTrace(filename, nrOfEyePositionsInTesting);
    
    %% Compute invariance heuristic
    invariancePlot = figure();
    
    responseCounts = invarianceHeuristics(filename, nrOfEyePositionsInTesting);

    bar(responseCounts);
    
    legends = cell(1,numTargets);
    for h=1:numTargets,
        legends{h} = ['Head-centered Location ' num2str(info.targets(h)) '^{\circ}'];
    end
    
    hLegend = legend(legends);
    legend('boxoff')
    hTitle = title('')%; title('Exclusive Cells');
    hXLabel = xlabel('#Effective Fixation Locations');
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

    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'YGrid'       , 'off'      , ...
      'LineWidth'   , 2         );
    
    ylim([0 0.13*numCells]); % We dont normalize with peak, but rather with fixed number so visual comparison is easy
    %}

    %{
    function [p,dist,omegaBins] = doDistributionPlot(omegaMatrix,preferenceMatrix)
        
        % Make figure
        p = figure();
        
        % Omega resoltion
        dO = 0.2;
        omegaBins = dO:dO:1; % Bin b (b=1,2,...) keeps all cells with omega value in range dO * (b-1,b];
        
        % make space
        % dist(1, bin) = min
        % dist(2, bin) = mean
        % dist(3, bin) = max
        dist = zeros(3 + numTargets,length(omegaBins));
        
        % targetBins
        targetBins = (0:numTargets) + 0.5;
        
        % Populate bins
        for b = 1:length(omegaBins),
        
          % Find eligable neurons: omega value within bin AND with a good
          % target match (match > 0)
          neurons = squeeze(omegaMatrix > (b-1)*dO & omegaMatrix <= b*dO & preferenceMatrix > 0); %
          
          % Make histogram of neurons over targets they prefer
          histogram = histc(analysis(4,neurons),targetBins);
          cHist = histogram(1:(end-1));
          
          % Save result
          dist(1,b) = min(cHist);
          dist(2,b) = mean(cHist);
          dist(3,b) = max(cHist);
          dist(4:end,b) = cHist;
        
        end
        
        % Plot bar
        upper = dist(3,:) - dist(2,:);
        lower = dist(2,:) - dist(1,:);
        X = 1:length(omegaBins);
        Y = dist(2,:);
        errorbar(X,Y,lower,upper)
        %plot(1:length(dist),dist(2,:));
        
    end
    %}
    
    % OLD CORRELATION
    
    %{
    % Compute region correlation
    corr = regionCorrelation(filename, info.nrOfEyePositionsInTesting);
    
    % Plot region correlation
    regionCorrelationPlot = figure();
    
    % IMAGESC CORRELATION
    imagesc(corr{region-1});
    colorbar;
    %}


    %{
    %{
    % Delta plot
    % Figure out what cells we have history for!!!!!, put it here!, all
    % other cells we just gray out
    %axisVals(r-1,1) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 1); % Save axis
    %deltaMatrix = rand(10,10);% painstakingly slow regionDelta(network_1, network_2, r);
    %im = imagesc(deltaMatrix);
    %daspect([size(deltaMatrix) 1]);
    %title('This vs. BlankNetwork weight matrix correlation per cell');
    %colorbar;
    %set(im, 'ButtonDownFcn', {@singleUnitCallBack, r}); % Setup callback
    %}

    axisVals(r-1,1) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 1); % Save axis

    if thereIsSingleUnitRecording,

        height = networkDimensions(r).y_dimension;
        width = networkDimensions(r).x_dimension;
        v2 = reshape([singleUnits{r}(:, :, 1).isPresent],[height width]);
        im = imagesc(v2);
        daspect([size(v2) 1]);
        title(['Recorded Units in Region: ' num2str(r)]);
        colorbar;
        set(im, 'ButtonDownFcn', {@singleUnitCallBack, r}); % Setup callback
    end

    if ~isempty(data),%{r-1}),

        % Activity indicator
        axisVals(r-1,2) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 2); % Save axis

        % TRADITIONAL
        %{ 
        im = imagesc(regionCorrs{r-1});
        title('Head centerede correlation');
        %}

        % SIMON
        %{
        v0 = data;%{r-1};
        v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed


        % Fix when only one object in Simon Mode
        if objectsPrEyePosition > 1,
            v1 = squeeze(sum(sum(v0))); % sum away
        else
            v1 = squeeze(sum(v0)); % sum away
        end

        v2 = v1(:,:,1);
        %im = imagesc(v2);         % only do first region
        %}
        im = imagesc(analysisResults.headCenteredNess);
        %daspect([size(v2) 1]);
        %title('Number of testing locations responded to');
        title('\lambda');
        colorbar;

        % ResponseCount historgram
        axisVals(r-1,3) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 3); % Save axis
        hist(hmatTOP,50);

        %noZeros = v2(:);
        %noZeros(noZeros == 0) = [];
        %hist(noZeros,1:(max(max(v2))));
        %title(['Mean: ' num2str(mean2(v2))]);
        set(im, 'ButtonDownFcn', {@imagescCallback, r}); % Setup callback

        % Invariance heuristic
        axisVals(r-1,PLOT_COLS) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + PLOT_COLS); % Save axis

        plot(analysisResults.RFLocation_Linear, analysisResults.headCenteredNess_Linear, 'ob');
        hold on;

        %scatterAxis = herrorbar(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, analysisResults.RFLocation_Confidence_Linear_Clean , 'or'); %, 'LineWidth', 2
        scatterAxis = plot(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or', 'LineWidth', 1);

        %scatterAxis = plot(hmat,lmat,'o');
        set(scatterAxis, 'ButtonDownFcn', {@scatterCallBack,r}); % Setup callback
        ylim([-0.1 1]);

        %{
        responseCounts = invarianceHeuristics(filename, nrOfEyePositionsInTesting);

        bar(responseCounts);
        %}

        %{
        % Plot a line for each object
        %for e=1:nrOfEyePositionsInTesting,
        %    plot(responseCounts{e}, ['-' markerSpecifiers{e}], 'Linewidth', PLOT_COLS);
        %    hold all
        %end

        %axis tight
        %legend(objectLegend);
        %}

        hold off
        %}

    %{
    % Get single cell score
    sCell = analysisResults.headCenteredNess(row, col);
    cellNr = (row-1)*topLayerRowDim + col;
    response = data(:, :, row, col);
    y = squeeze(response);

    figure();
    imagesc(y');
    %}

    %{
    figure();
    x = info.targets;
    y = info.eyePositions;

    v = response;

    [xq,yq] = meshgrid(info.targets(1):0.1:info.targets(end), info.eyePositions(1):0.1:info.eyePositions(end));

    vq = griddata(x,y,v,xq,yq);

    mesh(xq,yq,vq);
    hold on

    [xq2,yq2] = meshgrid(info.targets, info.eyePositions);
    %plot3(xq2(:),yq2(:),response(:),'o');
    %}

    %{
    figure();
    [xq,yq] = meshgrid(info.targets, info.eyePositions); 
    mesh(xq,yq,response);
    %}

    %{
    % Dialogs
    answer = inputdlg('Qualifier')

    if ~isempty(answer)
        qualifier = ['-' answer{1}];
    else
        qualifier = '';
    end
    %}

    %{
    if doHeadCentered,

        for h = 1:nrOfEyePositionsInTesting,

            f = figure();

            y = squeeze(data{region-1}(h, :, row, col));

            %if doHeadCentered,
                % head centere refrernce frame
                x = info.targets;
            %else
                % retinal reference frame
                %x = info.targets - info.eyePositions(h);
            %end

            % color

            %c = mod(e-1,length(colors)) + 1;

            %plot(x,y, ['-k' markerSpecifiers{h}]);
            %colors{c}
            plot(x,y,'-bd','LineWidth',2,'MarkerSize',8);

            %hold all;

            hTitle = title('')%; title(['Fixating ' num2str(info.eyePositions(h)) '^{\circ}']); % ', R:' num2str(region) % ', \Omega_{' num2str(cellNr) '} = ' num2str(sCell)
            %axis([min(info.targets) max(info.targets) -0.1 1.1]);
            %hLegend = legend(objectLegend);
            %legend('boxoff')
            hYLabel = ylabel('Firing rate');
            hXLabel = xlabel('Head-centered location (deg)');

            set( gca                       , ...
                'FontName'   , 'Helvetica' );
            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set(gca             , ...
                'FontSize'   , 28           );
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 28          );
            set( hTitle                    , ...
                'FontSize'   , 32          , ...
                'FontWeight' , 'bold'      );

            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'in'     , ...
              'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'off'     , ...
              'YMinorTick'  , 'off'      , ...
              'YGrid'       , 'off'      , ...
              'YTick'       , 0:0.2:1, ...
              'LineWidth'   , 2         );

            %'XColor'      , [.3 .3 .3], ...
            %'YColor'      , [.3 .3 .3], ...     

            set(gca,'YLim',[-0.1 1.1]);
            %set(gca,'XTick',1:nrOfBins);

            set(gca,'XTick', xTick);
            set(gca,'XTickLabel', xTickLabels);

            xlim([(xTick(1)-0.5) (xTick(end)+0.5)]);

            % SAVE
            chap = 'chap-2';
            fname = [THESIS_FIGURE_PATH chap '/neuron_response_' num2str(h) '_' num2str(cellNr) qualifier '.eps'];
            set(gcf,'renderer','painters');
            print(f,'-depsc2','-painters',fname);

        end

        %hXLabel = xlabel('Head-centered location (deg)');
    else
        %{

        f = figure();

        for o = 1:objectsPrEyePosition,

            y = squeeze(data{region-1}(:, o, row, col));
            x = info.eyePositions;

            c = mod(o-1,length(colors)) + 1;

            plot(x,y,['-' markerSpecifiers{c}],'LineWidth',2,'MarkerSize',8);

            hold all;
        end

        set(gca,'XTick', xTick);
        set(gca,'XTickLabel', xTickLabels);

        hXLabel = xlabel('Fixation location (deg)');
        hLegend = legend(objectLegend);
        set([hLegend, gca]             , ...
        'FontSize'   , 14           );

        hTitle = title('');
       % hTitle = title(['Cell #' num2str(cellNr)]); % ', R:' num2str(region) % ', \Omega_{' num2str(cellNr) '} = ' num2str(sCell)
        %axis([min(info.targets) max(info.targets) -0.1 1.1]);

        legend('boxoff')
        hYLabel = ylabel('Firing rate');

        set( gca                       , ...
            'FontName'   , 'Helvetica' );
        set([hTitle, hXLabel, hYLabel], ...
            'FontName'   , 'AvantGarde');
        set([hXLabel, hYLabel]  , ...
            'FontSize'   , 28          );
        set( hTitle                    , ...
            'FontSize'   , 32,           ...
            'FontWeight' , 'bold'      );
        set( gca             , ...
            'FontSize'   , 28           );

        set(gca, ...
          'Box'         , 'on'     , ...
          'TickDir'     , 'in'     , ...
          'TickLength'  , [.02 .02] , ...
          'XMinorTick'  , 'off'     , ...
          'YMinorTick'  , 'off'      , ...
          'YGrid'       , 'off'      , ...
          'YTick'       , 0:0.2:1, ...
          'LineWidth'   , 2         );

        %'XColor'      , [.3 .3 .3], ...
        %'YColor'      , [.3 .3 .3], ...     

        set(gca,'YLim',[-0.1 1.1]);
        %set(gca,'XTick',1:nrOfBins);

        % SAVE
        chap = 'chap-2';
        fname = [THESIS_FIGURE_PATH chap '/neuron_response_m_' num2str(cellNr) '.eps'];
        set(gcf,'renderer','painters');
        print(f,'-depsc2','-painters',fname);

        %}

    end

    %}

   
    
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
    
    
    
    
 
 %{
     
    
    numExperiments = length(experiments);
    
    % Start figures
    
    ticks = zeros(1,numExperiments)
    multiUpper = zeros(1,numExperiments);
    multiLower = zeros(1,numExperiments);
    multiMean = zeros(1,numExperiments);
    
    %tickLabels = cell(1,numExperiments);
    %numPerfectCells = zeros(1,numExperiments);
    % Iterate experiments and plot
    for e = 1:numExperiments,
        
        e
        
        % Load analysis file for experiments
        collation = load([expFolder experiments(e).Folder '/analysisResults.mat']);
        
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
    
    
    errorbar(ticks,multiMean,multiLower,multiUpper,'LineWidth',2,'MarkerSize',8);
    topValues = multiUpper+multiMean;
    bottomValues = multiMean-multiLower;
    ylim([max(topValues)*-0.01 max(topValues)*1.01]);
    axis tight
    label_y = 'Head-Centeredness Percentile (\lambda = 0.8)';
    label_y2 = 'Head-Centered Space Coverage (bits)';
    
    %% LOGARITHMIC
    %errorbarlogx(0.02);
    %set(gca,'xscale','log'); 
    %grid on
    
    %plot(ticks,numPerfectCells,'LineWidth',2,'MarkerSize',8);
    
    %% Movement
    label_x = 'Fixations - (\kappa)';
    hold on;
    %plot(ticks,bottomValues,'-or','LineWidth',2,'MarkerSize',8);
    
    %% Trace time constant
    %label_x = 'Trace Time Constant - \tau_{q} (s)';
    %ticks = [0.01 0.1 1.0 10.0 100.0 900.0];
    
    
    %% Sparseness
    %label_x = 'Sparseness - \pi (%)';
    
    
    %% Learningrate
    %label_x = 'Learningrate - \rho';
    %ticks = [0.001 0.01 0.1 0.9];
    
    legend('boxoff')
    hTitle = title('')%; title('Varying Sparseness Percentile');
    hXLabel = xlabel(label_x);
    hYLabel = ylabel(label_y);
    %{

    set( gca                       , ...
        'FontName'   , 'Helvetica' );
    set([hTitle, hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');
    set(gca             , ...
        'FontSize'   , 10           );
    set(hYLabel  , ...
        'FontSize'   , 18          );
    set(hXLabel  , ...
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
      'LineWidth'   , 2         , ...
      'XTick'       , ticks);
  %}
  
%}
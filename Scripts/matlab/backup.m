
    %{
    % Receptive Field
    receptiveFieldPlot = figure();
    plot(analysisResults.RFLocation_Linear_Clean, analysisResults.RFSize_Linear_Clean, 'or', 'LineWidth', 1);
    title('Receptive Field');
    xlabel('Receptive Field Location (deg)');
    ylabel('Receptive Field Size (deg)');
    axis([-0.1 1 -0.1 1]);
    saveFigureAndDelete(receptiveFieldPlot, 'receptiveFieldPlot');
    %}


    %{
            %scatterAxis = herrorbar(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, analysisResults.RFLocation_Confidence_Linear_Clean , 'or'); %, 'LineWidth', 2
            scatterAxis_RED = plot(analysisResults.eyeCenteredNess_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or', 'LineWidth', 1);
            set(scatterAxis_RED, 'ButtonDownFcn', {@scatterCallBack,r}); % Setup callback
            axis([-0.1 1 -0.1 1]);
            plot([-0.1 1],[-0.1 1]);
            title('Refence Frames');
            xlabel('Eye-Centeredness');
            ylabel('Head-Centeredness');
            %xlim([info.targets(end) info.targets(1)]);
            hold off
            
            % Receptive Field vs sie
            axisVals(r-1,PLOT_COLS) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + PLOT_COLS); % Save axis
            plot(analysisResults.RFLocation_Linear_Clean, analysisResults.RFSize_Linear_Clean, 'or', 'LineWidth', 1);
            title('Receptive Fields');
            xlabel('Receptive Field Location');
            ylabel('Receptive Field Size');
%}



    
    %{
    % lambda/h scatter plot
    lambdahPlot = figure();
    plot(analysisResults.RFLocation_Linear, analysisResults.headCenteredNess_Linear, 'ob');
    hold on;
    plot(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or');
    xlabel('h-value');
    ylabel('\lambda');
    ylim([-0.1 1]);
    xlim([info.targets(end) info.targets(1)]);
    saveFigureAndDelete(lambdahPlot, 'lambdah');
    
    % Psi/h
    psiHPlot = figure();
    plot(analysisResults.RFSize_Linear, analysisResults.RFLocation_Linear, 'ob');
    hold on;
    plot(analysisResults.RFSize_Linear_Clean, analysisResults.RFLocation_Linear_Clean, 'or');
    xlabel('\psi');
    ylabel('h-value');
    saveFigureAndDelete(psiHPlot, 'psih');
    
    % h/Psi/Lambda
    hPsiLambdaPlot = figure();
    scatter3(analysisResults.RFLocation_Linear_Clean, analysisResults.RFSize_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean);
    xlabel('h-value');
    ylabel('\psi');
    zlabel('\lambda');
    saveFigureAndDelete(hPsiLambdaPlot, 'hpsilambda');
    %}



%{
            for d=1:inputLayerDepth,
                for ret=1:nrOfVisualPreferences,
                    
                    retPref = visualPreferences(nrOfVisualPreferences - (ret - 1));
                    
                    for eye=1:nrOfEyePositionPrefrerence,
                    
                        eyePref = eyePositionPreferences(eye);
                        
                        [connect, weight] = doConnect(eyePref,retPref,target,d,inputLayerDepth);
                        
                        if connect,

                            % Increase number of synapses
                            numberOfAfferentSynapses = numberOfAfferentSynapses + 1;
                            
                            % Save synapse
                            synapses(:,numberOfAfferentSynapses) = [0 (d-1) (ret-1) (eye-1) weight];
                            
                            %{
                            % FIGURE
                            if d==1,
                                mat1(ret,eye) = mat1(ret,eye) + weight;
                            else
                                mat2(ret,eye) = mat2(ret,eye) + weight;
                            end
                            %}
                            
                        end
                        
                    end
                end
            end
            %}


%{
    function [connect,weight] = doConnect(eyePref, retPref, target, d, inputLayerDepth)
    
        if inputLayerDepth == 1, % PEAKED
            
            connectWindow = 2;
            cond1 = eyePref+retPref <= target+connectWindow*inputLayerSigma; % isBelowUpperBound
            cond2 = eyePref+retPref >= target-connectWindow*inputLayerSigma; % isAboveLowerBound
            
            % Find distane to head-centeredness diagonal
            % smallest distance between ax + bx + c = 0 and x0,y0 is:
            %
            % abs(ax_0 + b_y0 + c) / norm([a b])
            %
            % where
            % x = e (eye position
            % y = r (retinal position)
            % c = -target (head position)
            x0 = eyePref;
            y0 = retPref;
            a = 1;
            b = 1;
            c = -target;
            
            distance = abs(a*x0 + b*y0 + c) / norm([a b]);
            
            weight = exp(-(distance^2)/(2*inputLayerSigma^2)); 
        elseif inputLayerDepth == 2 % SIGMOID
            
            cond1 = (eyePref+retPref <= target && d==1); % isToLeftOfTargets
            cond2 = (eyePref+retPref >= target && d==2); % isAboveLowerBound
            weight = rand([1 1]); % Get random weight
        end
        
        % Make final stochastic decision
        connect = cond1 && cond2 && rand([1 1]) > (1-fanInPercentage);
        
        %if rand([1 1]) > 0.9 && ((eyePref+retPref <= target && d==1) || (eyePref+retPref >= target && d==2)), % SIGMOID
        %rand([1 1]) > 0.9 && ((eyePref+retPref <= target && d==1) && (eyePref+retPref >= target && d==2)), % PEAKED

    end
    %}


%{
        fixationAxes = zeros(1,numEyePositions);
        for e = 1:numEyePositions,

            y = squeeze(data(e, :, row, col));

            c = mod(e-1,length(colors)) + 1;
            
            % Curve
            fixationAxes(e) = plot(info.targets, y,'-','Color',colors{c});
            %plot(y,['-' markerSpecifiers{c}],'Color',colors{c},'MarkerSize',8);
            
            hold on;
            
            % Mean
            meanY = mean(y)
            plot([info.targets(1) info.targets(end)], [meanY meanY], '.--','Color', colors{c});
            hold on;
            
        end
        %}

%{
OneD_Stimuli_SpatialFigure.m

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};
    
    % Make figure
    fig = figure();
    
    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Stimuli_Load(trainingStimuliName);

    % Derived
    leftMostVisualPosition = -visualFieldSize/2;
    rightMostVisualPosition = visualFieldSize/2;
    leftMostEyePosition = -eyePositionFieldSize/2;
    rightMostEyePosition = eyePositionFieldSize/2;     

    % Cleanup nan
    temp = buffer;
    v = isnan(buffer); % v(:,1) = get logical indexes for all nan rows
    temp(v(:,1),:) = [];  % blank out all these rows

    X = [];
    Y = [];

    % Plot spatial data
    for o = 1:numberOfSimultanousObjects,

        if color == '',
            cCode = colors{o};
        else
            cCode = color;
        end

        plot(temp(:,1), temp(:,o + 1) , [cCode markstyle],'LineWidth',linewidth,'MarkerSize', markersize);

        X = [X temp(:,1)];
        Y = [Y temp(:,o + 1)];

        hold on;
    end

    %scatterhist(X,Y);

    % Adjust axis
    axis([leftMostEyePosition rightMostEyePosition leftMostVisualPosition rightMostVisualPosition]);
    
    % SAVE
    fname = [base 'Stimuli/' testingStimuliName '/inputData.eps'];
    set(gcf,'renderer','painters');
    print(fig,'-depsc2','-painters',fname);
%}


%% metrics.m

%function [outputPatternsPlot, MeanObjects, MeanTransforms, orthogonalityIndex, regionOrthogonalizationPlot, regionCorrelationPlot,thetaPlot, thetaMatrix, omegaMatrix, dist, omegaBins, invariancePlot, distributionPlot] = plotRegion(filename, info, dotproduct, region, depth)

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
    
%{
    function psi = computePsi(row,col)

        f = zeros(1,nrOfEyePositionsInTesting);

        % Iterate all combinations of eye positions
        for k = 1:nrOfEyePositionsInTesting,

            v = dataPrEyePosition(k,:,row,col);
            f(k) = nnz(v > mean(v));

        end

        psi = max(f);
    end   
%}

%{
    function [match,chi] = computeChi(row,col)
        
        % Find mean center off mas across fixations
        meanCenterOffMass = 0;
        changedCenterOfMass = false;
        
        for e=1:nrOfEyePositionsInTesting,
            
            responses = dataPrEyePosition(e, :,row,col);
            centerOfMass = dot(responses,targets) / sum(responses);
            
            % dont include fixation if there was NO response, i.e. sum() =
            % 0, i.e centerOfMass is NaN
            if ~isnan(centerOfMass)
                meanCenterOffMass = meanCenterOffMass + centerOfMass;
                changedCenterOfMass = true;
            end
        end
        
        meanCenterOffMass = meanCenterOffMass / nrOfEyePositionsInTesting;
        
        % return errors
        chi = (targets - meanCenterOffMass).^2;
        [C I] = min(chi);
        match = I;
        
        % If tehre are NaN entries, it means this is 
        % a non-responsive neuron for atleast one eye position,
        % and hence we mark it so it will not be par tof analysis
        if ~changedCenterOfMass,
            match = -1;
            chi = -1 * ones(1,length(targets));
        end
    end
%}

%{
    function theta = computeTheta(row,col)
        
        sigma = 2; % 2 worked well
        theta = 0;
        responses = dataPrEyePosition(:,:,row,col);
        
        counter = 0;
        
        for target_i=1:length(targets),
            for eye_j=1:length(eyePositions),
                
                notAllTargets = 1:length(targets);
                notAllTargets(target_i) = []; % Remove
                
                for target_k=notAllTargets,
                    for eye_l=1:length(eyePositions),
                        c = responses(eye_j,target_i)*responses(eye_l,target_k)*exp(-((targets(target_i)-eyePositions(eye_j)) - (targets(target_k) - eyePositions(eye_l)))^2/(2*sigma^2));
                        
                        
                        theta = theta + c;
                        
                        counter = counter + 1;
                    end
                end
            end
        end
        
        theta = theta/counter;
    end

%}
    
    {%
    %
%  pouget.m
%  SMI
%
%  Created by Bedeho Mender on 21/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function pouget()

    % A. Pouget & T. Sejnowski (1997)
    
    % Seed rng
    rng(33, 'twister');
    
    % Stimuli:
    % 441=21*21 pairs of retinal and eye positions.
    % 21 retinal locations in [-40,40]
    % 21 eye positions in [-20,20]
    retinalTargets = centerN(80, 21);
    eyeTargets = centerN(40, 21);
    numPatterns = length(retinalTargets)*length(eyeTargets);
    
    mexRetTarget = max(retinalTargets);
    maxEyeTarget = max(eyeTargets);
    
    % Input:
    % 121 units
    % \mu uniform in 12 increments \in [-60,60]
    % \sigma = 18
    % \inflection points uniform in 8 increments \in [-40,40]
    % slope = 8
    inputSigma = 18;
    sigmoidSlope = 8;
    retinalPreferences = centerDistance(60*2, 12);
    eyePreferences = centerDistance(40*2, 8);
    
    [eyeMesh retMesh] = meshgrid(retinalPreferences, eyePreferences);
    numInputNeurons = numel(retMesh);
    
    % Output:
    % 1 unit
    % \sigma = 18
    % \mu = 0
    outputSigma = 18;
    outputHeadPreferences = [-1 1];%-10:2:10;%[0]; -mexRetTarget:2:mexRetTarget;
    outputRetinalPreferences = [-1 1];%-10:2:10;%[0]; -mexRetTarget:2:mexRetTarget;
    numOutputNeurons = length(outputHeadPreferences) + length(outputRetinalPreferences);
    
    % Network Parameters
    learningrate = 0.001;
    numEpochs = 1000;
    
    [inputPatterns, outputPatterns] = generatePatterns();
    
    outputPatterns = 1*outputPatterns;
    
    % Create network
    untrainedNet = feedforwardnet([]);
    
    % Setup Training
    untrainedNet.trainParam.epochs = numEpochs;
    untrainedNet.trainParam.goal = 0.01;	
    untrainedNet.trainParam.lr = learningrate;
    untrainedNet.trainParam.show = 1;
    untrainedNet.trainParam.time = 1000;
     
    % Train
    [trainedNet, tr] = train(untrainedNet, inputPatterns, outputPatterns);
    synapses = trainedNet.IW{1};
    
    %% Synaptic weight distribution
    
    % Old style
    %{
    figure;
    hist(synapses(:), -1.3:0.1:1.3);
    %errorbar(means,stdev);
    %ymax = max(h)*1.1;
    %ylim([0 ymax]);
    axis tight;
    %plot(m*[1 1], [0 ymax],'r-');
    hXLabel = xlabel('Synaptic Weight');
    hYLabel = ylabel('Number of Synapses');
    
    disp(['Number of Inhibitory: ' num2str(nnz(synapses < 0))]);
    
    set([hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');

    set(hYLabel  , ...
        'FontSize'   , 18          );
    set(hXLabel  , ...
        'FontSize'   , 18          );

    set(gca, ...
      'FontName'    , 'Helvetica', ...
      'FontSize'    , 10         , ...         
      'Box'         , 'on'       , ...
      'TickDir'     , 'in'       , ...
      'TickLength'  , [.02 .02]  , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'LineWidth'   , 2         );
    %}
    
    
    % New style
    figure;

    lineardata = synapses(:);
    max_deviation = max(lineardata);
    min_deviation = min(lineardata);
    ticks = min_deviation:(max_deviation-min_deviation)/100:max_deviation;
    
    hdist = hist(lineardata, ticks);

    hBar = bar(ticks,hdist','stacked','LineStyle','none');
    set(hBar(1),'FaceColor', [67,82,163]/255); %, {'EdgeColor'}, edgeColors

    xlim([min_deviation max_deviation]);
    
    hXLabel = xlabel('Synaptic Weight');
    hYLabel = ylabel('Number of Synapses');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    box off
    
    axis square
    
    
    %% Show Input->Hidden Weight matrix
    
    figure;
    imagesc(synapses);
    
    hXLabel = xlabel('Hidden Layer Unit');
    hYLabel = ylabel('Input Layer Unit');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    colorbar
    axis square
    
    %% Single unit weight plot
    
    figure;
    output_weight_vector = reshape(synapses(1,:), [length(retinalPreferences), length(eyePreferences)]);
    imagesc(output_weight_vector);
    
    
    %% DALE principle
    
    % OLD STyle
    %{
    figure();
    iMoreExcitatory = sum(trainedNet.IW{1} >= 0) - sum(trainedNet.IW{1} < 0);
    hMoreExcitatory = sum(trainedNet.LW{1} >= 0) - sum(trainedNet.LW{1} < 0);

    hist([iMoreExcitatory hMoreExcitatory],-9:1:9);
    
    hXLabel = xlabel('Number of Surplus Excitatory Projections');
    hYLabel = ylabel('Number of Neurons');
    
    set( gca                   , ...
        'FontName'   , 'Helvetica' , ...
        'FontSize'   , 10          );
    
    set([ hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');

    set(hYLabel  , ...
        'FontSize'   , 18          );
    set(hXLabel  , ...
        'FontSize'   , 18          );

    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'LineWidth'   , 2         );
    %}
    
    %hidden layer units
    inputToHidden_numExcitatory = sum((synapses > 0)');
    inputToHidden_numInhibitory = sum((synapses < 0)');
    
    [receptivefieldPlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms({inputToHidden_numExcitatory}, {inputToHidden_numInhibitory}, 'XTitle', 'Excitatory Efferents', 'YTitle', 'Inhibitory Efferents', 'FaceColors', {[67,82,163]/255},'Location', 'SouthEast');

    % Generate stimuli
    function [inputPatterns, outputPatterns] = generatePatterns()

        inputPatterns = zeros(numInputNeurons, numPatterns);
        outputPatterns = zeros(numOutputNeurons, numPatterns);
        
        % Iterate all targets comboes
        counter = 1;
        for r=retinalTargets,
            for e=eyeTargets,
                
                % Input
                in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (eyeMesh - e)));
                
                inputPatterns(:,counter) = in(:);
                
                % Output
                h = r+e;
                
                if(mod(counter,13) == 110),
                    figure;
                    subplot(1,3,1);
                    imagesc(in);
                    subplot(1,3,2);
                    plot(exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2)));
                    title('head');
                    xlim([1 length(outputHeadPreferences)]);
                    ylim([0 1]);
                    subplot(1,3,3);
                    plot(exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2)));
                    title('retinal');
                    xlim([1 length(outputRetinalPreferences)]);
                    ylim([0 1]);
                    x=1;
                end
                
                if(~isempty(outputHeadPreferences) && ~isempty(outputRetinalPreferences)),
                    outputPatterns(:,counter) = [exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2)) exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2))];
                elseif(~isempty(outputHeadPreferences)),
                    outputPatterns(:,counter) = exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2));
                else
                    outputPatterns(:,counter) = exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2));
                end

                counter = counter + 1;
            end
        end

    end

    %{
    % Train over multiple trials
    %numTrials = 10;
    %numBins = 15;
    %histVector = zeros(numTrials, numBins);
    %for t=1:numTrials,
        
        %[trainedNet, tr] = train(untrainedNet, inputPatterns, outputPatterns);
        %histVector(t,:) = hist(trainedNet.IW{1},numBins);
        
    %end
    
    % Process data
    %means = mean(histVector);
    %stdev = std(histVector);
    %}

end
    %}
    
    %{
        % OLD STyle
    %{
    figure();
    iMoreExcitatory = sum(trainedNet.IW{1} >= 0) - sum(trainedNet.IW{1} < 0);
    hMoreExcitatory = sum(trainedNet.LW{1} >= 0) - sum(trainedNet.LW{1} < 0);

    hist([iMoreExcitatory hMoreExcitatory],-9:1:9);
    
    hXLabel = xlabel('Number of Surplus Excitatory Projections');
    hYLabel = ylabel('Number of Neurons');
    
    set( gca                   , ...
        'FontName'   , 'Helvetica' , ...
        'FontSize'   , 10          );
    
    set([ hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');

    set(hYLabel  , ...
        'FontSize'   , 18          );
    set(hXLabel  , ...
        'FontSize'   , 18          );

    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'LineWidth'   , 2         );
    %}
    %}
    
    %{
        
    % Old style
    %{
    figure;
    hist(synapses(:), -1.3:0.1:1.3);
    %errorbar(means,stdev);
    %ymax = max(h)*1.1;
    %ylim([0 ymax]);
    axis tight;
    %plot(m*[1 1], [0 ymax],'r-');
    hXLabel = xlabel('Synaptic Weight');
    hYLabel = ylabel('Number of Synapses');
    
    disp(['Number of Inhibitory: ' num2str(nnz(synapses < 0))]);
    
    set([hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');

    set(hYLabel  , ...
        'FontSize'   , 18          );
    set(hXLabel  , ...
        'FontSize'   , 18          );

    set(gca, ...
      'FontName'    , 'Helvetica', ...
      'FontSize'    , 10         , ...         
      'Box'         , 'on'       , ...
      'TickDir'     , 'in'       , ...
      'TickLength'  , [.02 .02]  , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'LineWidth'   , 2         );
    %}
    %}
    
    
    %{
    %
%  pouget.m
%  SMI
%
%  Created by Bedeho Mender on 21/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function pouget()

    % A. Pouget & T. Sejnowski (1997)
    
    % Seed rng
    rng(33, 'twister');
    
    % Stimuli:
    % 441=21*21 pairs of retinal and eye positions.
    % 21 retinal locations in [-40,40]
    % 21 eye positions in [-20,20]
    retinalTargets = centerN(80, 21);
    eyeTargets = centerN(40, 21);
    numPatterns = length(retinalTargets)*length(eyeTargets);
    
    mexRetTarget = max(retinalTargets);
    maxEyeTarget = max(eyeTargets);
    
    % Input:
    % 121 units
    % \mu uniform in 12 increments \in [-60,60]
    % \sigma = 18
    % \inflection points uniform in 8 increments \in [-40,40]
    % slope = 8
    inputSigma = 3;
    sigmoidSlope = 18;
    retinalPreferences = centerDistance(60*2, 10);
    eyePreferences = centerDistance(40*2, 4);
    
    [eyeMesh retMesh] = meshgrid(retinalPreferences, eyePreferences);
    numInputNeurons = numel(retMesh);
    
    % Output:
    % 1 unit
    % \sigma = 18
    % \mu = 0
    outputSigma = 18;
    outputHeadPreferences = -10:2:10;%[0]; -mexRetTarget:2:mexRetTarget;
    outputRetinalPreferences = -10:2:10;%[0]; -mexRetTarget:2:mexRetTarget;
    numOutputNeurons = length(outputHeadPreferences) + length(outputRetinalPreferences);
    
    % Network Parameters
    learningrate = 0.001;
    numEpochs = 10;
    
    [inputPatterns, outputPatterns] = generatePatterns();
    numPatterns = length(inputPatterns);
    
    %% Train
    figure;
    
    synapses = rand(numOutputNeurons, numInputNeurons);
    totalAveragError = zeros(1,numEpochs);
    
    for epochNr=1:numEpochs,
        
        % do one round of larning
        for p=1:numPatterns,
            
            % get input and desired output
            input = inputPatterns(:,p);
            target = outputPatterns(:,p);
            
            % compute response
            response = synapses*input;
            
                             
            
            
            
            if(1),
                    figure;
                    
                    subplot(1,2,1);
                    imagesc(input);
                    title('input')
                    
                    subplot(1,2,2);
                    plot(response , 'r');
                    ylim([0 1]);
                    
                    hold on;
                    
                    subplot(1,3,3);
                    plot(target,'b');
                    
                    xlim([1 numOutputNeurons]);
                    
                    x=1;
            end
                    
            
            
            
            
            
            % update synapses
            synapses = synapses + learningrate*(target - response)*input';
        end

        % get error after last epoch
        error = 0;
        for p=1:numPatterns,
            
            % get input and desired output
            input = inputPatterns(:,p);
            target = outputPatterns(:,p);
            
            % compute response
            response = synapses*input;
            
            % error
            error = error + sum((target-response).^2);
        end
        
        totalAveragError(epochNr) = error/numOutputNeurons;
    end
    
    plot(totalAveragError);
    ylabel('Error');
    xlabel('Epoch');
    
    %% Synaptic weight distribution   
    figure;

    lineardata = synapses(:);
    max_deviation = max(lineardata);
    min_deviation = min(lineardata);
    ticks = min_deviation:(max_deviation-min_deviation)/100:max_deviation;
    
    hdist = hist(lineardata, ticks);

    hBar = bar(ticks,hdist','stacked','LineStyle','none');
    set(hBar(1),'FaceColor', [67,82,163]/255); %, {'EdgeColor'}, edgeColors

    xlim([min_deviation max_deviation]);
    
    hXLabel = xlabel('Synaptic Weight');
    hYLabel = ylabel('Number of Synapses');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    box off
    
    axis square
    
    
    %% Show Input->Hidden Weight matrix
    figure;
    imagesc(synapses);
    
    hXLabel = xlabel('Hidden Layer Unit');
    hYLabel = ylabel('Input Layer Unit');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    colorbar
    axis square
    
    %% Single unit weight plot
    
    figure;
    output_weight_vector = reshape(synapses(2,:), [length(retinalPreferences), length(eyePreferences)]);
    imagesc(output_weight_vector);
    
    %% DALE principle
    
    inputToHidden_numExcitatory = sum((synapses > 0)');
    inputToHidden_numInhibitory = sum((synapses < 0)');
    
    [receptivefieldPlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms({inputToHidden_numExcitatory}, {inputToHidden_numInhibitory}, 'XTitle', 'Excitatory Efferents', 'YTitle', 'Inhibitory Efferents', 'FaceColors', {[67,82,163]/255},'Location', 'SouthEast');
    
    
    % Generate stimuli
    function [inputPatterns, outputPatterns] = generatePatterns()

        inputPatterns = zeros(numInputNeurons, numPatterns);
        outputPatterns = zeros(numOutputNeurons, numPatterns);
        
        % Iterate all targets comboes
        counter = 1;
        for r=retinalTargets,
            for e=eyeTargets,
                
                % Input
                in = exp(-(r - retMesh).^2/(2*inputSigma^2)) .* 1./(1 + exp(sigmoidSlope * (eyeMesh - e)));
                
                inputPatterns(:,counter) = in(:);
                
                % Output
                h = r+e;
                
                %{
                if(mod(counter,13) == 110),
                    figure;
                    subplot(1,3,1);
                    imagesc(in);
                    subplot(1,3,2);
                    plot(exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2)));
                    title('head');
                    xlim([1 length(outputHeadPreferences)]);
                    ylim([0 1]);
                    subplot(1,3,3);
                    plot(exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2)));
                    title('retinal');
                    xlim([1 length(outputRetinalPreferences)]);
                    ylim([0 1]);
                    x=1;
                end
                %}
                
                if(~isempty(outputHeadPreferences) && ~isempty(outputRetinalPreferences)),
                    outputPatterns(:,counter) = [exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2)) exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2))];
                elseif(~isempty(outputHeadPreferences)),
                    outputPatterns(:,counter) = exp(-((h - outputHeadPreferences).^2)/(2*outputSigma^2));
                else
                    outputPatterns(:,counter) = exp(-((r - outputRetinalPreferences).^2)/(2*outputSigma^2));
                end

                counter = counter + 1;
            end
        end

    end

end
    %}
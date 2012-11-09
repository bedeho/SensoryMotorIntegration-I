   
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
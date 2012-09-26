%
%  inspectWeights.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectWeights(networkFile, filename, nrOfEyePositionsInTesting, stimuliName)
    
    declareGlobalVars();
    
    global base;
    global THESIS_FIGURE_PATH;
    
    % Load data
    [networkDimensions, neuronOffsets] = loadWeightFileHeader(networkFile); % Load weight file header
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % MaxDepth
    
    
    % Load stimuli
    startDir = pwd;
    cd([base 'Stimuli/' stimuliName]);
    C = load('info.mat');
    info = C.info;
    cd(startDir);
    
    
    % Setup vars
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions-1, 3); % Save axis that we can lookup 'CurrentPoint' property on callback
    topLayerRowDim = networkDimensions(numRegions).x_dimension;
    
    % Iterate regions to do correlation plot and setup callbacks
    fig = figure('name',filename,'NumberTitle','off');
    title('Number of testing locations responded to');
    
    for r=2:numRegions
        
        % Save axis
        clickAxis(r-1,1) = subplot(numRegions-1, 3, 3*(r-2)+1);
        
        % Plot
        if ~isempty(data{r-1})
            v0 = data{r-1};
            v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed
            
            % Fix when only one object in Simon Mode
            if objectsPrEyePosition > 1,
                v1 = squeeze(sum(sum(v0))); % sum away
            else
                v1 = squeeze(sum(v0)); % sum away
            end

            v2 = v1(:,:,1);

        else
            v2 = zeros(networkDimensions(r).y_dimension, networkDimensions(r).x_dimension);
        end
        
        % Decorate
        title(['Region: ' num2str(r)]);
        im = imagesc(v2);         % only do first region
        daspect([size(v2) 1]);
        colorbar;
        
        % Setup callback
        set(im, 'ButtonDownFcn', {@responseCallBack, r});
    end
    
    % Keep open for callback
    fileID = fopen(networkFile);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        
        pos = get(clickAxis(region-1,1), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);
        
        % Response count
        disp(['# responding: ' num2str(v2(row,col))]);
        
        % Check if we right clicked
        rightClicked =  strcmp(get(gcf,'SelectionType'),'alt');
        
        drawWeights(region, row, col, 1, rightClicked);
        
        if region == 2 && networkDimensions(1).depth > 1,
            drawWeights(region, row, col, 2, rightClicked);
        end
        
    end

    function drawWeights(region, row, col, sourceDepth,rightClicked)
        
        % Plot the two input layers
        subplot(numRegions-1, 3, 3*(region-2) + 1 + sourceDepth);
        weightBox1 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, region, 1, row, col, region-1, sourceDepth);
        % wrong: disp(['Number of synapses from this depth from this region: ' num2str(numel(weightBox1))]);
        cla
        imagesc(weightBox1);
        dim = fliplr(size(weightBox1));
        daspect([dim 1]);
        colorbar;
        axis square;
        
        [height,width] = size(weightBox1);
        
        % External figure
        if rightClicked,
            
            answer = inputdlg('Qualifier')
            
            if ~isempty(answer)
                qualifier = ['-' answer{1}];
            else
                qualifier = '';
            end
            
            f = figure();
            
            %% IMAGESC SCHME
            h = imagesc(weightBox1);
            
            
            %% SURF SCHEME
            %x = 1:width;
            %y = 1:height;
            %[X, Y] = meshgrid(x, y);
            %h = surf(X, Y, weightBox1,'EdgeColor','none','LineStyle','none','FaceLighting','phong');
            %h = surf(weightBox1);
            %set(h, 'linestyle', 'none');
            %view(0, 90);
            %axis tight
            %box on
            %grid off
            %alpha(.5)
            
            dim = fliplr(size(weightBox1));
            daspect([dim 1]);
            
            %colormap gray
            colorbar
            %colorbar('location','southoutside')
            
            
            cellNr = (row-1)*topLayerRowDim + col;
            %hTitle = title(''); %; title(['Afferent synaptic weights of cell #' num2str(cellNr) extraTitle]);
            hTitle = title(''); %title(['Cell #' num2str(cellNr) ]); % extraTitle
            
            hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}
            hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
            
            set( gca                       , ...
                'FontName'   , 'Helvetica' );
            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            
            set(gca             , ...
                'FontSize'   , 6           );
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 24          , ...
                'FontWeight' , 'bold'      );
 
            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'out'     , ...
              'TickLength'  , [.01 .01] , ...
              'XMinorTick'  , 'off'    );
          
            % Unbelievable: cannot
            % find matlab command to turn vector into string
            % must do it manually
            
            % Width
            wTicks = 1:width;
            wTicks = wTicks(1:4:end);
            wLabels = info.eyePositionPreferences(1:4:end);
            wCellLabels = cell(1,length(wLabels));
            for l=1:length(wLabels),
              wCellLabels{l} = num2str(wLabels(l));
            end

            set(gca,'XTick',wTicks);
            set(gca,'XTickLabel',wCellLabels);
            
            % Height
            hTicks = 1:height;
            hTicks = hTicks(1:10:end);
            hLabels = info.visualPreferences(1:10:end);
            hCellLabels = cell(1,length(hLabels));
            for l=1:length(hLabels),
              hCellLabels{l} = num2str(hLabels(l));
            end

            set(gca,'YTick',hTicks);
            set(gca,'YTickLabel',hCellLabels);
            
            %% Reme buffer around figure
            %tightInset = get(gca, 'TightInset');
            %position(1) = tightInset(1);
            %position(2) = tightInset(2);
            %position(3) = 1 - tightInset(1) - tightInset(3);
            %position(4) = 1 - tightInset(2) - tightInset(4);
            %set(gca, 'Position', position);
            %saveas(h, 'WithoutMargins.pdf');
            
            %% SAVE
            chap = 'chap-2';
            fname = [THESIS_FIGURE_PATH chap '/neuron_weight_' num2str(cellNr) qualifier '.eps'];
            set(gcf,'renderer','painters');
            print(f,'-depsc2','-painters',fname);
            
            %fname_eps = [ path 'cell_weight_' num2str(cellNr) '.pdf'];
            %print(f,'-dpdf','-painters','-r600',fname);
 
            %plot2svg('myfile.svg', f)
           
            
            %print(f,'-depsc2','-painters','plotname.eps')
            %
            %
            %-depsc 
            %saveas(f, fname,'eps');
            
            %oldfolder = cd(filepath);
                    %print(f,'-depsc', fname);
                    %fname = strcat(fname, '.eps'); 
            %eps2pdf(fname, fname_eps);
            %        cd(oldfolder);
        end
    end
end
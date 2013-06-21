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
    
    % Load data
    [networkDimensions, neuronOffsets] = loadWeightFileHeader(networkFile); % Load weight file header
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % Load TRAINING stimuli
    trainingStimuliName = strrep(stimuliName, '-stdTest', '-training');
    
    startDir = pwd;
    cd([base 'Stimuli/' trainingStimuliName]);
    dimensions = load('dimensions.mat');
    cd(startDir);
    
    %Load testing stimuli
    cd([base 'Stimuli/' stimuliName]);
    info = load('info.mat');
    info = info.info;
    cd(startDir);
    
    % Read out analysis results
    [pathstr, name, ext] = fileparts(filename);
    x = load([pathstr '/analysisResults.mat']);
    analysisResults = x.analysisResults;
    
    % Extract head-position from name if tehre
    [pathstr, name, ext] = fileparts(networkFile);
    splitted = strsplit(name,'_');
    if(length(splitted) == 3),
        targetNr = str2num(cell2mat(splitted(end)));
    end
    
    % Setup vars
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions-1, 3); % Save axis that we can lookup 'CurrentPoint' property on callback
    topLayerRowDim = networkDimensions(numRegions).x_dimension;
    inputDepth = networkDimensions(1).depth;
    
    vfSize                              = dimensions.visualFieldSize;
    epSize                              = dimensions.eyePositionFieldSize;
    visualPreferenceDistance            = 1;
    eyePositionPrefrerenceDistance      = 1;
    visualPreferences                   = fliplr(centerDistance(dimensions.visualFieldSize, visualPreferenceDistance));
    eyePositionPreferences              = centerDistance(dimensions.eyePositionFieldSize, eyePositionPrefrerenceDistance);

    % Iterate regions to do correlation plot and setup callbacks
    fig = figure('name',filename,'NumberTitle','off');
    title('Number of testing locations responded to');
    
    % Read out analysis results
    [pathstr, name, ext] = fileparts(filename);
    
    x = load([pathstr '/analysisResults.mat']);
    
    analysisResults = x.analysisResults;
    
    for r=2:numRegions
        
        % Save axis
        clickAxis(r-1,1) = subplot(numRegions-1, 3, 3*(r-2)+1);
        
        % Decorate
        title(['Region: ' num2str(r)]);
        im = imagesc(analysisResults.headCenteredNess);         % only do first region
        pbaspect([fliplr(size(im)) 1]);
        colorbar;
        
        % Setup callback
        set(im, 'ButtonDownFcn', {@responseCallBack, r});
    end
    
    % Keep open for callback
    fileID = fopen(networkFile);
    
        function h = circle2(x,y,r)
        d = r*2;
        px = x-r;
        py = y-r;
        h = rectangle('Position',[px py d d],'Curvature',[1,1],'EdgeColor',[1 1 1]); % 
        daspect([1,1,1])
    end
    
    % Callback
    function responseCallBack(varargin)
        
                                % Contour drawing
                                if false,
                                    for row_= 3:3,%networkDimensions(numRegions).x_dimension,
                                        for col_=1:networkDimensions(numRegions).y_dimension,

                                            if col_ > 20,
                                                continue;
                                            end

                                            eye = analysisResults.eyeCenteredNess(row_,col_);
                                            head = analysisResults.headCenteredNess(row_,col_);

                                            if  eye > 0 ,
                                                
                                                cellNr = (row_-1)*topLayerRowDim + col_;
                                                disp(['Cell: ' num2str(cellNr) ', row: ' num2str(row_) ' col: ' num2str(col_)]);

                                                figure('Units','Pixels','position', [1000 1000 300 600]);
                                                hold on
                                                

                                                w = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, numRegions, 1, row_, col_, numRegions-1, 1);
                                                
                                                % get 
                                                %{
                                                w2 = conv2(w,ones(30),'same');
                                                [c,h] = contour(w2,[2 2],'Color',[1 0 0]);
                                                XX=get(h(1),'xdata');
                                                YY=get(h(1),'ydata');
                                                %}
                                                
                                                % add weight
                                                imagesc(w);
                                                colorbar
                                                %colormap('gray')
                                                
                                                %plot(XX,YY,'r')

                                                % Add head bar
                                                target = analysisResults.RFLocation(row_,col_);%dimensions.allShownTargets(targetNr);
                                                plot(info.eyePositions+epSize/2,vfSize/2 - (target-info.eyePositions),'-*g','LineWidth',2);
                                                
                                                % Add testing & circles
                                                numTargets = length(info.targets);
                                                for e=info.eyePositions,
                                                    
                                                    plot(ones(1,numTargets)*e+epSize/2,vfSize/2 - (info.targets-e),'.y');
                                                    circle2(e + epSize/2,vfSize/2 - (target-e), 6);
                                                end
                                                
                                                set(gca,'YDir','reverse');
                                                
                                                box on
                                                
                                                
                                                %% pretty up
                                                dim = fliplr(size(w));
                                                pbaspect([dim 1]);
                                                %colorbar;

                                                [height,width] = size(w);
                                                xlim([1 width]);
                                                ylim([1 height]);

                                                hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
                                                hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}

                                                % Fix axes ticks
                                                wTicks = 1:width;
                                                wdist = 15;
                                                wTicks = wTicks(1:wdist:end);
                                                wLabels = eyePositionPreferences(1:wdist:end);
                                                wCellLabels = cell(1,length(wLabels));
                                                for t=1:length(wLabels),
                                                  wCellLabels{t} = num2str(wLabels(t));
                                                end

                                                set(gca,'XTick',wTicks);
                                                set(gca,'XTickLabel',wCellLabels);

                                                % Height
                                                hTicks = 1:height;
                                                hdist = 20;
                                                hTicks = hTicks(1:hdist:end);
                                                hLabels = visualPreferences(1:hdist:end);
                                                hCellLabels = cell(1,length(hLabels));
                                                for l=1:length(hLabels),
                                                  hCellLabels{l} = [num2str(hLabels(l))];
                                                end

                                                set(gca,'YTick',hTicks);
                                                set(gca,'YTickLabel',hCellLabels);

                                                % Change font size
                                                set([hYLabel hXLabel], 'FontSize', 16);
                                                set(gca, 'FontSize', 14);

                                            end

                                        end
                                    end

                                    
                                end
                                            
        % Extract region,row,col
        region = varargin{3};
        
        pos = get(clickAxis(region-1,1), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);
        
        % Response count
        disp(['row,col =' num2str(row) ',' num2str(col)]);
        
        % Check if we right clicked
        rightClicked =  strcmp(get(gcf,'SelectionType'),'alt');
        
        drawWeights(region, row, col, 1, rightClicked);
        
        if region == 2 && networkDimensions(1).depth > 1,
            figure(fig);
            drawWeights(region, row, col, 2, rightClicked);
        end
        
        if rightClicked && inputDepth,
            drawCombinedWeights(region, row, col);
        end
        
    end

    function drawWeights(region, row, col, sourceDepth, rightClicked)
        
        % Plot the two input layers
        subplot(numRegions-1, 3, 3*(region-2) + 1 + sourceDepth);
        weightBox1 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, region, 1, row, col, region-1, sourceDepth);
        % wrong: disp(['Number of synapses from this depth from this region: ' num2str(numel(weightBox1))]);
        cla
        imagesc(weightBox1);
        dim = fliplr(size(weightBox1));
        pbaspect([dim 1]);
        colorbar;
        %colormap('gray')
        
        [height,width] = size(weightBox1);
        
        % External figure
        if rightClicked,
            
            figure('Units','Pixels','position', [1000 1000 300 500]);
            
            % Plot
            imagesc(weightBox1);
            %save('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/decoupled_gainencoding/weightBox1.mat', 'weightBox1')
            dim = fliplr(size(weightBox1));
            pbaspect([dim 1]);
            colorbar

            %hTitle = title(''); %; title(['Afferent synaptic weights of cell #' num2str(cellNr) extraTitle]);
            hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
            hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}
            
            cellNr = (row-1)*topLayerRowDim + col;
            disp(['Cell: ' num2str(cellNr)]);
            disp(['Number of Afferent synapses: ' num2str(nnz(weightBox1 > 0))]);
          
            % Fix axes ticks
            
            wTicks = 1:width;
            wdist = 15;
            wTicks = wTicks(1:wdist:end);
            wLabels = eyePositionPreferences(1:wdist:end);
            wCellLabels = cell(1,length(wLabels));
            for t=1:length(wLabels),
              wCellLabels{t} = num2str(wLabels(t));
            end
            
            set(gca,'XTick',wTicks);
            set(gca,'XTickLabel',wCellLabels);
            
            % Height
            hTicks = 1:height;
            hdist = 20;
            hTicks = hTicks(1:hdist:end);
            hLabels = visualPreferences(1:hdist:end);
            hCellLabels = cell(1,length(hLabels));
            for l=1:length(hLabels),
              hCellLabels{l} = [num2str(hLabels(l)) ];
            end

            set(gca,'YTick',hTicks);
            set(gca,'YTickLabel',hCellLabels);
            
            % Change font size
            set([hYLabel hXLabel], 'FontSize', 16);
            set(gca, 'FontSize', 14);
            
            
            %% Add head-centered bar
            if false ,
                hold on;

                target = dimensions.allShownTargets(targetNr);
                vfs = dimensions.visualFieldSize;
                eps = dimensions.eyePositionFieldSize;
                eyePositionRange = dimensions.targetEyePositionRange;

                dx = (eps - eyePositionRange)/2;

                x1 = -eps/2 + dx;
                y1 = vfs/2 - (target - x1);

                x2 = eps/2 - dx;
                y2 = vfs/2 - (target - x2);

                plot([dx (dx + eyePositionRange)],[y1 y2],'-ow','LineWidth',1);
            end
            
        end
    end

    function drawCombinedWeights(region, row, col)

        % Start figure
        figure('Units','Pixels','position', [1000 1000 300 350]);
        
        % Get Weight vectors
        weightBox1 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, region, 1, row, col, region-1, 1);
        weightBox2 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, region, 1, row, col, region-1, 2);
        totalweightBox = [weightBox1 weightBox2];
        [height,width] = size(totalweightBox);
        
        % Plot
        %save('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/decoupled_gainencoding/weightBox1.mat', 'weightBox1')
        imagesc(totalweightBox);
        dim = fliplr(size(totalweightBox));
        pbaspect([dim 1]);
        colorbar;
        
        % Add marker line
        hold on;
        plot([width/2 width/2],[height 1],'--w','LineWidth',1);
        
        
            %% Add head-centered bar
            if false,
                
                target = dimensions.allShownTargets(targetNr);
                vfs = dimensions.visualFieldSize;
                eps = dimensions.eyePositionFieldSize;
                eyePositionRange = dimensions.targetEyePositionRange;

                dx = (eps - eyePositionRange)/2;

                y = target - (-(eps/2 - dx));
                y2 = target - (eps/2 - dx);

                dy = vfs/2 - y;
                dy2 = vfs/2 - y2;

                plot([dx (eps-dx)],[dy dy2],'-ow','LineWidth',1);

                plot([(dx+eps) (2*eps-dx)],[dy dy2],'-ow','LineWidth',1);
            end
        
        
        
        %hTitle = title(''); %; title(['Afferent synaptic weights of cell #' num2str(cellNr) extraTitle]);
        hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
        hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}

        cellNr = (row-1)*topLayerRowDim + col;
        disp(['Cell: ' num2str(cellNr)]);
        disp(['Number of Afferent synapses: ' num2str(nnz(weightBox1 > 0))]);

        % Fix axes ticks
        wTicks = 1:(width/2);
        wdist = 15;
        wTicks = wTicks(1:wdist:end);
        wLabels = eyePositionPreferences(1:wdist:end);
        wCellLabels = cell(1,length(wLabels));
        for t=1:length(wLabels),
          wCellLabels{t} = num2str(wLabels(t));
        end
         
        % ticks and labels
        for t=2:length(wTicks),
          wCellLabels{length(wCellLabels)+1} = num2str(wLabels(t));
        end

        set(gca,'XTick',[wTicks (width/2 + wTicks(2:end))]);
        set(gca,'XTickLabel',wCellLabels);

        % Height
        hTicks = 1:height;
        hdist = 20;
        hTicks = hTicks(1:hdist:end);
        hLabels = visualPreferences(1:hdist:end);
        hCellLabels = cell(1,length(hLabels));
        for l=1:length(hLabels),
          hCellLabels{l} = [num2str(hLabels(l)) ];
        end

        set(gca,'YTick',hTicks);
        set(gca,'YTickLabel',hCellLabels);

        % Change font size
        set([hYLabel hXLabel], 'FontSize', 16);
        set(gca, 'FontSize', 14);
            
    end
end
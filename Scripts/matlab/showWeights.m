%
%  showWeights.m
%  SMI
%
%  Created by Bedeho Mender on 24/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function showWeights(networkFile, networkDimensions, neuronOffsets, region, row, col, depth)

    figure();
    
    % Open network file
    fileID = fopen(networkFile);
    
    % Load data
    [synapses] = afferentSynapseList(fileID, neuronOffsets, region, depth, row, col);
    
    % Prefil source buffer
    sources = [synapses(1).region; synapses(1).depth]; % (region, depth)*number
    numSources = 1;
    
    % Find number of afferent regions
    for s=2:length(synapses),
        
        thisSource = [synapses(s).region; synapses(s).depth];
        
        % Check if we know about what regions we know
        if nnz(find(sources(1,:) == synapses(s).region)) > 0, % We know this region
            
            if ~any(sum(abs(sources - repmat(thisSource,1,numSources))) == 0) % We do not know this combination of region and depth
                sources = [sources thisSource];
                numSources = numSources + 1;
            end

            
        else % We dont know this region, then add it with its depth
            sources = [sources thisSource];
            numSources = numSources + 1;
        end
        
    end
    
    % Most attractive presentation
    numCols = floor(sqrt(numSources));
    numRows = ceil(numSources / numCols);
    
    % Plot sources
    for s=1:numSources,
        
        sourceRegion = sources(1,s);
        sourceDepth = sources(2,s);
        
        subplot(numRows, numCols, s);
        
        weightBox = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, region, depth, row, col, sourceRegion, sourceDepth);
        cla
        dim = fliplr(size(weightBox));
        
        % imagesc
        imagesc(weightBox);
        daspect([dim 1]);
        
        % surf
        %surf(weightBox);
        %zlim([0 max(max(weightBox))]);
        %axis tight;
        
        
        title(['Region: ' num2str(sourceRegion) ', Depth: ' num2str(sourceDepth)]);
    end
    
    % Close file
    fclose(fileID);

%{
    function drawWeights(region, row, col, sourceDepth,rightClicked)
        
        % Plot the two input layers
        subplot(numRegions-1, 3, 3*(region-2) + 1 + sourceDepth);
       
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
    %}
    
end
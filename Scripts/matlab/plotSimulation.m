%
%  plotSimulation.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  PLOT REGION INVARIANCE FOR ALL SIMULATION FILES
%  Input=========
%  experiment: experiment name
%  simulation: simulation name

function [summary] = plotSimulation(experiment, simulation, info, dotproduct)

    % Import global variables
    declareGlobalVars();
    
    global EXPERIMENTS_FOLDER;

    simulationFolder = [EXPERIMENTS_FOLDER experiment '/' simulation '/'];

    % Iterate all network result folders in this simulation folder
    listing = dir(simulationFolder);

    % Preallocate struct array for summary
    summary = [];
    counter = 1;

    % Iterate dir and do plot for each folder
    for d = 1:length(listing),
        
        % We are only looking for directories, but not the
        % 'Training' directory, since it has network evolution in training
        directory = listing(d).name;
        
        if listing(d).isdir == 1 && ~strcmp(directory,'Training') && ~strcmp(directory,'.') && ~strcmp(directory,'..'),
            
            netDir = [simulationFolder directory];
            
            [outputPatternsPlot, MeanObjects, MeanTransforms, orthogonalityIndex, regionOrthogonalizationPlot, regionCorrelationPlot,thetaPlot, thetaMatrix, singleCell, multiCell, omegaBins, invariancePlot, distributionPlot] = plotRegion([netDir '/firingRate.dat'], info, dotproduct);
            
            % regionCorrelationPlot
            saveas(regionCorrelationPlot,[netDir '/result_1.eps']);
            delete(regionCorrelationPlot);
            
            % regionOrthogonalizationPlot
            saveas(regionOrthogonalizationPlot, [netDir '/orthogonality.eps']);
            delete(regionOrthogonalizationPlot);
            
            % outputPatternsPlot
            saveas(outputPatternsPlot, [netDir '/outputOrthogonality.eps']);
            delete(outputPatternsPlot);
            
            % outputPatternsPlot
            saveas(invariancePlot, [netDir '/invariance.eps']);
            %print(invariancePlot, '-depsc2', '-painters', [netDir '/' experiment '_invariance.eps']);
            delete(invariancePlot);
            
            % distributionPlot
            saveas(distributionPlot, [netDir '/dist.eps']);
            delete(distributionPlot);
            
            % thetaPlot
            saveas(thetaPlot, [netDir '/theta.eps']);
            delete(thetaPlot);
            
            % Save results for summary
            summary(counter).directory = directory;
            summary(counter).nrOfHeadCenteredCells = nnz(singleCell > 0); % Count number of cells with positive correlation
            summary(counter).orthogonalityIndex = orthogonalityIndex;
            summary(counter).MeanObjects = MeanObjects;
            summary(counter).MeanTransforms = MeanTransforms;
            
            %summary(counter).fullInvariance = fullInvariance;
            %summary(counter).meanInvariance = meanInvariance;
            %summary(counter).multiCell = multiCell;
            %summary(counter).nrOfSingleCell = nrOfSingleCell;
            
            % Save for collation
            save([netDir '/collation.mat'],'singleCell','multiCell','omegaBins','thetaMatrix');
            
            counter = counter + 1;
        end
    end
    
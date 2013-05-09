
%  plotRegion.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function plotRegion(filename, info, trainingInfo, netDir)
    
    analysisResults = metrics(filename, info, trainingInfo);
    
    disp(['Discarded: ' num2str(100*nnz(analysisResults.DiscardStatus_Linear > 0)/numel(analysisResults.DiscardStatus_Linear)) '%']);
    
    % Refence Frames
    referenceFramePlot = figure();
    hold on;
    plot(analysisResults.eyeCenteredNess_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or');     
    plot([-0.1 1],[-0.1 1]);
    title('Refence Frame');
    xlabel('Eye-Centeredness');
    ylabel('Head-Centeredness');
    axis([-0.1 1 -0.1 1]);
    saveFigureAndDelete(referenceFramePlot, 'referenceFramePlot');
    
    % Coverage analysis
    %% Coverage analysis : Only if we have information abour training locations
     if isstruct(trainingInfo)
                 
        coveragePlot = figure();
        bar(analysisResults.preferredTargetDistribution,'LineStyle','none');
        box off;
        ylabel('Frequency');
        xlabel('Head-Centered Training Location (deg)');
        ylim([0 1]);
        set(gca,'XTickLabel', sort(trainingInfo.allShownTargets));

        saveFigureAndDelete(coveragePlot, 'coveragePlot');
    end

    % Save for collation
    save([netDir '/analysisResults.mat'], 'analysisResults' );
    
    function saveFigureAndDelete(fig, name)
        
        saveas(fig, [netDir '/' name '.eps']);
        saveas(fig, [netDir '/' name '.png']);
        delete(fig);  
    end
    

end

%  plotRegion.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function plotRegion(filename, info, dotproduct, netDir)
    
    analysisResults = metrics(filename, info);
    
    disp(['Discarded: ' num2str(100*nnz(analysisResults.DiscardStatus_Linear > 0)/numel(analysisResults.DiscardStatus_Linear)) '%']);
    
    % Psi/lambda scatter plot
    psiLambdaPlot = figure();
    plot(analysisResults.RFSize_Linear, analysisResults.headCenteredNess_Linear, 'ob');
    hold on;
    plot(analysisResults.RFSize_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or');
    xlabel('\psi');
    ylabel('\lambda');
    ylim([-0.1 1]);
    saveFigureAndDelete(psiLambdaPlot, 'psilambda');
    
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
    
    % Save for collation
    save([netDir '/analysisResults.mat'], 'analysisResults' );
    
    function saveFigureAndDelete(fig, name)
        
        saveas(fig, [netDir '/' name '.eps']);
        saveas(fig, [netDir '/' name '.png']);
        delete(fig);  
    end
    

end
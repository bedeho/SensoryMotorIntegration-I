
x = load('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/prewiredPO/X=1_Y=1/TrainedNetwork/analysisResults.mat')
EstimatedLambda = x.analysisResults.RFLocation(:);

y = load('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/prewiredPO/info.mat');
PerfectLambda = y.allocatedHeadPositions(:);

[maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms({EstimatedLambda}, {PerfectLambda}, 'XTitle', 'Hardwired RF-Location (deg)', 'YTitle', 'Estimated RF-Location - \Pi (deg)', 'YLabelOffset', 4, 'FaceColors', {[0,0,1]});

axes(scatterAxis);

plot(XLim, YLim, 'r');

corrcoef(EstimatedLambda, PerfectLambda)

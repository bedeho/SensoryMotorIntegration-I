
% Load finished product
x = load('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/prewiredPO/X=1_Y=1/TrainedNetwork/analysisResults.mat');
analysisResults = x.analysisResults;

% Load hardcoded
y = load('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/prewiredPO/info.mat');

% plot
prewiredLocation = y.allocatedHeadPositions(:);
decodedLocation = analysisResults.RFLocation(:);
plot(decodedLocation, prewiredLocation,'o');
hold on
plot([min(decodedLocation) max(decodedLocation)],[min(prewiredLocation) max(prewiredLocation)]);
axis square
axis tight
hXLabel = xlabel('Decoded Receptive Field Location (deg)');
hYLabel = ylabel('Prewired Receptive Field Location (deg)');

set([hYLabel hXLabel], 'FontSize', 20);
set(gca, 'FontSize', 18);

corrcoef(prewiredLocation, decodedLocation)
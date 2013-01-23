

%% Load encodings used

col = 201;
row = 61;

eyeModulationOnly = zeros(col, row);

fileID = fopen('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/decoupled_gainencoding/dump');

C = textscan(fileID,'%d:%d:%d');

numvals = length(C{1});
rows = C{1};
cols = C{2};
vals = C{3};

for i=1:numvals,
    eyeModulationOnly(rows(i)+1,cols(i)+1) = vals(i);
end

fclose(fileID);

eyeModulationOnly = logical(eyeModulationOnly);
retinalOnly = ~eyeModulationOnly;

%figure;imagesc(eyeModulationOnly);title('eyeModulationOnly');
%figure;imagesc(retinalOnly);title('retinalOnly');

%% Load weights

z = load('/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/decoupled_gainencoding/weightBox1.mat');

z = z.weightBox1

%figure;imagesc(z);title('original');

eyeModulatedSynapses = z;
eyeModulatedSynapses(retinalOnly) = 0; % clean out the retinal synapses
eyeCum = sum(eyeModulatedSynapses);

figure;imagesc(eyeModulatedSynapses);title('eyeModulatedSynapses');colorbar;

figure;
hBar = bar(eyeCum);
axis tight;
hYLabel = ylabel('Cumulative Weight');
hXLabel = xlabel('Eye Position Preference - \beta (deg)');
set([hYLabel hXLabel], 'FontSize', 16);
set(gca, 'FontSize', 14);

            width = 61;
            eyePositionPreferences = (1:width) - ceil(width/2);
            wTicks = 1:width;
            wdist = 10;
            wTicks = wTicks(1:wdist:end);
            wLabels = eyePositionPreferences(1:wdist:end);
            wCellLabels = cell(1,length(wLabels));
            for t=1:length(wLabels),
              wCellLabels{t} = [num2str(wLabels(t))];
            end
            
            set(gca,'XTick',wTicks);
            set(gca,'XTickLabel',wCellLabels);
            set(hBar,'FaceColor', [0,0,0.8]);
            set(hBar,'EdgeColor', [0,0,0.8]);

retsynapses = z;
retsynapses(eyeModulationOnly) = 0; % clean out eye position synapses
retCum = sum(retsynapses');

figure;imagesc(retsynapses);title('retsynapses');colorbar;

figure;
hBar = bar(retCum);
axis tight;
hYLabel = ylabel('Cumulative Weight');
hXLabel = xlabel('Retinal Preference - \alpha (deg)');
set([hYLabel hXLabel], 'FontSize', 16);
set(gca, 'FontSize', 14);
            
            % Height
            height = 201;
            visualPreferences = (1:height) - ceil(height/2);
            hTicks = 1:height;
            hdist = 20;
            hTicks = hTicks(1:hdist:end);
            hLabels = visualPreferences(1:hdist:end);
            hCellLabels = cell(1,length(hLabels));
            for l=1:length(hLabels),
              hCellLabels{l} = [num2str(hLabels(l)) ];
            end

            set(gca,'XTick',hTicks);
            set(gca,'XTickLabel',hCellLabels);
            set(hBar,'FaceColor', [0,0,0.8]);
            set(hBar,'EdgeColor', [0,0,0.8]);
            % Change font size



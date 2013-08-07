
sigmoidSlope = 0.0625;
r_0 = 0.5;
E = 60;
R = 200;

e_prefs = -E/2:1:E/2;
r_prefs = R/2:-1:-R/2;
[eye_prefs ret_prefs] = meshgrid(e_prefs,r_prefs);

num_e_prefs = length(e_prefs);
num_r_prefs = length(r_prefs);
 
%% gain < 1
% bias_negativegain
gain = -1;
h_lower = ret_prefs - E/2;
h_higher = ret_prefs + eye_prefs + (1/(-2*gain))*log((1/r_0) - 1);

%% gain > 0
% bias_positivegain
%{
gain = 1;
h_lower = ret_prefs + eye_prefs + (1/(-2*gain))*log((1/r_0) - 1);
h_higher = ret_prefs + E/2;
%}

%% Figure
h = h_higher - h_lower;
figure;
imagesc(h);
colorbar
caxis([0 60])

% Pretty up

            dim = fliplr(size(overlap));
            pbaspect([dim 1]);

            hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
            hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}
            
            % Fix axes ticks
            
            wTicks = 1:num_e_prefs;
            wdist = 15;
            wTicks = wTicks(1:wdist:end);
            wLabels = e_prefs(1:wdist:end);
            wCellLabels = cell(1,length(wLabels));
            for t=1:length(wLabels),
              wCellLabels{t} = num2str(wLabels(t));
            end
            
            set(gca,'XTick',wTicks);
            set(gca,'XTickLabel',wCellLabels);
            
            % Height
            hTicks = 1:num_r_prefs;
            hdist = 20;
            hTicks = hTicks(1:hdist:end);
            hLabels = r_prefs(1:hdist:end);
            hCellLabels = cell(1,length(hLabels));
            for l=1:length(hLabels),
              hCellLabels{l} = [num2str(hLabels(l)) ];
            end

            set(gca,'YTick',hTicks);
            set(gca,'YTickLabel',hCellLabels);
            
            % Change font size
            set([hYLabel hXLabel], 'FontSize', 16);
            set(gca, 'FontSize', 14);


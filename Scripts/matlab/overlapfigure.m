
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
% overlap_a0_b-Ediv2_g-1_r05
% overlap_a0_b-Ediv4_g-1_r05
% overlap_a0_bE0_g-1_r05
% overlap_a0_bEdiv4_g-1_r05
% overlap_a0_bEdiv2_g-1_r05

%{
gain = -1;
ref_alpha = 0
ref_beta = E/2 % E/2, E/4, 0, -E/4, -E/2

ref_h_lower = ref_alpha - E/2; 
ref_h_higher = ref_alpha + ref_beta + (1/(-2*gain))*log((1/r_0) - 1);

h_lower = ret_prefs - E/2;
h_higher = ret_prefs + eye_prefs + (1/(-2*gain))*log((1/r_0) - 1);
%}

%% gain > 0
% overlap_a0_b-Ediv2_g1_r05
% overlap_a0_b-Ediv4_g1_r05
% overlap_a0_bE0_g1_r05
% overlap_a0_bEdiv4_g1_r05
% overlap_a0_bEdiv2_g1_r05

gain = 1;
ref_alpha = 0
ref_beta = -E/2 % -E/2, -E/4 , 0 ,  E/4,  E/2

ref_h_lower = ref_alpha + ref_beta + (1/(-2*gain))*log((1/r_0) - 1);
ref_h_higher = ref_alpha + E/2;

h_lower = ret_prefs + eye_prefs + (1/(-2*gain))*log((1/r_0) - 1);
h_higher = ret_prefs + E/2;


%% Compute overlap
overlap = min(ref_h_higher,h_higher) - max(ref_h_lower,h_lower);
overlap(overlap < 0) = 0;

%% Figure
figure;
imagesc(overlap);
colorbar
caxis([0 60])

% Add marker axis
hold on
plot([1 num_e_prefs],[R/2 R/2] + 1,'--w');
plot(1 + E/2 + [ref_beta ref_beta],[1 num_r_prefs],'--w');

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



% gain < 1
% overlap_a0_b-Ediv2_g-1_r05
% overlap_a0_b-Ediv4_g-1_r05
% overlap_a0_bE0_g-1_r05
% overlap_a0_bEdiv4_g-1_r05
% overlap_a0_bEdiv2_g-1_r05
%
% gain > 1
% overlap_a0_b-Ediv2_g1_r05
% overlap_a0_b-Ediv4_g1_r05
% overlap_a0_bE0_g1_r05
% overlap_a0_bEdiv4_g1_r05
% overlap_a0_bEdiv2_g1_r05
    
function overlapfigure_sigmodal()

    r_0 = 0.5;
    E = 60;
    R = 200;

    e_prefs = -E/2:1:E/2;
    r_prefs = R/2:-1:-R/2;
    [eye_prefs ret_prefs] = meshgrid(e_prefs,r_prefs);
  
    gain_magnitude = 0.0625;
    
    % Reference neuron
    ref_gain_sign = -1;
    ref_alpha = 0;
    ref_beta = 0; % -E/2, -E/4 , 0 ,  E/4,  E/2

    overlap_pos = getRange(1);
    overlap_neg = getRange(-1);
    overlap = [overlap_pos overlap_neg];

    % Figure
    figure;
    imagesc(overlap);
    hold on;
    colorbar;
    caxis([0 60]);
    
    % add cell identifier
    x = 1 + E*(ref_gain_sign<0) + (E/2 + ref_beta);
    y = 1 + R/2 - ref_alpha;
    %plot([1 2*E],[y y],'-y','LineWidth',2); % horizontal line
    %plot([x x],[1 R],'-y','LineWidth',2); % horizontal line
    plot(x,y,'+w','LineWidth',2,'MarkerSize',10);
    
    dim = fliplr(size(overlap));
    pbaspect([dim 1]);
    [height,width] = size(overlap);
    

        %% Make pretty 
        % Add marker line
        plot([width/2 width/2],[height 1],'--w','LineWidth',1);
        
        hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
        hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}

        % Fix axes ticks
        wTicks = 1:(width/2);
        wdist = 15;
        wTicks = wTicks(1:wdist:end);
        wLabels = e_prefs(1:wdist:end);
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

    function overlap = getRange(gain_sign)

        if(ref_gain_sign > 0),
            
            ref_h_lower = ref_alpha - E/2;
            ref_h_higher = ref_alpha + ref_beta + (1/(2*gain_magnitude))*log((1/r_0) - 1);
        else
            
            ref_h_lower = ref_alpha + ref_beta + (1/(-2*gain_magnitude))*log((1/r_0) - 1);
            ref_h_higher = ref_alpha + E/2;
        end
        
        
        if(gain_sign > 0),
            
            h_lower = ret_prefs - E/2;
            h_higher = ret_prefs + eye_prefs + (1/(2*gain_magnitude))*log((1/r_0) - 1);
        else

            h_lower = ret_prefs + eye_prefs + (1/(-2*gain_magnitude))*log((1/r_0) - 1);
            h_higher = ret_prefs + E/2;            
        end

        overlap = min(ref_h_higher,h_higher) - max(ref_h_lower,h_lower);         % Compute overlap
        overlap(overlap < 0) = 0;
    end

end


    
function overlapfigure_peaked_region()

    r_0 = 0.5;
    E = 60;
    R = 200;

    e_prefs = -E/2:1:E/2;
    r_prefs = R/2:-1:-R/2;
    [eye_prefs ret_prefs] = meshgrid(e_prefs,r_prefs);
    
    % Reference neuron
    sigma = 6.0;

        
    % Reference neuron
    ref_upper = 20;
    ref_lower = -20;

    % Compute overlap    
    h_lower = ret_prefs + eye_prefs - 2*sigma*sqrt(log(1/r_0));
    h_higher = ret_prefs + eye_prefs + 2*sigma*sqrt(log(1/r_0));
    
    overlap = min(ref_upper,h_higher) - max(ref_lower,h_lower);         % Compute overlap
    overlap(overlap < 0) = 0;
    
    % Figure
    figure;
    imagesc(overlap);
    hold on;
    colorbar;
    %caxis([0 20]);
    
    % positive gain
    plot([1 (E+1)],[(R/2 + (ref_upper-E/2))  (R/2 + (ref_upper+E/2))],'--m','LineWidth',2); % upper constraint
    plot([1 (E+1)],[(R/2 + (ref_lower-E/2))  (R/2 + (ref_lower+E/2))],'--m','LineWidth',2); % lower constraint
    
    dim = fliplr(size(overlap));
    pbaspect([dim 1]);
    [height,width] = size(overlap);
    

        %% Make pretty 
            hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
            hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}
          
            % Fix axes ticks
            
            wTicks = 1:width;
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

end

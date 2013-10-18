    
function overlapfigure_peaked()

    r_0 = 0.5;
    E = 60;
    R = 200;

    e_prefs = -E/2:1:E/2;
    r_prefs = R/2:-1:-R/2;
    [eye_prefs ret_prefs] = meshgrid(e_prefs,r_prefs);
    
    % Reference neuron
    sigma = 6.0;
    ref_alpha = 0;
    ref_beta = E/2; % -E/2, -E/4 , 0 ,  E/4,  E/2

    % Compute overlap
    ref_h_lower = ref_alpha + ref_beta - 2*sigma*sqrt(log(1/r_0));
    ref_h_higher = ref_alpha + ref_beta + 2*sigma*sqrt(log(1/r_0));
    
    h_lower = ret_prefs + eye_prefs - 2*sigma*sqrt(log(1/r_0));
    h_higher = ret_prefs + eye_prefs + 2*sigma*sqrt(log(1/r_0));
    
    overlap = min(ref_h_higher,h_higher) - max(ref_h_lower,h_lower);         % Compute overlap
    overlap(overlap < 0) = 0;
    
    % Figure
    figure;
    imagesc(overlap);
    hold on;
    colorbar;
    caxis([0 20]);
    
    % add cell identifier
    x = 1 + (E/2 + ref_beta);
    y = 1 + R/2 - ref_alpha;
    %plot([1 2*E],[y y],'-y','LineWidth',2); % horizontal line
    %plot([x x],[1 R],'-y','LineWidth',2); % horizontal line
    plot(x,y,'+w','LineWidth',2,'MarkerSize',10);
    
    dim = fliplr(size(overlap));
    pbaspect([dim 1]);
    [height,width] = size(overlap);
    

        %% Make pretty 
        
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

end

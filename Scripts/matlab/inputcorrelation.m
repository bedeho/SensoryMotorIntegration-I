
dr = 1.0;
de = 1.0;

R = fliplr(-100:dr:100);
E = -30:de:30;

visualPreferences = fliplr(-100:1:100);
eyePositionPreferences = -30:1:30;

% input encoding
sigma = 6;
slope_magnitude = 0.0625;

% reference input neuron
e_ref=0;
r_ref=0;
g_ref=1;

% Computing utilities
[E_mesh,R_mesh] = meshgrid(E, R);
area = (E(end) - E(1))*(R(1)-R(end));

% Allocate space for covariance map
map_peak    = zeros(length(R),length(E));
map_posgain = zeros(length(R),length(E));
map_neggain = zeros(length(R),length(E));

%% Evaluate maps

% Compute reference response function
ref_response_peak   = exp(-(R_mesh - r_ref).^2/(2*sigma^2)) .* exp(-(E_mesh - e_ref).^2/(2*sigma^2));
ref_response_planar = exp(-(R_mesh - r_ref).^2/(2*sigma^2)) .* 1./(1 + exp(g_ref * slope_magnitude * (E_mesh - e_ref)));

% Find average response of any response function over area
ref_average_peak   = (de*trapz(dr*trapz(ref_response_peak))/area);
ref_average_planar = (de*trapz(dr*trapz(ref_response_planar))/area);

for i=1:length(R),
    
    % GEt retinal location
    r = R(i) % R
    
    for j=1:length(E),
        
        % Get eye position
        e = E(j);
        
        % Shifted responses
        shifted_peak = exp(-(R_mesh - r).^2/(2*sigma^2)) .* exp(-(E_mesh - e).^2/(2*sigma^2));
        shifted_posgain = exp(-(R_mesh - r).^2/(2*sigma^2)) .* 1./(1 + exp(+1 * slope_magnitude * (E_mesh - e)));
        shifted_neggain = exp(-(R_mesh - r).^2/(2*sigma^2)) .* 1./(1 + exp(-1 * slope_magnitude * (E_mesh - e)));

        % Find average response of this shifted responses: EDGE EFFECT
        % REQUIRES THIS TO BE RECOMPUTED
        shifted_peak_average = (de*trapz(dr*trapz(shifted_peak))/area);
        shifted_posgain_average = (de*trapz(dr*trapz(shifted_posgain))/area);
        shifted_neggain_average = (de*trapz(dr*trapz(shifted_neggain))/area);
        
        % Compute covariate integral
        covariate_peak = (ref_response_peak - ref_average_peak).*(shifted_peak - shifted_peak_average);
        covariate_posgain = (ref_response_planar - ref_average_planar).*(shifted_posgain - shifted_posgain_average);
        covariate_neggain = (ref_response_planar - ref_average_planar).*(shifted_neggain - shifted_neggain_average);
        
        % Do double integral with trapezoid method
        map_peak(i,j) = de*trapz(dr*trapz(covariate_peak));
        map_posgain(i,j) = de*trapz(dr*trapz(covariate_posgain));
        map_neggain(i,j) = de*trapz(dr*trapz(covariate_neggain));
        
    end
end


%% Mape figure

% PEAKED 
%{
figure;

imagesc(map_peak);
colorbar

    % pretty up
    dim = fliplr(size(map));
    pbaspect([dim 1]);
    %colorbar;

    [height,width] = size(map);
    xlim([1 width]);
    ylim([1 height]);

    hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
    hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}

    % Fix axes ticks
    wTicks = 1:width;
    wdist = 15;
    wTicks = wTicks(1:wdist:end);
    wLabels = eyePositionPreferences(1:wdist:end);
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
    hLabels = visualPreferences(1:hdist:end);
    hCellLabels = cell(1,length(hLabels));
    for l=1:length(hLabels),
      hCellLabels{l} = [num2str(hLabels(l))];
    end

    set(gca,'YTick',hTicks);
    set(gca,'YTickLabel',hCellLabels);

    % Change font size
    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
                                                
 %}

% SIGMOIDAL

figure;

        totalweightBox = [map_posgain map_neggain];
        [height,width] = size(totalweightBox);

        imagesc(totalweightBox);
        colorbar

        dim = fliplr(size(totalweightBox));
        pbaspect([dim 1]);
        colorbar;
        
        % Add marker line
        hold on;
        plot([width/2 width/2],[height 1],'--w','LineWidth',1);
        
        %hTitle = title(''); %; title(['Afferent synaptic weights of cell #' num2str(cellNr) extraTitle]);
        hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
        hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}

        % Fix axes ticks
        wTicks = 1:(width/2);
        wdist = 15;
        wTicks = wTicks(1:wdist:end);
        wLabels = eyePositionPreferences(1:wdist:end);
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
        hLabels = visualPreferences(1:hdist:end);
        hCellLabels = cell(1,length(hLabels));
        for l=1:length(hLabels),
          hCellLabels{l} = [num2str(hLabels(l)) ];
        end

        set(gca,'YTick',hTicks);
        set(gca,'YTickLabel',hCellLabels);

        % Change font size
        set([hYLabel hXLabel], 'FontSize', 16);
        set(gca, 'FontSize', 14);



                                                
                                                
                                                
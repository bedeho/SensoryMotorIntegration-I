
function prewiredModel(filename)

    % Open file
    fileID = fopen(filename);
    
    % Init variables
    dimensions = OneD_DG_Dimensions();
    
    numRegions = 2;
    targets = dimensions.targets;
    numTargets = length(targets);

    % Write number of regions
    fwrite(fileID, numRegions, 'uint16');
    
    % Write 7a dimensions, dummy info really
    fwrite(fileID, [1 1 1], 'uint16');
    
    % Layer 1
    verticalDimension = 30;
    horizontalDimension = 30;
    depth = 1;
    fanInCount = x;
    
    % Write LIP dimensions, dummy info really
    fwrite(fileID, [verticalDimension horizontalDimension depth], 'uint16');
    
    % Write neuron spesific specs
    for row=1:horizontalDimension,
        for col=1:verticalDimension,
            
            % Pick target
            target = targets(randi(numTargets,1,1));
            
            % Setup neuron variables
            numberOfAfferentSynapses = 0;
            synapses()...
            
            % Connect
            for d=1:2,
                for eye=dimensions.nrOfEyePositionPrefrerence,
                    for ret=1:dimensions.nrOfVisualPreferences,
                        if suitable_connection,
                            add presynaptic side to afferent synapse vector
                            numberOfAfferentSynapses = numberOfAfferentSynapses + 1;
                        end
                    end
                end
            end
            
            % Write
            
        end
    end
    
end


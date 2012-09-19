
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
    
    % Allocate space to keep network,
    % online generation is not possible since there is a header,
    % numberOfAFferentSynapses varies across neurons
    synapseBuffer = cell(verticalDimension,horizontalDimension);
    
    % Write neuron spesific specs
    for col=1:verticalDimension,
        for row=1:horizontalDimension,
            
            % Pick target
            target = targets(randi(numTargets,1,1));
            
            % Setup neuron variables
            numberOfAfferentSynapses = 0;
            
            % Connect
            for d=1:2,
                for eye=dimensions.nrOfEyePositionPrefrerence,
                    for ret=1:dimensions.nrOfVisualPreferences,
                        if suitable_connection,
                            add presynaptic side to afferent synapse vector
                            numberOfAfferentSynapses = numberOfAfferentSynapses + 1;
                            weight = 
                        end
                    end
                end
            end
            
            % Normalize weight vector
            synapses(5,:) = synapses(5,:)/norm(synapses(5,:));
            
            % Save synapses
            synapseBuffer(col,row) = synapses;
            
            % Write out for header
            fwrite(fileID, numberOfAfferentSynapses, 'uint16');
        end
    end
    
    % Write out actual network
    for col=1:verticalDimension,
        for row=1:horizontalDimension,
            
            % Get synapses
            synapses = synapseBuffer(col,row);
            
            % Iterate afferent synapses and dump
            for s=1:length(synapses),
                
               % Write synaps
               fwrite(fileID, numberOfAfferentSynapses, 'uint16'); 
            end
        end
    end
    
    fclose(fileID);

end


/*
 *  Synapse.h
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#ifndef SYNAPSE_H
#define SYNAPSE_H

// Forward declarations
class Neuron;
class HiddenNeuron;

// Includes
#include <vector>

using std::vector;

class Synapse {
    
    public:
		float weight;
        
		const Neuron * preSynapticNeuron;     // Presynaptic neuron syanpse to our target
		const HiddenNeuron * postSynapticNeuron;  // This pointer is used when we have forward firing computation routine
		
		// Preallocate the required amount of space to save the history of the network
        //vector<float> weightHistory;
        float * weightHistory;
        
        Synapse(float weight, const Neuron * preSynapticNeuron, const HiddenNeuron * postSynapticNeuron, float * weightHistory);//, int fixedBufferWeightHistorySize);
		~Synapse();
        
        // blockage dynamics
        float blockage;
    
        /*
        int fixedBufferWeightHistorySize;
        int lastBufferElement;
        float * fixedBufferWeightHistory;
        float getLast();
        void savePresent();
        */
        void resetBlockage();
        
};

#endif // SYNAPSE_H

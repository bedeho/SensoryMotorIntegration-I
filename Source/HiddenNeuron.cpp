/*
 *  HiddenNeuron.cpp
 *  SMI
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "HiddenNeuron.h"
#include "Param.h"
#include "Synapse.h"
#include "Region.h"
#include "HiddenRegion.h"
#include "InputRegion.h"
#include "InputNeuron.h"
#include "BinaryWrite.h"
#include <iostream>

using std::cout;
using std::endl;
using std::cerr;

void HiddenNeuron::init(HiddenRegion * region,
                        u_short depth, 
                        u_short row, 
                        u_short col, 
                        float * activationHistory, 
                        float * inhibitedActivationHistory, 
                        float * firingRateHistory, 
                        float * traceHistory, 
                        float * stimulationHistory, 
                        bool saveNeuronHistory, 
                        bool saveSynapseHistory, 
                        u_short desiredFanIn) {

    
	// Call base constructor
    Neuron::init(region, depth, row, col);
	
	// Set vars
    this->neuronHistoryCounter = 0;
    this->synapseHistoryCounter = 0;
	this->saveNeuronHistory = saveNeuronHistory;
	this->saveSynapseHistory = saveSynapseHistory;
    this->desiredFanIn = desiredFanIn;
    
    // Setup buffer pointers
    this->activationHistory = activationHistory;
    this->inhibitedActivationHistory = inhibitedActivationHistory;
    this->firingRateHistory = firingRateHistory;
    this->traceHistory = traceHistory;
    this->stimulationHistory = stimulationHistory;
    
    // Reserve, so only capacity changes, not size
    this->afferentSynapses.reserve(desiredFanIn);
    
	// Initialize all state variables to zero
	clearState(true);
}

HiddenNeuron::~HiddenNeuron() {
    afferentSynapses.clear();
}

void HiddenNeuron::addAfferentSynapse(const Neuron * preSynapticNeuron, float weight) {
    
    // Ask region for history buffer
    float * buffer = saveSynapseHistory ? (static_cast<HiddenRegion *>(region))->getSynapseHistorySlot() : NULL;
    
    // Add synapse to synapse lisr
    afferentSynapses.push_back(Synapse(weight, preSynapticNeuron, this, buffer)); // historyLength
}

void HiddenNeuron::setupAfferentSynapses(Region & preSynapticRegion, CONNECTIVITY connectivity, INITIALWEIGHT initialWeight, gsl_rng * rngController) {
    
    if(connectivity == FULL) {
        
        for(int d = 0;d < preSynapticRegion.depth;d++)
            for(int i = 0;i < preSynapticRegion.verDimension;i++)
                for(int j = 0;j < preSynapticRegion.horDimension;j++) {
                    
                    float weight = initialWeight != ZERO ? static_cast<float>(gsl_rng_uniform(rngController)) : 0;
                    addAfferentSynapse(preSynapticRegion.getNeuron(d, i, j), weight);
                }
        
    } else if (connectivity == SPARSE) {
        
        for(int d = 0;d < preSynapticRegion.depth;d++) {
            
            u_short connectionsMade = 0;

            while(connectionsMade < desiredFanIn) {
                
                // Sample location
                unsigned long int rowSource = gsl_rng_uniform_int(rngController, preSynapticRegion.verDimension);
                unsigned long int colSource = gsl_rng_uniform_int(rngController, preSynapticRegion.horDimension);
                
                // Grab neuron
                Neuron * preSynapticNeuron = preSynapticRegion.getNeuron(d, rowSource, colSource);
                
                // Make sure we don't reconnect
                if(!areYouConnectedTo(preSynapticNeuron)) {
                    
                    float weight = initialWeight != ZERO ? static_cast<float>(gsl_rng_uniform(rngController)) : 0;
                    addAfferentSynapse(preSynapticNeuron, weight);
                    
                    connectionsMade++;
                }
            }
        }
    } /*else if (connectivity == SPARSE_BIASED) {
        
        u_short connectionsMade = 0;
        
        // Sample row
        int rowSource = gsl_rng_uniform_int(rngController, preSynapticRegion.verDimension);
        // In the future just set int rowSourcMean to something, and use it to set int rowSource = Gauss(rowSourcMean) inside loop

        while(connectionsMade < desiredFanIn) {
            
            // Sample location
            int colSource = gsl_rng_uniform_int(rngController, preSynapticRegion.horDimension);
            
            for(int d = 0;d < preSynapticRegion.depth;d++) {
                
                // Grab neuron
                Neuron * preSynapticNeuron = preSynapticRegion.getNeuron(d, rowSource, colSource);
                
                
                // Make sure we don't reconnect - NOT NECASsARY necessary
                //if(areYouConnectedTo(preSynapticNeuron)) {
                //    
                //    cerr << "Tried to reconnect, failure!" << endl;
                //    isTraining(isTraining_FAILURE);
                //}
                //
                
                float weight = initialWeight != ZERO ? static_cast<float>(gsl_rng_uniform(rngController)) : 0;
                addAfferentSynapse(preSynapticNeuron, weight);
                
                connectionsMade++;
            }
        }
    }*/

}

bool HiddenNeuron::areYouConnectedTo(const Neuron * n) {
    
    for(u_short s = 0;s < afferentSynapses.size();s++)
        if(afferentSynapses[s].preSynapticNeuron == n)
            return true;
    
    return false;
}

void HiddenNeuron::output(BinaryWrite & file, DATA data) {
    
    if(data <= STIMULATION) {
        
        const float * buffer;
        
        if(data == FIRING_RATE)
            buffer = firingRateHistory;
        else if(data == ACTIVATION)
            buffer = activationHistory;
        else if(data == INHIBITED_ACTIVATION)
            buffer = inhibitedActivationHistory;
        else if(data == TRACE)
            buffer = traceHistory;
        else if(data == STIMULATION)
            buffer = stimulationHistory;
        
        // Dump buffer content to file
        output(file, buffer);
        
    } else if(data == FAN_IN_COUNT)
        file << static_cast<u_short>(afferentSynapses.size());
    else { // WEIGHTS_FINAL, WEIGHT_HISTORY, WEIGHT_AND_NEURON_HISTORY
        
        // Iterate afferent synapses
        for(int s = 0;s < afferentSynapses.size();s++) {
            
            const Neuron * n = afferentSynapses[s].preSynapticNeuron;
            
            // Output synapse
            file << n->region->regionNr << n->depth << n->row << n->col;
            
            if(data == WEIGHTS_FINAL)
                file << afferentSynapses[s].weight;
            else { // WEIGHT_HISTORY, WEIGHT_AND_NEURON_HISTORY
                
                // Fan in of this neuron
                file << static_cast<u_short>(afferentSynapses.size());
                
                // Output weight history - WEIGHT_HISTORY
                for(int t = 0;t < synapseHistoryCounter;t++)
                    file << afferentSynapses[s].weightHistory[t];
                
                // Output neurnal values as well
                if(data == WEIGHT_AND_NEURON_HISTORY) {
                    output(file, firingRateHistory);
                    output(file, activationHistory);
                    output(file, inhibitedActivationHistory);
                    output(file, traceHistory);
                    output(file, stimulationHistory);
                }
            }
        }
    }
}

void HiddenNeuron::output(BinaryWrite & file, const float * buffer) {
    
    for(int t = 0;t < synapseHistoryCounter;t++)
        file << buffer[t];
}
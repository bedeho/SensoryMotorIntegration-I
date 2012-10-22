/*
 *  HiddenNeuron.h
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#ifndef HIDDENNEURON_H
#define HIDDENNEURON_H

// Forward declarations
class Param;
class Region;
class HiddenRegion;
class InputRegion;
class BinaryWrite;

// Includes
#include "Neuron.h"
#include "Synapse.h"
#include "Param.h"
#include <vector>
#include <gsl/gsl_randist.h>
#include <cfloat>
#include "Utilities.h"

using std::vector;

class HiddenNeuron: public Neuron {
	
	private:
        
        u_short desiredFanIn;
    
        // History saving
        unsigned long neuronHistoryCounter;
        unsigned long synapseHistoryCounter;
		bool saveNeuronHistory;
		
        // History buffers
        float * activationHistory;
        float * inhibitedActivationHistory;
        float * firingRateHistory;
        float * traceHistory;
        float * stimulationHistory;
        float * effectiveTraceHistory;
    
        void output(BinaryWrite & file, const float * buffer);
    
    public:
    
    
        // temporarily moved
        bool saveSynapseHistory;
        
        // Data structures
        vector<Synapse> afferentSynapses;
        
        // Neuron State
        float activation;             // Normal weighted sum of input firing rates
        float inhibitedActivation;    // Activation after being passed through inhibit routine
        float trace;                  // Defines trace values for this neuron
        
        float effectiveTrace;		  // sigmoid(trace);
        float newActivation;
        float newInhibitedActivation;
        float newTrace;
    
        // inspection purposes
        float stimulation;            // Presynaptic stimulation, only used for inspection purposes.
        //float inhibition;               // total inhibition from neighboors

		// Init
		void init(HiddenRegion * region, 
                  u_short depth, 
                  u_short row, 
                  u_short col, 
                  float * const activationHistory, 
                  float * const inhibitedActivationHistory, 
                  float * const firingRateHistory, 
                  float * const traceHistory,
                  float * const stimulationHistory,
                  float * const effectiveTraceHistory,
                  bool saveNeuronHistory, 
                  bool saveSynapseHistory,
                  u_short desiredFanIn);
        
        // Destructor
        ~HiddenNeuron();
        
        void doTimeStep(bool save);
        void saveState();
        void clearState(bool resetTrace); // Does not clear history vectors, just state vars
		
        // Output data
        void output(BinaryWrite & file, DATA data);
        
		// Setup network
        void setupAfferentSynapses(Region & preSynapticRegion, CONNECTIVITY connectivity, INITIALWEIGHT initialWeight, gsl_rng * rngController);    
        void samplePresynapticLocation(u_short preSynapticRegionDimension, u_short radius, gsl_rng * rngController, int & xSource, int & ySource);
        void addAfferentSynapse(const Neuron * preSynapticNeuron, float weight);
                                       
        // Synapse utils used when setting up connections
        bool areYouConnectedTo(const Neuron * n);
		void normalize();
		void normalize(float norm);
};

/*
*
* Are placed here because of inlining:
* Read note on: [9.6] How do you tell the compiler to make a non-member function inline?
* http://www.parashift.com/c++-faq-lite/inline-functions.html#faq-9.9
*
*/

#include <cfloat>
#include <cmath>

//////////////////// DEBUG
#include <math.h>
#include <iostream.h>

inline void HiddenNeuron::clearState(bool resetTrace) {
	
	firingRate = 0;
	newFiringRate = 0;
	activation = 0;
    newActivation = 0;             
	inhibitedActivation = 0;
    newInhibitedActivation = 0;
    stimulation = 0;
	
	if(resetTrace) {
		trace = 0; 
		newTrace = 0;

		effectiveTrace = 0;
	}
}

// Housekeeping - switches old and new variables, and saves
// neuron states if saveState == true.
inline void HiddenNeuron::doTimeStep(bool save) {
    
	activation = newActivation;
	newActivation = FLT_MIN;
	
	inhibitedActivation = newInhibitedActivation;
	newInhibitedActivation = FLT_MIN;
	
	firingRate = newFiringRate;
	newFiringRate = FLT_MIN;
	
	trace = newTrace;
	// n->newTrace MUST NOT BE RESET TO 0 since it is not always
	// recomputed on every time step (when p.trainAtTimeStepMultiple > 1 in discrete neurons),
    // which results that all learning is cancelled!
	
	if(save)
		saveState();
}

inline void HiddenNeuron::saveState() {
    
    if(saveNeuronHistory) {
        
        activationHistory[neuronHistoryCounter] = activation;
        inhibitedActivationHistory[neuronHistoryCounter] = inhibitedActivation;
        firingRateHistory[neuronHistoryCounter] = firingRate;
        traceHistory[neuronHistoryCounter] = trace;
        stimulationHistory[neuronHistoryCounter] = stimulation;
        effectiveTraceHistory[neuronHistoryCounter] = effectiveTrace;
        neuronHistoryCounter++;
    }
    
    if(saveSynapseHistory) {
        
        for(u_short s = 0;s < afferentSynapses.size();s++)
            afferentSynapses[s].weightHistory[synapseHistoryCounter] = afferentSynapses[s].weight;
        
        synapseHistoryCounter++;
    }
}

inline void HiddenNeuron::normalize() {
	
	float norm = 0;
	
	for(u_short s = 0;s < afferentSynapses.size();s++)
		norm += afferentSynapses[s].weight * afferentSynapses[s].weight;
	
	normalize(norm);
}

// The reason we have this odd subroutine is because
// this is directly called during learning where norm
// is computed along with the weight update.
inline void HiddenNeuron::normalize(float norm) {
	
	norm = static_cast<float>(sqrt(norm));
	for(u_short s = 0;s < afferentSynapses.size();s++)
		afferentSynapses[s].weight /= norm;
}


#endif // HIDDENNEURON_H

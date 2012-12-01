/*
 *  HiddenRegion.h
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#ifndef HIDDENREGION_H
#define HIDDENREGION_H

// Forward declarations
// class Param; forward declaration is not succicient since we need Param enums.
class BinaryWrite;

// Includes
#include "Region.h"
#include "HiddenNeuron.h"
#include "Param.h"
#include <vector>
#include <queue>
#include <functional>
#include <gsl/gsl_cdf.h>
#include <gsl/gsl_randist.h>
#include "Utilities.h"

using std::vector;
using std::priority_queue;
using std::greater;
  
class HiddenRegion : public Region { 
    
    public:

        // Neurons[depth][rows][col]
        vector<vector<vector<HiddenNeuron> > > Neurons;
    
        // Buffers
        // These are all kept here, instead on in HiddenNeuron
        // to avoid memory fragmentation. Perfect respect of 
        // would put the first five in HiddenNeuron class, and
        // the last five in Synapse class.
        vector<float> activationBuffer;
        vector<float> inhibitedActivationHistoryBuffer;
        vector<float> firingRateBuffer;
        vector<float> traceBuffer;
        vector<float> stimulationBuffer;
        vector<float> synapseHistoryBuffer;
        vector<float> effectiveTraceBuffer;

		// Init - instead of ctor
        void init(u_short regionNr, Param & p, bool isTraining, unsigned long int outputtedTimeStepsPerEpoch, u_short samplingRate, u_short desiredFanIn);

        // Destructor
        ~HiddenRegion();
    
    	// Computes new firing rate by computing activation and doing competition
    	void computeNewFiringRate();
    
        // Update weights of afferent synapses
        void applyLearningRule();
    	
    	// Housekeeping - calls same routine on neurons
    	void doTimeStep(bool saveState);
    	
    	// Build
    	void setupAfferentSynapses(Region & region, 
                                   WEIGHTNORMALIZATION weightNormalization, 
                                   CONNECTIVITY connectivity, 
                                   INITIALWEIGHT initialWeight,
                                   gsl_rng * rngController);

    	// Output routines	
        void outputRegion(BinaryWrite & sparsityPercentileValueFile);
        void outputNeurons(BinaryWrite & file, DATA data);
        void outputSingleCells(BinaryWrite & file);
    
		void resetTrace();
		void clearState(bool resetTrace);
		
		//HiddenNeuron * getHiddenNeuron(u_short depth, u_short row, u_short col);
		Neuron * getNeuron(u_short depth, u_short row, u_short col);
    
        // Synapse history buffer
        float * getSynapseHistorySlot();
		
    private:

        // Track region level variables
        u_short percentileSize;
        float threshold;
		vector<float> sparsityPercentileValue;
        unsigned long long int regionHistoryCounter;
    
        // Indicates what cells to single cell record
        // should really be bool, but STL is fucked up!
        vector<vector<short> > recordedSingleCells; 
	
        // Filters
        vector<vector<float> > inhibitoryFilter;
		vector<vector<float> > somFilter;
       
        // Find better solution later, this is not that nice
		// Param + copied out of actual param for speed and not having to projecting components all the time
		u_short filterWidth;							// duplicate of p.filterWidth[regionNr-1]
		float inhibitoryRadius;						    // duplicate of p.inhibitoryRadius[regionNr-1]
		float inhibitoryContrast;						// duplicate of p.inhibitoryContrast[regionNr-1]
		float somExcitatoryRadius;						// duplicate of p.somExcitatoryRadius[regionNr-1]
		float somExcitatoryContrast;					// duplicate of p.somExcitatoryContrast[regionNr-1]
		float somInhibitoryRadius;						// duplicate of p.somInhibitoryRadius[regionNr-1]
		float somInhibitoryContrast;					// duplicate of p.somInhibitoryContrast[regionNr-1]	
		float sparsenessLevel;							// duplicate of p.sparsities[regionNr-1]
		float sigmoidSlope;							    // duplicate of p.sigmoidSlopes[regionNr-1]
        float sigmoidThreshold;                         // duplicate of p.sigmoidSlopes[regionNr-1]
		float learningRate;							    // duplicate of p.learningRates[regionNr-1]
		float eta;										// duplicate of p.etas[regionNr-1]
		float timeConstant;								// duplicate of p.timeConstants[regionNr-1]
        float covarianceThreshold;
		double stepSize;
		float traceTimeConstant;
        float globalInhibitoryConstant;
        float externalStimulation;
    
        //TRANSFER_FUNCTION transferFunction;
		SPARSENESSROUTINE sparsenessRoutine;
		LEARNING_RULE rule;
		WEIGHTNORMALIZATION weightNormalization;
		LATERAL lateralInteraction;
        SAVEHISTORY saveHistory;
	
        // SetSparse
        float findThreshold();                          // finds actual percentile value based on sparisity parameter
        
        // Lateral Interaction
		u_short filterCenter;
		void setupFilters();
		void filter();
		void computeNewActivation();					// classic weighted sum of presynaptic firingrates
        u_short wrap(int x, u_short d);
        
        // Synapse history pointer
        unsigned long long int synapseHistoryCounter;
        unsigned long long int singleSynapseBufferSize;
};


inline u_short HiddenRegion::wrap(int x, u_short d) {
    
	// One cannot trust result of (x % b) with negative
	// input x for various compilers:
	// http://www.learncpp.com/cpp-tutorial/32-arithmetic-operators/
	// Hence we take abs(x) first
    
	if(x > 0)
		return x % d;
	else if((-x) % d == 0)
		return 0;
	else
		return d - ((-x) % d);
}

#endif // HIDDENREGION_H

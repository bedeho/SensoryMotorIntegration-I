/*
 *  Network.h
 *  SMI
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#ifndef NETWORK_H
#define NETWORK_H

#ifndef DEBUG
//#define OMP_ENABLE
#endif

// Forward declarations
class HiddenNeuron;
class BinaryWrite;
class HiddenRegion;
class InputRegion;

// Includes
#include "InputRegion.h"
#include "Param.h"
#include <vector>
#include "Utilities.h"

using std::vector;

class Network {
    
    private:
    
        // Output FILE types
        enum OUTPUT_FILE {  
            OF_REGIONAL = 0, // 
            OF_REGION_NEURONAL = 1, // 
            OF_REGION_SYNAPTIC = 2, // 
            OF_SINGLE_CELLS = 3 // 
        };
        
        // Outputing
        void outputHistory(const char * outputDirectory, bool isTraining);
        void openHistoryFile(BinaryWrite & file, const char * outputDirectory, const char * filename, bool isTraining, OUTPUT_FILE fileType);
        void outputRegionHistory(const char * outputDirectory, bool isTraining);
        void outputNeuronHistoryData(const char * outputDirectory, bool isTraining, DATA data);
        void outputSingleUnits(const char * outputDirectory);
        void outputSynapticHistory(const char * outputDirectory);
    
        // Utility functions
        void buildESPathway();
        void setupAfferentSynapsesV2();
		void setupAfferentSynapsesForV3AndAbove(u_short esPathwayIndex);
		void normalize(HiddenNeuron * n);

		bool verbose;
		Param p;
	
    public:
    	vector<HiddenRegion> ESPathway;
    	InputRegion area7a;
    	
		// Build new network based on these parameters
		Network(const char * parameterFile, bool verbose);
	
    	// Load network from weight file
    	Network(const char * dataFile, const char * parameterFile, bool verbose, const char * inputWeightFile, bool isTraining);
    	    	
    	// Destructor, frees ESPathway and rngController
    	~Network();
    	
    	// Run based on parameter file supplied in constructor, argument is file list
		// isTraining = true means that we apply learning rule in param file and run the number of epochs in the param file
		// isTraining = false means that we have no learning and only run ONE epoch
    	void run(const char * outputDirectory, bool isTraining, int numberOfThreads, bool xgrid);
		u_short runDiscrete(const char * outputDirectory, bool isTraining, bool xgrid);
		u_short runContinous(const char * outputDirectory, bool isTraining, bool xgrid);
	
    	// Save final weights of network
        void outputFinalNetwork(const char * outputWeightFile);
};

#endif // NETWORK_H

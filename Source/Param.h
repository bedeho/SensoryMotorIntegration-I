/*
 *  Param.h
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#ifndef PARAM_H
#define PARAM_H

#include <vector>
#include "Utilities.h"

using std::vector;

// Read parameter file for full explanation
enum FEEDBACK {   
    
    NOFEEDBACK = 0,           
    SYMMETRIC = 1
};

enum LEARNING_RULE { 
    
    TRACE_RULE = 0,
    HEBB_RULE = 1,
    COVARIANCE_PRESYNAPTIC_TRACE_RULE = 2
};

enum SPARSENESSROUTINE   {  
    
    NOSPARSENESS = 0,
    HEAP = 1,
    GLOBAL = 2 
};

enum WEIGHTNORMALIZATION {  
    
    NONORMALIZATION = 0,
    CLASSIC = 1 
};

enum INPUT_ENCODING {
    
    MIXED = 1,
    DOUBLEPEAK_GAUSSIAN = 2,
    DECOUPLED = 3 
};

enum INITIALWEIGHT {
    
    ZERO = 0,                 
    RANDOMEQUAL = 1,                        
    RANDOMINDEPENDENT = 2 
};

enum LATERAL {
    
    NONE = 0,
    SHORT_INHIBITION_LONG_EXCITATION = 1,
    SHORT_EXCITATION_LONG_INHIBITION = 2
};

enum CONNECTIVITY {
    
    FULL = 0,                 
    SPARSE = 1,                             
    SPARSE_BIASED = 2
};

enum SAVEHISTORY {
    
    SH_NONE = 0,          
    SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION = 1,
    SH_ALL_NEURONS_IN_REGION = 2,
    SH_SINGLE_CELLS = 3
};

// In the future, make HiddenRegion/striate param internal classes
// that keep projects of these vectors, and thenmake param_layer class
// that is a flat copy of Param +projection, this is passed to HiddenRegions etc
class Param  {

    public:
		u_short seed;
		u_short nrOfEpochs;
		u_short outputAtTimeStepMultiple;
		u_short saveNetworkAtEpochMultiple;
		float traceTimeConstant;
        float covarianceThreshold;
        float playAtPrcntOfOriginalSpeed;
		bool resetTrace;
		bool resetActivity;
		bool saveNetwork;
    
        float weightVectorLength;

        // Only 7a
        INPUT_ENCODING inputEncoding;
        float visualPreferenceDistance;         
        float eyePositionPrefrerenceDistance;   
        float gaussianSigma;                    
        float sigmoidSlope;                     
        float horVisualFieldSize;
        float horEyePositionFieldSize;
        float sigmoidModulationPercentage;
        
        // Not for 7a		
		vector<float> fanInCountPercentage;    
		vector<float> learningRates;			
		vector<float> timeConstants;		
		vector<float> etas;					   
		vector<float> sparsenessLevels;		 
		vector<float> sigmoidSlopes;
        vector<float> sigmoidThreshold;
        
		vector<float> inhibitoryRadius;		    
		vector<float> inhibitoryContrast;		
        vector<float> somExcitatoryRadius;		
		vector<float> somExcitatoryContrast;	
		vector<float> somInhibitoryRadius;		
		vector<float> somInhibitoryContrast;
    
        vector<float> globalInhibitoryConstant;
        vector<float> externalStimulation;
    
        //vector<float> blockageLeakTime;
        //vector<float> blockageRiseTime;
        //vector<float> blockageTimeWindow;
    
        float blockageLeakTime;
        float blockageRiseTime;
        float blockageTimeWindow;
    
        vector<u_short> depths;
        vector<u_short> dimensions;
		vector<u_short> epochs;
        vector<u_short> filterWidth;
        vector<u_short> nrOfRecordedSingleCells;
        
        vector<CONNECTIVITY> connectivities;
        vector<SAVEHISTORY> saveHistory;
        
        vector<vector<vector<short> > > recordedSingleCells; // Should be bool, but STL is fucked up!
        
		WEIGHTNORMALIZATION weightNormalization;
		SPARSENESSROUTINE sparsenessRoutine;
		FEEDBACK feedback;
		LEARNING_RULE rule;
		INITIALWEIGHT initialWeight;
		LATERAL lateralInteraction;
    
        // Values derived from other parameters
        float stepSize;
        u_short numberOfLayers;
    
        // Indicators of what we need to save
        bool saveAllNeuronsAndSynapsesInRegion;
        bool saveAllNeuronsInRegion;
        bool saveSingleCells;
    
    	// Constructor
    	Param(const char * filename, bool isTraining);

	private:
	
		float stepSizeFraction; // not used by rest of simulator directly, but is in parameter file
        void validate(bool isTraining);
};

#endif // PARAM_H

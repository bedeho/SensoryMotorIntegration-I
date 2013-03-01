/*
 *  InputRegion.h
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#ifndef INPUTREGION_H
#define INPUTREGION_H

// Forward declarations
class Neuron;
class Param;

// Includes
#include "Region.h"
#include "InputNeuron.h"
#include <vector>
#include <string>
#include <gsl/gsl_randist.h>
#include "Utilities.h"

using std::vector;
using std::string;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
class InputRegion : public Region {
	
	private:
		vector<vector<vector<float> > > data; // data[object][sample][0 1 .... numberOfSimultanousObjects]
    
        vector<float> sample;
        vector<u_short> stimuliSamplesInObject;
        vector<double> objectDuration;
        
        // Load file names from file list
        void loadDataFile(const char * dataFile, float stepSize, u_short outputAtTimeStepMultiple);
    
        // Get data by interpolating from loaded data
        void linearInterpolate(u_short object, double time);
    
        // Matlab counter part
        void centerDistance(vector<float> & v, float width, float distance);
        
    public:
    
        ~InputRegion();
    
        // moved so input neurons can see, could have made into friend class, but wasnt bothtered
        vector<float> horVisualPreferences;
        vector<float> horEyePreferences;
    
        // Read from data file
        u_short nrOfObjects;
        
        u_short samplingRate;
        u_short numberOfSimultanousObjects;
        float horVisualFieldSize;
        float horEyePositionFieldSize;
    
        // Derived from data read from file
        u_short horVisualDimension;
        u_short horEyeDimension;
        double interSampleTime;
    
        vector<unsigned long int> timeStepsInObject;
        vector<unsigned long int> outputtedTimeStepsInObject;
        unsigned long int timeStepsPerEpoch;
        unsigned long int outputtedTimeStepsPerEpoch;
        double epochDuration;
        
        // Neurons[depth][rows][col]
        vector<vector<vector<InputNeuron> > > Neurons;
        
		// Init
		void init(Param & p, const char * dataFile, gsl_rng * rngController);

		// Load switch content from buffer
        void setFiringRate(u_short object, double time);
	
        Neuron * getNeuron(u_short depth, u_short row, u_short col);
};

#endif // INPUTREGION_H

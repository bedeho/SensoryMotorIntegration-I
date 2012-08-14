/*
 *  InputRegion.cpp
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "InputRegion.h"
#include "InputNeuron.h" 
#include "Neuron.h"
#include "Param.h"
#include "BinaryRead.h"
#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <cmath>
#include <iomanip>
#include <cstdlib>
#include <cstring>
#include "Utilities.h"

using std::cerr;
using std::cout;
using std::endl;
using std::string;
using std::fstream;
using std::ostringstream;
using std::stringstream;
using std::ifstream;
using std::setw;
using std::left;

// reason we use init and not ctor is for uniformity with hiddenRegion class
void InputRegion::init(Param & p, const char * dataFile, gsl_rng * rngController) {

    // No call to region.init()
    
    // Compute and populate preference vectors
    centerDistance(horVisualPreferences, p.horVisualFieldSize, p.visualPreferenceDistance);
    centerDistance(horEyePreferences, p.horEyePositionFieldSize, p.eyePositionPrefrerenceDistance);
    
    // Set variables
    this->regionNr = 0;
    
    this->depth = 2;
    this->horVisualDimension = horVisualPreferences.size();
    this->horEyeDimension = horEyePreferences.size();
    this->verDimension = this->horVisualDimension;
    this->horDimension = this->horEyeDimension;
    
    this->horVisualFieldSize = p.horVisualFieldSize;
    this->horEyePositionFieldSize = p.horEyePositionFieldSize;
    
    // Load data if it is provided
	if(dataFile != NULL) {
        
        loadDataFile(dataFile);
        
        this->interSampleTime = (float)1/samplingRate;
        this->objectDuration = interSampleTime * samplesPrObject;
        this->continousTimeStepsPrObject = (unsigned)(objectDuration / p.stepSize);
        this->totalDuration = this->objectDuration * nrOfObjects;
    }
    else {
        
        // set variables that otherwise would have been read from file,
        // means they will not be used
        
        this->nrOfObjects = 0;
        this->samplesPrObject = 0;
        this->samplingRate = 0;
        this->numberOfSimultanousObjects = 0;
        this->interSampleTime = 0;
        this->objectDuration = 0;
        this->continousTimeStepsPrObject = 0;
        this->totalDuration = 0;
    }
    
    // Space for sample
    sample.resize(1 + numberOfSimultanousObjects);
    
    /*
    //test
    for(int d = 0; d < data.size();d++)
        for(int s = 0; s < data[d].size();s++)
            cout << "eye " << data[d][s][0] << ", ret:" << data[d][s][1] << endl;
    */
    
    // Allocate neuron space
	vector<vector<vector<InputNeuron> > > tmp1(depth, vector<vector<InputNeuron> >(horVisualDimension, vector<InputNeuron>(horEyeDimension)));
	Neurons = tmp1;
    
	// Initialize neurons
	for(u_short d = 0;d < depth;d++)
        for(u_short i = 0;i < horVisualDimension;i++)
            for(u_short j = 0;j < horEyeDimension;j++) {
                
                float hvisual = horVisualPreferences[(horVisualDimension - 1) - i]; // flip it so that the first row prefers the rightmost visual location
                float heye = horEyePreferences[j];
                float hslope = (d == 0 ? p.sigmoidSlope : -1 * p.sigmoidSlope);
                float hsigma = p.gaussianSigma;
                
                INPUT_EYE_MODULATION modulationType = static_cast<INPUT_EYE_MODULATION>(gsl_ran_bernoulli(rngController, p.sigmoidModulationPercentage));
                
                Neurons[d][i][j].init(this, d, i, j, heye, hslope, hvisual, hsigma, modulationType);
            }
}

InputRegion::~InputRegion() {
    Neurons.clear();
	data.clear();
}

/*
 * MATLAB:
 * function [v] = centerDistance(width, distance)
 *
 * v = -width/2:distance:width/2;
 * v = v - (v(1) + v(end)) / 2; % shift approprite amount in the right direction to center
 */

void InputRegion::centerDistance(vector<float> & v, float width, float distance) {
    
    int length = floor(width/distance);
    
    for(int i = 0;i < length;i++)
        v.push_back(-width/2 + i*distance);
    
    float offset = (v.front() + v.back())/2;
    
    for(int i = 0;i < length;i++)
        v[i] = v[i] - offset;
}

void InputRegion::loadDataFile(const char * dataFile) {
    
    // Initialize som variables we will be working with
	u_short maxSamplesFound = 0;
    this->nrOfObjects = 0;
    this->samplesPrObject = 0;
    
    // Open file
    BinaryRead file(dataFile);
    
    // Variables that must be visible in catch clause
    //u_short lastNrOfSamplesFound = 0; // For validation of file list
    
    bool readAFullSample = false;
    bool readHeader = false;
    
    try {
        
        // Read header
        vector<vector<float> > objectData;
        float e,v;
        
        file >> this->samplingRate;
        file >> this->numberOfSimultanousObjects;
        file >> v;
        file >> e;
        
        readHeader = true;
        
        // Check compatibility of parameter file
        if(v != this->horVisualFieldSize || e != this->horEyePositionFieldSize) {
            
            cerr << "visual field or eye movement field is not the same as in input file:" << v << "!=" << this->horVisualFieldSize << " || " <<  e << " != " << this->horEyePositionFieldSize << endl;
            cerr.flush();
            exit(EXIT_FAILURE);
        }
        
        // Read data points
        while(file >> e) {
            
            // NaN encodes end of "object", like '*' did in VisNet
            if(std::isnan(e)) {
                
                //if(lastNrOfSamplesFound != 0 && lastNrOfSamplesFound != samplesPrObject) {
                //
                //    cerr << "Number of samples varied across objects" << endl;
                //    cerr.flush();
                //    exit(EXIT_FAILURE);
                //}
                
                cout << "Loaded object " << nrOfObjects << endl;
                
                data.push_back(objectData);
                objectData.clear();
                nrOfObjects++;
                
                // Save if this is greater present maximum
                if(maxSamplesFound < samplesPrObject)
                	maxSamplesFound = samplesPrObject;

                //lastNrOfSamplesFound = samplesPrObject;
                samplesPrObject = 0;
                
            } else {
                
                vector<float> sample(1 + numberOfSimultanousObjects);
                
                // Assume we will fail to read sample
                readAFullSample = false;
                
                // Read eye position
                sample[0] = e;
                
                for(int i = 0; i < numberOfSimultanousObjects;i++) {
                    
                    file >> v;
                    sample[i + 1] = v;
                }
                
                objectData.push_back(sample);
                samplesPrObject++;
                readAFullSample = true;
            }        
        
        }
    }
    catch(fstream::failure e) {
        
        if(!readAFullSample){
            
            // Interrupted while reading a sample
            cerr << "Reading of " << dataFile << " interrupted: " << strerror(errno) << endl;
            cerr.flush();
            exit(EXIT_FAILURE);
           
        //} else if (samplesPrObject != 0) {
        //
        //    // Last object had different number of samples
        //    cerr << "Number of samples varied across objects" << endl;
        //    cerr.flush();
        //    exit(EXIT_FAILURE);
        //
            
        } else if (!readHeader){          
            cout << "Was unable to read header of data file." << endl;
            cerr.flush();
            exit(EXIT_FAILURE);
        }
        else { 

            // Success!
            //samplesPrObject = lastNrOfSamplesFound;
            samplesPrObject = maxSamplesFound;
            cout << "Objects: " << nrOfObjects << ", Samples/Object: " << samplesPrObject << endl;
        }
    }
}
/*
// Normalized scheme!
void InputRegion::setFiringRate(u_short object, float time) {
    
    #pragma omp single
    {
    
    // Linear interpolation
    linearInterpolate(object, time);

    float norm = 0; // can really be computed once, but what the heck!!
    
    // Set neurons firing rates
    for(int d = 0;d < depth;d++)
        //CANT BE PARALLELL NO MORE!! #pragma omp for // we moved pragma one step in because SMI model has so small depth
        for(int i = 0;i < horVisualDimension;i++)
            for(int j = 0;j < horEyeDimension;j++) {
                Neurons[d][i][j].setFiringRate(sample);
                norm += Neurons[d][i][j].firingRate * Neurons[d][i][j].firingRate;
            }
                
    norm = sqrt(norm);
    
    // Set neurons firing rates
    for(int d = 0;d < depth;d++)
        //CANT BE PARALLELL NO MORE!! #pragma omp for // we moved pragma one step in because SMI model has so small depth
        for(int i = 0;i < horVisualDimension;i++)
            for(int j = 0;j < horEyeDimension;j++) {
                Neurons[d][i][j].firingRate /= norm;
                Neurons[d][i][j].newFiringRate /= norm;
            }
    }
}
*/

// Classic
void InputRegion::setFiringRate(u_short object, float time) {
    
    #pragma omp single
    {
        // Linear interpolation
        linearInterpolate(object, time);
    }
    
    // Set neurons firing rates
	for(int d = 0;d < depth;d++)
    #pragma omp for // we moved pragma one step in because SMI model has so small depth
		for(int i = 0;i < horVisualDimension;i++)
			for(int j = 0;j < horEyeDimension;j++)
				Neurons[d][i][j].setFiringRate(sample);
}

void InputRegion::linearInterpolate(u_short object, float time) {

    // use <time> to find/interpolate present eye/visual location
    unsigned sampleIndex = (int)floor(time * samplingRate); // (time/interSampleTime) = time * samplingRate
    
    // Test that there is one more data point
    if(!(data[object].size() > sampleIndex)) {
        
        cerr << "Time is outside of recorded data: time=" << time << ", sampleIndex=" << sampleIndex << ", size=" << data[object].size() << endl;
        //cerr.flush();
        //exit(EXIT_FAILURE);
        sampleIndex = data[object].size() - 1; // JUST PUT IN LAST SAMPLE
    }
    
    // Time between 
    float interSampleOverflow = time - sampleIndex * interSampleTime;
    
    //cout << " time = " << setw(8) << left << time;
    //cout << "over = " << setw(5) << left << interSampleOverflow;
    //cout << "index = " << setw(5) << left << sampleIndex << ": ";  
    
    float val;
    
    // Interpolate for each data point in sample
    for(unsigned i = 0;i < sample.size();i++){
        
        if(data[object].size() == sampleIndex + 1) {
            
            // if we are on last sample, just use it, no interpolation possible
            val = data[object][sampleIndex][i];
            
        } else { 
            
            // use linear interpolation otherwise,
            float dy = data[object][sampleIndex + 1][i] - data[object][sampleIndex][i];
            float slope = dy/interSampleTime;
            float intercept = data[object][sampleIndex][i];
            
            val = intercept + slope * interSampleOverflow;
        }
        
        sample[i] = val;
        
        //cout << " " << setw(10) << val;
    }
    
    //cout << endl;
}

Neuron * InputRegion::getNeuron(u_short depth, u_short row, u_short col) {
    return &Neurons[depth][row][col];
}

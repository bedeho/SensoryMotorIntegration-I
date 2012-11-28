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

#include <vector>

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

    //cerr << "horEyePreferences: ";
    //for (unsigned int i = 0; i < horEyePreferences.size(); i++ )
    //    cerr << " " << horEyePreferences[i];

    // Set variables
    this->regionNr = 0;
    this->depth = (p.sigmoidModulationPercentage == 0 ? 1 : 2); // comparison with 0 works, because it is perfectly represented
    //cout << "Depth: " << this->depth << ", P(sig): " << p.sigmoidModulationPercentage << endl;
    this->horVisualDimension = horVisualPreferences.size();
    this->horEyeDimension = horEyePreferences.size();
    this->verDimension = this->horVisualDimension;
    this->horDimension = this->horEyeDimension;
    this->horVisualFieldSize = p.horVisualFieldSize;
    this->horEyePositionFieldSize = p.horEyePositionFieldSize;
    
    // Load data if it is provided
	if(dataFile != NULL)
        loadDataFile(dataFile, p.stepSize, p.outputAtTimeStepMultiple);
    
    // Space for sample
    sample.resize(1 + numberOfSimultanousObjects); // Do not put above loadDataFile
    
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
                
                float hvisual = horVisualPreferences[(horVisualDimension - 1) - i]; // flip it so that the first row prefers the rightmost (largest +) visual location
                float heye = horEyePreferences[j];
                float hslope = (d == 0 ? p.sigmoidSlope : -1 * p.sigmoidSlope);
                float hsigma = p.gaussianSigma;
                
                INPUT_EYE_MODULATION modulationType = static_cast<INPUT_EYE_MODULATION>(gsl_ran_bernoulli(rngController, static_cast<double>(p.sigmoidModulationPercentage)));
                
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
    
    int length = static_cast<int>(floor(width/distance));
    
    for(int i = 0;i <= length;i++) {
    	//cerr << -width/2 + i*distance << " ";
        v.push_back(-width/2 + i*distance);
    }
    
    //cerr << "\n\n";

    float offset = (v.front() + v.back())/2;
    
    //cerr << "offset: " << offset << endl;

    for(int i = 0;i <= length;i++) {
    	//cerr << v[i] - offset << " ";
        v[i] = v[i] - offset;
    }

    //cerr << "\n\n";
}

void InputRegion::loadDataFile(const char * dataFile, float stepSize, u_short outputAtTimeStepMultiple) {
    
    // Open file
    BinaryRead file(dataFile);

    // Initialize som variables we will be working with
    this->nrOfObjects = 0;
    this->outputtedTimeStepsPerEpoch = 0;
    this->timeStepsPerEpoch = 0;
    this->epochDuration = 0;
    
    bool readAFullSample = false;
    bool readHeader = false;
    unsigned long int objectSamples = 0;
    
    try {
        
        // Read header
        vector<vector<float> > objectData;
        float e,v;
        
        file >> this->samplingRate;
        file >> this->numberOfSimultanousObjects;
        file >> v;
        file >> e;
        
        this->interSampleTime = (float)1/samplingRate;
        
        readHeader = true;
    
        // Check compatibility of parameter file
        if(v != this->horVisualFieldSize || e != this->horEyePositionFieldSize) {
            
            cerr << "Visual field or eye movement field is not the same as in input file:" << v << "!=" << this->horVisualFieldSize << " || " <<  e << " != " << this->horEyePositionFieldSize << endl;
            cerr.flush();
            exit(EXIT_FAILURE);
        }
        
        // Read data points
        while(file >> e) {
            
            // NaN encodes end of "object", like '*' did in VisNet
            if(std::isnan(e)) {

                cout << "Loaded object " << nrOfObjects << endl;
                
                // Save sample vector
                data.push_back(objectData);
                
                // Clear sample variable
                objectData.clear();
                
                // Save duration of object
                stimuliSamplesInObject.push_back(objectSamples);
                
                // Save object duration
                double duration = interSampleTime * objectSamples;
                this->objectDuration.push_back(duration);
                
                // Increase epoch duration
                epochDuration += duration;
                
                // Save number of timesteps in object
                unsigned long int timeStepsInObject = (unsigned)(duration / stepSize);
                this->timeStepsInObject.push_back(timeStepsInObject);
                
                // Increase total duration of epoch
                this->timeStepsPerEpoch += timeStepsInObject;
                
                // Save number timesteps in object that will be outputted
                unsigned long int outputtedTimeSteps = timeStepsInObject / outputAtTimeStepMultiple;
                this->outputtedTimeStepsInObject.push_back(outputtedTimeSteps);
                 
                //Increase total number of outputted timestepds
                outputtedTimeStepsPerEpoch += outputtedTimeSteps;
                
                // Increase number of objects
                nrOfObjects++;
                
                // Reset samplecounter
                objectSamples = 0;
                
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
                objectSamples++;
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
            
        } else if (!readHeader){          
            cout << "Was unable to read header of data file." << endl;
            cerr.flush();
            exit(EXIT_FAILURE);
        }
        else { 

            // Success!
            cout << "Objects loaded: " << nrOfObjects << endl;
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

#include <fstream>

// Classic
void InputRegion::setFiringRate(u_short object, double time) {
    
    /*
    #pragma omp single
    {
        // Linear interpolation
        linearInterpolate(object, time);
        
        // OPEN DEBUG FILE
        std::ofstream dump;
        stringstream s;
        s << "/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/InputLayerDump/o-" << object << "_t-" << time;
        string filename = s.str();
        dump.open(filename.c_str());
        
        cerr << " Dumping: " << filename << endl;

        // Set neurons firing rates
        for(int d = 0;d < depth;d++) {
            //#pragma omp for // we moved pragma one step in because SMI model has so small depth
            for(int i = 0;i < horVisualDimension;i++) {
                for(int j = 0;j < horEyeDimension;j++) {
                    Neurons[d][i][j].setFiringRate(sample);
                    dump << Neurons[d][i][j].firingRate << " ";
                }
                
                dump << endl;
            }
        }
        
        // CLOSE DEBUG FILE
        dump.close();
        
    }
     */
    
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

void InputRegion::linearInterpolate(u_short object, double time) {

    // use <time> to find/interpolate present eye/visual location
    unsigned long long sampleIndex = (int)floor(time * samplingRate); 
    
    // Test that there is one more data point
    if(!(data[object].size() > sampleIndex)) {
        
        cerr << "Time is outside of recorded data: time=" << time << ", sampleIndex=" << sampleIndex << ", size=" << data[object].size() << endl;
        cerr.flush();
        exit(EXIT_FAILURE);
        //sampleIndex = data[object].size() - 1; // JUST PUT IN LAST SAMPLE
    }
    
    // Time between 
    double interSampleOverflow = time - sampleIndex * interSampleTime;
    
    //cout << " time = " << setw(8) << left << time;
    //cout << "over = " << setw(5) << left << interSampleOverflow;
    //cout << "index = " << setw(5) << left << sampleIndex << ": ";  
    
    double val;
    
    // Interpolate for each data point in sample
    for(unsigned i = 0;i < sample.size();i++){
        
        if(data[object].size() == sampleIndex + 1) {
            
            // if we are on last sample, just use it, no interpolation possible
            val = data[object][sampleIndex][i];
            
        } else { 
            
            // use linear interpolation otherwise,
            double dy = data[object][sampleIndex + 1][i] - data[object][sampleIndex][i];
            double slope = dy/interSampleTime;
            double intercept = data[object][sampleIndex][i];
            
            val = intercept + slope * interSampleOverflow;
        }
        
        sample[i] = static_cast<float>(val);
        
        //cout << " " << setw(10) << val;
    }
    
    //cout << endl;
}

Neuron * InputRegion::getNeuron(u_short depth, u_short row, u_short col) {
    return &Neurons[depth][row][col];
}

/*
 *  Network.cpp
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "Network.h"
#include "HiddenRegion.h"
#include "HiddenNeuron.h"
#include "InputRegion.h"
#include "BinaryRead.h"
#include "BinaryWrite.h"
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string> 
#include <sstream>
#include <ctime>
#include <cmath>
#include <iomanip>
#include <cerrno>
#include "Utilities.h"

#ifdef OMP_ENABLE
	#include <omp.h>
#endif

#define U_SHORT_1 static_cast<u_short>(1)
#define U_SHORT_0 static_cast<u_short>(0)

using std::cerr;
using std::cout;
using std::cin;
using std::endl;
using std::string;
using std::ofstream;
using std::stringstream;
using std::setw;
using std::left;

// Do not use this constructor if you intend to train later, use the one 
// below, if constructors where named then this amgibuity could have been
// avoided
Network::Network(const char * parameterFile, bool verbose) :
		verbose(verbose),
		p(parameterFile, false),
		ESPathway(p.dimensions.size()) {
            
    // Seed random number generator
    rngController = gsl_rng_alloc(gsl_rng_taus);	// Setup GSL RNG with seed
    gsl_rng_set(rngController, p.seed);

    // Init regions
	area7a.init(p, NULL, rngController);
                                                                    
    for(u_short i = 0;i < ESPathway.size();i++) {
        
        Region & r = (i == 0) ? static_cast<Region&>(area7a) : static_cast<Region&>(ESPathway[i-1]);
        u_short desiredFanIn = r.verDimension * r.horDimension; // 2 * = both signs (((i == 0) ? 2 : 1)
        
        if(p.connectivities[i] == SPARSE)
            desiredFanIn *= p.fanInCountPercentage[i];
        else if(p.connectivities[i] == SPARSE_BIASED)
            desiredFanIn *= (p.fanInCountPercentage[i]/r.verDimension);
        
        cout << "Layer " << i+1 << " desiredFanIn: " << desiredFanIn * r.depth << endl;
        
        ESPathway[i].init(i+1, p, false, 0, 1, desiredFanIn); // The constructor we are in now is the build constructor, so no learning will happen
    }
    
	// Make afferent synapses for V2,V3,V4,V5,...
	ESPathway[0].setupAfferentSynapses(area7a, p.weightNormalization, p.connectivities[0], p.initialWeight, rngController);
                                                                    
    for(u_short i = 1;i < ESPathway.size();i++)
        ESPathway[i].setupAfferentSynapses(ESPathway[i - 1], p.weightNormalization, p.connectivities[i - 1], p.initialWeight, rngController);
	
	gsl_rng_free(rngController);
}

Network::Network(const char * dataFile, const char * parameterFile, bool verbose, const char * inputWeightFile, bool isTraining) :
		verbose(verbose),
		p(parameterFile, isTraining),
		ESPathway(p.dimensions.size()) {

    // Seed random number generator
    rngController = gsl_rng_alloc(gsl_rng_taus);
    gsl_rng_set(rngController, p.seed);
            
	area7a.init(p, dataFile, rngController);
																								
	BinaryRead weightFile(inputWeightFile);
	
    // Read number of regions and list of dimensions
	// These values are not actually used!!!
	// We just have to consume them from the
	// file stream. We use the parameter file settings
	// to get the actual dimensions.
	// 
	// The reason these values are here is for matlab
	// matlab analysis/completeness/generality
	
	try {
		u_short regions, verDimension, horDimension, depth;

		// Number of regions, including 7a
		weightFile >> regions; 

		// striate cortex
		weightFile >> verDimension;    // area7a.horVisualDimension
        weightFile >> horDimension;    // area7a.horEyeDimension
		weightFile >> depth;        // area7a.depth
   
		for(u_short i = 0;i < regions-1;i++) {
			weightFile >> verDimension;
            weightFile >> horDimension;
			weightFile >> depth;
		}
        
	} catch(fstream::failure e) {
        
        cerr << "Failed while reading network header: " << strerror(errno) << endl;
        cerr.flush();
        exit(EXIT_FAILURE);
    }
    
    // Init regions																																							
    for(u_short i = 0;i < ESPathway.size();i++) {
        

        Region & r = (i == 0) ? static_cast<Region&>(area7a) : static_cast<Region&>(ESPathway[i-1]);
        u_short desiredFanIn = r.depth * r.verDimension * r.horDimension; // 2 * = both signs, (((i == 0) ? 2 : 1) *
        
        if(p.connectivities[i] == SPARSE)
            desiredFanIn *= p.fanInCountPercentage[i];
        else if(p.connectivities[i] == SPARSE_BIASED)
            desiredFanIn *= (p.fanInCountPercentage[i]/r.verDimension);
        
        cout << "Layer " << i+1 << " desiredFanIn: " << desiredFanIn << " << AS READ FROM PARAMTER FILE, MAY NOT HOLD!!!" << endl;
        
        ESPathway[i].init(i+1, p, isTraining, area7a.outputtedTimeStepsPerEpoch, area7a.samplingRate, desiredFanIn);
    }
                                                                                                
    try {                                                                                            

        // Buffer for reading header with numberOfAfferentSynapses
        vector<vector<vector<vector<u_short> > > > numberOfAfferentSynapses(ESPathway.size());

        for(u_short k = 0;k < ESPathway.size();k++) {
            vector<vector<vector<u_short> > > region(ESPathway[k].depth);

            for(u_short d = 0;d < ESPathway[k].depth;d++) {
                vector<vector<u_short> > sheet(ESPathway[k].verDimension);

                for(u_short i = 0;i < ESPathway[k].verDimension;i++) {
                    vector<u_short> row(ESPathway[k].horDimension);

                    for(u_short j = 0;j < ESPathway[k].horDimension;j++) {
                        weightFile >> row[j];
                        
                        //cout << row[j] << endl;
                    }
                    
                    
                    sheet[i] = row;
                }
                region[d] = sheet;
            }
            numberOfAfferentSynapses[k] = region;
        }
            
        // Setup afferent synaptic connections and weights (NOT FOR 7a)
        for(u_short k = 0;k < ESPathway.size();k++)
            for(u_short d = 0;d < ESPathway[k].depth;d++)
                for(u_short i = 0;i < ESPathway[k].verDimension;i++)
                    for(u_short j = 0;j < ESPathway[k].horDimension;j++) {
                        
                        //if(ESPathway[k].Neurons[d][i][j].saveSynapseHistory)
                        //    cout << "About to save neuron (" << i << "," << j << ") with #synapses = " << numberOfAfferentSynapses[k][d][i][j] << endl;
                        
                        for(u_short m = 0;m < numberOfAfferentSynapses[k][d][i][j];m++) {
                            
                            u_short regionNr, depth, row, col;
                            float weight;
                            
                            weightFile >> regionNr >> depth >> row >> col >> weight;
                            
                            //cout << "(" << regionNr << "," << depth << "," << row << "," << col << "," << weight << ")" << endl;

                            Neuron * n;
                            
                            // put in error checking on this presynaptic source, does it exist?

                            if(regionNr == 0)
                                n = area7a.getNeuron(depth,row,col);
                            else
                                n = ESPathway[regionNr-1].getNeuron(depth,row,col);
                            
                            ESPathway[k].Neurons[d][i][j].addAfferentSynapse(n, weight);
                            
                        }
                    }
        
	} catch(fstream::failure e) {
        
        cerr << "Failed while reading network body: " << strerror(errno) << endl;
        cerr.flush();
        exit(EXIT_FAILURE);
    }
    
    weightFile.close();
}

Network::~Network() {
    ESPathway.clear(); 
}

void Network::run(const char * outputDirectory, bool isTraining, int numberOfThreads, bool xgrid) {

	#ifdef OMP_ENABLE
        omp_set_num_threads(numberOfThreads);
        double start = omp_get_wtime();

    	if(numberOfThreads == 1) {

    		cout << endl;
    		cout << "**********************************" << endl;
    		cout << "**** ONLY SINGLE THREADED !!! ****" << endl;
    		cout << "**********************************" << endl;
    		cout << endl;
    	}
    	else
    		cout << "Number of threads: " << numberOfThreads << endl;
	#else
    	cout << endl;
    	cout << "*******************" << endl;
    	cout << "**** no OpenMP ****" << endl;
    	cout << "*******************" << endl;
    	cout << endl;
	#endif

	u_short nrOfEpochs = runContinous(outputDirectory, isTraining, xgrid);
	
	#ifdef OMP_ENABLE
        double finish = omp_get_wtime();
        double elapsed = (double)(finish - start);
        
        cout << "Total run time = " <<  (int)(elapsed)/60 << " minutes: " << (int)(elapsed)%60 << " seconds" << endl;
        cout << "Run time for one epoch = " << elapsed/nrOfEpochs << " seconds" << endl;
	#endif
}

u_short Network::runContinous(const char * outputDirectory, bool isTraining, bool xgrid) {

	const u_short nrOfEpochs = isTraining ? p.nrOfEpochs : 1;
    
    cout << "*** EPOCH DURATION = " << area7a.epochDuration << "s" << endl;
	cout << "*** STEP SIZE = " << p.stepSize << "s" << endl;

	#pragma omp parallel
	{
		for(u_short e = 0; e < nrOfEpochs;e++) {
			
			// We cannot continue without reseting old values from
			// the last time step in the last epoch.
			for(unsigned k = 0;k < ESPathway.size();k++)
				ESPathway[k].clearState(true);
			
			#pragma omp single
			{
				cout << ">> epoch #" << e << endl;
				
				if(xgrid)
					cout << "<xgrid>{control = statusUpdate; percentDone = " << static_cast<int>(((float)(e+1)*100)/nrOfEpochs) << "; }</xgrid>";
			}
			
			// For object/timestep
			for(u_short o = 0; o < area7a.nrOfObjects;o++) {
                
                for(unsigned long int t = 0; t < area7a.timeStepsInObject[o];t++) {
                    
                    //#pragma omp single
                    //{
                    //    cout << ">> step #" << t << endl;
                    //}
                    
                    //#pragma omp single // Due to normalization of inputs we have to let one cell do write back
                    //{
                        area7a.setFiringRate(o, t * p.stepSize);
                    //}
                    
                    // Compute new firing rates
                    for(unsigned k = 0; k < ESPathway.size();k++)
                        ESPathway[k].computeNewFiringRate();
                    
                    // We need barrier due to nowait in computeNewFiringRate()
                    #pragma omp barrier
                    
                    // Do learning
                    if(isTraining) {
                        for(unsigned k = 0; k < ESPathway.size();k++)
                            ESPathway[k].applyLearningRule();
                    }
                    
                    // We need barrier due to nowait in applyLearningRule()
                    #pragma omp barrier
                    
                    // Make time step for each region, and save data if we are on appropriate time step
                    bool save = ((t+1) % p.outputAtTimeStepMultiple) == 0;
                    for(unsigned k = 0;k < ESPathway.size();k++)
                        ESPathway[k].doTimeStep(save); 
                }
                
                #pragma omp single
                {
                    cout << ">Completed Periode nr." << o+1 << endl;
                }
                
                // During learning, reset activity/trace on last sample of object
                if(isTraining) {
                    
                    if(p.resetActivity) {
                        
                        for(unsigned k = 0;k < ESPathway.size();k++)
                            ESPathway[k].clearState(p.resetTrace);
                        
                    } else if(p.resetTrace) {
                        
                        for(unsigned k = 0;k < ESPathway.size();k++)
                            ESPathway[k].resetTrace();
                    }
                    
                } else { // In testing we MUST reset betweene objects when we are testing with continous neurons
                    
                    for(unsigned k = 0;k < ESPathway.size();k++)
                        ESPathway[k].clearState(true); // does not matter if trace is reset here
                }
			}
			
			// Do intermediate network saves
			if(isTraining && p.saveNetwork && (e+1) % p.saveNetworkAtEpochMultiple == 0) {
				
				#pragma omp single
				{
					cout << "Saving: TrainedNetwork_e" << e+1 << ".txt" << endl;
					
					stringstream ss;
					ss << outputDirectory << "TrainedNetwork_e" << e+1 << ".txt";
					string name = ss.str();
					outputFinalNetwork(name.c_str());
				}
			}
		}		
	}
	
	cout << "Saving history..." << endl;
	outputHistory(outputDirectory, isTraining);
	return nrOfEpochs;
}

void Network::outputHistory(const char * outputDirectory, bool isTraining) {
	
    if(isTraining) { // Output neuronal and synaptic training data
        
        if(p.saveSingleCells)
            outputSingleUnits(outputDirectory);
        
        if(p.saveAllNeuronsAndSynapsesInRegion) 
            outputSynapticHistory(outputDirectory);
    }
    
    // Output region data
    outputRegionHistory(outputDirectory, isTraining);
    
    // Output neuronal data
    
    // Do a small check to see that 
    // we have anything to save, saves us from dumping
    // empty files
    if(!isTraining || p.saveAllNeuronsAndSynapsesInRegion || p.saveAllNeuronsInRegion) {
        
        outputNeuronHistoryData(outputDirectory, isTraining, FIRING_RATE);
        outputNeuronHistoryData(outputDirectory, isTraining, ACTIVATION);
        outputNeuronHistoryData(outputDirectory, isTraining, INHIBITED_ACTIVATION);
        outputNeuronHistoryData(outputDirectory, isTraining, TRACE);
        outputNeuronHistoryData(outputDirectory, isTraining, STIMULATION);
        outputNeuronHistoryData(outputDirectory, isTraining, EFFECTIVE_TRACE);
    }
}

void Network::openHistoryFile(BinaryWrite & file, const char * outputDirectory, const char * filename, bool isTraining, OUTPUT_FILE fileType) {
    
    string s(outputDirectory);
    s.append(filename);
    
	file.openFile(s);
    
	// Header
    file << (isTraining ? p.nrOfEpochs : U_SHORT_1);
    file << p.numberOfLayers;
    file << area7a.nrOfObjects;
    
    // Iterate and output size of each
    for(u_short o = 0; o < area7a.nrOfObjects;o++)
        file << area7a.outputtedTimeStepsInObject[o];
    
    // Input layer dimensions
    file << area7a.horVisualDimension;
    file << area7a.horEyeDimension;
    file << area7a.depth;
    file << U_SHORT_0; // Never present
    
    // Hidden layer description
    for(u_short k = 0;k < ESPathway.size();k++) {
        
        u_short isPresent = 0;
        
        switch (fileType) {
                
            case OF_REGIONAL:
                isPresent = 1;
                break;
            case OF_REGION_NEURONAL:
                isPresent = (!isTraining || p.saveHistory[k] == SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION || p.saveHistory[k] == SH_ALL_NEURONS_IN_REGION) ? 1 : 0;
                break;
            case OF_REGION_SYNAPTIC:
                isPresent = (p.saveHistory[k] == SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION ? 1 : 0); // !isTraining is not relevant, because we cannot co
                break;
            case OF_SINGLE_CELLS:
                isPresent = (p.saveHistory[k] == SH_SINGLE_CELLS ? 1 : 0); // !isTraining is not relevant, because we cannot co
                break;    
            default:
                break;
        }
        
        file << ESPathway[k].verDimension; 
        file << ESPathway[k].horDimension;
        file << ESPathway[k].depth; 
        file << isPresent;
    }
}

void Network::outputRegionHistory(const char * outputDirectory, bool isTraining) {
    
    // Open file
	BinaryWrite regionData;
	openHistoryFile(regionData, outputDirectory, "regionData.dat", isTraining, OF_REGIONAL);

    // Output data
	for(u_short k = 0;k < ESPathway.size();k++)
		ESPathway[k].outputRegion(regionData);
    
    // Close file
    regionData.close();
}

void Network::outputNeuronHistoryData(const char * outputDirectory, bool isTraining, DATA data) {
    
    // Select
    const char * filename = NULL;
    
    switch (data) {
        case FIRING_RATE:
            filename = "firingRate.dat";
            break;
        case ACTIVATION:
            filename = "activation.dat";
            break;
        case INHIBITED_ACTIVATION:
            filename = "inhibitedActivation.dat";
            break;
        case TRACE:
            filename = "trace.dat";
            break;
        case STIMULATION:
            filename = "stimulation.dat";
            break;
        case EFFECTIVE_TRACE:
        	filename = "effectiveTrace.dat";
        	break;
        default:
            break;
    }
    
    // Open files
    BinaryWrite file;
    openHistoryFile(file, outputDirectory, filename, isTraining, OF_REGION_NEURONAL);

    // Output data
    for(u_short k = 0;k < ESPathway.size();k++)
        if(!isTraining || (p.saveHistory[k] == SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION || p.saveHistory[k] == SH_ALL_NEURONS_IN_REGION))
            ESPathway[k].outputNeurons(file, data);
    
    // Close files
    file.close();
}
    
void Network::outputSingleUnits(const char * outputDirectory) {
    
    // Output single unit recordings
    BinaryWrite singleUnits;
    openHistoryFile(singleUnits, outputDirectory, "singleUnits.dat", true, OF_SINGLE_CELLS);
    
    // Write out afferent synaptic weights for each region
    for(u_short k = 0;k < ESPathway.size();k++)
        if(p.saveHistory[k] == SH_SINGLE_CELLS)
            ESPathway[k].outputSingleCells(singleUnits);
    
    singleUnits.close();
}

void Network::outputSynapticHistory(const char * outputDirectory) {
    
    // Output synaptic weight history   
    BinaryWrite synapticWeights;
    openHistoryFile(synapticWeights, outputDirectory, "synapticWeights.dat", true, OF_REGION_SYNAPTIC);
    
    // Neuronal indegree, used for file seeking in matlab
    for(u_short k = 0;k < ESPathway.size();k++)
        if(p.saveHistory[k] == SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION)
            ESPathway[k].outputNeurons(synapticWeights, FAN_IN_COUNT);
    
    // Synapse history
    for(u_short k = 0;k < ESPathway.size();k++)
        if(p.saveHistory[k] == SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION)
            ESPathway[k].outputNeurons(synapticWeights, WEIGHT_HISTORY);
    
    synapticWeights.close();
}

void Network::outputFinalNetwork(const char * outputWeightFile) {
	
	BinaryWrite file(outputWeightFile);
    
    // Input layer dimensions
	file << p.numberOfLayers;
    file << area7a.horVisualDimension;
    file << area7a.horEyeDimension;
    file << area7a.depth;
	
    // Hidden layer dimensiosn
    for(u_short k = 0;k < ESPathway.size();k++) {
        file << ESPathway[k].verDimension; 
        file << ESPathway[k].horDimension;
        file << ESPathway[k].depth;
    }
    
    // Neuronal indegree, used for file seeking in matlab
    for(u_short k = 0;k < ESPathway.size();k++)
        ESPathway[k].outputNeurons(file, FAN_IN_COUNT);
    
	// Synapses (source, weights)
    for(u_short k = 0;k < ESPathway.size();k++)
        ESPathway[k].outputNeurons(file, WEIGHTS_FINAL);
    
    file.close();
}

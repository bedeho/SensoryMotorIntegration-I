/*
 *  HiddenRegion.cpp
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "HiddenRegion.h"
#include "HiddenNeuron.h"
#include "Synapse.h"
#include "BinaryWrite.h"
#include "InputNeuron.h"
#include "InputRegion.h"
#include <cmath>
#include <sstream>
#include <algorithm>
#include <queue>
#include <iostream>
#include <cstdlib>
#include "Utilities.h"

using std::cout;
using std::endl;
using std::cerr;

// reason we use init and not ctor is because Network class puts a bunch of 
// objects of this type in a vector in its ctor auto list, which does not allow passing args,
// should have just used ptrs in retrospect.
void HiddenRegion::init(u_short regionNr, Param & p, bool isTraining, unsigned long int outputtedTimeStepsPerEpoch, u_short samplingRate, u_short desiredFanIn) {
	
	// Call base constructor
	Region::init(regionNr, p);
    
	// Set vars
	this->regionHistoryCounter = 0;
	this->filterWidth = p.filterWidth[regionNr-1]; 
	this->inhibitoryRadius = p.inhibitoryRadius[regionNr-1]; 
	this->inhibitoryContrast = p.inhibitoryContrast[regionNr-1];
	this->somExcitatoryRadius = p.somExcitatoryRadius[regionNr-1]; 
	this->somExcitatoryContrast = p.somExcitatoryContrast[regionNr-1];
	this->somInhibitoryRadius = p.somInhibitoryRadius[regionNr-1]; 
	this->somInhibitoryContrast = p.somInhibitoryContrast[regionNr-1];
	this->sparsenessLevel = p.sparsenessLevels[regionNr-1];
	this->sigmoidSlope = p.sigmoidSlopes[regionNr-1];
    this->sigmoidThreshold = p.sigmoidThreshold[regionNr-1];
	this->learningRate = p.learningRates[regionNr-1]; // /desiredFanIn was used before, no longer though! 0.1 seems to be the magic bullet
	this->eta = p.etas[regionNr-1];
	this->timeConstant = p.timeConstants[regionNr-1];
    this->globalInhibitoryConstant = p.globalInhibitoryConstant[regionNr-1];
    this->externalStimulation = p.externalStimulation[regionNr-1];
    
    this->covarianceThreshold = p.covarianceThreshold;
	this->stepSize = p.stepSize;
	this->traceTimeConstant = p.traceTimeConstant;
	this->sparsenessRoutine = p.sparsenessRoutine;
    //this->transferFunction = p.transferFunction;
	this->rule = p.rule;
	this->weightNormalization = p.weightNormalization;
    this->lateralInteraction = p.lateralInteraction;
    this->percentileSize = static_cast<u_short>(depth*verDimension*horDimension*(1-sparsenessLevel));
    this->recordedSingleCells = p.recordedSingleCells[regionNr-1];
    this->saveHistory = p.saveHistory[regionNr-1];
    
    //this->blockageLeakTime = p.blockageLeakTime;
    //this->blockageRiseTime = p.blockageRiseTime;
    //this->blockageTimeWindow = p.blockageTimeWindow;
    
    //this->blockageLeakTime = p.blockageLeakTime[regionNr-1];
    //this->blockageRiseTime = p.blockageRiseTime[regionNr-1];
    //this->blockageTimeWindow = p.blockageTimeWindow[regionNr-1];
    
    /*
    float bufferDuration = this->globalInhibitoryConstant; // 0.5, this->blockageTimeWindow
    int fixedBufferWeightHistorySize = static_cast<int>(ceil(bufferDuration/this->stepSize));
    
    if(fixedBufferWeightHistorySize < 0) {
        
        cout << "wtf: " << p.blockageTimeWindow << " , " << this->stepSize << endl;
        exit(EXIT_FAILURE);
    }
    
    cout << "fixedBufferWeightHistorySize: " << fixedBufferWeightHistorySize << endl;
     
    */
    
    int fixedBufferWeightHistorySize = 0;
    
    if(percentileSize < 1 && p.sparsenessRoutine != NOSPARSENESS) {
        cerr << "Sparseness is to low : " << percentileSize << endl;
        cerr.flush();
		exit(EXIT_FAILURE);
    }
    
	// Build - this part is identical in InputRegion as well, but not for long, so we dont put it in region
	vector<vector<vector<HiddenNeuron> > > tmp1(depth, vector<vector<HiddenNeuron> >(verDimension, vector<HiddenNeuron>(horDimension)));
	Neurons = tmp1;
    
    // Compute epoch size
    unsigned long int outputsPerCellPerEpoch = outputtedTimeStepsPerEpoch;
    
    // Deduce history buffer sizes based on on whether there is learning or not
    unsigned long long int outputsPerCell, outputsPerSynapse, outputsPerRegion, bufferSize;
    
    // Determine buffer sizes
    if(isTraining) {
        
        outputsPerRegion = outputsPerCellPerEpoch * p.nrOfEpochs;
        outputsPerCell = (saveHistory == SH_NONE) ? 0 : outputsPerRegion;
        outputsPerSynapse = (saveHistory == SH_ALL_NEURONS_IN_REGION) ? 0 : outputsPerCell;
        
        if (saveHistory == SH_NONE)
            bufferSize = 0;
        else {
            
            bufferSize = outputsPerCell;
            
            if(saveHistory == SH_ALL_NEURONS_IN_REGION)
                bufferSize *= depth*verDimension*horDimension;
            else {
                
                if(saveHistory == SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION || saveHistory == SH_ALL_NEURONS_IN_REGION)
                    bufferSize *= depth*verDimension*horDimension;
                else if(saveHistory == SH_SINGLE_CELLS)
                    bufferSize *= p.nrOfRecordedSingleCells[regionNr-1];
                
                unsigned long long int regionSynapseBufferSize = bufferSize*desiredFanIn;
                synapseHistoryBuffer.resize(regionSynapseBufferSize,-1); // put in -1 junk for safety
                
                cout << "***>> Allocated synapse buffer space for region #" << regionNr << " = " << regionSynapseBufferSize << " data points (float)." << endl;
            }
        }
        
    } else {
        
        outputsPerRegion = outputsPerCellPerEpoch;
        outputsPerCell = outputsPerCellPerEpoch;
        outputsPerSynapse = 0;
        
        bufferSize = outputsPerCell*depth*verDimension*horDimension;
    }
    
    // Resize, put in -1 junk for safety
    this->activationBuffer.resize(bufferSize,-1);
    this->inhibitedActivationHistoryBuffer.resize(bufferSize,-1);
    this->firingRateBuffer.resize(bufferSize,-1);
    this->traceBuffer.resize(bufferSize,-1);
    this->stimulationBuffer.resize(bufferSize,-1);
    this->effectiveTraceBuffer.resize(bufferSize,-1);

    this->sparsityPercentileValue = vector<float>(outputsPerRegion);
    
    this->synapseHistoryCounter = 0;
    this->singleSynapseBufferSize = outputsPerSynapse;
    
    // Init neurons
    unsigned long long int bufferOffset = 0;
	for(int d = 0;d < depth;d++)
        for(int i = 0;i < verDimension;i++)
            for(int j = 0;j < horDimension;j++) {
                
                // Decide what to save for this cell
                bool recordThisCell = (saveHistory == SH_SINGLE_CELLS && recordedSingleCells[i][j]);
                bool saveNeuronHistory = !isTraining || (saveHistory == SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION || saveHistory == SH_ALL_NEURONS_IN_REGION || recordThisCell);
                bool saveSynapseHistory = isTraining && (saveHistory == SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION || recordThisCell);
                
                // Setup buffers pointers
                float * activation = NULL,
                      * inibitedActivation = NULL,
                      * firingRate = NULL,
                      * trace = NULL,
                      * stimulation = NULL,
                      * effectiveTrace = NULL;
                
                if(saveNeuronHistory) {
                    
                    activation = &(activationBuffer[bufferOffset]);
                    inibitedActivation = &(inhibitedActivationHistoryBuffer[bufferOffset]);
                    firingRate = &(firingRateBuffer[bufferOffset]);
                    trace = &(traceBuffer[bufferOffset]);
                    stimulation = &(stimulationBuffer[bufferOffset]);
                    effectiveTrace = &(effectiveTraceBuffer[bufferOffset]);
                    
                    // Increment buffer offset for next cell
                    bufferOffset += outputsPerCell;
                }
                
                // Init cell
                Neurons[d][i][j].init(this, d, i, j, activation, inibitedActivation, firingRate, trace, stimulation, effectiveTrace, saveNeuronHistory, saveSynapseHistory, desiredFanIn, p.weightVectorLength, fixedBufferWeightHistorySize);
            }
               
	
	// This is how matlab determines filter center with in conv2
	// http://www.mathworks.com/help/techdoc/ref/conv2.html
	// -1 from what matlab does, to make it index, and divisor in c++ takes care of floor()
	filterCenter = (filterWidth - 1)/2;
    
	// Setup spatial filter and the partial sum table for the filter
	vector<vector<float> > tmp2(verDimension, vector<float>(horDimension));
	inhibitoryFilter = tmp2;
	somFilter = tmp2;
	
    if(lateralInteraction != NONE)
        setupFilters();
}

HiddenRegion::~HiddenRegion() {
    
    Neurons.clear();
	inhibitoryFilter.clear();
	somFilter.clear();
    
    // Buffers
    activationBuffer.clear();
    inhibitedActivationHistoryBuffer.clear();
    firingRateBuffer.clear();
    traceBuffer.clear();
}

void HiddenRegion::setupFilters() {
	
	float nonCenterCumulativeSum = 0;
	
    for(int i = 0;i < filterWidth;i++)
        for(int j = 0;j < filterWidth;j++) {
            
            u_short a = abs(filterCenter - i);
            u_short b = abs(filterCenter - j);
			
			// Inhibitory filter
            if(a != 0 || b != 0) { // a == 0 && b == 0 is handled below
                inhibitoryFilter[i][j] = -1 * inhibitoryContrast * exp (-1 * (float)(a*a + b*b) / (inhibitoryRadius*inhibitoryRadius));
                nonCenterCumulativeSum += inhibitoryFilter[i][j];
            }
			
			// SOM
			somFilter[i][j] = -1 * somInhibitoryContrast * exp (-1 * (float)(a*a + b*b) / (somInhibitoryRadius * somInhibitoryRadius)) + somExcitatoryContrast * exp (-1 * (float)(a*a + b*b) / (somExcitatoryRadius * somExcitatoryRadius));
        }
	
    // Set the center of the filter with the special case formula
    inhibitoryFilter[filterCenter][filterCenter] = 1-nonCenterCumulativeSum;
}

void HiddenRegion::computeNewFiringRate() {
    
    if(sparsenessRoutine == HEAP) {
	
        // Compute activation
        computeNewActivation();
        
        // Do local inhibition
        // Even if we do not run .inhibit(), the activation
        // values will still have been copied through to 
        // n->newInhibitedActivation by .computeNewActivation(),
        // hence all future calculations that expect inhibited values
        // will still work.
        
        if(lateralInteraction != NONE)
            filter();
        
        // this value is written to once by each thread,
        // but it is the same value is computed in all threads,
        // so it does not matter
        if(sparsenessRoutine != NOSPARSENESS)
            threshold = findThreshold();
        
        /*
        ///****************************************************************
        
        // ADJUST threshold
        float activationScaler = 0.256315005; // 0.556315005 <== do rough. 0.456315005 some neurons fired, 0.356315005 still not enough.
        float averageActivation = 0;
        
        for(int d = 0;d < depth;d++)
            for(int i = 0;i < verDimension; i++)
                for(int j = 0;j < horDimension; j++)
                    averageActivation += Neurons[d][i][j].newInhibitedActivation;
        
        averageActivation /= verDimension*horDimension*depth;
        
        threshold /= (averageActivation/activationScaler);
        
        //cout << "averageActivation: " << averageActivation << endl;
        
        ///****************************************************************
        */
        
        // Compute firing rate using contrast enhancement
        for(int d = 0;d < depth;d++)
        {
            #pragma omp for nowait
            for(int i = 0;i < verDimension; i++)
                for(int j = 0;j < horDimension; j++)
                    Neurons[d][i][j].newFiringRate = 1/(1+exp(-2*sigmoidSlope*(Neurons[d][i][j].newInhibitedActivation - threshold - sigmoidThreshold)));
        }
    }
    else if(sparsenessRoutine == GLOBAL) {
        
        float cumulativeFiringRate = 0;
        
        for(int i = 0;i < verDimension; i++)
            for(int j = 0;j < horDimension; j++)
                cumulativeFiringRate += Neurons[0][i][j].firingRate;
        
         #pragma omp for nowait
         for(int i = 0;i < verDimension; i++)
         for(int j = 0;j < horDimension; j++) {
         
             // Presynaptic Stimulation
             HiddenNeuron * n = &Neurons[0][i][j];
             float stimulation = 0;
         
             for(std::vector<Synapse>::iterator s = n->afferentSynapses.begin(); s != n->afferentSynapses.end();s++)
                stimulation += (*s).weight * (*s).preSynapticNeuron->firingRate;
             
             // Save stimulation variable
             n->stimulation = stimulation;
             
             // Scale global inhibition
             n->newInhibitedActivation = globalInhibitoryConstant * cumulativeFiringRate;
                          
             // CLASSIC: fast membrane dynamics approach, slow firing rate
             //
             /*
             n->newActivation = stimulation - n->newInhibitedActivation;// + externalStimulation;
         
             // Pass stimulation+inhibition through neural response function
             float transferFunctionStimulation = 20 * (1 / (1 + exp(-2*sigmoidSlope*(n->newActivation - sigmoidThreshold))));
            
             // Compute firing rate
             n->newFiringRate = n->firingRate + (stepSize/timeConstant)*(-n->firingRate + transferFunctionStimulation);
             */
             
             // NEW (daniel): fast firing rate, slow membrane dynamics
             //
             n->newActivation = n->activation + (stepSize/timeConstant) * (-n->activation + stimulation - n->newInhibitedActivation);
             n->newFiringRate = 1/(1+exp(-2*sigmoidSlope*(n->newActivation - sigmoidThreshold)));
             
         }
         
    }
}

// Save outout in newActivation (also newInhibitedActivation)
void HiddenRegion::computeNewActivation() {
	
	for(int d = 0;d < depth;d++)
	{
		#pragma omp for
    	for(int i = 0;i < verDimension; i++)
    		for(int j = 0;j < horDimension; j++) {
                
                HiddenNeuron * n = &Neurons[d][i][j];
				float stimulation = 0;

				for(std::vector<Synapse>::iterator s = n->afferentSynapses.begin(); s != n->afferentSynapses.end();s++) {
                    
                    // classic
                    stimulation += (*s).weight * (*s).preSynapticNeuron->firingRate;

                    /*
                    switch (rule) {
                            
                        case COVARIANCE_PRESYNAPTIC_TRACE_RULE:
                        	stimulation += ((*s).preSynapticNeuron->firingRate > covarianceThreshold) ? (*s).weight * ((*s).preSynapticNeuron->firingRate - covarianceThreshold) : 0;
                            break;
                        default:
                            
                            // classic
                            stimulation += (*s).weight * (*s).preSynapticNeuron->firingRate;
                            
                            break;
                    }
                     */
                    
                }
                
                //old obsucated: n->newActivation = (1 - stepSize/timeConstant) * n->activation + (stepSize/timeConstant) * stimulation;
                n->newActivation = n->activation + (stepSize/timeConstant) * (-n->activation + stimulation);
                
                n->stimulation = stimulation;
				
    			// Is copied forward in case do not have inhibition routine
    			// turned on in parameter file
    			n->newInhibitedActivation = n->newActivation;
    		}	
	}
}

// CLASSIC
void HiddenRegion::filter() {

	int n_i, n_j;		 // neuron being inspected by filter
	float convolutionResult;
	
	// Choose neuron to center filter on
	#pragma omp for
	for(int i = 0;i < verDimension;i++)
        for(int j = 0;j < horDimension;j++) {
			
            convolutionResult = 0;
			
            // Iterate over neighberhood of (i,j)
            for(int f_i = 0; f_i < filterWidth;f_i++)
                for(int f_j = 0; f_j < filterWidth;f_j++) {

					n_i = i + f_i - filterCenter;
					n_j = j + f_j - filterCenter;
					
					// Wrap around
					n_i = wrap(n_i, verDimension);
					n_j = wrap(n_j, horDimension);
					
					convolutionResult += Neurons[0][n_i][n_j].newActivation * (lateralInteraction == SHORT_INHIBITION_LONG_EXCITATION ? inhibitoryFilter[f_i][f_j] : somFilter[f_i][f_j]);
                }
            
            // Save result convolutionResult
            Neurons[0][i][j].newInhibitedActivation = convolutionResult;
        }	
}

float HiddenRegion::findThreshold() {

	u_short added = 0;
    
    float average = 0;
	
	// Clear existing content from last run, there is no clear method, so we have to reset
	// Slows everything down that we cannot preallocate appropriate space and just keep buffer arround across calls,
	// hopefully still faster then qsort().
	priority_queue<float,vector<float>,greater<float> > minimumHeap = priority_queue<float,vector<float> ,greater<float> >();
	
	// Iterate layer, and only replace top of heap if bigger then .top is found
	for(int d = 0;d < depth;d++)
		for(int i = 0;i < verDimension;i++)
			for(int j = 0;j < horDimension;j++) {
				
				float x = Neurons[d][i][j].newInhibitedActivation;
                
                average += x;
				
				if(added < percentileSize) {
					minimumHeap.push(x);
					added++;
				} else if(minimumHeap.top() < x) {
					minimumHeap.pop();
					minimumHeap.push(x);
				}
			}
	
	// Find percentile
    float top = minimumHeap.top();
    
    /*
    #pragma omp single
    {
        // SetSparse defence!!!
        if(top - (average/depth*verDimension*horDimension) < 0.1) {
            cout << "VERY LIKELY TO BE ALL ON!..." << endl;
        }
    }
    */    
    
	return top;
}

void HiddenRegion::applyLearningRule() {
    
    if(learningRate == 0)
        return;
    
    for(int d = 0; d < depth;d++)
		#pragma omp for nowait
        for(int i = 0; i < verDimension;i++)
            for(int j = 0; j < horDimension;j++) {
				
                HiddenNeuron * n = &Neurons[d][i][j];
                float norm = 0, dw;

				for(std::vector<Synapse>::iterator s = n->afferentSynapses.begin(); s != n->afferentSynapses.end();s++) {
                    
                    // Keep values previous time step
                    float oldBlockage = (*s).blockage;
                    float oldWeight = (*s).weight;
                    
                    // OLD: Update synapse blockage
                    ///if(1)
                    //    (*s).blockage += stepSize * (-blockageLeakTime*oldBlockage + blockageRiseTime*fabs(oldWeight - (*s).getLast()));
                    
                    // NEW Update synapse blockage
                    //(*s).blockage += stepSize * (blockageLeakTime*(1-oldBlockage) - blockageRiseTime*(learningRate * n->trace * (*s).preSynapticNeuron->firingRate)*oldBlockage);
                    
                    // Get delayed trace
                    //float delayedTrace = n->getDelayedTrace();
                    
                    // Add to cumulative norm value
					norm += oldWeight * oldWeight;

                    switch (rule) {
                            
                        case HEBB_RULE:
                            
                            (*s).weight += stepSize * (learningRate * n->firingRate * (*s).preSynapticNeuron->firingRate);
                            
                            break;
                            
                        case TRACE_RULE:
                            
                            // CLASSIC
                            (*s).weight += stepSize * (learningRate * n->trace * (*s).preSynapticNeuron->firingRate);
                            
                            // INDIVIDUAL WEIGHT SATURATION
                            //(*s).weight += stepSize * (globalInhibitoryConstant - (*s).weight)*(learningRate * n->trace * (*s).preSynapticNeuron->firingRate);

                            // ISOLATE TRACE MAGNITUDE
                            //if(n->trace > 0.1)
                            //    (*s).weight += stepSize * (learningRate * (*s).preSynapticNeuron->firingRate);
                            
                            // DELAYED TRACE
                            //(*s).weight += stepSize * (learningRate * delayedTrace * (*s).preSynapticNeuron->firingRate);
                            
                            /* not used
                            // SATURATION RULE 1: b_ij =0 -> LTP is possible
                            //dw = stepSize * (learningRate * (n->trace * (*s).preSynapticNeuron->firingRate - oldBlockage));
                            //(*s).weight += dw > 0 ? dw : 0;
                            
                            // BLOCKING
                            //(*s).weight += stepSize * (learningRate * (n->trace * (*s).preSynapticNeuron->firingRate)*oldBlockage);
                            */
                            
                            break;
                            
                        case COVARIANCE_PRESYNAPTIC_TRACE_RULE:
                            
                            // CLASSIC COVARIANCE
                            //(*s).weight += stepSize * ((*s).preSynapticNeuron->firingRate * (*s).weight * learningRate * n->trace * ((*s).preSynapticNeuron->firingRate - covarianceThreshold));
                            
                            // Conditional LTP : controlled version
                            if((*s).preSynapticNeuron->firingRate > covarianceThreshold)
                               (*s).weight += stepSize * (learningRate * n->trace); // * ((*s).preSynapticNeuron->firingRate - covarianceThreshold)
                            
                            // Conditional LTP 2 : controlled version
                            //if((*s).preSynapticNeuron->firingRate > covarianceThreshold)
                            //    (*s).weight += stepSize * (0.1 - (*s).weight)* (learningRate * n->trace); // * ((*s).preSynapticNeuron->firingRate - covarianceThreshold)
                            
                            // REAL Conditional LTP : controlled version
                            //if((*s).preSynapticNeuron->firingRate > covarianceThreshold)
                            //   (*s).weight += stepSize * (learningRate * n->trace) * (*s).preSynapticNeuron->firingRates; // * ((*s).preSynapticNeuron->firingRate - covarianceThreshold)
                            
                            break;
                    }
                    
                    // Save weight to buffer
                    //if(1)
                    //    (*s).savePresent();
				}
                
                // Update trace for this neuron
				//obfuscated form: n->newTrace = (1 - stepSize/traceTimeConstant)*n->trace + (stepSize/traceTimeConstant)*n->firingRate;
                n->newTrace = n->trace + (stepSize/traceTimeConstant)*(-n->trace + n->firingRate);
                
                // Save this trace value in buffer
                //n->addNewTraceValueToTraceBuffer();
                
				// Normalization
				if(weightNormalization == CLASSIC)
					n->normalize(norm);
            }
}

void HiddenRegion::doTimeStep(bool save) {
	
    // Update/Save neuron level data
	for(int d = 0;d < depth;d++)
		#pragma omp for
		for(int i = 0;i < verDimension;i++)
    		for(int j = 0;j < horDimension;j++)
               Neurons[d][i][j].doTimeStep(save);
	
    // Save region level data
	#pragma omp single	
	{	
		if(save) {
			sparsityPercentileValue[regionHistoryCounter] = threshold;
			regionHistoryCounter++;
		}
	}
}

void HiddenRegion::resetTrace() {
	
	for(int d = 0; d < depth;d++)
		#pragma omp for
    	for(int i = 0;i < verDimension;i++)
    		for(int j = 0;j < horDimension;j++) {
    			
    			// Reseting .trace is not enough, because .newTrace
    			// will be copid back into .trace in .doTimeStep() 
    			// if there is no learning in next time step.
    			// Also, if we switch to symmetric trace rule,
    			// then newTrace is used directly
                Neurons[d][i][j].trace = 0;
    			Neurons[d][i][j].newTrace = 0; 
    		}
}

void HiddenRegion::clearState(bool resetTrace) {
	
	for(int d = 0;d < depth;d++)
		#pragma omp for
		for(int i = 0;i < verDimension;i++)
    		for(int j = 0;j < horDimension;j++)
                Neurons[d][i][j].clearState(resetTrace); 
}

void HiddenRegion::setupAfferentSynapses(Region & region, WEIGHTNORMALIZATION weightNormalization, CONNECTIVITY connectivity, INITIALWEIGHT initialWeight, gsl_rng * rngController) {
    
    for(int d = 0;d < depth;d++)
        for(int i = 0;i < verDimension;i++)
            for(int j = 0;j < horDimension;j++) {
				
    			HiddenNeuron & postSynapticNeuron = Neurons[d][i][j];
                    
                postSynapticNeuron.setupAfferentSynapses(region, connectivity, initialWeight, rngController);
    			
    			if(weightNormalization == CLASSIC)
                    postSynapticNeuron.normalize();
            }  
}

Neuron * HiddenRegion::getNeuron(u_short depth, u_short row, u_short col) {
    return &Neurons[depth][row][col];
}

void HiddenRegion::outputRegion(BinaryWrite & file) {
	
	for(unsigned long long int t = 0;t < regionHistoryCounter;t++)
		file << sparsityPercentileValue[t];
}

void HiddenRegion::outputNeurons(BinaryWrite & file, DATA data) {
	
    for(int d = 0;d < depth;d++)                   
        for(int i = 0;i < verDimension;i++)
            for(int j = 0;j < horDimension;j++)
                Neurons[d][i][j].output(file, data);                
}

// Used when outputting single cell recordings from training only (WEIGHT_AND_NEURON_HISTORY)
void HiddenRegion::outputSingleCells(BinaryWrite & file) {
	
    for(int d = 0;d < depth;d++)
        for(int i = 0;i < verDimension;i++)
            for(int j = 0;j < horDimension;j++)
                if(recordedSingleCells[i][j])
                    Neurons[d][i][j].output(file, WEIGHT_AND_NEURON_HISTORY);          
}

float * HiddenRegion::getSynapseHistorySlot() {
    
    // Get the present first unused slot
    float * bufferSlot = &(synapseHistoryBuffer[synapseHistoryCounter]);
    
    // New required size of buffer
    synapseHistoryCounter += singleSynapseBufferSize;
    
    // Check that we have enough space
    unsigned long long size = synapseHistoryBuffer.size();
    if(size < synapseHistoryCounter) {
        
        // Allocate more space
        //synapseHistoryBuffer.resize(synapseHistoryCounter);
        
        cerr << "***>> Could not allocate sufficient synapse history buffer slots, buffer size = " << size << ", failed to get next slot brining buffer to size = " << synapseHistoryCounter << endl;
        exit(EXIT_FAILURE);
    }

    // Return slot
    return bufferSlot;
}

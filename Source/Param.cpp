/*
 *  param.cpp
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "Param.h"
#include <iostream>
#include <cstdlib>
#include <libconfig.h++>
#include <cmath>
#include <cfloat>

using namespace libconfig;
using std::cerr;
using std::endl;
using std::cout;

Param::Param(const char * filename, bool isTraining) {

    Config cfg;

	try
	{
		cfg.readFile(filename);

		int tmp;
        
        //cfg.lookupValue("transferFunction", tmp);
		//transferFunction = static_cast<TRANSFER_FUNCTION>(tmp);
		
		cfg.lookupValue("traceTimeConstant", traceTimeConstant);
		cfg.lookupValue("stepSizeFraction", stepSizeFraction);
		cfg.lookupValue("resetActivity", resetActivity);
		cfg.lookupValue("outputAtTimeStepMultiple", tmp);
		outputAtTimeStepMultiple = static_cast<u_short>(tmp);
		
		// training
		cfg.lookupValue("training.rule", tmp);
		rule = static_cast<LEARNING_RULE>(tmp);
        cfg.lookupValue("training.covarianceThreshold", covarianceThreshold);
		cfg.lookupValue("training.resetTrace", resetTrace);
		cfg.lookupValue("training.saveNetwork", saveNetwork);
		cfg.lookupValue("training.saveNetworkAtEpochMultiple", tmp);
		saveNetworkAtEpochMultiple = static_cast<u_short>(tmp);
		cfg.lookupValue("training.nrOfEpochs", tmp);
		nrOfEpochs = static_cast<u_short>(tmp);
		
		// general        
		cfg.lookupValue("feedback", tmp);
		feedback = static_cast<FEEDBACK>(tmp);
		
		cfg.lookupValue("initialWeight", tmp);
		initialWeight = static_cast<INITIALWEIGHT>(tmp);
		
		cfg.lookupValue("weightNormalization", tmp);
		weightNormalization = static_cast<WEIGHTNORMALIZATION>(tmp);
		
        cfg.lookupValue("weightVectorLength", weightVectorLength);
        
		cfg.lookupValue("sparsenessRoutine", tmp);
		sparsenessRoutine = static_cast<SPARSENESSROUTINE>(tmp);
		
		cfg.lookupValue("lateralInteraction", tmp);
		lateralInteraction = static_cast<LATERAL>(tmp);
        
        cfg.lookupValue("blockageLeakTime", blockageLeakTime);
        cfg.lookupValue("blockageRiseTime", blockageRiseTime);
        cfg.lookupValue("blockageTimeWindow", blockageTimeWindow);
        
        //this->blockageLeakTime = 0.01;
        //this->blockageRiseTime = 80.1; //1000 to big, 100 to big also, 10 was to small, 50 was to small?
        //this->blockageTimeWindow = 0.5;

        //cfg.lookupValue("playAtPrcntOfOriginalSpeed", playAtPrcntOfOriginalSpeed);
        
		cfg.lookupValue("seed", tmp);
		seed = static_cast<u_short>(tmp);

		// 7a
        cfg.lookupValue("area7a.visualPreferenceDistance", visualPreferenceDistance);
        cfg.lookupValue("area7a.eyePositionPrefrerenceDistance", eyePositionPrefrerenceDistance);
        cfg.lookupValue("area7a.horVisualFieldSize", horVisualFieldSize);
        cfg.lookupValue("area7a.horEyePositionFieldSize", horEyePositionFieldSize);
        cfg.lookupValue("area7a.gaussianSigma", gaussianSigma);
        cfg.lookupValue("area7a.sigmoidSlope", sigmoidSlope);
        cfg.lookupValue("area7a.sigmoidModulationPercentage", sigmoidModulationPercentage);
        cfg.lookupValue("area7a.inputEncoding", tmp);
		inputEncoding = static_cast<INPUT_ENCODING>(tmp);
        
		// extrastriate
		Setting & extrastriate = cfg.lookup("extrastriate");
        
        numberOfLayers = extrastriate.getLength() + 1; // 1+ = input layer
        
        // Assume all layers have no history
        saveAllNeuronsAndSynapsesInRegion = false;
        saveAllNeuronsInRegion = false;
        saveSingleCells = false;
        
		for(int i = 0;i < extrastriate.getLength();i++) {
			
            tmp = static_cast<int>(extrastriate[i]["dimension"]);
			dimensions.push_back(tmp);
            
			depths.push_back(static_cast<u_short>(static_cast<int>(extrastriate[i]["depth"])));
            
            tmp = extrastriate[i]["connectivity"];
            connectivities.push_back(static_cast<CONNECTIVITY>(tmp));
            
			//fanInRadius.push_back(static_cast<u_short>(static_cast<int>(extrastriate[i]["fanInRadius"])));
			fanInCountPercentage.push_back(extrastriate[i]["fanInCountPercentage"]);
			epochs.push_back(static_cast<u_short>(static_cast<int>(extrastriate[i]["epochs"])));
			
			learningRates.push_back(extrastriate[i]["learningrate"]);
			etas.push_back(extrastriate[i]["eta"]);
			timeConstants.push_back(extrastriate[i]["timeConstant"]);
			sparsenessLevels.push_back(extrastriate[i]["sparsenessLevel"]);
			sigmoidSlopes.push_back(extrastriate[i]["sigmoidSlope"]);
            sigmoidThreshold.push_back(extrastriate[i]["sigmoidThreshold"]);
            globalInhibitoryConstant.push_back(extrastriate[i]["globalInhibitoryConstant"]);
            externalStimulation.push_back(extrastriate[i]["externalStimulation"]);

			inhibitoryRadius.push_back(extrastriate[i]["inhibitoryRadius"]);
			inhibitoryContrast.push_back(extrastriate[i]["inhibitoryContrast"]);
			somExcitatoryRadius.push_back(extrastriate[i]["somExcitatoryRadius"]);
			somExcitatoryContrast.push_back(extrastriate[i]["somExcitatoryContrast"]);
			somInhibitoryRadius.push_back(extrastriate[i]["somInhibitoryRadius"]);
			somInhibitoryContrast.push_back(extrastriate[i]["somInhibitoryContrast"]);
			filterWidth.push_back(static_cast<u_short>(static_cast<int>(extrastriate[i]["filterWidth"])));
            
            //blockageLeakTime.push_back(extrastriate[i]["blockageLeakTime"]);
			//blockageRiseTime.push_back(extrastriate[i]["blockageRiseTime"]);
			//blockageTimeWindow.push_back(extrastriate[i]["somInhibitoryContrast"]);
            
            tmp = extrastriate[i]["saveHistory"];
            saveHistory.push_back(static_cast<SAVEHISTORY>(tmp));
            
            switch (tmp) {
                    
                case SH_ALL_NEURONS_AND_SYNAPSES_IN_REGION:
                    saveAllNeuronsAndSynapsesInRegion = true;
                    break;
                    
                case SH_ALL_NEURONS_IN_REGION:
                    saveAllNeuronsInRegion = true;
                    break;
                
                case SH_SINGLE_CELLS:
                    saveSingleCells = true;
                    break;
            }

            // Add layer
            int dim = dimensions.back();
            vector<vector<short > > layer(dim, vector<short>(dim, 0)); // 0 == false
            recordedSingleCells.push_back(layer);
            nrOfRecordedSingleCells.push_back(0);
            
            // Set sentinel to true for selected cells
            if(tmp == SH_SINGLE_CELLS) {
                
                Setting & list = extrastriate[i]["recordedSingleCells"];
                
                nrOfRecordedSingleCells[i] = list.getLength();
                
                // Iterate list of cells and set value to true
                for(int c = 0;c < nrOfRecordedSingleCells[i];c++) {
                    
                    // Input is specified in MATLAB 1-based indexes
                    int row = list[c][0];
                    int col = list[c][1];
                    
                    // Check
                    if(row < dimensions[i] && col < dimensions[i] && row >= 0 && col >= 0) {
                        
                        if(!recordedSingleCells[i][row-1][col-1])
                            recordedSingleCells[i][row-1][col-1] = 1; // 1 == true
                        else {
                            
                            cerr << "recordedSingleCells is spesified twice: row =" << row << ",col =" << col << endl;
                            exit(EXIT_FAILURE);
                        }
                        
                    } else {
                        
                        cerr << "recordedSingleCells cell which is not inside layer: row =" << row << ",col =" << col << endl;
                        exit(EXIT_FAILURE);
                    }
                }
            }
		}

		validate(isTraining);
	}
	catch(const FileIOException &fioex) {
		cerr << "I/O error while reading parameter file: " << filename << endl;
        cerr.flush();
		exit(EXIT_FAILURE);
	}
	catch(const ParseException &pex) {
		cerr << "Parse error at " << pex.getFile() << ":" << pex.getLine()
		<< " - " << pex.getError() << "." << endl;
        cerr.flush();
		exit(EXIT_FAILURE);
	}
	catch(const SettingNotFoundException &nfex) {
		cerr << "Setting not found in file." << endl;
        cerr.flush();
		exit(EXIT_FAILURE);
	}
	catch(const SettingTypeException & stex) {
		cerr << "Setting had incompatible type." << endl;
        cerr.flush();
		exit(EXIT_FAILURE);
	}
	// add more exception support later, more cases, catch them all!
}

void Param::validate(bool isTraining) {

		float smallestTimeConstant = FLT_MAX;
		
		// Find the smallest time constant
		for(unsigned i = 0;i < timeConstants.size();i++) {
			smallestTimeConstant = smallestTimeConstant > timeConstants[i] ? timeConstants[i] : smallestTimeConstant;
			
			if(smallestTimeConstant <= 0) {
				cerr << "timeConstant cannot be zero." << endl;
                cerr.flush();
				exit(EXIT_FAILURE);
			}
		}
		
		stepSize = smallestTimeConstant * stepSizeFraction;
    
        cout << "dt = " << stepSize << endl;
    
        if(nrOfEpochs < 1) {
            cerr << "No training epochs, nrOfEpochs = 0." << endl;
            cerr.flush();
            exit(EXIT_FAILURE);
        }
	
	if(traceTimeConstant <= 0) {
		// Cannot be zero, because then traceFactor = -inf, 
		cerr << "traceFactor cannot be zero => traceFactor = -inf => trace = NaN => dW = NaN => firing/activation = NaN." << endl;
        cerr.flush();
		exit(EXIT_FAILURE);
	}
}

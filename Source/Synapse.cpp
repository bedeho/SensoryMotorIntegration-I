 /*
 *  Synapse.cpp
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "Synapse.h"
#include <cfloat>

Synapse::Synapse(float weight,
                 const Neuron * preSynapticNeuron,
                 const HiddenNeuron * postSynapticNeuron,
                 float * weightHistory)//
                 : // ,int fixedBufferWeightHistorySize)
                                                                                                    weight(weight), 
                                                                                                    preSynapticNeuron(preSynapticNeuron),
                                                                                                    postSynapticNeuron(postSynapticNeuron),
                                                                                                    weightHistory(weightHistory)//,
                                                                                                    //fixedBufferWeightHistorySize(fixedBufferWeightHistorySize)
{
    // Allocate buffer space.
    //fixedBufferWeightHistory = new float[fixedBufferWeightHistorySize];
    
    // Set with initial value of weight
    resetBlockage();
    
    
    
}
/*
float Synapse::getLast() {
    // The elemnt in the buffer directly behind (lower index, with wrap arround) the oldest, is the newest
    return fixedBufferWeightHistory[lastBufferElement];
}

void Synapse::savePresent() {

    // Save new addition in the position of the oldest
    fixedBufferWeightHistory[lastBufferElement] = weight;
    
    // move position of the oldest along
    lastBufferElement = (lastBufferElement == fixedBufferWeightHistorySize-1) ? 0 : lastBufferElement+1;
}

#include <iostream>
*/

void Synapse::resetBlockage() {
 
    blockage = 1;
    
    /*
    lastBufferElement = 0;
    blockage = 0;
    
    for(int i=0;i < fixedBufferWeightHistorySize;i++)
        fixedBufferWeightHistory[i] = weight;
    
    //std::cout << "RESET blockage" << std::endl;
    */
}


Synapse::~Synapse() {
    
    // DO NOT use this, since putting in vector calls this!! due to copying
    //std::cout << " DELETING!!!" << std::endl;
    //delete [] fixedBufferWeightHistory;
}

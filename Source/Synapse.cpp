 /*
 *  Synapse.cpp
 *  SMI
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "Synapse.h"
#include <cfloat>

Synapse::Synapse(float weight, const Neuron * preSynapticNeuron, const HiddenNeuron * postSynapticNeuron, float * weightHistory) :
                                                                                                    weight(weight), 
                                                                                                    preSynapticNeuron(preSynapticNeuron),
                                                                                                    postSynapticNeuron(postSynapticNeuron),
                                                                                                    weightHistory(weightHistory)
{}

Synapse::~Synapse() {}

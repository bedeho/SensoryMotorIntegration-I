/*
 *  Neuron.cpp
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "Neuron.h"

void Neuron::init(Region * region, u_short depth, u_short row, u_short col) {

	this->region = region;
    this->depth = depth;
    this->row = row;
    this->col = col;
    this->firingRate = 0;
	this->newFiringRate = 0;
}

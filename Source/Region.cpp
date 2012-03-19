/*
 *  Region.cpp
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "Region.h"
#include "Param.h"

void Region::init(u_short regionNr, Param & p) {
	
	this->regionNr = regionNr; 
    this->verDimension = p.dimensions[regionNr-1];
    this->horDimension = p.dimensions[regionNr-1];
    this->depth = p.depths[regionNr-1];
}

Region::~Region() {
}

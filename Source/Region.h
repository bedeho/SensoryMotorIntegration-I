/*
 *  Region.h
 *  SMI
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#ifndef REGION_H
#define REGION_H

// Forward declarations
class Neuron;
class Param;

// Includes
#include <vector>
#include "Utilities.h"

using std::vector;

class Region {
    	
	public:
        u_short regionNr, verDimension, horDimension, depth;
		
		// Init
		void init(u_short regionNr, Param & p);
		~Region();
		
		// Virtual method redefined in HiddenRegion/7a
		virtual Neuron * getNeuron(u_short depth, u_short row, u_short col) = 0;
};

#endif // REGION_H

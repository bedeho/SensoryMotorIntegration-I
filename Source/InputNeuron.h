/*
 *  InputNeuron.h
 *  SMI
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#ifndef INPUTNEURON_H
#define INPUTNEURON_H

// Forward declarations

// Includes
#include "Neuron.h"
#include "Utilities.h"

class InputNeuron : public Neuron {
    
    public: 
		float horEyePositionPreference;
        float horVisualPreference;
    
        float horEyePositionSigmoidSlope;
        float horVisualSigma;

		void init(Region * region, u_short depth, u_short row, u_short col, float horEyePositionPreference, float horEyePositionSigmoidSlope, float horVisualPreference, float horVisualSigma);
        void setFiringRate(const vector<float> & sample);
};

#endif // INPUTNEURON_H

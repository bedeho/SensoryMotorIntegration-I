/*
 *  InputNeuron.h
 *  SensoryMotorIntegration-I
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
#include "Param.h"
#include "Utilities.h"
#include <gsl/gsl_cdf.h>
#include <gsl/gsl_randist.h>

class InputNeuron : public Neuron {
    
    private:
    
        float horEyePositionPreference, horEyePositionPreference2;
        float horVisualPreference;
    
        float horEyePositionSigmoidSlope;
        float horVisualSigma;
    
        float peak1Magnitude, peak2Magnitude;
    
        // What modality does this neuron encode
        enum RESPONSE_FUNCTION {
        
            PURE_VISUAL = 1,
            PURE_PROPRIOCEPTIVE = 2, // gauss
            MULTIMODAL_GAUSS_MODULATION = 4,
            MULTIMODAL_DOUBLEGAUSS_MODULATION = 5,
            MULTIMODAL_SIGMOID_MODULATION = 6
        };
    
        RESPONSE_FUNCTION responseFunction;
    
        float computeRetinalComponent(const vector<float> & sample);
        float computeEyePositionCompononent(float eyePosition);
        
    public: 
    
        void init(Region * region,
                  u_short depth,
                  u_short row,
                  u_short col,
                  gsl_rng * rngController,
                  Param & p);
    
        void setFiringRate(const vector<float> & sample);
    
};

#endif // INPUTNEURON_H

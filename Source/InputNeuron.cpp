/*
 *  InputNeuron.h
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "InputNeuron.h"
#include "InputRegion.h"
#include <cmath>

//for debug purposes
#include <iostream>
using std::endl;
using std::cout;

void InputNeuron::init(Region * region, 
                       u_short depth, 
                       u_short row, 
                       u_short col,  
                       gsl_rng * rngController,
                       Param & p) {

    Neuron::init(region, depth, row, col);
    
    // type casted parent region
    InputRegion * r = static_cast<InputRegion *>(region);
    
    // dimensions
    u_short horVisualDimension = r->horVisualDimension;
    u_short horEyeDimension = r->horEyeDimension;
    
    // preferences
    vector<float> horVisualPreferences = r->horVisualPreferences;
    vector<float> horEyePreferences = r->horEyePreferences;
    
    this->horVisualPreference = horVisualPreferences[(horVisualDimension - 1) - row]; // flip it so that the first row prefers the rightmost (largest +) visual location
    this->horEyePositionPreference = horEyePreferences[col];

    // params
    this->horEyePositionSigmoidSlope = (depth == 0 ? p.sigmoidSlope : -1 * p.sigmoidSlope);
    this->horVisualSigma = p.gaussianSigma;
    
    this->peak1Magnitude = gsl_rng_uniform(rngController);
    this->peak2Magnitude = gsl_rng_uniform(rngController);
    
    // input encoding
    switch (p.inputEncoding) {
            
        case MIXED:
            
            if(gsl_ran_bernoulli(rngController, static_cast<double>(p.sigmoidModulationPercentage)))
                responseFunction = MULTIMODAL_SIGMOID_MODULATION;
            else
                responseFunction = MULTIMODAL_GAUSS_MODULATION;
            
            break;
            
        case DOUBLEPEAK_GAUSSIAN:
            
            // Only X % allowed to actually be double
            if(gsl_ran_bernoulli(rngController, 0.2)) {
            
                responseFunction = MULTIMODAL_DOUBLEGAUSS_MODULATION;
            
                this->horEyePositionPreference2 = horEyePreferences[gsl_rng_uniform_int(rngController, horEyeDimension)];
                
            } else
                responseFunction = MULTIMODAL_GAUSS_MODULATION;
            
            break;
            
        case DECOUPLED:
            
            if(gsl_ran_bernoulli(rngController, 0.5))
                responseFunction = PURE_VISUAL;
            else
                responseFunction = PURE_PROPRIOCEPTIVE;
            
            break;
            
        default:
            break;
    }

}

void InputNeuron::setFiringRate(const vector<float> & sample) {
    
    /* 
     * MATLAB:
     * % visual component
     * sigmoidPositive(j,i) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
     * sigmoidNegative(j,i) = exp(-(retinalPositions - v).^2/(2*gaussianSigma^2));
     *
     * % eye modulation
     * sigmoidPositive(j,i) = sigmoidPositive(j,i) * 1/(1 + exp(sigmoidSlope * (eyePosition - e))); % positive slope
     * sigmoidNegative(j,i) = sigmoidNegative(j,i) * 1/(1 + exp(-1 * sigmoidSlope * (eyePosition - e))); % negative slope
     */
    
    float retinalComponent = computeRetinalComponent(sample);
    float eyePositionComponent = computeEyePositionCompononent(sample.front());
    
    switch (responseFunction) {
            
        case PURE_VISUAL:
            
            this->firingRate = retinalComponent;
            break;
            
        case PURE_PROPRIOCEPTIVE:
            this->firingRate = eyePositionComponent;
            break;
            
        case MULTIMODAL_GAUSS_MODULATION:
        case MULTIMODAL_DOUBLEGAUSS_MODULATION:
        case MULTIMODAL_SIGMOID_MODULATION:
            this->firingRate = retinalComponent*eyePositionComponent;
            
            break;
            
        default:
            break;
    }
    
    this->newFiringRate = this->firingRate;
}

float InputNeuron::computeRetinalComponent(const vector<float> & sample) {
    
    float component = 0;
    
    // Iterate retinal locations of targets, do MAX routine
    for(unsigned i = 1;i < sample.size();i++) {
        
        float norm = (horVisualPreference - sample[i])*(horVisualPreference - sample[i]); // (a - b)^2
        float gauss = exp(-norm/(2*horVisualSigma*horVisualSigma)); // gaussian
        
        // MAX routine
        component = (gauss > component ? gauss : component);
        
        // CLASSIC
        //component += exp(-norm/(2*horVisualSigma*horVisualSigma)); // gaussian
    }
    
    return component; //peak1Magnitude
}

float InputNeuron::computeEyePositionCompononent(float eyePosition) {
    
    float component;
    
    switch (responseFunction) {
            
        case PURE_VISUAL:
            
            component = 0;
            break;
            
        case PURE_PROPRIOCEPTIVE:
        case MULTIMODAL_GAUSS_MODULATION:
            
            component = exp(-(eyePosition - horEyePositionPreference)*(eyePosition - horEyePositionPreference)/(2*horVisualSigma*horVisualSigma)); // peak1Magnitude
            break;
            
        case MULTIMODAL_DOUBLEGAUSS_MODULATION:
            
            component = exp(-(eyePosition - horEyePositionPreference)*(eyePosition - horEyePositionPreference)/(2*horVisualSigma*horVisualSigma)); // peak1Magnitude
            component += peak2Magnitude*exp(-(eyePosition - horEyePositionPreference2)*(eyePosition - horEyePositionPreference2)/(2*horVisualSigma*horVisualSigma));
            break;
            
        case MULTIMODAL_SIGMOID_MODULATION:
            
            component = 1/(1 + exp(horEyePositionSigmoidSlope * (eyePosition - horEyePositionPreference))); // peak1Magnitude
            break;
            
        default:
            break;
    }
    
    return component;
}

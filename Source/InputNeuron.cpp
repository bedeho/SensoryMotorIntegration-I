/*
 *  InputNeuron.h
 *  SensoryMotorIntegration-I
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "InputNeuron.h"
#include <cmath>

void InputNeuron::init(Region * region, u_short depth, u_short row, u_short col, float horEyePositionPreference, float horEyePositionSigmoidSlope, float horVisualPreference, float horVisualSigma, INPUT_EYE_MODULATION modulationType) {

    Neuron::init(region, depth, row, col),
    
	this->horEyePositionPreference = horEyePositionPreference;
	this->horEyePositionSigmoidSlope = horEyePositionSigmoidSlope;
    this->horVisualPreference = horVisualPreference;
    this->horVisualSigma = horVisualSigma;
    this->modulationType = modulationType;
}

#include <iostream>
using std::endl;
using std::cout;

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
    
    /*
     * FLAW
    // iterate all visual stimuli and compute gaussian of all
    float norm = 0;
    for(unsigned i = 1;i < sample.size();i++)
        norm += (horVisualPreference - sample[i])*(horVisualPreference - sample[i]); // (a - b)^2
    
    // firing = sigmoid * gaussian
    float firing;
    firing  = 1 / (1 + exp(horEyePositionSigmoidSlope * (sample.front() - horEyePositionPreference))); // sigmoid
    //firing  = exp((-(sample.front() - horEyePositionPreference) * (sample.front() - horEyePositionPreference))/(2*horVisualSigma*horVisualSigma) ); // sigmoid
    firing *= exp(-norm/(2*horVisualSigma*horVisualSigma)); // gaussian
    */
    
    // NEW WORKING VERSION!
    // iterate all visual stimuli and compute gaussian of all
    // firing = sigmoid(gauss_1 + ... + gauss_n)
    float firing = 0;
    
    for(unsigned i = 1;i < sample.size();i++) {
        
        float norm = (horVisualPreference - sample[i])*(horVisualPreference - sample[i]); // (a - b)^2
        firing += exp(-norm/(2*horVisualSigma*horVisualSigma)); // gaussian
    }
    
    if(modulationType == SIGMOID)
        firing *= 1 / (1 + exp(horEyePositionSigmoidSlope * (sample.front() - horEyePositionPreference))); // sigmoid
    else if(modulationType == GAUSSIAN)
        firing *= exp(-(sample.front() - horEyePositionPreference)*(sample.front() - horEyePositionPreference)/(2*horVisualSigma*horVisualSigma)); // gaussian
    
    // Set variables
    this->firingRate = firing;
    this->newFiringRate = firing;
}

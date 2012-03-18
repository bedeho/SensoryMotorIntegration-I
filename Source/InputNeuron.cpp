/*
 *  InputNeuron.h
 *  SMI
 *
 *  Created by Bedeho Mender on 17/11/11.
 *  Copyright 2011 OFTNAI. All rights reserved.
 *
 */

#include "InputNeuron.h"
#include <cmath>

void InputNeuron::init(Region * region, u_short depth, u_short row, u_short col, float horEyePositionPreference, float horEyePositionSigmoidSlope, float horVisualPreference, float horVisualSigma) {

    Neuron::init(region, depth, row, col),
    
	this->horEyePositionPreference = horEyePositionPreference;
	this->horEyePositionSigmoidSlope = horEyePositionSigmoidSlope;
    this->horVisualPreference = horVisualPreference;
    this->horVisualSigma = horVisualSigma;
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
    
    // iterate all visual stimuli and compute gaussian of all
    float norm = 0;
    for(unsigned i = 1;i < sample.size();i++)
        norm += (horVisualPreference - sample[i])*(horVisualPreference - sample[i]); // (a - b)^2
    
    /*if(norm < horVisualSigma) {
        cout << "yey" << endl;
    }*/
    
    float t = exp((float)5); // - horEyePositionPreference, sample.front()
    t = 9;
    
    // firing = sigmoid * gaussian
    float firing;
    firing  = 1 / (1 + exp(horEyePositionSigmoidSlope * (sample.front() - horEyePositionPreference))); // sigmoid
    //firing  = exp((-(sample.front() - horEyePositionPreference) * (sample.front() - horEyePositionPreference))/(2*horVisualSigma*horVisualSigma) ); // sigmoid
    firing *= exp(-norm/(2*horVisualSigma*horVisualSigma)); // gaussian
    
    /*
    if(firing > 0.5) {
        cout << "loaded firing" << endl;
    }*/
    
    // Set variables
    this->firingRate = firing;
    this->newFiringRate = firing;
}

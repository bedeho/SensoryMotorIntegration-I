#ifndef UTILITIES_H
#define UTILITIES_H

#ifndef DEBUG
#define OMP_ENABLE
#endif

#if defined(_WIN32) || defined(WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__BORLANDC__)
#define OS_WIN
#endif

typedef unsigned short u_short;

enum DATA { 
    FIRING_RATE = 0,
    ACTIVATION = 1,
    INHIBITED_ACTIVATION = 2,
    TRACE = 3,
    STIMULATION = 4,
    EFFECTIVE_TRACE = 5,
    FAN_IN_COUNT = 6,
    WEIGHTS_FINAL = 7,
    WEIGHT_HISTORY = 8,
    WEIGHT_AND_NEURON_HISTORY = 9};

/*
 if(p.connectivity == SPARSE) {
 
 u_short connectionsMade = 0;
 u_short desiredFanIn = p.fanInCount[region->regionNr - 1];
 
 while(connectionsMade < desiredFanIn) {
 
 // Sample location
 int rowSource, colSource;
 samplePresynapticLocation(horVisualDimension, horEyeDimension, desiredFanIn, rngController, rowSource, colSource);
 
 // Subsample depth
 u_short d =  gsl_rng_uniform_int (rngController, preSynapticRegion.depth);
 
 // Grab neuron
 Neuron * preSynapticNeuron = preSynapticRegion.getNeuron(d, i, j);
 
 // Make sure we don't reconnect
 if(!areYouConnectedTo(preSynapticNeuron)) {
 
 float weight = p.initialWeight != ZERO ? static_cast<float>(gsl_rng_uniform(rngController)) : 0;
 
 addAfferentSynapse(weight, preSynapticNeuron);
 
 connectionsMade++;
 }
 }
 
 
 } 
*/
/*

void HiddenNeuron::setupAfferentSynapses(InputRegion & preSynapticRegion, Param & p, gsl_rng * rngController) {
    
    if(p.connectivity == FULL)
        for(int d = 0;d < preSynapticRegion.depth;d++)
            for(int i = 0;i < preSynapticRegion.horVisualDimension;i++)
                for(int j = 0;j < preSynapticRegion.horEyeDimension;j++) {
                    
                    Neuron * preSynapticNeuron = preSynapticRegion.getNeuron(d, i, j);
                    float weight = p.initialWeight != ZERO ? static_cast<float>(gsl_rng_uniform(rngController)) : 0;
                    
                    addAfferentSynapse(weight, preSynapticNeuron);
                }
}

void HiddenNeuron::setupAfferentSynapses(HiddenRegion & preSynapticRegion, Param & p, gsl_rng * rngController) {
    
    if(p.connectivity == FULL)
        for(int i = 0;i < preSynapticRegion.dimension;i++)
            for(int j = 0;j < preSynapticRegion.dimension;j++) {
                
                Neuron * preSynapticNeuron = preSynapticRegion.getNeuron(0, i, j);
                float weight = p.initialWeight != ZERO ? static_cast<float>(gsl_rng_uniform(rngController)) : 0;
                
                addAfferentSynapse(weight, preSynapticNeuron);
            }
}
*/

/*
 void HiddenNeuron::addAfferentSynapse(float weight, const Neuron * preSynapticNeuron) {
 
 Neuron * preSynapticNeuron = preSynapticRegion.getNeuron(d, i, j);
 float weight = p.initialWeight != ZERO ? static_cast<float>(gsl_rng_uniform(rngController)) : 0;
 
 afferentSynapses.push_back(Synapse(weight, preSynapticNeuron, this, nrOfSavedSynapseStates));
 numberOfAfferentSynapses = afferentSynapses.size();
 }
 
 // I dont bother removing either, future may require them being distinct
 void HiddenNeuron::setupAfferentSynapses(InputRegion & preSynapticRegion, Param & p, gsl_rng * rngController) {
 
 if(p.connectivity == FULL) {
 for(int d = 0;d < preSynapticRegion.depth;d++)
 for(int i = 0;i < preSynapticRegion.horVisualDimension;i++)
 for(int j = 0;j < preSynapticRegion.horEyeDimension;j++) {
 
 Neuron * preSynapticNeuron = preSynapticRegion.getNeuron(d, i, j);
 float weight = p.initialWeight != ZERO ? static_cast<float>(gsl_rng_uniform(rngController)) : 0;
 
 addAfferentSynapse(weight, preSynapticNeuron);
 }
 }
 }
 
 void HiddenNeuron::setupAfferentSynapses(HiddenRegion & preSynapticRegion, Param & p, gsl_rng * rngController) {
 
 if(p.connectivity == FULL) {
 for(int d = 0;d < preSynapticRegion.depth;d++)
 for(int i = 0;i < preSynapticRegion.dimension;i++)
 for(int j = 0;j < preSynapticRegion.dimension;j++)
 addAfferentSynapse(weight, preSynapticNeuron);
 
 } else(p.connectivity == SPARSE) {
 
 }
 }
 */
#endif // UTILITIES_H

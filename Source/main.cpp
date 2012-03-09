
#include "Network.h"
#include <iostream>
#include <cstring>
#include <string>
#include <cstdlib>

#ifdef OMP_ENABLE
	#include <omp.h>
#endif

using std::cout;
using std::cin;
using std::cerr;
using std::endl;
using std::string;

void usage();

int main (int argc, char *argv[]) {

	// Iterate command line options
	bool verbose = false;
	bool xgrid = false;
	
	#ifdef OMP_ENABLE
		int numberOfThreads = (3 * omp_get_num_procs())/4; // Ben's advice, use 75% of cores
	#else
		int numberOfThreads = 1;
	#endif
    
	int i = 1;
	for(;i < argc;i++) {

		if(argv[i][0] != '-' || argv[i][1] != '-')	// break on first non-option token
			break;
		if(strcmp("--help", argv[i]) == 0) {
			usage();
			return 0;
		}
		else if(strcmp("--verbose", argv[i]) == 0)
			verbose = true;
		else if(strcmp("--xgrid", argv[i]) == 0)
			xgrid = true;
		else if(strcmp("--singlethreaded", argv[i]) == 0)
			numberOfThreads = 1;
		else {
			cout << "Unknown option: " << argv[i] << endl;
			usage();
			return 1;
		}
	}
    
	// Iterate command line arguments
	if(argc - i < 3)
		cout << "Expected atleast three arguments." << endl;
	else {
        
        const char * paramFile = NULL, 
                    * net = NULL, 
                    * dataFile = NULL, 
                    * outputDir = NULL;

		if(strcmp("build", argv[i]) == 0) {

			if(argc - i != 3)
				cout << "Expected three arguments: build <parameter file> <output directory>" << endl;
			else {
                
                paramFile = argv[i + 1];
                outputDir = argv[i + 2];
                
				cout << "Building network..." << endl;
				Network n(paramFile, verbose);

				cout << "Saving network..." << endl;
				string s(outputDir);
				s.append("BlankNetwork.txt");
				n.outputFinalNetwork(s.c_str());
			}

		} else if(strcmp("train", argv[i]) == 0) {
			
            paramFile = argv[i + 1];
            net = argv[i + 2];

			if(xgrid) {
				
				if(argc - i != 3) {
                    
					cout << "Expected three arguments: train <parameter file> <untrained network file>" << endl;
					return 1;
                    
				} else {
                    
                    dataFile = "data.dat";
                    outputDir = "./";
                    
                    #ifndef OS_WIN
                        system("tar -xjf xgridPayload.tbz"); // On linux/mac we must untar result when xgrid is used
                    #endif
                    
				}
				
			} else {
				
				if(argc - i != 5) {
                    
					cout << "Expected five arguments: train <parameter file> <untrained network file> <data file> <output directory>" << endl;
					return 1;
                    
				} else {
                    
					dataFile = argv[i + 3];
					outputDir = argv[i + 4];
				}
			}
			
			cout << "Loading network..." << endl;
			Network n(dataFile, paramFile, verbose, net, true);
			
			cout << "Training network..." << endl;
			n.run(outputDir, true, numberOfThreads, xgrid);

			cout << "Saving network..." << endl;
			string s(outputDir);
			s.append("TrainedNetwork.txt");
			n.outputFinalNetwork(s.c_str());
			
			#ifndef OS_WIN
                // On linux/mac we tar and cleanup when xgrid is used
                if(xgrid) {
                    system("tar -cjf result.tbz *.dat"); // tar results
                    system("rm *.dat"); // delete all original result files
                }			
			#endif
			
		} else if(strcmp("test", argv[i]) == 0) {
			
			if(xgrid) {
				cerr << "No support for testing on grid..." << endl;
				return 1;
			} else if(argc - i != 5) {
				cout << "Expected five arguments: test <parameter file> <trained network file> <data file> <output directory>" << endl;
				return 1;
			}
            
            paramFile = argv[i + 1];
            net = argv[i + 2];
            dataFile = argv[i + 3];
            outputDir = argv[i + 4];

			cout << "Loading network..." << endl;
			Network n(dataFile, paramFile, verbose, net, false);

			cout << "Testing network..." << endl;
			n.run(outputDir, false, numberOfThreads, xgrid);

		} else if(strcmp("loadtest", argv[i]) == 0) {
            
            /*
             * add parsing later
             */
            
            paramFile = argv[i + 1];
            net = argv[i + 2];
            outputDir = argv[i + 3];

			cout << "Loading network..." << endl;
			Network n(NULL, paramFile, verbose, net, false);

			cout << "Saving network..." << endl;
			string s(outputDir);
			s.append("LOADTEST.txt");
			n.outputFinalNetwork(s.c_str()); 
		}
		else
			cout << "Unknown command." << endl;
        
        cout << "Finished." << endl;
	}
}

void usage() {

	cout << endl;
	cout << "usage: smi [--help] [--verbose]  [--xgrid] [--multicore] " << endl; // [--silent]
    cout << "               COMMAND ARGS" << endl;
    cout << endl;
    cout << "The command list for smi is:" << endl;

	cout << "\t build\t Build new network." << endl;
	cout << "\t\t\t build <parameter file> <output directory>" << endl;

	cout << "\t run\t Train built network." << endl;
	cout << "\t\t\t  train <parameter file> <untrained network file> <data file> <output directory>" << endl;

	cout << "\t run\t Test trained network." << endl;
	cout << "\t\t\t  test <parameter file> <untrained network file> <data file> <output directory>" << endl;
}
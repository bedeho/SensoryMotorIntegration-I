/*
 *  BinaryRead.cpp
 *  SMI
 *
 *  Created by Bedeho Mender on 05/03/12.
 *  Copyright 2012 OFTNAI. All rights reserved.
 *
 */

// Forward declarations

// Includes
#include "BinaryRead.h"

using std::cerr;
using std::endl;

BinaryRead::BinaryRead() : fstream() {}

BinaryRead::BinaryRead(const char * filename) : fstream() { openFile(filename); }

BinaryRead::BinaryRead(const string & filename) : fstream() { openFile(filename); }

void BinaryRead::openFile(const string & filename) { openFile(filename.c_str()); }

void BinaryRead::openFile(const char * filename) {
    
    this->filename = filename;
    
    exceptions( std::ios_base::badbit | std::ios_base::failbit);    
    // badbit  = fatal i/o error, e.g. file does note exist
    // failbit = non-fatal i/o error, e.g. eof reached
    
    // Open file
	try {
		open(filename, std::ios_base::in | std::ios_base::binary);
	} catch (fstream::failure e) {
        
        cerr << "Unable to open file " << filename << " for reading: " << strerror(errno) << endl;
        cerr.flush();
        exit(EXIT_FAILURE);
	}
}

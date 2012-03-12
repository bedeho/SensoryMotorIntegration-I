/*
 *  BinaryWrite.h
 *  SMI
 *
 *  Created by Bedeho Mender on 05/03/11.
 *  Copyright 2012 OFTNAI. All rights reserved.
 *
 */

#ifndef BINARYWRITE_H
#define BINARYWRITE_H

// Forward declarations

// Includes
#include <fstream>
#include <string>
#include <iostream>
#include <errno.h>

using std::string;
using std::fstream;
using std::cerr;
using std::endl;

class BinaryWrite : public fstream {

	private:   
        const char * filename;
    
    public: 
        
        // Constructors
        BinaryWrite();
		BinaryWrite(const char * filename);
		BinaryWrite(const string & filename);
    
        void openFile(const char * file);
        void openFile(const string & file);

        // Overloaded output/input ops. resp.
        template <class T> BinaryWrite & operator<<(T val);
};

// We include code here because of templates definitions having to be visible at compile time
// in each translation unit

template <class T>
BinaryWrite & BinaryWrite::operator<<(T val) {
    
    try {

        write(reinterpret_cast<char*>(&val), sizeof(T));
    
    } catch (fstream::failure e) {
    
        cerr << "Unable to write to " << filename << ": " << e.what() << endl;
        cerr.flush();
        exit(EXIT_FAILURE);
    }
    
    return *this;
}
#endif // BINARYWRITE_H
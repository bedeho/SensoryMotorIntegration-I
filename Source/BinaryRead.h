/*
 *  BinaryRead.h
 *  SMI
 *
 *  Created by Bedeho Mender on 05/03/11.
 *  Copyright 2012 OFTNAI. All rights reserved.
 *
 */

#ifndef BINARYREAD_H
#define BINARYREAD_H

// Forward declarations

// Includes
#include <fstream>
#include <string>
#include <iostream>
#include <cerrno>

using std::string;
using std::fstream;
using std::cerr;
using std::endl;

class BinaryRead : public fstream {

	private:
        const char * filename;
    
    public: 
        
        // Constructors
        BinaryRead();
		BinaryRead(const char * filename);
		BinaryRead(const string & filename);
    
        void openFile(const char * file);
        void openFile(const string & file);

        // Overloaded output/input ops. resp.
        template <class T> BinaryRead & operator>>(T& val);
};

// We include code here because of templates definitions having to be visible at compile time
// in each translation unit

// We use reference here since we have to write to it
template <class T>
BinaryRead & BinaryRead::operator>>(T& val) {
    
    read(reinterpret_cast<char*>(&val), sizeof(T));
    return *this;
}

#endif // BINARYREAD_H

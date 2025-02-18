#ifndef DECODER_H
#define DECODER_H

#include "systemc.h"

SC_MODULE(decoder){
    sc_in < sc_uint<16> > instruction;//instruction from pattern
    sc_out < sc_uint<3> > opcode;//to ALU unit, decide which operation ALU unit do calculate
    sc_out < sc_uint<4> > rs;//an address to register unit, register unit will output the corresponding data to ALU unit
    sc_out < sc_uint<4> > rt;//an address to register unit, register unit will output the corresponding data to ALU unit
    sc_out < sc_uint<5> > immediate;//this signal represent the Memory address where your ALU output result need to go, and your ALU unit also need this to do some of the operation
    


    SC_CTOR(decoder){
        SC_METHOD(Decoder);
        sensitive << instruction;
    }

    void Decoder(){
        opcode.write(instruction.read().range(15, 13));
        rs.write(instruction.read().range(12, 9));
        rt.write(instruction.read().range(8, 5));
        immediate.write(instruction.read().range(4, 0));
    }
    
};
#endif


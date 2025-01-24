#ifndef ALU_H
#define ALU_H

#include "systemc.h"
#include <bitset>

SC_MODULE(ALU){
    sc_in < sc_uint<3> > opcode;//opcode from decoder, to decide which operation ALU unit do calculate
    sc_in < sc_int<16> > rs_data;//rs_data from register, data from register[rs] to calculate in ALU unit
    sc_in < sc_int<16> > rt_data;//rt_data from register, data from register[rt] to calculate in ALU unit
    sc_in < sc_uint<5> > immediate;//immediate from decoder, data from instruction to calculate in ALU unit
    sc_out < sc_int<16> > ALU_out;//after your calculation, put your result in this port

    SC_CTOR(ALU){
        SC_METHOD(alu);
        sensitive << opcode << rs_data << rt_data << immediate;
        dont_initialize();
    }

    void alu(){
        sc_uint<3> opcode_in;
        sc_int<16> rs_in, rt_in;
        sc_uint<5> immediate_in;

        opcode_in = opcode.read();
        rs_in = rs_data.read();
        rt_in = rt_data.read();
        immediate_in = immediate.read();

        if(opcode_in == 0)
            ALU_out.write(rs_in + rt_in);
        else if(opcode_in == 1)
            ALU_out.write(rs_in * rt_in);
        else if(opcode_in == 2)
            ALU_out.write(rs_in & rt_in);
        else if(opcode_in == 3)
            ALU_out.write(~rs_in);
        else if(opcode_in == 4){
            if(rs_in >= 0)
                ALU_out.write(rs_in);
            else
                ALU_out.write(-rs_in);
        }
        else if(opcode_in == 5){
            if(rs_in >= rt_in)
                ALU_out.write(rt_in);
            else
                ALU_out.write(rs_in);
        }
        else if(opcode_in == 6)
            ALU_out.write(rs_in << immediate_in.to_uint());
        else if(opcode_in == 7)
            if(immediate_in[4] == 0)
                ALU_out.write(rs_in + immediate_in);
            else
                ALU_out.write(rs_in + immediate_in - 32);
    }
  
};

#endif

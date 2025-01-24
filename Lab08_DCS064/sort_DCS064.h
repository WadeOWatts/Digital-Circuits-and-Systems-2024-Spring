#ifndef SORT_H
#define SORT_H

#include <systemc.h>

SC_MODULE(stable_sort_6_value) {
    // Input signals
    sc_in<sc_uint<48>> in_Aid_all;
    sc_in<sc_uint<48>> in_CNT_all;

    // Output signals
    sc_out<sc_uint<48>> out_Aid_all;
    sc_out<sc_uint<48>> out_CNT_all;

    // Internal signals
    sc_uint<8> bubble [6][2];
    sc_uint<8> temp_cnt, temp_aid;
    sc_uint<48> concate_Aid_all;
    sc_uint<48> concate_CNT_all;


    // Process Declaration

    void Bubble(){
        for(int i = 0; i < 6; i++){
            bubble[i][1] = in_CNT_all.read().range(8*i+7, 8*i);
            bubble[i][0] = in_Aid_all.read().range(8*i+7, 8*i);
        }

        for(int i = 0; i < 5; i++){
            for(int j = 0; j < 5-i; j++){
                if(bubble[j][1] > bubble[j+1][1]){
                    temp_cnt = bubble[j][1];
                    temp_aid = bubble[j][0];
                    bubble[j][1] = bubble[j+1][1];
                    bubble[j][0] = bubble[j+1][0];
                    bubble[j+1][1] = temp_cnt;
                    bubble[j+1][0] = temp_aid;
                }
            }
        }

        concate_Aid_all = (bubble[5][0], bubble[4][0], bubble[3][0], bubble[2][0], bubble[1][0], bubble[0][0]);
        concate_CNT_all = (bubble[5][1], bubble[4][1], bubble[3][1], bubble[2][1], bubble[1][1], bubble[0][1]);

        out_Aid_all.write(concate_Aid_all);
        out_CNT_all.write(concate_CNT_all);
    }

    // Constructor
    SC_CTOR(stable_sort_6_value){
        SC_METHOD(Bubble);
        sensitive << in_Aid_all << in_CNT_all;
    }
};
#endif
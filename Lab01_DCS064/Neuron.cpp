#include "Neuron.h"

void Neuron::neuron() {
	// ----- put your code here -----
    X = input1.read() * w1;
	Y = input2.read() * w2;
	output_temp = X + Y;
	output.write(ReLU(output_temp + b));
    
    
	// ------------------------------
}
float Neuron::ReLU(float x){
	if(x >= 0)
		return x;
	else
		return 0.0;	
}


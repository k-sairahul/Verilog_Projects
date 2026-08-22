This design uses AXI4-Stream Handshaking protocol to perform Fast Fourier Transform in DIF style.  
**Latency = 8 Clocks**; after AXI system passed all inputs to internal FFT Hardware.  
After that, for each clock, one output is observed.

Since in real-time, no imaginary inputs are generated. This hardware considers imaginary inputs as zero by default.

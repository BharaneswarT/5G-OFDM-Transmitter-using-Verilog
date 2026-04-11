Hi Recruters, PLEASE GIMME A CHANCE ;) 

This is a complete 4-point Cyclic Prefix Orthogonal Frequency Division Multiplexing (CP-OFDM) baseband transceiver implemented in Verilog HDL and simulated on ModelSim.
This project demonstrates core physical layer (PHY) concepts used in modern wireless communication systems such as 4G LTE and 5G.

TRANSMITTER PART ---> (Bits → 16-QAM → IFFT → Cyclic Prefix)
     -> 16-QAM Modulation: Maps 4-bit input data to complex constellation points. Has Imaginary and Real component.
     -> Radix-4 DIT IFFT: Converts frequency-domain symbols to time-domain signals.
     -> Cyclic Prefix Insertion: Adds guard interval by copying the last sample to the front to combat Inter-Symbol Interference (ISI).

RECEIVER PART ---> (CP Removal → FFT → 16-QAM Demodulation → Serial Output)
     -> Cyclic Prefix Removal: Discards the CP before FFT processing
     -> Radix-4 DIT FFT: Recovers frequency-domain symbols from the received time-domain signal
     -> 16-QAM Demodulation: Recovers original 4-bit data using nearest neighbor decision
     -> Serial Output: Converts demodulated bits into serial stream

The design uses synchronous pipeline architecture with valid handshake signals for clean data flow between stages. 
End-to-end simulation shows error-free symbol recovery in the ideal channel conditions.

Transmitter Result:
<img width="1920" height="1022" alt="Transmitter_result" src="https://github.com/user-attachments/assets/039f524b-fdc3-4f38-9a1b-bc2154b1f63c" />

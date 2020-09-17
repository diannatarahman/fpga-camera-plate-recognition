# fpga-camera-plate-recognition
Undergraduate thesis project about FPGA based vehicle number plate recognition

# Required devices
1. Nexys3 Spartan-6 FPGA Board Xilinx
2. OV7670 Camera Module
3. VGA Monitor

# How it works
The FPGA Board will be programmed with these major blocks being implemented:

**Camera controller -> SCCB interface** -> (OV7670 Camera Module) -> **image capture interface -> memory -> number plate recognition -> VGA driver** -> (Monitor)

The algorithm of the number plate recognition based on known image processing techniques (vertical edge detection, thresholding, clipping / cropping based on projection analysis, weighted average downsampling) then the final OCR (Optical Character Recognition) is simply compare with reference images and choose the one with lowest error / distance.

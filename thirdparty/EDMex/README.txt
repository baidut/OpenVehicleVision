IMPORTANT NOTES:
1	The Microsoft Visual C++ 2012 Redistributable Package (x64) is required for this code to run. It is included as "vcredist_x64.exe" to the contents.
2	64-bit Windows is required.

For extra information, visit:
http://ceng.anadolu.edu.tr/cv/

This package includes the .mex files and wrapper functions for the following methods:
ED (Edge Drawing)
EDPF (Parameter Free Edge Drawing)
EDLines (regular EDLines)
EDPFLines (EDLines using EDPF)

It is recommended to use the wrapper functions rather than the .mex functions. Examples on how these functions are used are provided as test scripts.
For example:
Running EDTest.m calls the wrapper function ED.m which calls the EDmex.mexw64. It loads lab.jpg and plots the results. When writing your own code, use ED.m.






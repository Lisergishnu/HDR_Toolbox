%
%       HDR Toolbox demo build radiance map:
%	   1) Read a stack of LDR images
%	   2) Align the stack
%	   3) Read exposure values from the exif
%	   4) Build the radiance map using the stack and stack_exposure
%	   5) Save the radiance map in .hdr format
%	   6) Show the tone mapped version of the radiance map
%       Author: Francesco Banterle
%       Copyright June 2013 (c)
%
%

disp('1) Read a stack of LDR images');
stack = ReadLDRStack('stack_alignment', 'JPG')/255.0;

disp('2) Align the stack');
stackOut = SiftAlignment(stack, 1, '', '');
clear('stack');

disp('3) Read exposure values from the exif');
stack_exposure = ReadLDRExif('stack_alignment', 'jpg');

disp('4) Build the radiance map using the stack and stack_exposure');
imgHDR = BuildHDR([], [], 'tabledDeb97', 'Gauss', stackOut, stack_exposure);

disp('5) Save the radiance map in the .hdr format');
hdrimwrite(imgHDR,'example_build_sift_alignment.hdr');

disp('6) Show the tone mapped version of the radiance map');
GammaTMO(ReinhardBilTMO(imgHDR), 2.2, 0, 1);
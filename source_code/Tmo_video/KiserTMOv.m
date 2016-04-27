function KiserTMOv(hdrv, filenameOutput, tmo_alpha_coeff, tmo_dn_clamping, tmo_gamma, tmo_quality, tmo_video_profile)
%
%
%      KiserTMOv(hdrv, filenameOutput, tmo_alpha_coeff, tmo_dn_clamping, tmo_gamma, tmo_quality, tmo_video_profile)
%
%
%       Input:
%           -hdrv: a HDR video structure; use hdrvread to create a hdrv
%           structure
%           -filenameOutput: output filename (if it has an image extension,
%           single files will be generated)
%           -tmo_alpha_coeff: \alpha_A, \alpha_B, \alpha_C coefficients
%           costants in the paper (Equation 3a, 3b, and 3c)
%           -tmo_dn_clamping: a boolean value (0 or 1) for setting black
%           and white levels clamping
%           -tmo_gamma: gamma for encoding the frame
%           -tmo_quality: the output quality in [1,100]. 100 is the best quality
%           1 is the lowest quality.%
%           -tmo_video_profile: the compression profile (encoder) for compressing the stream.
%           Please have a look to the profile of VideoWriter from the MATLAB
%           help. Depending on the version of MATLAB some profiles may be not
%           be present.
%
%     Copyright (C) 2013-15 Francesco Banterle
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%     The paper describing this technique is:
%     "Real-time Automated Tone Mapping System for HDR Video"
% 	  by Chris Kiser, Erik Reinhard, Mike Tocci and Nora Tocci
%     in IEEE International Conference on Image Processing, 2012 
%
%

if(~exist('tmo_alpha_coeff', 'var'))
    tmo_alpha_coeff = 0.98;
end

if(~exist('tmo_dn_clamping', 'var'))
    tmo_dn_clamping = 0;
end

if(~exist('tmo_gamma', 'var'))
    tmo_gamma = 2.2;
end

if(tmo_gamma<0)
    bsRGB = 1;
else
    bsRGB = 0;
end

if(~exist('tmo_quality', 'var'))
    tmo_quality = 95;
end

if(~exist('tmo_video_profile', 'var'))
    tmo_video_profile = 'Motion JPEG AVI';
end

name = RemoveExt(filenameOutput);
ext  = fileExtension(filenameOutput);

bVideo = 0;
writerObj = 0;

if(strfind(ext, 'avi') | strfind(ext, 'mp4'))
    bVideo = 1;
    writerObj = VideoWriter(filenameOutput, tmo_video_profile);
    writerObj.FrameRate = hdrv.FrameRate;
    writerObj.Quality = tmo_quality;
    open(writerObj);
end

hdrv = hdrvopen(hdrv, 'r');

disp('Tone Mapping...');
tmo_alpha_coeff_c = 1.0 - tmo_alpha_coeff;

beta_clamping   = 0.999;
beta_clamping_c = (1.0 - beta_clamping);

for i=1:hdrv.totalFrames
    disp(['Processing frame ', num2str(i)]);
    [frame, hdrv] = hdrvGetFrame(hdrv, i);
    
    %Only physical values
    frame = RemoveSpecials(frame);
    frame(frame<0) = 0;
    
    if(tmo_dn_clamping)%Clamping black and white levels
        L = RemoveSpecials(lum(frame));
        %computing CDF's histogram 
        [histo, bound, ~] = HistogramHDR(L, 256, 'log10', [], 1);  
        histo_cdf = cumsum(histo);
        histo_cdf = histo_cdf/max(histo_cdf(:));
        [~, ind] = min(abs(histo_cdf - beta_clamping));
        maxL = 10^(ind*(bound(2) - bound(1)) / 256 + bound(1));

        [~, ind] = min(abs(histo_cdf-beta_clamping_c));
        minL = 10^(ind*(bound(2) - bound(1)) / 256 + bound(1));

        frame(frame > maxL) = maxL;
        frame(frame < minL) = minL;
        frame = frame - minL;
    end
   
    %computing statistics for the current frame
    L = lum(frame);
    Lav = logMean(L);
    A = max(L(:)) - Lav;
    B = Lav - min(L(:));
   
    if(i == 1)
        Aprev = A;
        Bprev = B;
        aprev = 0.18 * 2^(2 * (B - A) / (A + B));
    end
    
    %temporal average
    An = tmo_alpha_coeff_c * Aprev + tmo_alpha_coeff * A;
    Bn = tmo_alpha_coeff_c * Bprev + tmo_alpha_coeff * B;

    a = 0.18 * 2^(2 * (Bn - An) / (An + Bn));
    an = tmo_alpha_coeff_c * aprev + tmo_alpha_coeff * a;
    
    %tone mapping
    [frameOut, ~, ~] = ReinhardTMO(frame, an);

    %Gamma/sRGB encoding
    if(bsRGB)
        frameOut = ClampImg(ConvertRGBtosRGB(frameOut, 0), 0, 1);
    else
        frameOut = ClampImg(GammaTMO(frameOut, tmo_gamma, 0, 0), 0, 1);
    end
    
    if(bVideo)
        writeVideo(writerObj, frameOut);
    else
        imwrite(frameOut, [name, sprintf('%.10d',i), '.', ext]);
    end
    
    %updating for the next frame
    Aprev = A;
    Bprev = B;
    aprev = a;   
end
disp('OK');

if(bVideo)
    close(writerObj);
end

hdrvclose(hdrv);

end

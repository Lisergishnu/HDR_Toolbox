function [lin_fun, pp, err] = MitsunagaNayarCRF(stack, stack_exposure, N, nSamples)
%
%       [lin_fun, pp, err] = MitsunagaNayarCRF(stack, stack_exposure, N, nSamples)
%
%       This function computes camera response function using Mitsunaga and
%       Nayar method.
%
%        Input:
%           -stack: a stack of LDR images. If the stack is a single or
%           double values are assumed to be in [0,1]
%           -stack_exposure: an array containg the exposure time of each
%           image. Time is expressed in second (s)
%           -N: polynomial degree of the inverse CRF
%           -nSamples: number of samples for computing the CRF
%
%        Output:
%           -pp: a polynomial encoding the inverse CRF
%           -lin_fun: tabled CRF
%           -err: error function
%
%     Copyright (C) 2015-16  Francesco Banterle
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

if(~exist('nSamples', 'var'))
    nSamples = 255;
end

if(~exist('N', 'var'))
    N = 3;
end

if(isempty(stack))
    error('MitsunagaNayarCRF: a stack cannot be empty!');
end

if(isempty(stack_exposure))
    error('MitsunagaNayarCRF: a stack_exposure cannot be empty!');
end

col = size(stack, 3);

if(isa(stack, 'uint8'))
    stack = single(stack) / 255.0;
end

if(isa(stack, 'uint16'))
    stack = single(stack) / 65535.0;
end

%stack sub-sampling
stack_hist = ComputeLDRStackHistogram(stack);
stack_samples = GrossbergSampling(stack_hist, nSamples);

%recovering the CRF
function d = MN_d(c, p, q, n)
    q_p = q + 1;
    R_q_q_p = stack_exposure(q) / stack_exposure(q_p);

    
    M_q = stack_samples(p, q, c);
    M_q_p = stack_samples(p, q_p, c);
    
    d = M_q^n - R_q_q_p * (M_q_p^n);
end

pp = zeros(col, N + 1);

err = 0.0;

for channel=1:col
    Q = length(stack_exposure);
    P = nSamples;

    %Matrix A
    A = zeros(N, N);
    for j=1:N
        for i=1:N

            A(i,j) = 0;

            for q=1:(Q - 1)
                for p=1:P
                    delta  = MN_d(channel, p, q, j - 1) - MN_d(channel, p, q, N);
                    A(i,j) = A(i,j) + MN_d(channel, p, q, i - 1) * delta;
                end
            end

        end
    end
    
    %b
    b = zeros(N, 1);
    for i=1:N
        b(i) = 0;

        for q=1:(Q - 1)
            for p=1:P
                b(i) = b(i) + MN_d(channel, p, q, i - 1) * MN_d(channel, p, q, N);
            end
        end
    end   
    
    b = -b;
    
    c = A \ b;    
    c_n = 1.0 - sum(c);
    
    pp(channel, :) = [c_n, c'];
    
    %compute err
    for q=1:(Q-1)
        R = stack_exposure(q) / stack_exposure(q + 1);
        for p=1:P
            e1 = polyval(pp(channel,:), stack_samples(p, q    , channel));
            e2 = polyval(pp(channel,:), stack_samples(p, q + 1, channel));
            err = err + (e1 - R * e2).^2;
        end
    end
end

lin_fun = zeros(256, col);

for i=1:col
    lin_fun(:,i) = polyval(pp(i,:), 0:(1.0 / 255.0):1);
end

end

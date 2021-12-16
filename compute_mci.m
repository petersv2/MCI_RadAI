%This code is distributed under the 
%GNU GENERAL PUBLIC LICENSE Version 3
%See file LICENSE.txt in the top directory of this distribution

% This function computes MCI image on input volume d, 
% which is then masked with input volume mask.
%
% delta_x, delta_y, delta_z are parameters specifying
% the spatial resolution in mm of the voxels in d.
% sigma is the scale parameter, i.e. the standard deviation
% of the Gaussian smoothing kernel in mm

function [mci_masked,mci]=compute_mci(d,mask,delta_x,delta_y,delta_z,sigma)



%% Gaussian smoothing of input volume


sigma_x = sigma/delta_x;
sigma_y = sigma/delta_y;
sigma_z = sigma/delta_z;

sz = 6*sigma_x; 
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma_x ^ 2));
gf = gaussFilter / sum (gaussFilter);

gf_x = reshape(gf,length(gf),1,1);
gf_y = reshape(gf,1,length(gf),1);

sz = 6*sigma_z; 
if(sz<3) sz=3; end
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma_z ^ 2));
gf = gaussFilter / sum (gaussFilter);
gf_z = reshape(gf,1,1,length(gf));


vol = convn(d,gf_x, 'same');
vol = convn(vol,gf_y, 'same');
vol = convn(vol,gf_z, 'same');
% vol is now the Gaussian-smoothed input volume

%% Compute Curvature map

mci = computeIsophoteCurvature(vol,delta_x,delta_y,delta_z);

mci_masked = mci.*double(mask);


end

%%%%%%%%%%%%%%%%%%%

function div = computeIsophoteCurvature(vol,delta_x,delta_y,delta_z)


[gx,gy,gz] = gradient(vol,delta_x,delta_y,delta_z);

gnorm = sqrt(gx.*gx + gy.*gy + gz.*gz);
gnorm = gnorm + eps;
gxnorm = gx./gnorm;
gynorm = gy./gnorm;
gznorm = gz./gnorm;

[X, Y, Z] = meshgrid((1:size(vol,1)).*delta_x, (1:size(vol,2)).*delta_y, (1:size(vol,3)).*delta_z);


hx = X(1,:,1); 
hy = Y(:,1,1); 
hz = Z(1,1,:); 
[px, ~, ~] = gradient(gxnorm, hx, hy, hz); 
[~, qy, ~] = gradient(gynorm, hx, hy, hz); 
[~, ~, rz] = gradient(gznorm, hx, hy, hz); 
  
div = px+qy+rz;

end

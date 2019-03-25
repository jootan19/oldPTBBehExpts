 function [texture] = CreateRandomDotTexture(x_sz,y_sz,dot_sz,amt_dots,binaryimg)
% x_sz = 640;
% y_sz = 640;
% dot_sz = 1;
% amt_dots = 0.5;
% binaryimg = 1;

img          = ones(y_sz,x_sz);
x_dotcenters = floor(dot_sz/2)+1 : dot_sz : x_sz -(floor(dot_sz/2)-1);
y_dotcenters = floor(dot_sz/2)+1 : dot_sz : y_sz -(floor(dot_sz/2)-1);

[ii,jj] = meshgrid(y_dotcenters,x_dotcenters);

ndots = numel(ii);

dots_idx = randsample(1:ndots,round(ndots*amt_dots));

for n = 1:length(dots_idx)
    idx = dots_idx(n);
    x_idx = jj(idx) - floor(dot_sz/2) : jj(idx) + round(dot_sz/2) - 1 ;
    y_idx = ii(idx) - floor(dot_sz/2) : ii(idx) + round(dot_sz/2) - 1;
    img(y_idx,x_idx) = 0;
end

if ~binaryimg
    texture = repmat(uint8(255 * img), [1, 1, 3]);
else
    texture = 255*img;
end
% imshow(img)
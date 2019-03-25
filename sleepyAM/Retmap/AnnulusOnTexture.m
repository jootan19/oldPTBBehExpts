function [textureOut] = AnnulusOnTexture(texsize,textureIn)
% texsize = texture size;
% textureIn = input texture - MUST BE BINARY FORMAT : [X,Y,2] <--2 CHANNEL IS ALPHA CHANNEL
% 
% Version history--------------
% 18 Feb 2014 Wrote it - Joo
% 

try
textureOut = textureIn;

% Create circular aperture for the alpha-channel:
[x,y]=meshgrid(-texsize:texsize, -texsize:texsize);
circle = 255 * (x.^2 + y.^2 <= (texsize)^2);
textureOut(:,:,2) = 0; % Set 2nd channel (the alpha channel) of 'grating' to the aperture defined in 'circle':
textureOut(1:2*texsize+1, 1:2*texsize+1, 2) = circle;
catch err
    sca
    fprintf('\n\nerror making annulus \n\n')
    rethrow(err)
end

function [TEXTURE] = CreateRandomDots(IMGX,IMGY,COLOURS,DOTSZ)
fprintf('%s\n',mfilename())

if ~exist('IMGX','var')    || isempty(IMGX)
    IMGX = 300;
end
if ~exist('IMGY','var')    || isempty(IMGY)
    IMGY = 300;
end
if ~exist('COLOURS','var') || isempty(COLOURS)
    COLOURS = [255 128 128; 128 255 128; 128 128 255];
end
if ~exist('DOTSZ','var') || isempty(DOTSZ)
    DOTSZ = 2;
end

if mod(IMGX,DOTSZ)~=0    
    fprintf('\t Image padded along X dim\n\t will crop back to old X dim: %i\n',IMGX)
    IMGX_2 = IMGX + (DOTSZ - mod(IMGX,DOTSZ));        
else
    IMGX_2 = IMGX;
end
if mod(IMGY,DOTSZ)~=0    
    fprintf('\t Image padded along y dim\n\t will crop back to old X dim: %i\n',IMGY)
    IMGY_2 = IMGY + (DOTSZ - mod(IMGY,DOTSZ));      
else
    IMGY_2 = IMGY;
end

BLANKIMG    = uint8(zeros(IMGY_2,IMGX_2,3));
NCOLOURS    = size(COLOURS,1);
NDOTS       = ((IMGX_2/DOTSZ)) * ((IMGY_2/DOTSZ));
COLOURORDER = mod(randperm(NDOTS),NCOLOURS)+1;

[XSTART YSTART] = meshgrid(1:DOTSZ:IMGX_2,1:DOTSZ:IMGY_2);
COLORLIB = zeros(DOTSZ,DOTSZ,3,NCOLOURS);
for CLRIDX = 1:NCOLOURS
     CLR = reshape(COLOURS(CLRIDX,:),1,1,3);
    COLORLIB(:,:,:,CLRIDX) = repmat(CLR,DOTSZ,DOTSZ);
end
for DOTID  = 1:NDOTS;           
    DOTCLR = COLOURORDER(DOTID);
    BLANKIMG(YSTART(DOTID):YSTART(DOTID)+DOTSZ-1, ...
      XSTART(DOTID):XSTART(DOTID)+DOTSZ-1, : ) = COLORLIB(:,:,:,DOTCLR);      
end

TEXTURE = BLANKIMG(1:IMGY,1:IMGX,:);
fprintf('%s DONE \n',mfilename())
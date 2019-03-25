
% MAKES COLOURED SINE WAVE GRATING OR GABOR PATCH IN RGB(A) FORMAT
%
% [VERSION HISTORY]
%       19 12 14    - wrote it - joo
%       08 02 17    - edited
%           renamed MakeSineWaveGrating3 --> MakeSineWaveGrating4
%           added extra RGB output [no alpha channel]
%           can now save in any img fmt (see imwrite for all fmts available)
% [USAGE]
%       [rgbtex, rgbatex] = MakeSineWaveGrating4([s], [phase], [sc], [freq], [contrast], [tilt], [gabor], [color0], [color1], [color2], [saveoutput], [fname], [outfmt])
%
%       [INPUTS]
%
%        NAME           FMT        OPTIONAL?         DESCRIPTION                        DEFAULT VALUES (if any)
%       ---------------------------------------------------------------------------------------------------------
%        s              INT        Y                size of texture                     200
%        phase          INT        Y                phase of texture in degree          0
%        sc             INT        Y                sigma of gaussian hull              50
%        freq           INT        Y                frequency in cycles per 100px       10
%        contrast       INT        Y                Contrast of texture                 0.5
%        tilt           INT        Y                tilt of grating                     0 (vertical)
%        gabor          INT        Y                gabor option?                       1 (yes), 0 --> No, outputs simple sine wave grating instead
%        color0         DOUBLE     Y                background colour                   [0.5 0.5 0.5]
%        color1         DOUBLE     Y                colour 1                            [0 1 0]
%        color2         DOUBLE     Y                colour 2                            [0 0 0]
%        saveoutput     INT        Y                save as img file?                   0 (no), 1 --> yes, saves gabor as png ("default")
%        fname          STR        Y                filename                            test.png
%        outfmt         STR        Y                output img file format              "png"


function [rgbtex, rgbatex,sinWaveNorm,gHullout] = MakeSineWaveGrating4(s, phase, sc, freq, contrast, tilt, gabor, color0, color1,color2,saveoutput,fname,outfmt)
fprintf('--------------------\nStarting %s \n',mfilename)

% DEFAULT VALUES
if ~exist('s','var')        || isempty(s),
    s         = 400;
    fprintf('           img size : 400px [default]\n');
else
    fprintf('           img size : %i\n',s);
end

if ~exist('phase','var')    || isempty(phase),
    phase     = 0;
    fprintf('              phase : %i [default]\n',phase);
else
    fprintf('              phase : %i \n',phase);
end
if ~exist('sc','var')       || isempty(sc),
    sc        = s/4;
    fprintf('                 sc : %i [default]\n',sc);
else
    fprintf('                 sc : %i \n',sc);
end
if ~exist('freq','var')     || isempty(freq),
    freq      = 3;
    fprintf('                 sf : %2.3f cycles/100px [default]\n',freq);
else
    fprintf('                 sf : %2.3f cycles/100px \n',freq);
end
if ~exist('contrast','var') || isempty(contrast),
    contrast  = 0.5;
    fprintf('           contrast : %2.3f [default]\n',contrast);
else
    fprintf('           contrast : %2.3f \n',contrast);
end
if ~exist('tilt','var')     || isempty(tilt),
    tilt      = 00;
    fprintf('               tilt : %i [default]\n',tilt);
else
    fprintf('               tilt : %i \n',tilt);
end
if ~exist('gabor','var')    || isempty(gabor),
    gabor     = 1;
    fprintf('              gabor : %i [y/n] [default]\n',gabor);
else
    fprintf('              gabor : %i [y/n] \n',gabor);
end
if ~exist('color0','var')   || isempty(color0) || ~isa(color0,'double'),
    color0 = [0.5 0.5 0.5];
    fprintf('           bg color : [%.2f %.2f %.2f] [default]\n',color0);
else
    fprintf('           bg color : [%.2f %.2f %.2f]\n',color0);
end
if ~exist('color1','var')   || isempty(color1) || ~isa(color1,'double'),
    color1 = [1 1 1];
    fprintf('            color 1 : [%.2f %.2f %.2f] [default]\n',color1);
else
    fprintf('            color 1 : [%.2f %.2f %.2f]\n',color1);
end
if ~exist('color2','var')   || isempty(color2) || ~isa(color2,'double'),
    color2 = [0 0 0];
    fprintf('            color 2 : [%.2f %.2f %.2f] [default]\n',color2);
else
    fprintf('            color 2 : [%.2f %.2f %.2f]\n',color2);
    
end
if ~exist('saveoutput','var')   || isempty(saveoutput) ,
    saveoutput = 0;
    fprintf('      save img file : %i [y/n] [default]\n',saveoutput);
else
    fprintf('      save img file : %i [y/n]\n',saveoutput);
end
% ------------------------------------------------------------------------------------------------------------------

res         = [s s];
cnvdeg2rad  = @(x) (pi/180).*x;

X = ones(res(1),1)*[-(res(2)-1)/2:1:(res(2)-1)/2];
Y =[-(res(1)-1)/2:1:(res(1)-1)/2]' * ones(1,res(2));

CosIm   =  cos(2.*pi.*(freq/100).* (cos(cnvdeg2rad(tilt)).*X + sin(cnvdeg2rad(tilt)).*Y)- cnvdeg2rad(phase)*ones(res) );
sinWave = contrast * (1+CosIm)/2;

% normalise
maxnormfac = max(max(sinWave));
minnormfac = min(min(sinWave));
rangevals  = maxnormfac - minnormfac;
sinWaveNorm = (sinWave-minnormfac)/rangevals;

r = color1(1) * sinWaveNorm + color2(1) * (1-sinWaveNorm);
g = color1(2) * sinWaveNorm + color2(2) * (1-sinWaveNorm);
b = color1(3) * sinWaveNorm + color2(3) * (1-sinWaveNorm);
if gabor
    [gab_x gab_y] = meshgrid(-s/2:s/2-1, -s/2:s/2-1);
    gHull         = exp(-((gab_x/sc).^2)-((gab_y/sc).^2)) .* ones(res); % Guassian Hull
    gHullout      = gHull;
    
    r = r.*gHull + color0(1).*(1-gHull);
    g = g.*gHull + color0(2).*(1-gHull);
    b = b.*gHull + color0(3).*(1-gHull);
    gHullalpha = 0.5-0.5*gHull;
    
else
    gHullalpha = ones(s,s);
end
rgbtex = zeros(s,s,3);
rgbtex(:,:,1) = r;
rgbtex(:,:,2) = g;
rgbtex(:,:,3) = b;
rgbatex = cat(3,rgbtex,gHullalpha);
rgbtex  = im2uint8(rgbtex);
rgbatex = im2uint8(rgbatex);

if saveoutput
    if ~exist('fname','var')    || isempty(fname)   || ~isa(fname,'char'),
        fname = 'test.png';
        disp('default filename used');
    end
    if ~exist('outfmt','var')   || isempty(outfmt)  || ~isa(outfmt,'char'),
        outfmt = 'png';
        disp('default ''png'' outputfmt used');
    end
    if strcmpi(outfmt,'png')
        imwrite(rgbtex,fname,outfmt,'Alpha',gHull);
    else
        imwrite(rgbtex,fname,outfmt);
    end
end
disp('Done')
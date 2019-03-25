function [tex] = MakeCheckeredBoard(texH,texW,pxpersq,startColor)
% Make checkered box
%   [USAGE]
%           [INPUT]         [FORMAT]        [COMMENTS]
%           --------------------------------------------
%           texH            INT             texture Height
%           texW            INT             texture Width
%           pxpersq         INT             num pixels per square 
%           startColor      STR             Color of top left hand corner square ['w' or 'b']
% 
% version history
% 18 feb 2014 wrote it - joo

if nargin<4
    texH    = 500;  % texture height
    texW    = 500;  % texture width
    pxpersq = 50;   % px per square
    startColor = 'w'; % start color, w = white, b = black
end
try
    numcol  = texW/pxpersq;
    numrow  = texH/pxpersq;
    tex = zeros(texW,texH,2);
    switch startColor
        case 'w' % WHITE FIRST
            for x = 1:numcol
                for y = 1:numrow
                    if mod(x,2)==1
                        if mod(y,2)==1
                            xfrom = (x-1) * pxpersq + 1;
                            xto   = xfrom + pxpersq;
                            yfrom = (y-1) * pxpersq + 1;
                            yto   = yfrom + pxpersq;
                            tex(yfrom:yto,xfrom:xto,:) = 255;
                        end
                    else
                        if mod(y,2)==0
                            xfrom = (x-1) * pxpersq + 1;
                            xto   = xfrom + pxpersq;
                            yfrom = (y-1) * pxpersq + 1;
                            yto   = yfrom + pxpersq;
                            tex(yfrom:yto,xfrom:xto,:) = 255;
                        end
                    end
                end
            end
        case 'b' % BLACK FIRST
            for x = 1:numcol
                for y = 1:numrow
                    if mod(x,2)==0
                        if mod(y,2)==1
                            xfrom = (x-1) * pxpersq + 1;
                            xto   = xfrom + pxpersq;
                            yfrom = (y-1) * pxpersq + 1;
                            yto   = yfrom + pxpersq;
                            tex(yfrom:yto,xfrom:xto,:) = 255;
                        end
                    else
                        if mod(y,2)==0
                            xfrom = (x-1) * pxpersq + 1;
                            xto   = xfrom + pxpersq;
                            yfrom = (y-1) * pxpersq + 1;
                            yto   = yfrom + pxpersq;
                            tex(yfrom:yto,xfrom:xto,:) = 255;
                        end
                    end
                end
            end
    end
catch err
    sca
    fprintf('\n\n Error generating checkered board \n\n')
    rethrow(err)
end
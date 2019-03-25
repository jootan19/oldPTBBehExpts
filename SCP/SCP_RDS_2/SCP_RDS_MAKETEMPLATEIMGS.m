function [savelog, templateImgs] = SCP_RDS_MAKETEMPLATEIMGS(savelog,templateimgarray)
fprintf('%s\n',mfilename())
try
    deg2rad = @(x) x.*pi./180 + 270; % 0 DEG = 12 O'CLOCK POSITION
    
    BGtilts        = savelog.bg;
    Targtilts      = savelog.targ;
    NBLOCKS        = length(BGtilts);
    imgX           = savelog.stimParams.elementgridSz(1);
    imgY           = savelog.stimParams.elementgridSz(2);
    ELEY           = round(imgY/2);
    ELEX           = round(imgX/2);
    
    
    NELE        = [9 6];
    RADII       = [90 40 ];
    STARTANGLES = deg2rad([0 90]);
    
    IMGPAD      = 10;
    IMGDIM      = (max(RADII)*2) + imgX + IMGPAD;
    BLANKIMG    = zeros(IMGDIM, IMGDIM);
    IMGCTR      = round([IMGDIM/2, IMGDIM/2]);
    
    for BLKID = 1:NBLOCKS
        TEMPIMG = BLANKIMG;
        bgtheta = BGtilts{BLKID};
        eval(sprintf('bgtemplate = templateimgarray.DEG%i;',bgtheta))
        targtheta = bgtheta + Targtilts{BLKID};
        eval(sprintf('targtemplate = templateimgarray.DEG%i;',targtheta))
        TEMPIMG(IMGCTR(2)-round(imgY/2)+1:IMGCTR(2)+round(imgY/2),...
            IMGCTR(1)-round(imgX/2)+1:IMGCTR(1)+round(imgX/2) ) = targtemplate;
        
        for RADIDX = 1:length(RADII)
            R = RADII(RADIDX);
            THETAS = STARTANGLES(RADIDX): (2*pi)/NELE(RADIDX): STARTANGLES(RADIDX)+(NELE(RADIDX) * ((2*pi)/NELE(RADIDX)));
            for ELEID = 1:NELE(RADIDX)
                THETA = THETAS(ELEID);
                TEMPX = round(cos(THETA) * R) + IMGCTR(1);
                TEMPY = round(sin(THETA) * R) + IMGCTR(2);
                TEMPIMG(TEMPY-ELEY+1:TEMPY+ELEY, TEMPX-ELEX+1:TEMPX+ELEX) = bgtemplate;
            end
        end
        eval(sprintf('templateImgs.block%i = TEMPIMG;',BLKID))
    end
    savelog.stimParams.nelements      = NELE;
    savelog.stimParams.elementRadii   = RADII;
    savelog.stimParams.startAnglesRAD = STARTANGLES;
    savelog.stimParams.templateSz     = size(TEMPIMG);
catch err
    sca
    commandwindow
    ShowCursor
    rethrow(err)
end

fprintf('%s DONE \n',mfilename())
function [RDS_LIB,savelog] = SCP_RDS_BUILDRDSLIB(wPtr,savelog,templateImgs)

fprintf('%s\n',mfilename())
% CREATE RDS TEMPLATE
try
    
    nblocks                           = length(savelog.bg);    
    savelog.stimParams.RDS_dotSz      = 2;
    savelog.stimParams.RDS_pixelshift = savelog.stimParams.RDS_dotSz * 2;
    
    RDS_LIB                = struct;
    RDS_TextureSz          = savelog.stimParams.templateSz;
    DOTCOLOURS = [255 128 128; 128 255 128; 128 128 255;128 128 128; 255 255 255];
    
           
    for BLKID = 1:nblocks        
        fprintf('\tBlock %i\n',BLKID)
        
        eval(sprintf('RDSTemplate = templateImgs.block%i;',BLKID))
        [eleIDX_i, eleIDX_j] = find(RDSTemplate~=0);      
        eleIDX_j_shifted     = eleIDX_j + savelog.stimParams.RDS_pixelshift;      
        tempdottexture       = CreateRandomDots(RDS_TextureSz(2), RDS_TextureSz(1),DOTCOLOURS,savelog.stimParams.RDS_dotSz);
              
        LTEXTURE       = tempdottexture;
        RTEXTURE       = tempdottexture;
      
        for DOTIDX = 1:length(eleIDX_i)
            LTEXTURE(eleIDX_i(DOTIDX), eleIDX_j(DOTIDX),:) = RTEXTURE(eleIDX_i(DOTIDX), eleIDX_j_shifted(DOTIDX),:);
        end
        temptargtexL = Screen('Maketexture',wPtr,LTEXTURE);
        temptargtexR = Screen('Maketexture',wPtr,RTEXTURE);
        
        eval(sprintf('RDS_LIB.block%i.LEFT  = temptargtexL;',BLKID))
        eval(sprintf('RDS_LIB.block%i.RIGHT = temptargtexR;',BLKID))
        
    end
    savelog.stimParams.RDSSz = size(LTEXTURE);
    savelog.stimParams.RDSColours = DOTCOLOURS;
catch err
    sca
    commandwindow
    ShowCursor
    rethrow(err)
end
fprintf('%s DONE \n',mfilename())
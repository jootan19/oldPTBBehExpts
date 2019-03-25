function [savelog, templateImgs] = SCP_RDS_MAKETEMPLATEIMGS(savelog,templateimgarray)
fprintf('%s\n',mfilename())
try
    BGtilts        = savelog.bg;
    Targtilts      = savelog.targ;
    nblocks        = length(BGtilts);
    imgX           = savelog.stimParams.elementgridSz(1);
    imgY           = savelog.stimParams.elementgridSz(2);
    neleX          = savelog.stimParams.neleX;
    neleY          = savelog.stimParams.neleY;
    jittertype     = savelog.stimParams.jittertype;
    jitteramt      = savelog.stimParams.jitteramt;
    trialsperblock = savelog.timings.trialsperblock;
    
    imgpad          = 10;
    nele            = neleY * neleX;
    ctreleID        = round(nele/2);
    jitteramt       = [-jitteramt 0 jitteramt];
    gridsz          = max(abs(jitteramt)*2)+imgX;
    textureDims     = [gridsz*neleX ,gridsz*neleY];
    templateXCtr    = textureDims(1)/2+imgpad;
    templateYCtr    = textureDims(2)/2+imgpad;
    
    [elexctrs, eleyctrs] = meshgrid(gridsz/2:gridsz:gridsz*neleX , gridsz/2:gridsz:gridsz*neleY);
    elexctrs = templateXCtr + reshape(elexctrs,1,numel(elexctrs)) - (gridsz * neleX * 0.5);
    eleyctrs = templateYCtr + reshape(eleyctrs,1,numel(eleyctrs)) - (gridsz * neleY * 0.5);
    
    locs_nojitter   = [elexctrs - imgX/2 + 1 ; eleyctrs- imgY/2 + 1 ; elexctrs + imgX/2 ; eleyctrs + imgY/2];
    
    locs_jitter     = struct;
    templateImgs = struct;
    
    switch  jittertype
        case 'pertrial'
            for perblockID = 1:nblocks
                
                bgtheta = BGtilts{perblockID};
                eval(sprintf('bgtemplate = templateimgarray.DEG%i;',bgtheta))
                targtheta = bgtheta + Targtilts{perblockID};
                eval(sprintf('targtemplate = templateimgarray.DEG%i;',targtheta))
                
                for pertrialID  = 1:trialsperblock
                    templocs    = locs_nojitter;
                    tempimg     = uint8(zeros(textureDims(2)+(imgpad*2),textureDims(1)+(imgpad*2),3));                   
                    for eleID = 1:nele
                        if eleID ~=ctreleID
                            xjitter1 = jitteramt(randi(length(jitteramt)));
                            yjitter1 = jitteramt(randi(length(jitteramt)));
                            templocs(:,eleID) = locs_nojitter(:,eleID) + [xjitter1; yjitter1; xjitter1; yjitter1];
                            
                            xjitter = elexctrs(eleID)+xjitter1;
                            yjitter = eleyctrs(eleID)+yjitter1;
                            tempimg(yjitter-imgY/2+1:yjitter+imgY/2,xjitter-imgX/2+1:xjitter+imgX/2,: ) = bgtemplate;
                            
                        else
                            xjitter = elexctrs(eleID);
                            yjitter = eleyctrs(eleID);
                            tempimg(yjitter-imgY/2+1:yjitter+imgY/2,xjitter-imgX/2+1:xjitter+imgX/2,: ) = targtemplate;
                        end
                    end
                    
                    eval(sprintf('templateImgs.block%i.trial%i =  tempimg;',perblockID,pertrialID));
                    eval(sprintf('locs_jitter.block%i(:,:,%i) = templocs;',perblockID,pertrialID));
                    
                end
            end
        case 'perblock'
            for perblockID = 1:nblocks
                templocs    = locs_nojitter;
                tempimg     = uint8(zeros(textureDims(2)+(imgpad*2),textureDims(1)+(imgpad*2)));
                bgtheta = BGtilts{perblockID};
                eval(sprintf('bgtemplate = templateimgarray.DEG%i;',bgtheta))
                targtheta = bgtheta + Targtilts{perblockID};
                eval(sprintf('targtemplate = templateimgarray.DEG%i;',targtheta))
                
                for eleID = 1:nele
                    if eleID ~=ctreleID
                        xjitter1 = jitteramt(randi(length(jitteramt)));
                        yjitter1 = jitteramt(randi(length(jitteramt)));
                        templocs(:,eleID) = locs_nojitter(:,eleID) + [xjitter1; yjitter1; xjitter1; yjitter1];
                        
                        xjitter = elexctrs(eleID)+xjitter1;
                        yjitter = eleyctrs(eleID)+yjitter1;
                        tempimg(yjitter-imgY/2+1:yjitter+imgY/2,xjitter-imgX/2+1:xjitter+imgX/2,: ) = bgtemplate;
                        
                    else
                        xjitter = elexctrs(eleID);
                        yjitter = eleyctrs(eleID);
                        tempimg(yjitter-imgY/2+1:yjitter+imgY/2,xjitter-imgX/2+1:xjitter+imgX/2,: ) = targtemplate;
                    end
                end
                
                eval(sprintf('templateImgs.block%i = tempimg;',perblockID))
                eval(sprintf('locs_jitter.block%i = templocs;',perblockID));
                
            end
    end
    savelog.stimParams.unjitteredlocs = locs_nojitter;
    savelog.stimParams.jitteredlocs   = locs_jitter;
    savelog.stimParams.templateSz     = size(tempimg);
catch err
    sca
    commandwindow
    rethrow(err)
end
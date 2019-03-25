fprintf('%s\n',mfilename())
try    
    ELEimgX = 30;
    ELEimgY = 30;
    rectX   = 24;
    rectY   = 12;
    rectCLR = [255 255 255];
    bgCLR   = [0 0 0];
    
    bgtilt    = [0 45 90 135];
    targtilt  = [0 20 45 90];
    
    
    % PARADIGM FILE
    
    para1    = [repmat(bgtilt,1,length(targtilt)); sort(repmat(targtilt,1,length(bgtilt)))];
    randIDX  = randperm(length(para1));
    para2    = para1(:,randIDX);
    condcode = zeros(1,length(randIDX));
    
    for TARGTILTID = 1:length(targtilt)
        condcode(para2(2,:)== targtilt(TARGTILTID)) = TARGTILTID;
    end
    
    correctAnsLoc  = repmat({'L' 'R'}, 1, round(size(para2,2)/2));
    correctAnsLoc2 = correctAnsLoc(:,randperm(length(correctAnsLoc)));
    para3          = num2cell(para2);
    para           = [para3 ; correctAnsLoc2(1:size(para3,2))];
    nblocks        = length(para);
    
    
    savelog.bg                     = para(1,:);
    savelog.targ                   = para(2,:);
    savelog.codedConds             = condcode;
    savelog.ansLoc                 = para(3,:);
    
    savelog.subjectResp            = [];
    savelog.responseTime           = [];
    savelog.QC.earlyBtnpress.flag  = zeros(1,nblocks);
    savelog.QC.earlyBtnpress.RT    = nan(1,nblocks);
    savelog.QC.earlyBtnpress.btnID = cell(1,nblocks);
    savelog.QC.respflip.numflips   = zeros(1,nblocks);

    savelog.stimParams.BarSz         = [rectX rectY];
    savelog.stimParams.elementgridSz = [ELEimgX ELEimgY];
    
    % TIMINGS
    if debugmode,
        trialsperblock = 5;
        stimDur        = 1;
        iti            = 0.5;
        fixDur         = 0.5;
        ansDur         = 1;
    else
        if practice
            trialsperblock = 10;
            fixDur         = 2;
        else
            trialsperblock = 10;
            fixDur         = 12;
        end
        stimDur        = 1;
        iti            = 0.2;
        ansDur         = 1;
    end
    
    trialDur       = stimDur + iti ;
    blockDur       = (stimDur + iti) * trialsperblock;
    totalexptDur   = (blockDur + ansDur + fixDur)*nblocks + fixDur;
    
    savelog.timings.totalExptDur   = totalexptDur;
    savelog.timings.trialsperblock = trialsperblock;
    savelog.timings.stimDur        = stimDur;
    savelog.timings.iti            = iti;
    savelog.timings.fixDur         = fixDur;
    savelog.timings.ansDur         = ansDur;
    
    % secondary task info
    %     nfixationchange = unique(round(trialsperblock * [.3:.05:.7]));
    nfixationchange = 0:trialsperblock;
    ansChoiceDiff1  = [1 2];
    ansChoiceDiff   = [ansChoiceDiff1 -ansChoiceDiff1];
    fixchangeID     = cell(1,nblocks);
    rightAnsSet     = zeros(1,nblocks);
    wrongAnsSet     = zeros(1,nblocks);
    
    for blkID = 1:nblocks
        nfixChange           = datasample(nfixationchange,1);
        fixchangeID{blkID}   = sort(datasample(1:trialsperblock,nfixChange,'Replace',false));
        
        rightAnsSet(blkID) = nfixChange;
        for wrondAnsID = 1:99
            wrongAnsSet(blkID) = rightAnsSet(blkID) + datasample(ansChoiceDiff,1);
            if rightAnsSet(blkID) ~= 0 && rightAnsSet(blkID) ~= trialsperblock
                if wrongAnsSet(blkID) >= 0 && wrongAnsSet(blkID) <= trialsperblock
                    break
                end
            elseif rightAnsSet(blkID) == 0
                if wrongAnsSet(blkID) > 0 && wrongAnsSet(blkID) <= trialsperblock +1
                    break
                end
            elseif rightAnsSet(blkID) == trialsperblock
                if wrongAnsSet(blkID) > 0 && wrongAnsSet(blkID) < trialsperblock
                    break
                end
            end
        end
    end
    
    savelog.taskinfo.numFixationChange = rightAnsSet;
    savelog.taskinfo.wrongAnsChoice    = wrongAnsSet;
    savelog.taskinfo.fixchangeID       = fixchangeID;
    savelog.taskinfo.ansChoiceDiff     = ansChoiceDiff;
        
    allthetas               = unique([bgtilt sum(para2,1)]);
    templateimgarray        = SCP_RDS_CreateRotatedRects(ELEimgX,ELEimgY,rectX,rectY,allthetas,rectCLR,bgCLR,1);
    [savelog, templateImgs] = SCP_RDS_MAKETEMPLATEIMGS(savelog,templateimgarray);
    
    
catch err
    sca
    commandwindow
    ShowCursor
    rethrow(err)
end

fprintf('%s DONE \n',mfilename())

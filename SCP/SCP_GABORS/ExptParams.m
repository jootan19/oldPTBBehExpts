fprintf('%s\n',mfilename())
try
    
    % PARADIGM + GABOR PARAMS
    s         = 100;
    phase     = 0;
    sc        = round(s/4);
    freq      = 5;
    contrast  = 1;
    gabor     = 1;
    color0    = [0 0 0];
    color2    = color0;
    
    savelog.gaborParams.s        = s;
    savelog.gaborParams.phase    = phase;
    savelog.gaborParams.sc       = sc;
    savelog.gaborParams.freq     = freq;
    savelog.gaborParams.contrast = contrast;
    savelog.gaborParams.bgc      = color0;
    savelog.gaborParams.color2   = color2;
    
    switch SALIENTFEATURE
        case 'ORI'
            bgtilt    = [0 45 90 135];
            targtilt  = [0 20 45 90];
            color1    = [0 1 0];
            para1     = [repmat(bgtilt,1,length(targtilt)); sort(repmat(targtilt, 1, length(bgtilt)))];
            randIDX   = randperm(length(para1));
            para2     = para1(:,randIDX);
            para3     = num2cell(para2);
            condcode  = zeros(1,length(randIDX));
            
            for x = 1:length(targtilt)
                condcode(para2(2,:)== targtilt(x)) = x;
            end
            
        case 'CLR'
            tilt      = 0;
            colorBG   = {[1 0 0] [1 0.5 0] [1 1 0]};
            colorTarg = {[1 0 0] [1 0.5 0] [1 1 0]};
            para1     = [repmat(1:length(colorBG),1,size(colorTarg,2)); sort(repmat(1:length(colorTarg),1,size(colorBG,2)))];
            randIDX   = randperm(length(para1));
            para2     = para1(:,randIDX);
            para3     = cell(size(para2));
            condcode  = zeros(1,length(randIDX));
            
            for BGIdx = 1:size(colorBG,2),
                para3(1,para2(1,:) == BGIdx) = colorBG(BGIdx);
            end
            for TargIdx = 1:size(colorTarg,2),
                para3(2,para2(2,:) == TargIdx) = colorTarg(TargIdx);
            end
            
            condsAvail = abs(para2(1,:) - para2(2,:));
            condcodeset = unique(condsAvail);
            for x =1:length(condcodeset)
                condcode(condsAvail == condcodeset(x)) = condcodeset(x) + 1;
            end            
    end
    
    correctAnsLoc  = repmat({'L' 'R'}, 1, round(size(para3,2)/2));
    correctAnsLoc2 = correctAnsLoc(:,randperm(length(correctAnsLoc)));
    para           = [para3 ; correctAnsLoc2(1:size(para3,2))];
    nblocks        = length(para);
    
    savelog.bg                  = para(1,:);
    savelog.targ                = para(2,:);
    savelog.codedConds          = condcode;
    savelog.ansLoc              = para(3,:);
    savelog.subjectResp         = [];
    savelog.responseTime        = [];
    savelog.QC.earlyBtnpress.flag  = zeros(1,nblocks);
    savelog.QC.earlyBtnpress.RT    = nan(1,nblocks);
    savelog.QC.earlyBtnpress.btnID = cell(1,nblocks);
    savelog.QC.respflip.numflips   = zeros(1,nblocks);
    
    % TIMINGS
    if debugmode,
        trialsperblock = 5;
        stimDur        = 0.5;
        iti            = 0.5;
        fixDur         = 0.5;
        ansDur         = 1;
    else
        if practice
            trialsperblock = 10;
            fixDur         = 5;
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
    
    % gabor location jittering
    jittertypeAvail = {'pertrial' , 'perblock'};
    jittertype      = jittertypeAvail{1};
    neleY           = 5;
    neleX           = 5;
    nele            = neleY * neleX;
    ctreleID        = round(nele/2);
%     jitteramt       = [10 15 20];
jitteramt       = [0 0 0];
    jitteramt       = [-jitteramt 0 jitteramt];
    
    GetGaborLocs;
    
    savelog.gaborParams.jittertype   = jittertype;
    savelog.gaborParams.jitteramt    = jitteramt;
    savelog.gaborParams.nojitterLocs = gaborlocs_nojitter;
    savelog.gaborParams.jitteredLocs = gaborlocs_jitter;
    
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
    
catch err
    disp('Error generating expt params..try again?')
    sca;
    ShowCursor;
    home;
    QuitSignal = 1;
    rethrow(err)
end

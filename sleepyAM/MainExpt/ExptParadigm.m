function [EXPTPARA, SAVELOG] = ExptParadigm(SAVELOG,debug)
fprintf('Running %s...',mfilename())
try    
        
    % timingss
    if    ~debug, 
        duration_fixation = 10;
        duration_stimblk = 20; % duration of stimulus block
    elseif debug, 
        duration_fixation = 1; 
        duration_stimblk = 5; % duration of stimulus block
    end    
    
    % expt paradigm            
    AM_Hi     = 10;
    AM_Lo     = 1;
    Pitch_Hi  = 3000;
    Pitch_Lo  = 1000;
    
    AM_Hi_conds = [1 1 2 2];
    AM_Hi_conds = AM_Hi_conds(:,randperm(length(AM_Hi_conds)))';
    
    AM_Lo_conds = [3 3 4 4];
    AM_Lo_conds = AM_Lo_conds(:,randperm(length(AM_Lo_conds)))';
    
    switch SAVELOG.Order
        case 1,
            Conds = reshape([AM_Hi_conds(:) AM_Lo_conds(:)]',2*size(AM_Hi_conds,1), [])';
        case 2,
            Conds = reshape([AM_Lo_conds(:) AM_Hi_conds(:)]',2*size(AM_Hi_conds,1), [])';
    end
    num_blocks = length(Conds);
    EXPTPARA = zeros(num_blocks,3);
    EXPTPARA(:,1) = Conds;
    
    for blkNo = 1:num_blocks
        switch Conds(blkNo)
            case 1
                EXPTPARA(blkNo,2) = AM_Hi;
                EXPTPARA(blkNo,3) = Pitch_Hi;
            case 2
                EXPTPARA(blkNo,2) = AM_Hi;
                EXPTPARA(blkNo,3) = Pitch_Lo;
            case 3
                EXPTPARA(blkNo,2) = AM_Lo;
                EXPTPARA(blkNo,3) = Pitch_Hi;
            case 4
                EXPTPARA(blkNo,2) = AM_Lo;
                EXPTPARA(blkNo,3) = Pitch_Lo;
        end
    end
    
    % SAVELOG ---- 
    SAVELOG.Paradigm.AM_Hi        = AM_Hi;
    SAVELOG.Paradigm.AM_Lo        = AM_Lo;
    SAVELOG.Paradigm.Pitch_Hi     = Pitch_Hi;
    SAVELOG.Paradigm.Pitch_Lo     = Pitch_Lo;    
    SAVELOG.Paradigm.ParadigmMat  = EXPTPARA;
    SAVELOG.Paradigm.FixationDur  = duration_fixation;
    SAVELOG.Paradigm.StimBlockDur = duration_stimblk;       
    SAVELOG.Paradigm.BlockDur     = duration_fixation + duration_stimblk;
    
    fprintf('[Done]\n\n')
    
catch err    
    fprintf('\n\nError generating paradigm matrix \n\n')
    CleanUp
    rethrow(err)
end

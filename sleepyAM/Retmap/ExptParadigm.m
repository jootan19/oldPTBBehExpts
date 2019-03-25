%function [paradigm, SAVELOG] = ExptParadigm(SAVELOG,debug)
fprintf('Running %s...',mfilename())
try
    behav = SAVELOG.Behav;
    % TIMING
    if debug
        duration_block    = 10;
        duration_fixation = 2;
    else
        if behav == 0
            duration_block    = 20;
            duration_fixation = 20;
        else
            duration_block    = 10;
            duration_fixation = 2;
        end
    end
    
    duration_total = duration_fixation + duration_block;
    
    rate_flicker      = 8; % stimulus flicker rate
    duration_stim     = 1/rate_flicker;
    rate_fixflicker   = 0.5; % fixation flicker rate
    
    duration_fixflick = 1/rate_fixflicker; % duration of fixation
    numClrChange = duration_block/duration_fixflick;
    
    % PARADIGM
    para_orders = perms(1:3);
    
    switch SAVELOG.Order
        case 1
            paradigm = [para_orders(1,:),para_orders(2,:)];
        case 2
            paradigm = [para_orders(3,:),para_orders(4,:)];
        case 3
            paradigm = [para_orders(5,:),para_orders(6,:)];
    end
    
    nblocks         = length(paradigm);    
    nTrials_total   = numClrChange * nblocks;
    ResultSet       = zeros(nTrials_total,5);
    ResultSet(:,4)  = 1;
    % [format] 1 = block number | 2 = color | 3 - ans | 4 = right/wrong | 5 = RT
    ResponseSet = zeros(nblocks,numClrChange);
    
    % SAVELOG
    SAVELOG.Timings.FixationDur      = duration_fixation;
    SAVELOG.Timings.StimBlockDur     = duration_block;
    SAVELOG.Timings.BlockDur         = duration_total;
    SAVELOG.Timings.BoardFlickerRate = rate_flicker;  % stimulus flicker rate (Hz)
    SAVELOG.Timings.FixChangeRate    = rate_fixflicker; % rate of colour change of fixation
    SAVELOG.Paradigm                 = paradigm;
        
    fprintf('[Done]\n\n')
    
    
    makeparafile(duration_fixation, duration_block, subNo, runNo,paradigm)
    
    
catch err
    fprintf('\n\nError generating paradigm matrix \n\n')
    CleanUp
    rethrow(err)
end

function [percentRight, nblocks, badblksID, earlyBtnPressBlkID, respflipBlkID, wrongAnsID] = SCP_GetRunStats(savelog)
fprintf('%s\n',mfilename())
RightAns = savelog.ansLoc;


if ~isempty(savelog.subjectResp)
    SubjectResp = savelog.subjectResp;
    nblocks = length(SubjectResp);
    earlyBtnPressBlkID = find(savelog.QC.earlyBtnpress.flag);
    respflipBlkID      = find(savelog.QC.respflip.numflips);     
    wrongAnsID   = find(strcmp(RightAns(1:nblocks),SubjectResp)==0);
    badblksID    = unique([earlyBtnPressBlkID respflipBlkID wrongAnsID]);
    nbadblocks   = length(badblksID);    
    percentRight = 100 * (nblocks -nbadblocks)/nblocks;
    
    fprintf('\n\t----------------------------------------\n ')
    fprintf('\tACCURACY STATS\n')
    fprintf('\t(Sub %i, Run %i)\n',savelog.subNo, savelog.runNo)
    fprintf('\t----------------------------------------\n ')
    fprintf('\tPercentage correct   = %3.2f%%\n\tNo. completed blocks = %i\n',percentRight,nblocks)
    fprintf('\tBad block(s) ID      = ')    
    if ~isempty(badblksID)
        for wrongID = 1:length(badblksID)
            fprintf('%i | ', badblksID(wrongID))
        end
    end
    fprintf('\n\t----------------------------------------\n ')
    
else
    nblocks      = 0;
    percentRight = NaN;
    wrongAnsID  = [];
    fprintf('\n\n\tNo completed blocks\n\n')
end
fprintf('%s DONE \n',mfilename())
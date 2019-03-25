function [SAVELOG] = MakeFSParaFile(SAVELOG)
fprintf('Running %s...',mfilename())
% [fmt]
%  1 = block start time wrt to run start time
%  2 = condition
%  3 = duration
%  4 = weight
try
    
    paraDir    = '../FSParaFiles';
    if ~isdir(paraDir), mkdir(paraDir); end
        
    parafName  = sprintf('%s/%s.para',paraDir,SAVELOG.Output.fNames);       
    fid        = fopen(parafName,'w');
    
    EXPTPARA    = SAVELOG.Paradigm.ParadigmMat;
    nblocks     = size(EXPTPARA,1);
    nfixations  = nblocks+1;    
    totalblocks = nblocks + nfixations;
    paraFile    = zeros(totalblocks, 4);
    
    FixDur        = SAVELOG.Paradigm.FixationDur;
    StimBlockDur  = SAVELOG.Paradigm.StimBlockDur;
    
    paraFile(2:2:totalblocks,2) = EXPTPARA(:,1);
    paraFile(1:2:totalblocks,3) = FixDur;
    paraFile(2:2:totalblocks,3) = StimBlockDur;
    paraFile(:,4) = 1; % weight
            
    for n = 1:totalblocks
        if n>1
            paraFile(n,1) = paraFile(n-1,3) + paraFile(n-1,1);
        end
        fprintf(fid,'%3d\t%2d\t%2d\t%1d\n' ,paraFile(n,:));
    end
    
    SAVELOG.FSParaFile.mat = paraFile;
    SAVELOG.FSParaFile.Dir = paraDir;
    
    fclose('all');
    fprintf('[Done]\n\n')
    
catch err  
    fprintf('\n\nError generating .para file\n\n')
    CleanUp
    rethrow(err)
end
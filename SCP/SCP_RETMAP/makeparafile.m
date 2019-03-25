function [FSFASTPARAFILE] = makeparafile(SUBNO, RUNNO,BLOCKDUR,FIXDUR,ATTENDCOND,CONDCODE, PRACTICE)

try
    if ~PRACTICE
        OUTPUTDIR = sprintf('FSFASTPARAFILE/SUB%i',SUBNO);
        if ~isdir(OUTPUTDIR)
            mkdir(OUTPUTDIR);
        end
        
        OUTPUTFNAME = sprintf('%s/%s_%i_%i.para', OUTPUTDIR,ATTENDCOND,SUBNO, RUNNO);
        FID = fopen(OUTPUTFNAME, 'w');
    end
    
    NBLOCKS = length(CONDCODE);
    
    % [format]   Col    var
    %             1     time block started
    %             2     condition
    %             3     duration
    %             4     weight
    NCOLS    = (NBLOCKS*2)+1;
    FSFASTPARAFILE              = zeros(NCOLS,4);
    FSFASTPARAFILE(2:2:NCOLS,2) = CONDCODE;
    FSFASTPARAFILE(2:2:NCOLS,3) = BLOCKDUR;
    FSFASTPARAFILE(1:2:NCOLS,3) = FIXDUR;
    FSFASTPARAFILE(:,4)         = 1;
    
    for N = 1:length(FSFASTPARAFILE)
        if N>1
            FSFASTPARAFILE(N,1) = FSFASTPARAFILE(N-1,1) + FSFASTPARAFILE(N-1,3);
        end
        if ~PRACTICE
            fprintf(FID, '%3d\t%3d\t%5.2f\t%1d\n',FSFASTPARAFILE(N,:));
        end
    end
    if ~PRACTICE
        fclose(FID);
    end
    
catch err
    sca
    ShowCursor
    commandwindow
    rethrow(err)
end


while CharAvail
    [temp, when] = GetChar;
    if strcmpi(temp, quitkey)
        fprintf('\n\nExperiment terminated early \n\n');
        outputfname2 = sprintf('%s_earlyQuit.mat',outputfname);                
        save(outputfname2,'savelog') 
        sca;        
        if exist('n','var')
            [percentRight, ntrials] = SCP_GetRunStats(savelog);
        end
        diary off;        
        ShowCursor;
        toc;
        QuitSignal = 1;
        break
    end
end

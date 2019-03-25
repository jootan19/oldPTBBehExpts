while CharAvail
    [temp, when] = GetChar;
    if strcmpi(temp, quitkey)
        fprintf('\n\nExperiment terminated early \n\n');
        outputfname = sprintf('%s/x%s_earlyQuit.mat',OutputDir, fNameStr);        
        save(outputfname,'savelog');
        sca;        
        diary off;
        ShowCursor;
        toc;
        QuitSignal = 1;
        break
    end
end

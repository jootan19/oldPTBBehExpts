while CharAvail
    [temp, when] = GetChar;
    if strcmpi(temp, quitkey)
        fprintf('\n\nExperiment terminated early \n\n')        
        save([outputDir '/' fNameStr '_SAVELOG_err.mat'],'SAVELOG')
        save([backupDir '/' fNameStr '_SAVELOG_err.mat'],'SAVELOG')        
        PsychPortAudio('Stop', pasound1, 0); % Stop white noise
        PsychPortAudio('Stop', pamodulator, 0); % Stop AM Modulation
        if eyetrack
            QuitEyeTracking
        end
        CleanUp;
        QuitSignal = 1;
        break
    end
end
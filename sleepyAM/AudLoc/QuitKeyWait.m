while CharAvail
    [temp, when] = GetChar;
    if strcmpi(temp, quitkey)
        save( [fNameStr '_AllVar.mat' ])
        [startTime endPositionSecs xruns estStopTime]=PsychPortAudio('Stop', pasound1);
        fprintf('\n\nExperiment terminated early \n\n')
        sca;
        QuitSignal = 1;
        break
    end
end
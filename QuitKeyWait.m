% Need to start  "ListenChar" in main script, also needs a "QuitSignal", Uncomment parts as required


while CharAvail
    [temp, when] = GetChar;
    if strcmpi(temp, quitkey)
%         save( [fNameStr '_AllVar.mat' ]);
        fprintf('\n\nExperiment terminated early \n\n');
%         fclose('all');
%         diary off;
        sca;
%         PsychPortAudio('Close');
        ShowCursor;
        QuitSignal = 1;
        break
    end
end
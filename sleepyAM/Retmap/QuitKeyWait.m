while CharAvail
    [temp, when] = GetChar;
    if strcmpi(temp, quitkey)
        save([outputDir '/' fNameStr '_SAVELOG_err.mat'],'SAVELOG')
        save([backupDir '/' fNameStr '_SAVELOG_err.mat'],'SAVELOG') 
        CleanUP;
        QuitSignal = 1;
        break
    end
end
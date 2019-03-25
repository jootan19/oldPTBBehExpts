try
    switch SALIENTFEATURE
        case 'ORI'            
            for nbgtilt = 1:length(bgtilt)
                bgtheta = bgtilt(nbgtilt);
                for ntargtilt = 1:length(targtilt)
                    targtheta = bgtheta + targtilt(ntargtilt);
                    [temptargtex ]= MakeSineWaveGrating4(s, phase, sc, freq, contrast, targtheta, gabor, color0, color1,color2);
                    temptargtex2 = Screen('Maketexture',wPtr,temptargtex);
                    eval(sprintf('texlib.bg%i_theta%i = temptargtex2;',bgtheta,targtilt(ntargtilt)))
                    
                end
            end
            
        case 'CLR'            
            nclrs = size(colorBG,2) + size(colorTarg,2);
            allclrs = reshape(cell2mat([colorBG colorTarg]),3,nclrs)';
            uniqClrs = unique(allclrs,'rows');
            for ClrIDS = 1:size(uniqClrs,1);
                tempClr = uniqClrs(ClrIDS,:);
                [temptargtex ]= MakeSineWaveGrating4(s, phase, sc, freq, contrast, tilt, gabor, color0, tempClr,color2);
                temptargtex2 = Screen('Maketexture',wPtr,temptargtex);
                eval(sprintf('texlib.R%i_G%i_B%i = temptargtex2;',round(tempClr*255)))
                
            end
    end   
    
catch err
    disp('Error creating texture library ~sigh')
    sca;
    ShowCursor;
    home;
    QuitSignal = 1;
    rethrow(err)
end

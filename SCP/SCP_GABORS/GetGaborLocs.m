try   
    gridsz    = max(abs(jitteramt)*2)+s;
    
    [elexctrs, eleyctrs] = meshgrid(gridsz/2:gridsz:gridsz*neleX , gridsz/2:gridsz:gridsz*neleY);
    elexctrs = XCtr + reshape(elexctrs,1,numel(elexctrs)) - (gridsz * neleX * 0.5);
    eleyctrs = YCtr + reshape(eleyctrs,1,numel(eleyctrs)) - (gridsz * neleY * 0.5);
    
    gaborlocs_nojitter   = [elexctrs - s/2 + 1 ; eleyctrs- s/2 + 1 ; elexctrs + s/2 ; eleyctrs + s/2];
    gaborlocs_jitter     = struct;
    
    switch jittertype
        case 'pertrial'
            for perblockID = 1:nblocks
                for pertrialID = 1:trialsperblock
                    templocs = gaborlocs_nojitter;
                    for eleID = 1:nele
                        if eleID ~=ctreleID
                            xjitter = jitteramt(randi(length(jitteramt)));
                            yjitter = jitteramt(randi(length(jitteramt)));
                            templocs(:,eleID) = gaborlocs_nojitter(:,eleID) + [xjitter; yjitter; xjitter; yjitter];
                        end
                    end
                    eval(sprintf('gaborlocs_jitter.block%i(:,:,%i) = templocs;',perblockID,pertrialID));
                end
            end
            
        case 'perblock'            
            for perblockID = 1:nblocks
                templocs = gaborlocs_nojitter;
                for eleID = 1:nele
                    if eleID ~=ctreleID
                        xjitter = jitteramt(randi(length(jitteramt)));
                        yjitter = jitteramt(randi(length(jitteramt)));
                        templocs(:,eleID) = gaborlocs_nojitter(:,eleID) + [xjitter; yjitter; xjitter; yjitter];
                    end
                end
                eval(sprintf('gaborlocs_jitter.block%i = templocs;',perblockID));
            end
            
    end
catch err
    error('Them gabors are refusing to arrange themselves...')
    sca;
    ShowCursor;
    home;
    QuitSignal = 1;
    rethrow(err)
end

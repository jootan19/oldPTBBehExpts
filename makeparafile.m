function makeparafile(duration_fixation, duration_block, subNo, runNo,paradigm)

% GENERATES .para file for fsl
if nargin<5    
    duration_fixation = 16;
    duration_block    = 20;
    subNo = 99; runNo = 99;
    paradigm = [randperm(3) randperm(3)];
end

try  
    outputDir = ['Subject ' num2str(subNo, '%.3i') '/'];
    if ~isdir(outputDir),  mkdir(outputDir);     end
   
    parafName =[outputDir 'Subject' num2str(subNo,'%.3d') '_' num2str(runNo,'%.3d') '.para'];
    fid = fopen(parafName,'w');
    

    num_blocks = length(paradigm);
    
    % [format]   Col    var 
    %             1     time block started
    %             2     condition
    %             3     duration
    %             4     weight
    
    
    mat = zeros((num_blocks*2)+1,4);
    mat(:,4) = 1; 
    mat(1,3) = duration_fixation;
    
    idx =0;    
    for blkID = 1:size(mat,1)
        if blkID > 1
            mat(blkID,1) = mat(blkID-1,1) + mat(blkID-1,3);
            
            if mod(blkID,2)==0 %even stim blocks
                idx = idx +1;
                mat(blkID,2) = paradigm(idx);
                mat(blkID,3) = duration_block;
            elseif mod(blkID,2)==1 %fixation
                mat(blkID,3) = duration_fixation;
            end
        end
        fprintf(fid, '%3d\t%1d\t%2d\t%1d\n', mat(blkID,:));
    end
    
    fclose(fid);
catch err
    sca;
    ShowCursor;
    fprintf('\n\n Error generating .para output \n\n')
    rethrow(err)
end
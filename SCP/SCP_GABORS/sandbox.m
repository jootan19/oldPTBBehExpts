clear all 
close all
commandwindow

load IMGARRAY.mat

nblocks = length(fieldnames(imgarray));

for ii = 1:nblocks
    
    eval(sprintf('imgtemp = imgarray.block%i.cue(:,200:1240,:);',ii))
    
    fname = sprintf('screenshots/RETMAP_CUE_%03i.jpg',ii)
    imwrite(imgtemp,fname)
    
    eval(sprintf('imgtemp2 = imgarray.block%i.stim(:,200:1240,:);',ii))
    
    fname2 = sprintf('screenshots/RETMAP_STIM_%03i.jpg',ii)
    imwrite(imgtemp2,fname2)
end
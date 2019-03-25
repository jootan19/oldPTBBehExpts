clear all
close all
commandwindow
home


EXPTCOND = input('What Expt Flavour? [1 GABORS, 2 RDS, 3 RETMAP] : ');
switch EXPTCOND
    case 1
        TARG = 'SCP_GABORS';
    case 2
        TARG = 'SCP_RDS_2';
    case 3
        TARG = 'SCP_RETMAP';        
end

fprintf('\n\t\t FLAVOUR [%s] CHOSEN\n', TARG)

cd(TARG)
run([TARG '_MAIN.m'])

cd ../





    
    


clc; clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%these steps fir unzip .gz file and delete .gz file
Maindir = 'E:\xiuxian\VRdata\BOTREC\newtrial\social-nonsocial'   % root inputdir for sublist
sublist = dir(fullfile(Maindir, 'sub*')) 
filelist = dir(fullfile(Maindir, '**\*.nii.gz*')) %list of the unzipped .gz file 
% filelist = dir(fullfile(rootdir, '**', '*.gz')) %list of the unzipped .gz file 
filelist = filelist(~[filelist.isdir]); 
% unzip .nii.gz files 
for j = 1:numel(filelist)
    F = fullfile(filelist(j).folder,filelist(j).name);
    gunzip(F) 
    delete(fullfile(filelist(j).folder,filelist(j).name)) %%%% deleted the .gz file after unzipp
end
clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Maindir = 'E:\xiuxian\VRdata\BOTREC\newtrial\social-nonsocial'   % root inputdir for sublist
BIDsdir = '\BIDs'
Outputdir = '\results'  
Behaviordir = '\behaviordata';
spmDir = '\1st_level\';
spmmDir = '\2nd_level\';

sublist = dir(fullfile(Maindir, BIDsdir, 'sub*'))  %list of .nii file after unzipping
BIDslist = dir(fullfile(Maindir, BIDsdir, '**\*.nii*')) %list of the unzipped .gz file 
timinglist = dir(fullfile(Maindir, Behaviordir, '**\*Model_Parameter.xlsx*'))
timingSuffix = '_Model_Parameter.xlsx'; 
%------------------------------------------------------create folders for first and second level
for s = 1:numel(sublist)
    %See whether output directory exists; if it doesn't, create it
    subpath=[Maindir, Outputdir, filesep, sublist(s).name]
    if ~exist(subpath)
        mkdir(subpath)
    end
    fstdir = [subpath spmDir]
    if ~exist(fstdir)
        mkdir(fstdir)
    end
    snddir = [subpath spmmDir]
    if ~exist(snddir)
        mkdir(snddir)
    end
end
%------------------------------------------------------direct to the original 'Model_Parameter' file to extract timing file to txt
cd([Maindir Behaviordir])

for k=1:numel(timinglist.name)
        currD=timinglist(k).folder
        cd(currD)
        filepattern=fullfile(currD, '*Model_Parameter*.xlsx')
        fn=dir(filepattern)
        opt=detectImportOptions(fn.name)
        tBC=struct;  tBC.run{1} = []; tBC.run{2} = []; tBC.run{3} = []; tBC.run{4} = [];tBC.run{5} = [];%tBC.run{6} = [];
        run=struct;  run.move{1} = []; run.move{2} = []; run.move{3} = []; run.move{4} = [];run.move{5} = [];%run.move{6} = [];
        run.static{1} = []; run.static{2} = []; run.static{3} = []; run.static{4} = [];run.static{5} = [];%run.static{6} = [];
        for runIdx=1:6 %6
        tBC.run{runIdx}=readtable(fn.name,'sheet', runIdx);
        end 
        for i = 1:length(tBC.run)
            for j = 1:length(tBC.run{i}.state)
                if find(strcmp('moving',tBC.run{i}.state(j, :)))
                    run.move{i}=[run.move{i}; tBC.run{i}.onset(j,:) tBC.run{i}.duration(j,:)]
                    move_run=sprintf('move_run%d.txt', i)
                    writematrix(run.move{i}, move_run)
                else if find(strcmp('static',tBC.run{i}.state(j, :)))
                    run.static{i}=[run.static{i}; tBC.run{i}.onset(j,:) tBC.run{i}.duration(j,:)]            
                    static_run=sprintf('static_run%d.txt', i)
                    writematrix(run.static{i}, static_run)
                end 
            end
            end
        end 
end         

%---------------------------the above steps have basically processed the files required for GLM, let's start the further process for GLM!  
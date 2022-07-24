%---------------------------------------------------------------------------this script will be finnally used for GLM
clear;
% numScans=[129 153 129] %number of scans that you acquire per run
% numScans=305; %The number of scans/TRs per run
% disacqs = 0;   %The number of scans you later discard during preprocessing
% spm('Defaults','fMRI'); %Initialise SPM fmri
% spm_jobman('initcfg');  %Initialise SPM batch mode
 %Navigate to output directory, specify and estimate GLM

Maindir = '/home/work/fmrianalysis/GLM'   % root inputdir for sublist
BIDsdir = '/BIDs'  %BID directory (including .nii and regressor files)
Outputdir = '/results'  % GLM model established directory
Behaviordir = '/behaviordata'; %behaviordata (timing file) directory
sublist = dir(fullfile(Maindir, BIDsdir, 'sub*'))  %list of unzipped .nii file before smooth in different subject folder  
for i=1:numel(sublist)    % for directing different subject folders
    currD=sublist(i).name  
    cd ([Maindir BIDsdir, filesep,currD])            % to the specific subject folder
    niilist = dir(fullfile(Maindir, BIDsdir, currD,  '**/*.nii*')) %list of the unzipped .gz file 
    resultlist = dir(fullfile(Maindir, Outputdir, currD)) %fitst level and second level folder
    matlabbatch{4}.spm.stats.fmri_spec.dir = {[resultlist(3).folder, filesep, resultlist(3).name]}   % to the fist level of the current subject folder                
%   matlabbatch{4}.spm.stats.fmri_spec.dir(i) = {[resultlist(3).folder, filesep, resultlist(3).name]}   % to the fist level of the current subject folder                                                           

    for j = 1:numel(niilist)
    runpath=niilist(j).folder % the directory of different run folder in the current subject folder
    runfile=niilist(j).name   % the nii file in the current run of the current subject folder
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = currD 
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files(j) = {
                                                                     {[runpath, filesep, runfile]}
                                                                     }';   % whole directory of the corresponding nii file 
    %------------------------------------------------------------------------smooth .nii
    matlabbatch{2}.spm.spatial.smooth.data(j) = cfg_dep(['Named File Selector: ', currD, '(', sprintf('%d',(j)), ')','- Files'], substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{j}));   
    matlabbatch{2}.spm.spatial.smooth.fwhm = [4 4 4];
    matlabbatch{2}.spm.spatial.smooth.dtype = 0;
    matlabbatch{2}.spm.spatial.smooth.im = 0;
    matlabbatch{2}.spm.spatial.smooth.prefix = 's'; 
%     delete(fullfile(niilist(j).folder,niilist(j).name)) %%%% deleted the .gz file after unzipp
    %-----------------------------------------------------
    matlabbatch{3}.cfg_basicio.file_dir.file_ops.cfg_file_split.name = [currD, '_FileSpilt'];
    matlabbatch{3}.cfg_basicio.file_dir.file_ops.cfg_file_split.files(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{3}.cfg_basicio.file_dir.file_ops.cfg_file_split.index(j) = {j
                                                                     }';
    %-------------------------------------------------------------------------timing parameter
%     matlabbatch{4}.spm.stats.fmri_spec.dir(i) = {[Maindir, Outputdir, filesep, currD, filesep, fstdir]}  % to the fist level of the current subject folder                                                           
    matlabbatch{4}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{4}.spm.stats.fmri_spec.timing.RT = 1.87; % interscan interval
    matlabbatch{4}.spm.stats.fmri_spec.timing.fmri_t = 129; % Microtime resolution, check by V = spm_vol() and V(1).dim functions
    matlabbatch{4}.spm.stats.fmri_spec.timing.f0mri_t0 = 65; % Microtime onset, half of the Microtime resolution in our case (after fmriprep)   
    %--------------------------------------------------------------------------
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).scans(1) = cfg_dep(['File Set Split: ', currD, '_FileSpilt ', '(', sprintf('%d',(1)), ')'], substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('{}',{j}));
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(1).name = 'Move';
    %---------------------------------------------------------------------------input the onset and duration of each run at different subject folder
    movetimingpath = dir(fullfile([Maindir, Behaviordir, filesep, currD], 'move_run*'))
    statictimingpath = dir(fullfile([Maindir, Behaviordir, filesep, currD], 'static_run*'))
%             for k = 1:numel(movetimingpath)
    moving = load([movetimingpath(j).folder, filesep, movetimingpath(j).name]) % timing file of moving state
    static = load([statictimingpath(j).folder, filesep, statictimingpath(j).name]) % timing file of static state
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(1).onset = moving(:, 1) 
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(1).duration = moving(:, 2)
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(1).tmod = 0; 
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(1).orth = 1;
    
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(2).name = 'Static';
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(2).onset = static(:, 1)
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(2).duration = static(:, 2)
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(2).tmod = 0;
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).cond(2).orth = 1;
    %--------------------------------------------------------------------------------------- input confound files
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).multi = {''};         
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).regress = struct('name', {}, 'val', {});
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).multi_reg = {[runpath, filesep, 'regressor.txt']};
    matlabbatch{4}.spm.stats.fmri_spec.sess(j).hpf = 128;
     
    matlabbatch{4}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{4}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{4}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{4}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{4}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{4}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{4}.spm.stats.fmri_spec.cvi = 'AR(1)';    
    matlabbatch{5}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));    
%     matlabbatch{5}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
    matlabbatch{5}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{5}.spm.stats.fmri_est.method.Classical = 1;
    %--------------------------------------------------------------------------Contrasts are created here
    matlabbatch{6}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
%     matlabbatch{6}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
    matlabbatch{6}.spm.stats.con.consess{j}.tcon.name = 'Move-Static';
    matlabbatch{6}.spm.stats.con.consess{j}.tcon.weights = [1 -1 0 0 0 0 0 0 0 0 0 0 0 0];
    matlabbatch{6}.spm.stats.con.consess{j}.tcon.sessrep = 'replsc';
    matlabbatch{6}.spm.stats.con.delete = 0;    
    end
    spm_jobman('run',matlabbatch); 
%     clear matlabbatch

end
                                                    
clear matlabbatch
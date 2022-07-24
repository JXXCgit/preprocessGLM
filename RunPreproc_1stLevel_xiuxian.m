% List of open inputs
nrun = 2; % enter the number of runs here
jobfile = {'E:\xiuxian\program\fMRIanalysis\GLM\RunPreproc_1stLevel_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
end
spm('defaults','fmri');
spm_jobman('initcfg');
%  spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

% spm_jobman('run',matlabbatch)


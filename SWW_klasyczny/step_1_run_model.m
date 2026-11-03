% Step 1: Run the classical SWW model in Dynare.
% Run this script from MATLAB; output remains in this model's directory.
% Add the installed Dynare matlab directory to the MATLAB path first.
model_dir = fileparts(mfilename('fullpath'));
cd(model_dir);
if exist('dynare', 'file') ~= 2
    error('Add Dynare to the MATLAB path, e.g., addpath(''C:/dynare/7.1/matlab'').');
end
dynare sww_klasyczny.mod noclearall;

function Report_Generator(branchname)
    % Check the branch to ensure we are working on the correct branch
    reporoot = pwd;
    validateBranch(branchname);

    % List modified `.slx` files in the last commit
    gitCommand = 'git --no-pager diff --name-only HEAD~1 HEAD';
    [status, modifiedFiles] = system(gitCommand);
    assert(status == 0, modifiedFiles);

    % Filter only `.slx` files
    modifiedFiles = split(modifiedFiles, newline);
    modifiedFiles = modifiedFiles(endsWith(modifiedFiles, '.slx'));

    if isempty(modifiedFiles)
        disp('No modified models in the last commit.');
    else 
        disp('There were modified files');
    end
    % Create a temporary folder to store the ancestors of the modified models
    tempdir = fullfile(reporoot, 'modelscopy');
    mkdir(tempdir)
    
    % Generate a comparison report for each modified model
    for i = 1:numel(modifiedFiles)
        filePath = strtrim(string(modifiedFiles(i))); % Trim whitespace
        if isfile(filePath)
            disp('Entering Generation of Reports')
            report = generateReportForModel(filePath, branchname);
        else
            fprintf('File not found (skipped): %s\n', filePath);
        end
    end
    rmdir modelscopy s
end

function report = generateReportForModel(filePath, branchname)
    % Retrieve the ancestor file
    ancestorFile = retrieveAncestor(filePath, branchname);
    % Open both the ancestor and current model in Simulink
    open_system(filePath); % Open current model
    disp('Current model opened in Simulink');
    open_system(ancestorFile); % Open ancestor model
    disp('Ancestor model opened in Simulink');

    % Create comparison object
    comp = visdiff(ancestorFile, filePath);
    filter(comp, 'unfiltered'); % Ensure no filters are hiding changes
    report = publish(comp, 'html');
    disp('Publishing completed to HTML');

end





function ancestorFile = retrieveAncestor(filePath, branchname)
    % Construct the ancestor file path
    [fileDir, fileName, fileExt] = fileparts(filePath);
    ancestorFile = fullfile(fileDir, sprintf('%s_ancestor%s', fileName, fileExt));

    % Replace separators for Git compatibility
    gitFilePath = strrep(filePath, '\', '/');
    ancestorFile = strrep(ancestorFile, '\', '/');

    % Fetch the ancestor file from the `main` branch
    gitCommand = sprintf('git --no-pager show origin/main:%s > "%s"', gitFilePath, ancestorFile);
    [status, result] = system(gitCommand);
    assert(status == 0, result);
end

function validateBranch(branchname)
    % Check the current branch
    [status, currentBranch] = system('git rev-parse --abbrev-ref HEAD');
    assert(status == 0, currentBranch);

    currentBranch = strtrim(currentBranch);

    % Ensure the script is running on the specified branch
    if ~strcmp(currentBranch, branchname)
        error('You are on branch "%s", but the specified branch is "%s".', currentBranch, branchname);
    end
end

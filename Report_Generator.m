function Report_Generator(branchname)
    % Check the branch to ensure we are working on the correct branch
    validateBranch(branchname);

    % List modified `.slx` files in the last commit
    gitCommand = 'git --no-pager diff --name-only HEAD~1 HEAD ***.slx';
    [status, modifiedFiles] = system(gitCommand);
    assert(status == 0, modifiedFiles);
    modifiedFiles = split(modifiedFiles);
    modifiedFiles(end) = []; % Removing the last empty element

    if isempty(modifiedFiles)
        disp('No modified models in the last commit.')
        return;
    end

    % Generate a comparison report for each modified model
    for i = 1:numel(modifiedFiles)
        filePath = string(modifiedFiles(i));
        generateReportForModel(filePath, branchname);
    end
end

function generateReportForModel(filePath, branchname)
    % Retrieve the ancestor file
    ancestorFile = retrieveAncestor(filePath, branchname);

    % Generate a comparison report
    [fileDir, fileName, ~] = fileparts(filePath);
    reportPath = fullfile(fileDir, sprintf('%s_comparison_report.pdf', fileName));
    comp = visdiff(ancestorFile, filePath);
    filter(comp, 'unfiltered');
    publish(comp, reportPath);

    fprintf('Comparison report generated: %s\n', reportPath);
end

function ancestorFile = retrieveAncestor(filePath, branchname)
    % Construct the ancestor file path
    [fileDir, fileName, fileExt] = fileparts(filePath);
    ancestorFile = fullfile(fileDir, sprintf('%s_ancestor%s', fileName, fileExt));

    % Replace separators for Git compatibility
    gitFilePath = strrep(filePath, '\', '/');
    ancestorFile = strrep(ancestorFile, '\', '/');

    % Fetch the ancestor file from the `main` branch
    gitCommand = sprintf('git --no-pager show origin/main:%s > %s', gitFilePath, ancestorFile);
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

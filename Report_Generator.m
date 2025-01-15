function Report_Generator(branchname)
    % Check the branch to ensure we are working on the correct branch
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
        return;
    end

    % Generate a comparison report for each modified model
    for i = 1:numel(modifiedFiles)
        filePath = strtrim(string(modifiedFiles(i))); % Trim whitespace
        if isfile(filePath)
            generateReportForModel(filePath, branchname);
        else
            fprintf('File not found (skipped): %s\n', filePath);
        end
    end
end

function generateReportForModel(filePath, branchname)
    % Retrieve the ancestor file
    ancestorFile = retrieveAncestor(filePath, branchname);

    % Generate a comparison report
    [fileDir, fileName, ~] = fileparts(filePath);
    reportName = sprintf('%s_comparison_report.pdf', fileName);
    tempDir = tempdir; % Use a temporary directory
    tempReportPath = fullfile(tempDir, reportName); % Temporary storage location
    finalReportPath = fullfile(fileDir, reportName);

    % Create comparison object
    comp = visdiff(ancestorFile, filePath);
    filter(comp, 'unfiltered');

    % Explicitly set the working directory for `publish`
    originalDir = pwd; % Save current directory
    cd(tempDir); % Change to temporary directory
    try
        publish(comp, 'pdf');
    catch e
        error('Error during publishing: %s', e.message);
    end
    cd(originalDir); % Restore original directory

    % Move the report to the desired location
    if isfile(tempReportPath)
        movefile(tempReportPath, finalReportPath);
        fprintf('Comparison report generated: %s\n', finalReportPath);
    else
        error('Report not generated: %s', tempReportPath);
    end
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

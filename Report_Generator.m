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
    else 
        disp('There were modified files');
    end

    % Generate a comparison report for each modified model
    for i = 1:numel(modifiedFiles)
        filePath = strtrim(string(modifiedFiles(i))); % Trim whitespace
        if isfile(filePath)
            disp('Entering Generation of Reports')
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
    
    % Set the report name and paths relative to the GitHub Actions workspace
    reportName = sprintf('%s_comparison_report.pdf', fileName);
    workspaceDir = getenv('GITHUB_WORKSPACE');  % GitHub workspace directory
    tempReportPath = fullfile(workspaceDir, reportName);  % Store in the workspace
    finalReportPath = fullfile(fileDir, reportName);

    disp('GitHub workspace directory:');
    disp(workspaceDir);
    
    % Create comparison object
    comp = visdiff(ancestorFile, filePath);
    filter(comp, 'unfiltered');

    % Explicitly set the working directory for `publish`
    originalDir = pwd; % Save current directory
    cd(workspaceDir); % Change to GitHub workspace directory

    % Verify the files in the workspace directory
    disp('GitHub workspace directory contents:');
    disp(dir(workspaceDir));  % This will show the files in the workspace directory

    try
        % Publish the comparison and save to PDF in the workspace directory
        publish(comp, 'pdf');  % Specify 'pdf' format
        disp('Publishing completed');
    catch e
        error('Error during publishing: %s', e.message);
    end

    cd(originalDir); % Restore original directory

    % Verify if the report is created in the workspace directory
    if isfile(tempReportPath)
        % Move the report to the desired location
        movefile(tempReportPath, finalReportPath);
        fprintf('Comparison report generated: %s\n', finalReportPath);
    else
        disp('Report not generated:');
        disp(tempReportPath);
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

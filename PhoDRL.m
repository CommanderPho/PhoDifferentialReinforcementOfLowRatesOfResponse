rng('default');
rng(1337);
randomProperties.numCells = 22;
randomProperties.numSamples = 2048;

correlationTreshold = 0.70;

% originalList: A numSamples x numCells matrix containing columns of
% waveforms for each cell
% if ~exist('originalList','var')
   originalList = rand(randomProperties.numSamples,randomProperties.numCells-2);
   originalList(:, end-3) = originalList(:, 1);
   originalList(:, end-2) = 2 .* originalList(:, end-4);
   originalList(:, end-1) = rand(randomProperties.numSamples,1) .* originalList(:, end-3) + originalList(:, 1);
   originalList(:, end) = rand(randomProperties.numSamples,1) .* originalList(:, end-10) + originalList(:, end-9);
% end

numCells = size(originalList, 2);
numSamples = size(originalList, 1);

activeList = originalList;
outputPartitionedList = {};

iterationIndex = 1;
partitionIndex = 1;
corrCoef = [];
while(size(activeList,2) > 0)
    % Always take the currSeedCell as the first cell of the activeList
    currSeedCell = activeList(:,1);
    activeList(:,1) = []; % Remove the currCell from the activeList
    % Find the cells that have corrCoef greater than the threshold and add them to the output array
    [similarCellIndicies, activePartitionList] = findSimilar(currSeedCell, activeList, correlationTreshold);
    currFinalOutputPartitionList = [currSeedCell activePartitionList];
    % Remove the similar cells from the activeList so they won't be considered again
    activeList(:,similarCellIndicies) = [];
    iterationIndex = iterationIndex + 1;
    % Repeat again for each of the cells in the currFinalOutputPartitionList:
    pendingConsiderationList = activePartitionList;
    while(~isempty(pendingConsiderationList))
        if isempty(activeList)
           break 
        end
        currSeedCell = pendingConsiderationList(:,1);
        pendingConsiderationList(:,1) = []; % Remove the currCell from the pendingConsiderationList
        % currSeedCell came from activePartitionList, so it's alrady been removed from activeList
        % It's okay to overwrite activePartitionList because it's cells have already been safely added to currFinalOutputPartitionList
        [similarCellIndicies, activePartitionList] = findSimilar(currSeedCell, activeList, correlationTreshold);
        currFinalOutputPartitionList = [currFinalOutputPartitionList activePartitionList];
        % add any newly added cells to the pendingConsiderationList to be considered
        pendingConsiderationList = [pendingConsiderationList activePartitionList];
        % Remove the similar cells from the activeList so they won't be considered again
        activeList(:,similarCellIndicies) = [];
        % Iterate until the pendingConsiderationList is empty
    end
    outputPartitionedList{partitionIndex} = currFinalOutputPartitionList; % Finished the partition
    partitionIndex = partitionIndex + 1; % Move on to the next partition
    % Iterate until the activeList is empty
end


% function [similarCellIndicies, activePartitionList] = recursivelyFindSimilar(activeList, correlationTreshold)
% % findSimilar Returns indicies of cells in activeList that are within correlationTreshold similar to seedCell.
%     % Always take the currSeedCell as the first cell of the activeList
%     currSeedCell = activeList(:,1);
%     activeList(:,1) = []; % Remove the currCell from the activeList
%     % Find the cells that have corrCoef greater than the threshold and add them to the output array
%     [similarCellIndicies, activePartitionList] = findSimilar(currSeedCell, activeList, correlationTreshold);
%     outputPartitionedList{iterationIndex} = [currSeedCell activePartitionList];
%     % Remove the similar cells from the activeList so they won't be considered again
%     activeList(:,similarCellIndicies) = [];
%     
%     
%     [similarCellIndicies, activePartitionList] = recursivelyFindSimilar(activeList, correlationTreshold)
%     iterationIndex = iterationIndex + 1;
%     % Repeat again for each of the cells in the outputPartitionedList{iterationIndex}:
%     
% end


function [similarCellIndicies, activePartitionList] = findSimilar(currSeedCell, activeList, correlationTreshold)
% findSimilar Returns indicies of cells in activeList that are within correlationTreshold similar to seedCell.
    numRemainingCells = size(activeList,2);
    activePartitionList = [];
    similarCellIndicies = [];
    % Iterate through the active list and find the correlation between
    corrCoef = zeros(numRemainingCells,1);
    for i = 1:numRemainingCells
        corrCoefTemp = corrcoef(currSeedCell, activeList(:,i));
        corrCoef(i) = corrCoefTemp(2,1); % Get the off-diagonal entry of the 2x2 correlation matrix. (1,2) would work too and be the same).
        if corrCoef(i) >= correlationTreshold
           similarCellIndicies(end+1) = i;
           activePartitionList = [activePartitionList activeList(:,i)];
        end
    end
end


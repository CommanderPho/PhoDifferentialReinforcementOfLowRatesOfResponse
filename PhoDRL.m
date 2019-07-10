rng('default');
rng(1337);
randomProperties.numCells = 22;
randomProperties.numSamples = 2048;

correlationTreshold = 0.70;

% originalList: A numSamples x numCells matrix containing columns of
% waveforms for each cell
if ~exist('originalList','var')
   originalList = rand(randomProperties.numSamples,randomProperties.numCells);
end

numCells = size(originalList, 2);
numSamples = size(originalList, 1);

activeList = originalList;
outputPartitionedList = {};
iterationIndex = 1;

while(size(activeList,2) > 0)
    % Always take the currSeedCell as the first cell of the activeList
    currSeedCell = activeList(:,1);
    activeList(:,1) = []; % Remove the currCell from the activeList
    % Iterate through the active list and find the correlation between 
    corrCoef = corrcoef([currSeedCell activeList]);
    % Find the cells that have corrCoef greater than the threshold and add them
    % to the output array
    similarCellIndicies = find(corrCoef >= correlationTreshold);
    outputPartitionedList{iterationIndex} = [currSeedCell activeList(:,similarCellIndicies)];
    % Remove the similar cells from the activeList so they won't be considered
    % again
    activeList(:,similarCellIndicies) = [];
    iterationIndex = iterationIndex + 1;

    % Iterate until the activeList is empty
end

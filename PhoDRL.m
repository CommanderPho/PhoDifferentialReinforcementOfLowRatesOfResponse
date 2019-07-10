rng('default');
rng(1337);
randomProperties.numCells = 22;
randomProperties.numSamples = 2048;

correlationTreshold = 0.70;

% originalList: A numSamples x numCells matrix containing columns of
% waveforms for each cell
if ~exist('originalList','var')
   originalList = rand(randomProperties.numSamples,randomProperties.numCells-2);
   originalList(:, end-3) = originalList(:, 3);
   originalList(:, end-2) = 2 .* originalList(:, end-4);
   originalList(:, end-1) = rand(randomProperties.numSamples,1) .* originalList(:, end-3) + originalList(:, end-6);
   originalList(:, end) = rand(randomProperties.numSamples,1) .* originalList(:, end-10) + originalList(:, end-9);
end

numCells = size(originalList, 2);
numSamples = size(originalList, 1);

activeList = originalList;
outputPartitionedList = {};
iterationIndex = 1;
corrCoef = [];
while(size(activeList,2) > 0)
    % Always take the currSeedCell as the first cell of the activeList
    currSeedCell = activeList(:,1);
    activeList(:,1) = []; % Remove the currCell from the activeList
    numRemainingCells = size(activeList,2);
    activePartitionList = [];
    similarCellIndicies = [];
    % Iterate through the active list and find the correlation between
    corrCoef{iterationIndex} = zeros(numRemainingCells,1);
    for i = 1:numRemainingCells
        corrCoefTemp = corrcoef(currSeedCell, activeList(:,i));
        corrCoef{i,iterationIndex} = corrCoefTemp(2,1); % Get the off-diagonal entry of the 2x2 correlation matrix. (1,2) would work too and be the same).
        if corrCoef{i,iterationIndex} >= correlationTreshold
           similarCellIndicies(end+1) = i;
           activePartitionList = [activePartitionList activeList(:,i)];
        end
    end
    % Find the cells that have corrCoef greater than the threshold and add them
    % to the output array
%     similarCellIndicies = find(corrCoef >= correlationTreshold);
%     outputPartitionedList{iterationIndex} = [currSeedCell activeList(:,similarCellIndicies)];
    outputPartitionedList{iterationIndex} = [currSeedCell activePartitionList];
    % Remove the similar cells from the activeList so they won't be considered
    % again
    activeList(:,similarCellIndicies) = [];
    iterationIndex = iterationIndex + 1;

    % Iterate until the activeList is empty
end

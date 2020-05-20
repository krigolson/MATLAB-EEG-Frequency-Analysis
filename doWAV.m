function WAV = doWAV(inputData,markers,baselineWindow,minimumFrequency,maximumFrequency,frequencySteps,mortletParameter)

    % written as a shell by Olav Krigolson
    % runs FFT analysis byu conditions on EEG data structure
    
    disp('Starting Wavelet analysis...');
    
    if ~isempty(baselineWindow)
        x = find(inputData.times >= baselineWindow(1));
        y = find(inputData.times >= baselineWindow(2));
        baselinePoints(1) = x(1);
        baselinePoints(2) = y(1);
    end
    
    numberOfConditions = size(markers,2);
    numberOfEpochs = size(inputData.data,3);
    
    for conditionCounter = 1:numberOfConditions
        
        tempData = [];
        tempDataCounter = 1;
        
        for epochCounter = 1:numberOfEpochs
    
            if strcmp(markers(conditionCounter),inputData.epoch(epochCounter).eventtype)
            
                tempData(:,:,tempDataCounter) = inputData.data(:,:,epochCounter);
                tempDataCounter = tempDataCounter + 1;
                
            end
            
        end
        
        if ~isempty(baselineWindow)
            [waveletData,waveletDataPercent,WAVFrequencies] = doWavelet(tempData,inputData.times,baselinePoints,minimumFrequency,maximumFrequency,frequencySteps,mortletParameter,inputData.srate);
        else
            if isempty(tempData)
                waveletData = NaN(size(inputData.data,1),frequencySteps,size(inputData.data,2));
                waveletDataPercent = NaN(size(inputData.data,1),frequencySteps,size(inputData.data,2));
                WAVFrequencies = linspace(minimumFrequency,maximumFrequency,frequencySteps);
            else
                ERP.data(:,:,conditionCounter) = nanmean(tempData,3);
                [waveletData,waveletDataPercent,WAVFrequencies] = doWavelet(tempData,inputData.times,[],minimumFrequency,maximumFrequency,frequencySteps,mortletParameter,inputData.srate);
                
            end
        end
        WAV.data(:,:,:,conditionCounter) = waveletData;
        WAV.percent(:,:,:,conditionCounter) = waveletDataPercent;
        WAV.epochCount(conditionCounter) = tempDataCounter - 1;
        
    end
    
    WAV.frequencies = WAVFrequencies;
    WAV.totalEpochs = numberOfEpochs;
    WAV.chanlocs = inputData.chanlocs;
    WAV.srate = inputData.srate;
    WAV.epochTime(1) = inputData.xmin;
    WAV.epochTime(2) = inputData.xmax;
    WAV.times = inputData.times;
    if ~isempty(baselineWindow)
        WAV.baseline = baselineWindow;
    else
        WAV.baseline = [];
    end
    WAV.frequencyRange = [minimumFrequency maximumFrequency];
    WAV.frequencySteps = frequencySteps;
    WAV.mortletParameter = mortletParameter;
    
    disp('Wavelets have now been created...');
    
end
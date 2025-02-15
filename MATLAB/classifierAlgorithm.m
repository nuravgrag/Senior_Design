%% Classifier Algorithm

function classifierAlgorithm(filePath)

% Read EEG signal from 18 records (3 = 3rd column).
% [tm,rawData] = rdsamp(filename, 3);

% Read EEG signal from .txt file.
rawData = load(filePath);

Fs = 250;  % samples (ticks)/second
dt = 1/Fs; % time resolution

% Bandpass filter the full data set.
passBand = [0.6 30]; % Hz
filterHd = bandPassFilter(Fs, passBand);
filteredData = filter(filterHd, rawData);

% Specify length of window to segment the data
windowDuration = 30; % seconds
% Split the entire EEG signal recording into 30 second recordings.
[tArr, dataIntervals] = getWindows(filteredData, windowDuration, Fs);

% Frequency range to extract low freq power.
lowFreqAverageRange = [0.5 4]; % Hz
% Frequency range to extract high freq power
highFreqAverageRange = [5 15];   % Hz


% Initialize counters
lightCounter = 0;
deepCounter = 0;
wakeCounter = 0;
remCounter = 0;

classificationArr = zeros(1, length(tArr));
% Loop through each 30-second window to classify the sleep stage
for i = 1:length(tArr)
    % Load time vector according to indexed window
    t = tArr{i};
    % Total timespan of recorded data
    T0 = length(t)/Fs;
    % Frequency resolution - determined by T0
    dF = 1/T0;
    % Freq data of DFT result
    freq = (-Fs/2:dF:Fs/2 - dF)';
    % Load EEG data in time domain according to indexed window
    sleepData = dataIntervals{i};
    % Use Fast Fourier Transform to transform data to frequency domain
    dataInFreqDomain = abs(fftshift(fft(sleepData*dt)));
    % Calculate average power at low frequency range
    lowFreqAverage = (mean(dataInFreqDomain(find(freq == lowFreqAverageRange(1)):find(freq == lowFreqAverageRange(2)))))^2;
    % Calculate average power at high frequency range
    highFreqAverage = (mean(dataInFreqDomain(find(freq == highFreqAverageRange(1)):find(freq == highFreqAverageRange(2)))))^2;
    
    % Classify based on cutoff values determined by testing 
    
    % MAP:
    % Deep = 1
    % Light = 2
    % REM = 3
    % Wake = 4
    if ((lowFreqAverage / highFreqAverage) <= 16 && (lowFreqAverage / highFreqAverage) >= 7.8)
        classificationArr(i) = 2;
    elseif ((lowFreqAverage / highFreqAverage) > 16)
        classificationArr(i) = 1;
    elseif ((lowFreqAverage / highFreqAverage) < 7.8 && (lowFreqAverage / highFreqAverage) >= 4)
        classificationArr(i) = 4;
    else
        classificationArr(i) = 3;
    end
end

disp(num2str(classificationArr));

end


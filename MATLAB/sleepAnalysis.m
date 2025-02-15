%% DEVELOPMENT NOTES
% mat2wfdb used to write MATLAB variable into WDFB record file

% theta = 4 - 7.9 Hz
% Lower Alpha = 7.9 - 10 Hz
% Upper Alpha = 10 - 13 Hz % edited
% Lower Beta = 13 - 17.9 Hz
% Upper Beta = 18 - 24.9 Hz

%% Classification Criteria

% Sleep stage 1/2 consist of Theta Waves (4-8Hz, amplitude 10)
% Sleep stage 3/4 consist of Delta Waves (0-4Hz, amplitude 20-100)
% REM sleep (R) demonstrate characteristics similar to waking sleep
% = a combination of alpha, beta, and desynchronous waves

% There is no real division between stages 3 and 4 except that,
% typically, stage 3 is considered delta sleep in which less than 50 
% percent of the waves are delta waves, and in stage 4 more than 50 percent
% of the waves are delta waves. 
%% Loading signal data from MIT-BIH slpdb

% Read EEG signal from 18 records (3 = 3rd column).
[tm,rawData] = rdsamp('slpdb/slp02a', 3);

% Read the annotation file. Each value represents a 30 second interval.
[~,~,~,~,~,comments] = rdann('slpdb/slp02a', 'st');

% Get the sleep stages only.
classifierAnnotations = getSleepStages(comments);

%% PRE-PROCESSING

Fs = 250;  % samples (ticks)/second
dt = 1/Fs; % time resolution

% Bandpass filter the full data set
passBand = [0.6 30]; % Hz
filterHd = bandPassFilter(Fs, passBand);
filteredData = filter(filterHd, rawData);

% Specify length of window to segment the data
windowDuration = 30; % seconds
% Split the entire EEG signal recording into 30 second recordings.
[tArr, dataIntervals] = getWindows(filteredData, windowDuration, Fs);


%% Testing Stages 1 and 3

%{
In this section, I wrote code to loop through each of the windows that have
been classified as stages 1 and 3 and analyzed the power in different
frequency ranges. These tests will be used to analyze the efficacy of
classifying sleep states based on the average value of the signal in  the
frequency domain within specified frequency ranges (both low and high).
%}

%% STAGE 1

% Find all windows that are classified as stage 1 sleep
sleepStage1Index = find([classifierAnnotations{:}] == 1);
% Initialize variables used in for loop
% Stores average power using specified cutoff values
totalAverage1 = zeros(1,length(sleepStage1Index));
totalAverageRange1 = [0.5 40];
% Stores average power from 0.5 - 3 Hz
lowFreqAverage1 = zeros(1,length(sleepStage1Index));
lowFreqAverageRange1 = [1 3.5];
% Stores average power from 5 - 15 Hz
highFreqAverage1 = zeros(1,length(sleepStage1Index));
highFreqAverageRange1 = [5 15];
% Loop through all sleep stage 1 data
for i = 1:length(sleepStage1Index);
    if (sleepStage1Index(i) <= length(sleepStage1Index))
        % Load time vector according to indexed window
        tSleepStage1 = tArr{sleepStage1Index(i)};
        % Total timespan of recorded data
        T0 = length(tSleepStage1)/Fs;
        % Frequency resolution - determined by T0
        dF = 1/T0;
        % Time vector of sampled data
        time = (0:dt:T0 - dt)';
        % Freq data of DFT result
        freq = (-Fs/2:dF:Fs/2 - dF)';
        % Load EEG data in time domain according to indexed window
        sleepDataStage1 = dataIntervals{sleepStage1Index(i)};
        % Use Fast Fourier Transform to transform data to frequency domain
        DataInFreqDomain1 = abs(fftshift(fft(sleepDataStage1*dt)));
        %figure;
        %stem(freq, DataInFreqDomain1,'LineWidth',0.5)
        %xlim([0 35])
        %title('Stage 1')
        % Save average power of signal in 3 different frequency ranges
        totalAverage1(i) = mean(DataInFreqDomain1(find(freq == totalAverageRange1(1)):find(freq == totalAverageRange1(2))));
        lowFreqAverage1(i) = mean(DataInFreqDomain1(find(freq == lowFreqAverageRange1(1)):find(freq == lowFreqAverageRange1(2))));
        highFreqAverage1(i) = mean(DataInFreqDomain1(find(freq == highFreqAverageRange1(1)):find(freq == highFreqAverageRange1(2))));
    end
end

freqPowerRatio1 = lowFreqAverage1 ./ highFreqAverage1;
highFreqPowerRatio1 = highFreqAverage1 ./ totalAverage1;


%% STAGE 2

% Find all windows that are classified as stage 2 sleep
sleepStage2Index = find([classifierAnnotations{:}] == 2);
% Initialize variables used in for loop
% Stores average power using specified cutoff values
totalAverage2 = zeros(1,length(sleepStage2Index));
totalAverageRange2 = [0.5 40];
% Stores average power from 0.5 - 3 Hz
lowFreqAverage2 = zeros(1,length(sleepStage2Index));
lowFreqAverageRange2 = [0.5 3];
% Stores average power from 5 - 15 Hz
highFreqAverage2 = zeros(1,length(sleepStage2Index));
highFreqAverageRange2 = [5 15];
% Loop through all sleep stage 2 data
for i = 1:length(sleepStage2Index);
    if (sleepStage2Index(i) <= length(sleepStage2Index))
        % Load time vector according to indexed window
        tSleepStage2 = tArr{sleepStage2Index(i)};
        % Total timespan of recorded data
        T0 = length(tSleepStage2)/Fs;
        % Frequency resolution - determined by T0
        dF = 1/T0;
        % Time vector of sampled data
        time = (0:dt:T0 - dt)';
        % Freq data of DFT result
        freq = (-Fs/2:dF:Fs/2 - dF)';
        % Load EEG data in time domain according to indexed window
        sleepDataStage2 = dataIntervals{sleepStage2Index(i)};
        % Use Fast Fourier Transform to transform data to frequency domain
        DataInFreqDomain2 = abs(fftshift(fft(sleepDataStage2*dt)));
        %figure;
        %stem(freq, DataInFreqDomain1,'LineWidth',0.5)
        %xlim([0 35])
        %title('Stage 1')
        % Save average power of signal in 3 different frequency ranges
        totalAverage2(i) = mean(DataInFreqDomain2(find(freq == totalAverageRange2(1)):find(freq == totalAverageRange2(2))));
        lowFreqAverage2(i) = mean(DataInFreqDomain2(find(freq == lowFreqAverageRange2(1)):find(freq == lowFreqAverageRange2(2))));
        highFreqAverage2(i) = mean(DataInFreqDomain2(find(freq == highFreqAverageRange2(1)):find(freq == highFreqAverageRange2(2))));
    end
end

freqPowerRatio2 = lowFreqAverage2 ./ highFreqAverage2;

%% STAGE 3

% Find all windows that are classified as stage 3 sleep
sleepStage3Index = find([classifierAnnotations{:}] == 3);
% Initialize variables used in for loop
% Stores average power using specified cutoff values
totalAverage3 = zeros(1,length(sleepStage3Index));
totalAverageRange3 = [0.5 40];
% Stores average power from 0.5 - 3 Hz
lowFreqAverage3 = zeros(1,length(sleepStage3Index));
lowFreqAverageRange3 = [0.5 3];
% Stores average power from 5 - 15 Hz
highFreqAverage3 = zeros(1,length(sleepStage3Index));
highFreqAverageRange3 = [5 15];
% Loop through all sleep stage 1 data
for i = 1:length(sleepStage3Index);
    if (sleepStage3Index(i) <= length(sleepStage3Index))
        % Load time vector according to indexed window
        tSleepStage3 = tArr{sleepStage3Index(i)};
        % Total timespan of recorded data
        T0 = length(tSleepStage3)/Fs;
        % Frequency resolution - determined by T0
        dF = 1/T0;
        % Time vector of sampled data
        time = (0:dt:T0 - dt)';
        % Freq data of DFT result
        freq = (-Fs/2:dF:Fs/2 - dF)';
        % Load EEG data in time domain according to indexed window
        sleepDataStage3 = dataIntervals{sleepStage3Index(i)};
        % Use Fast Fourier Transform to transform data to frequency domain
        DataInFreqDomain3 = abs(fftshift(fft(sleepDataStage3*dt)));
        %figure;
        %stem(freq, DataInFreqDomain3,'LineWidth',0.5)
        %xlim([0 35])
        %title('Stage 3')
        % Save average power of signal in 3 different frequency ranges
        totalAverage3(i) = mean(DataInFreqDomain3(find(freq == totalAverageRange3(1)):find(freq == totalAverageRange3(2))));
        lowFreqAverage3(i) = mean(DataInFreqDomain3(find(freq == lowFreqAverageRange3(1)):find(freq == lowFreqAverageRange3(2))));
        highFreqAverage3(i) = mean(DataInFreqDomain3(find(freq == highFreqAverageRange3(1)):find(freq == highFreqAverageRange3(2))));
    end
end

freqPowerRatio3 = lowFreqAverage3 ./ highFreqAverage3;
highFreqPowerRatio3 = highFreqAverage3 ./ totalAverage3;



%% STAGE 4

% Find all windows that are classified as stage 4 sleep
sleepStage4Index = find([classifierAnnotations{:}] == 4);
% Initialize variables used in for loop
% Stores average power using specified cutoff values
totalAverage4 = zeros(1,length(sleepStage4Index));
totalAverageRange4 = [0.5 40];
% Stores average power from 0.5 - 3 Hz
lowFreqAverage4 = zeros(1,length(sleepStage4Index));
lowFreqAverageRange4 = [0.5 3];
% Stores average power from 5 - 15 Hz
highFreqAverage4 = zeros(1,length(sleepStage4Index));
highFreqAverageRange4 = [5 15];
% Loop through all sleep stage 1 data
for i = 1:length(sleepStage4Index);
    if (sleepStage4Index(i) <= length(sleepStage4Index))
        % Load time vector according to indexed window
        tSleepStage4 = tArr{sleepStage4Index(i)};
        % Total timespan of recorded data
        T0 = length(tSleepStage4)/Fs;
        % Frequency resolution - determined by T0
        dF = 1/T0;
        % Time vector of sampled data
        time = (0:dt:T0 - dt)';
        % Freq data of DFT result
        freq = (-Fs/2:dF:Fs/2 - dF)';
        % Load EEG data in time domain according to indexed window
        sleepDataStage4 = dataIntervals{sleepStage4Index(i)};
        % Use Fast Fourier Transform to transform data to frequency domain
        DataInFreqDomain4 = abs(fftshift(fft(sleepDataStage4*dt)));
        %figure;
        %stem(freq, DataInFreqDomain4,'LineWidth',0.5)
        %xlim([0 35])
        %title('Stage 1')
        % Save average power of signal in 3 different frequency ranges
        totalAverage4(i) = mean(DataInFreqDomain4(find(freq == totalAverageRange4(1)):find(freq == totalAverageRange4(2))));
        lowFreqAverage4(i) = mean(DataInFreqDomain4(find(freq == lowFreqAverageRange4(1)):find(freq == lowFreqAverageRange4(2))));
        highFreqAverage4(i) = mean(DataInFreqDomain4(find(freq == highFreqAverageRange4(1)):find(freq == highFreqAverageRange4(2))));
    end
    
end

freqPowerRatio4 = lowFreqAverage4 ./ highFreqAverage4;
highFreqPowerRatio4 = highFreqAverage4 ./ totalAverage4;



%% Wake Stage

% Find all windows that are classified as stage 1 sleep
sleepStageWIndex = find([classifierAnnotations{:}] == 'W');
% Initialize variables used in for loop
% Stores average power using specified cutoff values
totalAverageW = zeros(1,length(sleepStageWIndex));
totalAverageRangeW = [0.5 40];
% Stores average power from 0.5 - 3 Hz
lowFreqAverageW = zeros(1,length(sleepStageWIndex));
lowFreqAverageRangeW = [1 4];
% Stores average power from 5 - 15 Hz
highFreqAverageW = zeros(1,length(sleepStageWIndex));
highFreqAverageRangeW = [5 15];
% Loop through all sleep stage 1 data
for i = 1:length(sleepStageWIndex);
    if (sleepStageWIndex(i) <= length(sleepStageWIndex))
        % Load time vector according to indexed window
        tSleepStageW = tArr{sleepStageWIndex(i)};
        % Total timespan of recorded data
        T0 = length(tSleepStageW)/Fs;
        % Frequency resolution - determined by T0
        dF = 1/T0;
        % Time vector of sampled data
        time = (0:dt:T0 - dt)';
        % Freq data of DFT result
        freq = (-Fs/2:dF:Fs/2 - dF)';
        % Load EEG data in time domain according to indexed window
        sleepDataStageW = dataIntervals{sleepStageWIndex(i)};
        % Use Fast Fourier Transform to transform data to frequency domain
        DataInFreqDomainW = abs(fftshift(fft(sleepDataStageW*dt)));
        figure;
        stem(freq, DataInFreqDomainW,'LineWidth',0.5)
        xlim([0 35])
        title('Stage 1')
        % Save average power of signal in 3 different frequency ranges
        totalAverageW(i) = mean(DataInFreqDomainW(find(freq == totalAverageRangeW(1)):find(freq == totalAverageRangeW(2))));
        lowFreqAverageW(i) = mean(DataInFreqDomainW(find(freq == 1):find(freq == 4)));
        highFreqAverageW(i) = mean(DataInFreqDomainW(find(freq == 5):find(freq == 15)));
    end
end

freqPowerRatioW = lowFreqAverageW ./ highFreqAverageW;
highFreqPowerRatioW = highFreqAverageW ./ totalAverageW;



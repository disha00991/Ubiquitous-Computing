% compute sampling frequency by averaging all timestamp distances acroos
% all folders and files for accelerometer data

dataDir = [pwd,'/allData/'];

dataDirNames = dir(dataDir);

%finding average inter timestamp distances for finding sampling rate
timestamp_distances = [];

for i = 1:length(dataDirNames)
           
    %goes through all of the directories representing all imei addresses
    if exist([dataDir dataDirNames(i).name],'dir') == 7 && dataDirNames(i).name(1) ~= '.'
        fprintf('Processing directory %s\n', dataDirNames(i).name);

        dirName = [dataDir dataDirNames(i).name '/'];
        files = dir([ dirName '*-accel.txt']);
        
        for ii = 1:length(files)
            file_name_prefix = files(ii).name(1:end-10);
            
            accel_data = csvread([dirName file_name_prefix '-accel.txt']);
            % remove duplicate timestamps
            ts = accel_data(:,1);    
            ts_same = (ts(1:end-1,1)==ts(2:end,1));
            ts_diff = diff(ts(~ts_same,:));
            timestamp_distances = [timestamp_distances; ts_diff];
        end
    end
end

sampling_rate = 1000/mean(timestamp_distances); % As timestamp is in milliseconds, we multiply sampling rate with 1000
fprintf("Data points captures in 1 second: %.3f", sampling_rate);
% Answer obtained was 207.159 => ~200 data points
% => 2s shift should be 400 data points, 10s window will have 2000 data
% points
% For the purpose of the assignment, we will take 32 datapoints/s (Used for windowing(320 data point window) and window shift(64 data point shift))
% => fs=32Hz (Used for extracting frequency domain features)
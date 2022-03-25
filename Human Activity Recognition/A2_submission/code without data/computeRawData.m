function [raw_data_vector,raw_data_label, y_bar_ts_all] = computeRawData( dir_name )
%COMPUTERAWDATA Summary of this function goes here
%   Detailed explanation goes here

%compute label names once
if exist('label_names.mat') ==0
    files = dir([ dir_name '*-accel.txt']); 
    activity_names = containers.Map;
    activity_names_indexed = {};
    k = 1;
    for i = 1:length(files)
        if ~isKey(activity_names, files(i).name(26:end-17)) %open first data file in first folder, count how many letters before and after Activity name
            activity_names(files(i).name(26:end-17)) = k;
            activity_names_indexed{k,1} = files(i).name(26:end-17);
            k = k + 1;
        end
    end
    save label_names activity_names_indexed activity_names
else

load label_names

%make the raw data files
% read the txt file
files = dir([ dir_name '*-accel.txt']);
y_accel_all = [];
y_bar_all = [];
y_bar_ts_all = [];
y_label_all = [];
activity_index = 0;

for ii = 1:length(files)
    file_name_prefix = files(ii).name(1:end-10);
      
    for act=1:length(activity_names_indexed)
        if(length(findstr(files(ii).name, activity_names_indexed{act}))>0)
            break;
        end
    end
    activity_index = act;
    
    time_to_exclude = 1;
    
    % ts,a_x,a_y,a_z
    accel_data = csvread([dir_name file_name_prefix '-accel.txt']);
    % remove duplicate timestamps
    ts = accel_data(:,1);    
    ts_same = (ts(1:end-1,1)==ts(2:end,1));

    accel_data = accel_data(1:end-1,:);
    accel_data = accel_data(~ts_same,:);
    y_accel_x = interp1(accel_data(:,1),accel_data(:,2),accel_data(1,1):1000/32:accel_data(end,1),'spline');
    y_accel_y = interp1(accel_data(:,1),accel_data(:,3),accel_data(1,1):1000/32:accel_data(end,1),'spline');
    y_accel_z = interp1(accel_data(:,1),accel_data(:,4),accel_data(1,1):1000/32:accel_data(end,1),'spline');
    y_accel_x = y_accel_x(time_to_exclude*32+1:end-time_to_exclude*32);
    y_accel_z = y_accel_z(time_to_exclude*32+1:end-time_to_exclude*32);
    y_accel_y = y_accel_y(time_to_exclude*32+1:end-time_to_exclude*32); %get rid of three seconds from start and end
    y_accel = [y_accel_x' y_accel_y' y_accel_z'];
    
    % ts, barometer
    bar_data = csvread([dir_name file_name_prefix '-pressure.txt']);
    % remove dupilicate timestamps
    ts = bar_data(:,1);
    ts_same = (ts(1:end-1,1)==ts(2:end,1));
    bar_data = bar_data(1:end-1,:);
    bar_data = bar_data(~ts_same,:);
    y_bar = interp1(bar_data(:,1),bar_data(:,2),accel_data(1,1):1000/32:accel_data(end,1),'spline','extrap');
    %compute barometer pressure
    %for every 128 features we do feature extraction
    y_bar_value = smooth(y_bar,4*128,'loess');
    y_bar_ts = accel_data(1,1):1000/32:accel_data(end,1); %creating new timestamp for bar data
    y_bar = y_bar_value(time_to_exclude*32+1:end-time_to_exclude*32); %get rid of three seconds from start and end
    %
    y_label = activity_index*ones(length(y_bar),1);
    
    %keep only multiple of 64 + 320 length of the vector 
    % (10s window with 2s shift as fs = 32 datapoints/s)
    ideal_limit =  64*floor((length(y_label)-320)/64) + 320;
    y_accel = y_accel(1:ideal_limit,:);
    y_bar = y_bar(1:ideal_limit);
    y_label = y_label(1:ideal_limit,1);
    y_bar_ts = y_bar_ts(1:ideal_limit);
    
    y_accel_all = [y_accel_all ; y_accel];
    y_label_all = [y_label_all ; y_label];
    y_bar_all = [y_bar_all ; y_bar];
    y_bar_ts_all = [y_bar_ts_all ; y_bar_ts'];
end

raw_data_vector = [y_accel_all y_bar_all];
raw_data_label = y_label_all;


end


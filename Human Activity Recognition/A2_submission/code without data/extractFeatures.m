function featureVector = extractFeatures(file_name)
load(file_name)

featureVector = [];
activityLabel = [];
% Here we are extracting the magnitude of the 3D accelerometer values
y_accel_mag = sqrt(raw_data_vector(:,1).^2 + raw_data_vector(:,2).^2 + raw_data_vector(:,3).^2);
% Here we are extracting the barometer data from the 4th column of the
% raw_data_vector
y_bar_value =  raw_data_vector(:,4);
k = 1;
    for i = 1:64:size(raw_data_vector,1)-320+1   % step size = 64 (2s), i goes till (size(data)-320)(10s)
        
        % extract 20 time domain (TD) features (10 accel mag TD features and 10 barometer TD features)    
        %
        % Your time domain feature extraction code will go here.
        accel_window = y_accel_mag(i:i+320-1);  % 10s window of 320 data points
        bar_window = y_bar_value(i:i+320-1);    % 10s window of 320 data points
        
        %median
        y_accel_mag_median = median(accel_window);
        y_bar_value_median = median(bar_window);
    
        % sd
        y_accel_mag_sd = std(accel_window);
        y_bar_value_sd = std(bar_window);
        
        skewns = @(x) (sum((x-mean(x)).^3)./length(x)) ./ (var(x,1).^1.5);
        % skewness
        y_accel_mag_skewness = skewns(accel_window);
        y_bar_value_skewness = skewns(bar_window);
        
        % mean crossing rate
        y_accel_mag_mcr = numel(find(accel_window > mean(accel_window)));
        y_bar_value_mcr = numel(find(bar_window > mean(bar_window)));
        
        % Slope (fit a line and estimate the m from y=mx+c)
        lineaccel = polyfit(1:320, accel_window, 1);
        y_accel_mag_slope = lineaccel(1);
        linebar = polyfit(1:320,bar_window, 1);
        y_bar_value_slope = linebar(1);
        
        % Interquartile range
        y_accel_mag_iqr = iqr(accel_window);
        y_bar_value_iqr = iqr(bar_window);
        
        % 25th Percentile
        y_accel_mag_25th_percentile = prctile(accel_window, 25);
        y_bar_value_25th_percentile = prctile(bar_window, 25);
        
        [peaks_ac, loc_ac] = findpeaks(accel_window);
        [peaks_bar, loc_bar] = findpeaks(bar_window);
        % Number of peaks
        y_accel_mag_total_peaks = numel(peaks_ac);
        y_bar_value_total_peaks = numel(peaks_bar);
        
        % Mean peak values
        y_accel_mag_mean_peaks = mean(peaks_ac);
        y_bar_value_mean_peaks = mean(peaks_bar);
        
        % Mean peak distance
        y_accel_mag_mean_peak_dist = mean(diff(loc_ac));
        y_bar_value_mean_peak_dist = mean(diff(loc_bar));
        
        % extract 10 frequency domain (FD) features (5 accel mag FD features and 5 barometer FD features)
        % Your frequency domain feature extraction code will go here.        
       
        [ac_energy, ac_f] = FREQUENCYDOMAIN.extractFFT(accel_window);
        [bar_energy, bar_f] = FREQUENCYDOMAIN.extractFFT(bar_window);

        % spectral centroid       
        y_accel_mag_spectral_centroid = FREQUENCYDOMAIN.findSpectralCentroid(ac_energy, ac_f);
        y_bar_value_spectral_centroid = FREQUENCYDOMAIN.findSpectralCentroid(bar_energy, bar_f);
        
        % spectral_spread        
        y_accel_mag_spectral_spread = FREQUENCYDOMAIN.findSpectralSpread(ac_energy, ac_f);
        y_bar_value_spectral_spread = FREQUENCYDOMAIN.findSpectralSpread(bar_energy, bar_f);
        
        % spectral roll off 75%        
        y_accel_mag_spectral_roll_off75 = FREQUENCYDOMAIN.findSpectralRolloffPoint(ac_energy, ac_f, 0.75);
        y_bar_value_spectral_roll_off75 = FREQUENCYDOMAIN.findSpectralRolloffPoint(bar_energy, bar_f, 0.75);
        
        % filter bank       
        [y_accel_mag_freq1, y_accel_mag_freq2] = FREQUENCYDOMAIN.filterBank(ac_energy, ac_f);
        [y_bar_value_freq1, y_bar_value_freq2] = FREQUENCYDOMAIN.filterBank(bar_energy, bar_f);
        
        % Make sure that you have added all the features to the featureVector
        % matrix
        featureVector(k,:) = [y_accel_mag_median y_accel_mag_sd y_accel_mag_skewness y_accel_mag_mcr y_accel_mag_slope y_accel_mag_iqr y_accel_mag_25th_percentile y_accel_mag_total_peaks y_accel_mag_mean_peaks y_accel_mag_mean_peak_dist y_bar_value_median y_bar_value_sd y_bar_value_skewness y_bar_value_mcr y_bar_value_slope y_bar_value_iqr y_bar_value_25th_percentile y_bar_value_total_peaks y_bar_value_mean_peaks y_bar_value_mean_peak_dist y_accel_mag_spectral_centroid y_accel_mag_spectral_spread y_accel_mag_spectral_roll_off75 y_accel_mag_freq1 y_accel_mag_freq2 y_bar_value_spectral_centroid y_bar_value_spectral_spread y_bar_value_spectral_roll_off75 y_bar_value_freq1 y_bar_value_freq2];  
        activityLabel = [activityLabel; mode(raw_data_label(i:i+320-1,1))];
        
        k = k + 1;
    end
    featureVector = [featureVector,activityLabel]; % Adding activityLabel in the last column of the featureVector

end
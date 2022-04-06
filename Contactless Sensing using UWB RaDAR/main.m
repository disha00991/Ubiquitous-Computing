clear;
close all;
warning off
 
% create a file for radar locations ground truth values(in meters) 
% considering R103 at the origin
if exist('radar_info.mat') == 0
    R103 = [0, 0];
    R108 = [0, 2.032];
    R109 = [1.016, 0];
    paths = ["/103/", "/108/", "/109/" ];
    pattern_suffix = ["_1033", "_103", "_102"];
    save radar_info R103 R108 R109 paths pattern_suffix
end
load radar_info

% create a file to contain pattern names for easy indexing and looping
if exist('pattern_labels.mat') == 0
    pattern(:,1) = ["diag", "U", "gamma", "L", "four"];
    save pattern_labels pattern
end
load pattern_labels

% create a file to contain ground truth pattern coordinates
if exist('pattern_ground_truth.mat') == 0
    % ground truths stored in this order ["diag", "U", "gamma", "L", "four"];
    ground_truths = [];
    for i=1:5
        I = [];
        X = [];
        Y = [];
        if (i==1)
            X = [0.762 1.98];
            Y = [0.9652 3.4];
            I = [1 1]
        end
        if (i==2)
            X = [0.762 0.762 1.98 1.98];
            Y = [3.4 0.9652 0.9652 3.4];
            I = [2 2 2 2]
        end
        if (i==3)
            X = [0.762 1.98 1.98];
            Y = [0.9652 0.9652 3.4];
            I = [3 3 3]
        end
        if (i==4)
            X = [0.762 1.98 1.98];
            Y = [3.4 3.4 0.9652];
            I = [4 4 4]
        end
        if (i==5)
            X = [0.762 0.762 1.98 1.98];
            Y = [3.4 2.1844 2.1844 0.9652];
            I = [5 5 5 5]
        end
        gt = [];
        gt(:, 1) = I;
        gt(:, 2) = X;
        gt(:, 3) = Y;
        ground_truths = [ground_truths; gt];
    end
    save pattern_ground_truth ground_truths
end
load pattern_ground_truth

% Process data for each participant
% radial distance of the human body from corresponding
% radar at ith scan is calculated using thresholding
participants = ["participant1", "participant2"];
radars = paths;
patterns = pattern;

dataDir = pwd+"/DataSet/Localization/";

for p=1:length(participants)
    for pat=1:length(patterns)      
        % find radial distances for each scan from each radar for a
        % particular pattern 'pat' using THRESHOLDING
        % also find the valid timestamps for which at least 1 value is greater than
        % the threshold
        filepath = dataDir + participants{p} + radars(1) + patterns(pat);
        [dist_103, ts103] = findRadialDistance(filepath, 1);
        filepath = dataDir + participants{p} + radars(2) + patterns(pat);
        [dist_108, ts108] = findRadialDistance(filepath, 2);
        filepath = dataDir + participants{p} + radars(3) + patterns(pat);
        [dist_109, ts109] = findRadialDistance(filepath, 3);
    
        % TIME SYNCHRONIZATION: synchronize timestamp data by keeping only
        % overlapping windows
        [ts_idx_103, ts_idx_108, ts_idx_109] = synchronize_time(ts103, ts108, ts109);    
        dist_103 = dist_103(ts_idx_103);
        dist_108 = dist_108(ts_idx_108);
        dist_109 = dist_109(ts_idx_109);
        ts103 = ts103(ts_idx_103);
        ts108 = ts108(ts_idx_108);
        ts109 = ts109(ts_idx_109);
        
        % WINDOWING to estimate radial distances of user from each radar 
        % within each window of 0.25s by taking centroid of all circles
        % that can be drawn within this window
        estimated_dists = perform_windowing(ts103, ts108, ts109, dist_103, dist_108, dist_109);

        % TRILATERATION to get x, y coordinate of the human body at each
        % window that were predicted within the room
        coordinates_matrix = get_coords_by_trilateration(estimated_dists);
        
        % PLOT the matrix
        figure(length(patterns)*(p-1) + pat);
        ground_truth = ground_truths(ground_truths(:,1)==pat,2:3)
        fig = plot_the_pattern(coordinates_matrix, participants(p), patterns(pat), ground_truth);
        saveas(fig,string(length(patterns)*(p-1) + pat)+'.jpg');
    end    
end

function [radial_dists, valid_timestamps] = findRadialDistance(filepath, radar)
    load radar_info.mat pattern_suffix;
    envelope_data = getfield(load(filepath+"/envNoClutterscans.mat"), "envNoClutterscansV"+pattern_suffix(radar));
    rangebins = getfield(load(filepath+"/range_bins.mat"), "Rbin"+pattern_suffix(radar));
    timestamps = getfield(load(filepath+"/T_stmp.mat"), "T_stmp"+pattern_suffix(radar));

    % find radial distance by finding the argument of the first
    % rangebin that has envelope magnitude > 5* 10^4    
    THRESHOLD = 5e+4;
    radial_dists = [];
    valid_scans = [];
    for row=1:size(envelope_data,1)
        arg = find(envelope_data(row,:) > THRESHOLD, 1);
        if (isempty(arg)) 
            % the row doesn't have a single value greater than threshold
            continue;
        else
            radial_dists = [radial_dists, rangebins(arg)];
            valid_scans = [valid_scans, row];
        end        
    end
    valid_timestamps = timestamps(valid_scans);
end

function [ts_idx_103, ts_idx_108, ts_idx_109] = synchronize_time(ts103, ts108, ts109)
    start = max([ts103(1), ts108(1), ts109(1)]);
    stop = min([ts103(end), ts108(end), ts109(end)]);
    
    ts_idx_103 = ts103>=start & ts103<=stop;
    ts_idx_108 = ts108>=start & ts108<=stop;
    ts_idx_109 = ts109>=start & ts109<=stop;
end

function coordinates_matrix = get_coords_by_trilateration(estimated_dists)
    load radar_info.mat R103 R108 R109
    % first finding the intersection point matrix X, Y for 2 circles with centers R103, R109.
    % Taking advantage of the fact that R103 is at origin and R109
    % is on the x-axis, we can deduce the formula for x, y and consider
    % only the positive y as the negative y is outside the room
    % x = (d^2 - r^2 + R^2)/2*d , y = |sqrt(R^2 - x^2)|
    % where d = R109's x-coordinate, r = radius of R109 circle, R = radius of
    % R103 circle (radial distance between human and radar)

    d = R109(1);
    r = estimated_dists(:,3);
    R = estimated_dists(:,1);

    X = (d^2 - r.^2 + R.^2)/2*d;
    Y = sqrt(R.^2 - X.^2);
    
    coordinates_matrix = []
    % check if x, y are within room boundaries
    for i=1:size(X, 1)        
        x = X(i);
        y = Y(i);          
        if (x > 0 && y > 0 && x < 4.04 && y < 4.04)
            coordinates_matrix = [coordinates_matrix; x y]; % found valid point of intersection of 3 circles
        end  
    end

    % check if the intersection point x, y lies on the third circle with center R108
    % by checking: distance between x, y and the center of R108 =
    % radius of R108 circle
    % P.S: since we could easily eliminate the second intersection point with
    % negative y-coordinate, this step is not needed for these radar
    % coordinates as the x, y found is the only intersection possible
    % anyway, hence commenting this for now

%     coordinates_matrix = [];
%     for i=1:size(dist_108, 2)
%         cx = R108(1);
%         cy = R108(2);
%         x = X(i)
%         y = Y(i)
%         if ((x - cx)^2 + (y - cy)^2 == dist_108(i)^2)
%             coordinates_matrix = [coordinates_matrix; x y]; % found valid point of intersection of 3 circles
%         end
%     end
end

function estimated_dists = perform_windowing(ts103, ts108, ts109, dist_103, dist_108, dist_109)
    window_size = 0.25;
    window_shift = 0.125;
    estimated_dists=[];
    tsfirst = min([ts103(1), ts108(1), ts109(1)]); % which one starts first
    tslast = min([ts103(end), ts108(end), ts109(end)]); % which one ends first
    for ts = tsfirst:window_shift:tslast-window_size        
        window103 = dist_103(ts<=ts103 & ts103<=ts+window_size);
        window108 = dist_108(ts<=ts108 & ts108<=ts+window_size);
        window109 = dist_109(ts<=ts109 & ts109<=ts+window_size);

        if (size(window103)~=0 & size(window108)~=0 & size(window109)~=0)
            estimated_dists = [estimated_dists; mean(window103), mean(window108), mean(window109)];
        end
    end
end

function fig = plot_the_pattern(coords, participant, pattern, ground_truth) 
    fig = scatter(coords(:,1), coords(:, 2), 20, "red", "filled");
    hold on;
    line(ground_truth(:,1), ground_truth(:,2),'Color','green','LineWidth', 4);
    xticks(0:0.5:4);
    yticks(0:0.5:4);
    xlabel("feetside");
    ylabel("window wall");
    title(['Pattern', pattern, 'tracking for ', participant]);
end
clear;
close all;
warning off

dataDir = [pwd,'/DataSet/Localization/participant1'];

figure(1)
addpath([dataDir '/103/diag/']);
load envNoClutterscans.mat
load range_bins.mat;
load T_stmp.mat;

rangebins = Rbin_1033;
scans = [1:length(T_stmp_1033)];
magnitude = envNoClutterscansV_1033;

x = [rangebins(1,1), rangebins(1,end)]
y = [scans(1,1), scans(1,end)]

imagesc(x, y, magnitude);
xlabel('Fast Time/Range');
ylabel('Slow Time/Scan Number');
title('Waterfall plot for participant1 pattern: diagonal, Radar R103')

figure(2)
addpath([dataDir '/108/diag/']);
load envNoClutterscans.mat
load range_bins.mat;
load T_stmp.mat;

rangebins = Rbin_103;
scans = [1:length(T_stmp_103)];
magnitude = envNoClutterscansV_103;

x = [rangebins(1,1), rangebins(1,end)]
y = [scans(1,1), scans(1,end)]

imagesc(x, y, magnitude);
xlabel('Fast Time/Range');
ylabel('Slow Time/Scan Number');
title('Waterfall plot for participant1 pattern: diagonal, Radar R108')



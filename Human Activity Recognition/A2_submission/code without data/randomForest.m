%%% classification RF
% -- Dataset split into train, test -- %
load label_names 
featureMatrix = load('allData/all_features.mat').featureMatrix;

domain = 'all'; % change this to 'all', 'time' or 'freq' to run script with all or few features
startidx = 1;
endidx = 30;
labelidx = 31;
subjectIdidx = 32;
if domain == 'time'
    endidx = 20;
end
if domain == 'freq'
    startidx = 21;
end
trainData = featureMatrix(featureMatrix(:, subjectIdidx) ~= 0, :);
testData = featureMatrix(featureMatrix(:, subjectIdidx) == 0, :);
X_train = trainData(:, startidx:endidx);
Y_train = trainData(:, labelidx);
X_test = testData(:, startidx:endidx);
Y_test = testData(:, labelidx);

% -- Using Random Forest classifier model -- %
% Set the number of trees
nTrees = 800;
% Fit the random forest model
random_forest_model = TreeBagger(nTrees, X_train, Y_train, 'Method', 'classification');
% Start prediction
predictLabels = str2num(cell2mat(predict(random_forest_model, X_test)));
% Compute the accuracy
fprintf("Random Forest performance:\n");
testAccuracy = sum(predictLabels == Y_test)/length(Y_test);
fprintf("testAccuracy:%.2f\n",testAccuracy);
find_performance(Y_test, predictLabels, activity_names_indexed);
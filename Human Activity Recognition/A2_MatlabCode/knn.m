%%% classification KNN
% -- Dataset split into train, test -- %
load label_names 
activity_names_indexed=activity_names_indexed(1:7,1);
featureMatrix = load('allData/all_features.mat').featureMatrix;
trainData = featureMatrix(featureMatrix(:, 32) ~= 0, :);
testData = featureMatrix(featureMatrix(:, 32) == 0, :);
X_train = trainData(:, 1:30);
Y_train = trainData(:, 31);
X_test = testData(:, 1:30);
Y_test = testData(:, 31);

% -- K-Nearest Neighbor Classifier model -- %
% Fit a knn model
knn_model = fitcknn(X_train, Y_train, 'NumNeighbors', 5, 'Standardize', 1); 
% Start predicting
predictLabels = predict(knn_model, X_test);
% Compute the accuracy
fprintf("KNN performance:\n");
testAccuracy = sum(predictLabels == Y_test)/length(Y_test);
fprintf("testAccuracy:%.2f\n",testAccuracy);
find_performance(Y_test, predictLabels, activity_names_indexed);
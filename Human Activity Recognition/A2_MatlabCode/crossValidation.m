% STEP 5: leave-one-out cross validation (using Random Forest Classifier)

load label_names 
featureMatrix = load('allData/all_features.mat').featureMatrix;

nTrees = 800;
overall_C = [];

for subjectId = 1:23 % run for total number of subjects
    fprintf("Processing Subject id: %d\n", subjectId);

    trainData = featureMatrix(featureMatrix(:, 32) ~= subjectId, :);
    testData = featureMatrix(featureMatrix(:, 32) == subjectId, :);

    xtrn= trainData(:, 1:30);
    ytrn = trainData(:, 31);
    xtest = testData(:, 1:30);
    ytest = testData(:, 31);

    random_forest_model = TreeBagger(nTrees, xtrn, ytrn, 'Method', 'classification');
    ytest_pred = str2num(cell2mat(predict(random_forest_model, xtest))); 

    if subjectId==1
        overall_C = confusionmat(ytest, ytest_pred, 'Order', [1:7]);
    else
        overall_C = overall_C + confusionmat(ytest, ytest_pred, 'Order', [1:7]);
    end
end

fprintf("Overall Confusion Matrix:\n");
disp(overall_C);
C = overall_C;

fprintf("Cross-Validated Activity wise Performance Metrics:\n");
fprintf("Activity | Precision | Recall | F-1 Score\n");
for i = 1:length(activity_names_indexed)
    precision = C(i,i)/sum(C(:,i));
    recall = C(i,i)/sum(C(i,:));
    f1_score = 2*precision*recall/(precision+recall);
    fprintf("%s |  %.2f  | %.2f  | %.2f \n", activity_names_indexed{i}, precision, recall, f1_score);
end
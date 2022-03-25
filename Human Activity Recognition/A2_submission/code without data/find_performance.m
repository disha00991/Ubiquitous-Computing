function find_performance(actual, predicted, activity_names_indexed) 
    C = confusionmat(actual,predicted);
    disp(C);
    fprintf("Activity wise Performance Metrics:\n");
    fprintf("Activity | Precision | Recall | F-1 Score\n");
    for i = 1:length(activity_names_indexed)
        precision = C(i,i)/sum(C(:,i));
        recall = C(i,i)/sum(C(i,:));
        f1_score = 2*precision*recall/(precision+recall);
        fprintf("%s |  %.2f  | %.2f  | %.2f \n", activity_names_indexed{i}, precision, recall, f1_score);
    end
end
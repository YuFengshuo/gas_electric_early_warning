function ALP = ALP_0_cal(initial_LP, final_LP)
for k=1:length(initial_LP)
    ALP{k} = initial_LP{k} - final_LP{k};
end
fid =  {'2U_3dayOldFemales_25C_day1_A.mat'
        '2U_3dayOldFemales_25C_day1_B.mat'
        '2U_3dayOldFemales_25C_day1_C.mat'
        '2U_3dayOldFemales_25C_day1_D.mat'
        '2U_3dayOldFemales_25C_day1_E.mat'
        '2U_3dayOldFemales_25C_day1_F.mat'
        '2U_3dayOldFemales_25C_day1_G.mat'
        '2U_3dayOldFemales_25C_day2_A.mat'
        '2U_3dayOldFemales_25C_day2_B.mat'
        '2U_3dayOldFemales_25C_day2_C.mat'
        '2U_3dayOldFemales_25C_day2_D.mat'
        '2U_3dayOldFemales_25C_day2_E.mat'
        '2U_3dayOldFemales_25C_day2_F.mat'
        '2U_3dayOldFemales_25C_day2_G.mat'};

ex = [];
obs = [];
    
for i = 1:length(fid)
    load(fid{i})
    [extmp obstmp] = flyMI(flyTracks);
    ex = [ex extmp];
    obs = [obs obstmp];
end

multiHist({ex obs})
varList=who;

totalFlies=0;
totalChoices=0;

for i=1:length(varList)
    eval(['temp=' varList{i} ';']);
    if strcmp(class(temp),'double')
        if size(temp,2)==40
            totalFlies=totalFlies+size(temp,1);
            totalChoices=totalChoices+sum(sum(not(isnan(temp))));
        end
    end
    
    
    
end

tempList={H_precocious,H_stragglers,broodControl,cantonS_original,eggBroods_all};
tempList=[tempList,eggMother20,eggMother23,eggMother27,eggMother28,eggMother30,eggMother9];
tempList=[tempList,female_camA,female_cantonS,male_camA,male_cantonS,female_corr_day1s,female_sim195];
tempList=[tempList,male_corr_day1s,male_sim195,w1118_5HTP_fed_original];
for i=1:length(tempList)
    temp=tempList{i};
    totalFlies=totalFlies-size(temp,1);
    totalChoices=totalChoices-sum(sum(not(isnan(temp))));
end

tempList={cantonS_aMW_wash.day5,corr14day.day15,corr1day.day2,corr28day.day29};
tempList=[tempList,corr2day.day3,corr3day.day4,corr4day.day5,corr5day.day6,corr6day.day7];
tempList=[tempList,oldFlies.day2,w1118_5HTP_wash.day5,trh_shi_5d30_t23_chronic_wash.day5];
for i=1:length(tempList)
 temp=tempList{i};
    totalFlies=totalFlies+size(temp,1);
    totalChoices=totalChoices+sum(sum(not(isnan(temp))));
end



[totalFlies totalChoices]

clear temp;
clear totalFlies;
clear totalChoices;
clear i;
clear tempList;
clear varList;
clear ans;
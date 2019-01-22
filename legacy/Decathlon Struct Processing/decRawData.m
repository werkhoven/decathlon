for i = 1:length(flyData)
    circData(i).ID=flyData(i).circles.ID;
    circData(i).mu=flyData(i).circles.mu;
    circData(i).angleavg=flyData(i).circles.angleavg;
    circData(i).numTrials=flyData(i).circles.numTrials;
    circData(i).speed=flyData(i).circles.speed;
    circData(i).habituation=flyData(i).circles.habituation;
    circData(i).edgeposition=flyData(i).circles.edgeposition;
    circData(i).angleSD=flyData(i).circles.angleSD;
    circData(i).angleSEM=flyData(i).circles.angleSEM;
end
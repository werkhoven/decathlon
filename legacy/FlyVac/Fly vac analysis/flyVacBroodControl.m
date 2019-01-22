function out=flyVacBroodControl

broodC=[];

for i=1:100
    temp=rand(1,40);
    broodC=[broodC;(temp>(1-0.6234))*2-1];
        temp=rand(1,40);
    broodC=[broodC;(temp>(1-0.5128))*2-1];
    
end

out.sim=broodC;


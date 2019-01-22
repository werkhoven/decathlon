function [optoChoice,handedness]=optoGetTurnData(current_arm,changedArm,stimProps,stim_status)

optoChoice=NaN(size(current_arm));
handedness=NaN(size(current_arm));
stimAngle=stimProps.angle(1:size(current_arm,1));

if stim_status==1
p1=(stimAngle==0).*(current_arm==1).*changedArm; %good
p2=(stimAngle==66).*(current_arm==2).*changedArm; %good
p3=(stimAngle==115).*(current_arm==2).*changedArm; %good
p4=(stimAngle==180).*(current_arm==3).*changedArm; %good
p5=(stimAngle==242).*(current_arm==3).*changedArm; %good
p6=(stimAngle==295).*(current_arm==1).*changedArm; %good
Tpos=boolean(p1+p2+p3+p4+p5+p6);
optoChoice(Tpos)=1;

n1=(stimAngle==0).*(current_arm==3).*changedArm; %good
n2=(stimAngle==66).*(current_arm==3).*changedArm; %good
n3=(stimAngle==115).*(current_arm==1).*changedArm; %good
n4=(stimAngle==180).*(current_arm==1).*changedArm; %good
n5=(stimAngle==242).*(current_arm==2).*changedArm; %good
n6=(stimAngle==295).*(current_arm==2).*changedArm; %good
Tneg=boolean(n1+n2+n3+n4+n5+n6);
optoChoice(Tneg)=0;
end

r1=(stimAngle==0).*(current_arm==1).*changedArm; %good
r2=(stimAngle==66).*(current_arm==3).*changedArm; %good
r3=(stimAngle==115).*(current_arm==2).*changedArm; %good
r4=(stimAngle==180).*(current_arm==1).*changedArm; %good
r5=(stimAngle==242).*(current_arm==3).*changedArm; %good
r6=(stimAngle==295).*(current_arm==2).*changedArm; %good
Tright=boolean(r1+r2+r3+r4+r5+r6);
handedness(Tright)=1;

l1=(stimAngle==0).*(current_arm==3).*changedArm;  %good
l2=(stimAngle==66).*(current_arm==2).*changedArm; %good
l3=(stimAngle==115).*(current_arm==1).*changedArm; %good
l4=(stimAngle==180).*(current_arm==3).*changedArm; %good
l5=(stimAngle==242).*(current_arm==2).*changedArm; %good
l6=(stimAngle==295).*(current_arm==1).*changedArm; %good
Tleft=boolean(l1+l2+l3+l4+l5+l6);
handedness(Tleft)=0;

end
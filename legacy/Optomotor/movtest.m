frame=zeros(720,1280,3);
stimulus=zeros(720,1280,3,20);
frame(:,:,1)=1;
frame(:,:,3)=1;

for i = 1:10;
    lineend=i:10:720;
    linestart=lineend-5;

    for j=1:72;
        if 1 <= i <= 5;
            frame(i+715:720,:,3)=0;
        end
        if linestart(j) < 1;
            linestart(j)=1;
        end
        if lineend(j) > 720;
        lineend(j)=720;
        end
        frame(linestart(j):lineend(j),:,3)=0;
    end
        stimulus(:,:,:,i)=frame;
        frame(:,:,1)=1;
        frame(:,:,3)=1;
end

for n=1:10;
    stimmov(n)=im2frame(stimulus(:,:,:,n));
end
movie(gcf,stimmov,40);
movie2avi(stimmov,'optomotorstimulus.avi', 'compression', 'Cinepak');
    
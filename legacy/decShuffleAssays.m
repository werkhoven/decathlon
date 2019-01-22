assays = {'Y-maze';'LED Y-maze';'Arena Circling';'Optomotor';...
    'Slow Phototaxis';'Geotaxis';'FlyVac Phototaxis';'Olfactory Tunnels'};

%%
perm = randperm(length(assays));
disp('');
for i = 1:length(assays)
    disp([num2str(i) ' - ' assays{perm(i)}]);
end
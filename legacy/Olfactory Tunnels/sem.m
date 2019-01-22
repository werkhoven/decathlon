function stderr = sem(distro)

distro = distro(~isnan(distro));

stderr = std(distro) / sqrt(length(distro));
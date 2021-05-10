function labelPrefix = defineMuscleList(mOrder)

    labelPrefix=([strcat('f',mOrder) strcat('s',mOrder)]); %To display fast and slow
    labelPrefix = strcat(labelPrefix,'_s');
    
end


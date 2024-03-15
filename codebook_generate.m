function codebook = codebook_generate(audio_file, num_mel_coeffs, ...
                                      num_clusters, max_itr, epsilon)

    window = hann(256, "periodic");
    mfccs = get_mfccs(audio_file, num_mel_coeffs, 256, 85, window);
    
    % Assuming melcc contains cepstral coefficients
    
    % ------------------ BOILERPLATE LBG IMPLEMENTATION --------------------
    
    % Little has been modified / optimized here from online resources, has not
    % been sufficiently tested (may need to be reimplemented).
    
    % Initialize codebook using random vectors from melcc
    % codebook = mfccs(randperm(size(mfccs, 1), num_clusters), :);
    % for iter = 1:max_itr
    %     % Vector quantization step: Assign each vector to the nearest centroid
    %     [~, assignments] = pdist2(codebook, mfccs, 'euclidean', 'Smallest', 1);
    % 
    %     % Update centroids
    %     new_codebook = zeros(size(codebook));
    %     for i = 1:num_clusters
    %         cluster_indices = (assignments == i);
    %         if any(cluster_indices)
    %             new_codebook(i, :) = mean(mfccs(cluster_indices, :), 1);
    %         else
    %             % If no vectors were assigned to this centroid, keep it unchanged
    %             new_codebook(i, :) = codebook(i, :);
    %         end
    %     end
    % 
    %     % Check for convergence
    %     if max(vecnorm(new_codebook - codebook, 2, 2)) < epsilon
    %         break;
    %     end
    % 
    %     % Update codebook
    %     codebook = new_codebook;
    % end

    % Assuming training_vectors is your input data matrix with Mel coefficients
    
    % Initialize codebook size based on the desired number of clusters and Mel coefficients
    num_mel_coefficients = size(mfccs, 2); % Number of Mel coefficients
    
    codebook = zeros(num_clusters, num_mel_coefficients); % Initialize codebook
    
    % Step 1: Initialize with a single-vector codebook (centroid of all training vectors)
    centroid = mean(mfccs, 1); % Calculate the centroid
    codebook(1, :) = centroid; % Initialize codebook with centroid
    
    % Step 2: Double the size of the codebook
    while size(codebook, 1) < num_clusters
        new_codebook = zeros(size(codebook, 1)*2, size(codebook, 2));
        for i = 1:size(codebook, 1)
            new_codebook(2*i-1, :) = codebook(i, :) * (1 + epsilon);
            new_codebook(2*i, :) = codebook(i, :) * (1 - epsilon);
        end
        codebook = new_codebook;
    end
    
    % Step 3: Nearest-Neighbor Search & Step 4: Centroid update
    average_distance = Inf;
    threshold = 0.001; % Preset threshold
    while average_distance > threshold
        % Nearest-Neighbor Search
        assigned_cells = zeros(size(mfccs, 1), 1);
        for i = 1:size(mfccs, 1)
            distances = sqrt(sum((codebook - mfccs(i, :)).^2, 2));
            [~, assigned_cells(i)] = min(distances);
        end
        
        % Centroid update
        new_codebook = zeros(size(codebook));
        for i = 1:num_clusters
            indices = find(assigned_cells == i);
            if ~isempty(indices)
                new_codebook(i, :) = mean(mfccs(indices, :), 1);
            else
                % If no training vector assigned to this codeword, keep the previous codeword
                new_codebook(i, :) = codebook(i, :);
            end
        end
        
        % Calculate average distance
        distances = sqrt(sum((new_codebook - codebook).^2, 2));
        average_distance = mean(distances);
        
        % Update codebook
        codebook = new_codebook;
    end


% Resulting codebook
% disp('Final codebook:');
% disp(codebook);


end
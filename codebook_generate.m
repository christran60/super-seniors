function codebook = codebook_generate(audio_file, num_mel_coeffs, ...
                                      num_clusters, epsilon, frame_size, ...
                                      overlap_size, window)

    % The maximum number of iterations that LBG can perform to attempt to
    % reach the epsilon requirement
    num_max_itr = 100;

    % Get the MFCCs to characterize the audio file
    mfccs = get_mfccs(audio_file, num_mel_coeffs, frame_size, overlap_size, ...
                        window);
    
    % Initialize the codebook with random MFCC vectors - this allows us to
    % have unrestricted control over the number of clusters that we can
    % generate, as it is not restricted by powers of 2
    codebook = mfccs(randperm(size(mfccs, 1), num_clusters), :);

    for n = 1:num_max_itr
        % Vector quantization step: Assign each vector to the nearest centroid
        % The "assignments" vector contains the index of the nearest
        % existing centroid to every MFCC vector
        [~, assignments] = pdist2(codebook, mfccs, 'euclidean', 'Smallest', 1);

        % Update the centroids with the newly added vectors in the clusters
        new_codebook = zeros(size(codebook));
        for i = 1:num_clusters
            % cluster_indices is an array that contains all vectors that
            % were assigned to the ith centroid - essentially all vectors
            % that had the smallest Euclidean distance to the ith centroid
            cluster_indices = (assignments == i);

            % If any of the cluster_indices are nonzero, update the
            % codebook with the mean of all the vectors assigned to this
            % cluster
            if any(cluster_indices)
                new_codebook(i, :) = mean(mfccs(cluster_indices, :), 1);
            else
                % If no vectors were assigned to this centroid, keep it 
                % unchanged
                new_codebook(i, :) = codebook(i, :);
            end
        end

        % Check for convergence
        % if max(vecnorm(new_codebook - codebook, 2, 2)) < epsilon
        %     break;
        % end

        distortion = norm(new_codebook - codebook, 2);
        if distortion < epsilon
            break;
        end

        % Update codebook
        codebook = new_codebook;

    end
end
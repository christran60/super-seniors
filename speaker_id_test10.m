% Parameters to adjust
num_clusters = 32;
num_mel_coeffs = 32;
frame_size = 512;
overlap_ratio = 0.8;
epsilon = 0.000001;
window = kaiser(frame_size, 0.5);

overlap_size = round(frame_size * overlap_ratio);

% Input-related data: adjust based on what the input path is
num_speakers = 19;
% path_train = "StudentAudioRecording/Twelve-Training/Twelve_train";
% path_test = "StudentAudioRecording/Twelve-Testing/Twelve_test";
path_train = "StudentAudioRecording/Zero-Training/Zero_train";
path_test = "StudentAudioRecording/Zero-Testing/Zero_test";
% path_train = "GivenSpeech_Data/Training_Data/s";
% path_test = "GivenSpeech_Data/Test_Data/s";

% Training phase: Get the codebooks of all speakers
list_of_codebooks = zeros(num_speakers, num_clusters*2, num_mel_coeffs-1);

invalid_files = 0;

for i = 1:num_speakers
    % Generate speaker file path
    file1 = "StudentAudioRecording/Twelve-Training/Twelve_train" + i + ".wav";
    file2 = "StudentAudioRecording/Zero-Training/Zero_train" + i + ".wav";
    if ~isfile(file1)
        disp("Invalid filename!");
        invalid_files = invalid_files + 1;
        continue;
    end
    if ~isfile(file2)
        disp("Invalid filename!");
        invalid_files = invalid_files + 1;
        continue;
    end

    % Get the codebook for a particular speaker
    codebook1 = codebook_generate(file1, num_mel_coeffs, num_clusters, epsilon, ...
                                    frame_size, overlap_size, window);

    codebook2 = codebook_generate(file1, num_mel_coeffs, num_clusters, epsilon, ...
                                    frame_size, overlap_size, window);

    codebook = combine_codebooks(codebook1, codebook2);

    % Store the codebook in our list of codebooks
    list_of_codebooks(i, :, :) = codebook;

end

% Matching phase: Compare test data with the previously stored codebooks

result_matrix = zeros(num_speakers, num_speakers);

for i = 1:num_speakers

    % Generate speaker file path
    file = path_test + i + ".wav";
    if ~isfile(file)
        continue;
    end

    test_mfccs = get_mfccs(file, num_mel_coeffs, frame_size, overlap_size, ...
                            window);
    
    % Array to keep track of all distances to centroid
    % Must update with average if wanting to create variable amount of
    % centroids
    all_dists = zeros(1, num_speakers);

    % This is rather inefficient, but for the sake of time we will not
    % spend time optimizing it
    for s = 1:num_speakers
        % For every MFCC vector, find the nearest centroid belonging to
        % speaker s
        for j = 1:size(test_mfccs, 1)
            
            % Check the distance to all k centroids to find the smallest one
            min_dist = Inf;

            for k = 1:size(list_of_codebooks, 2)

                X = test_mfccs(j, :);
                Y = squeeze(list_of_codebooks(s, k, :))';
                dist = sqrt(sum((X-Y).^2));

                % If it is closer than previous, update minimum distance
                if dist < min_dist
                    min_dist = dist;
                end

            end

            % We now have the shortest distance that it takes to get from this
            % dart to the nearest centroid from speaker s - update the
            % record of the sum of all distances
            all_dists(s) = all_dists(s) + min_dist;
        end
    end

    % The index of the minimum distance is our choice for the closest
    % matching speaker.
    [M, I] = min(all_dists);
    result_matrix(i, I) = 1;

end

disp(result_matrix);

diag_count = sum(diag(result_matrix) ~= 0);
percent = diag_count / (size(result_matrix, 1) - invalid_files) * 100;

% disp("Accuracy: " + diag_percentage+"% ("+diag_count+"/" ...
%     +size(result_matrix,1),")");

fprintf("Accuracy: %f (%i/%i)\n", percent, diag_count, ...
            size(result_matrix, 1) - invalid_files);

function combined_codebook = combine_codebooks(codebook1, codebook2)
    % Concatenate the two codebooks vertically
    combined_codebook = [codebook1; codebook2];

    % Get the maximum cluster index of the first codebook
    max_index_codebook1 = max(codebook1(:, 1));

    % Adjust the cluster indices of the second codebook
    codebook2(:, 1) = codebook2(:, 1) + max_index_codebook1;

    % Concatenate the adjusted second codebook to the first codebook
    combined_codebook = [codebook1; codebook2];
end
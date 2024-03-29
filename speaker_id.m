% Parameters to adjust
num_clusters = 32;
num_mel_coeffs = 32;
frame_size = 512;
overlap_ratio = 0.8;
epsilon = 0.000001;
window = kaiser(frame_size, 0.5);

% num_clusters = 20;
% num_mel_coeffs = 20;
% frame_size = 256;
% overlap_ratio = 0.4;
% epsilon = 0.01;
% window = hamming(frame_size);

overlap_size = round(frame_size * overlap_ratio);

% Input-related data: adjust based on what the input path is
num_speakers = 37;

% For testing the Twelve data set (n=19)
path_train = "StudentAudioRecording/Twelve-Training/Twelve_train";
path_test = "StudentAudioRecording/Twelve-Testing/Twelve_test";

% For testing the Zero dataset (n=19)
% path_train = "StudentAudioRecording/Zero-Training/Zero_train";
% path_test = "StudentAudioRecording/Zero-Testing/Zero_test";

% For testing with the given test data (n=8)
% path_train = "GivenSpeech_Data/Training_Data/s";
% path_test = "GivenSpeech_Data/Test_Data/s";

% For Test 10: Aggregate of all test samples (n=37)
% path_train = "AllTests/train/";
% path_test = "AllTests/test/";

% Training phase: Get the codebooks of all speakers
list_of_codebooks = zeros(num_speakers, num_clusters, num_mel_coeffs-1);

invalid_files = 0;

for i = 1:num_speakers
    % Generate speaker file path
    file = path_train + i + ".wav";
    if ~isfile(file)
        disp("Invalid filename!");
        invalid_files = invalid_files + 1;
        continue;
    end

    % Get the codebook for a particular speaker
    codebook = codebook_generate(file, num_mel_coeffs, num_clusters, epsilon, ...
                                    frame_size, overlap_size, window);

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
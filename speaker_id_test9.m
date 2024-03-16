% Parameters to adjust
num_clusters = 32;
num_mel_coeffs = 32;
frame_size = 512;
overlap_ratio = 0.8;
overlap_size = round(frame_size * overlap_ratio);
epsilon = 0.000001;
window = kaiser(frame_size, 0.5);

% OPT with old alg
 %num_clusters = 20;
% num_mel_coeffs = 20;
% frame_size = 256;
% overlap_ratio = 0.3;
% overlap_size = round(frame_size * overlap_ratio);
% epsilon = 0.01;
% window = hamming(frame_size);


% Input-related data: adjust based on what the input path is
num_speakers = 18;
path_train = "StudentsAndNonStudentsTrain/Zero_train";
path_test = "StudentsAndNonStudentsTest/Zero_test";
% path_train = "GivenSpeech_Data/Training_Data/s";
% path_test = "GivenSpeech_Data/Test_Data/s";

% Training phase: Get the codebooks of all speakers
list_of_codebooks = zeros(num_speakers, num_clusters, num_mel_coeffs-1);
for i = 1:num_speakers
    % Generate speaker file path
    file = path_train + i + ".wav";
    if ~isfile(file)
        disp("Invalid filename!");
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

    for s = 1:num_speakers

        % For every MFCC vector, find the nearest centroid belonging to
        % speaker s
        for j = 1:size(test_mfccs, 1)
            
            % Check the distance to all k centroids to find the smallest one
            min_dist = 10^7;

            for k = 1:size(list_of_codebooks, 2)
                
                % Calculate the distance from jth MFCC to kth centroid


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
disp("Accuracy: " + percentage_diagonal(result_matrix)+"%");

% Plot VQ codewords over same dimension
% speaker1 = 1;
% speaker2 = 7;
% dim1_index = 10;
% dim2_index = 11;
% 
% s1_mfccs = get_mfccs(path_test + speaker1 + ".wav", num_mel_coeffs, ...
%                         frame_size, overlap_size, window);
% s2_mfccs = get_mfccs(path_test + speaker2 + ".wav", num_mel_coeffs, ...
%                         frame_size, overlap_size, window);
% 
% % Plot the intersection of the two dimensions
% figure;
% scatter(s1_mfccs(:, dim1_index), s1_mfccs(:, dim2_index), 'r', 'filled');
% hold on
% scatter(s2_mfccs(:, dim1_index), s2_mfccs(:, dim2_index), 'b', 'filled');

% Graph all codevectors
% for i = 1:num_clusters
%      plot(list_of_codebooks(speaker1, i, dim1_index), ...
%             list_of_codebooks(speaker1, i, dim2_index), 'xr', ...
%             'MarkerSize',20)
%       % 
%       % plot(list_of_codebooks(speaker2, i, dim1_index), ...
%       %   list_of_codebooks(speaker2, i, dim2_index), 'xb', ...
%       %   'MarkerSize',20)
% end

%centroid = s1_mfccs(1, :); %mean(mfccs, 1);
% centroid = mean(s1_mfccs, 1);
% 
% plot(centroid(dim1_index), centroid(dim2_index), 'xb', 'MarkerSize', 20);
% 
% hold off
% 
% xlabel(['mfcc-', num2str(dim1_index)]);
% ylabel(['mfcc-', num2str(dim2_index)]);

% ChatGPT-generated function to find the percentage on the diagonal
function percentage = percentage_diagonal(matrix)
    % Check if the input is a square matrix
    [rows, cols] = size(matrix);
    if rows ~= cols
        error('Input matrix must be square.');
    end
    
    % Count the number of nonzero elements on the diagonal
    diagonal_count = sum(diag(matrix) ~= 0);
    
    % Calculate the total number of elements on the diagonal
    total_diagonal_elements = min(rows, cols);
    
    % Calculate the percentage of diagonal elements that are nonzero
    percentage = (diagonal_count / total_diagonal_elements) * 100;
end
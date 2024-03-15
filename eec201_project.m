
%{

TRAINING PHASE

    1) Take in input from wav file
    2) Frame blocking: divide the wav file into frames
    3) Apply a window to the frames... leave room to programatically
        change the window type.
    4) Calculate MFCC for each frame
    5) Clustering algorithm

%}

% Generate frame_count random frame vectors and put them in the master
% frame vector. Proper input will replace this when completed - we are
% expecting a cell array all_frames{} which contains all of the frame
% vectors, with windowing applied.

% all_frames = cell(1, frame_count);
% 
% for i = 1:frame_count
%     new_frame = randn(1, frame_length);
%     all_frames{i} = new_frame;
% end

% START CHRIS CODE --------------------------------------------------------
[x, fs] = audioread('Twelve_test1.wav');

% Define parameters for frame blocking
frame_size = 256;  % Choose an appropriate frame size
overlap = 0.33;      % Choose the overlap ratio (0 to 1)

% Calculate the overlap size
overlap_size = round(frame_size * overlap);

% Perform frame blocking
num_frames = floor((length(x) - overlap_size) / (frame_size - overlap_size));
frames = zeros(frame_size, num_frames);

for i = 1:num_frames
    start_index = (i - 1) * (frame_size - overlap_size) + 1;
    end_index = start_index + frame_size - 1;
    frames(:, i) = x(start_index:end_index);
end

% Identify and remove frames that are all zeros
nonzero_frames = frames(:, any(frames, 1));

% Now 'frames' contains the blocked audio signal, and each column represents a frame
% You can do further processing on each frame if needed
% For example, apply a window function to each frame
window = hamming(frame_size);
windowed_frames = frames .* window;

% Perform FFT on windowed frames
fft_size = 2^nextpow2(frame_size);
fft_frames = abs(fft(windowed_frames, fft_size));

% END CHRIS CODE ----------------------------------------------------------

% Define parameters for filerbank
num_filters = 20; % Number of filters in the filterbank
sample_rate = 44100; % Sample rate of the audio signal

% Create the Mel-spaced filterbank
[fb, cf] = designAuditoryFilterBank(sample_rate, 'NumBands', num_filters, ...
    'FFTLength', frame_size, 'FrequencyRange', [0 sample_rate/2]);

% Create an empty matrix to store the MFCCs for each frame
mfcc_frames = zeros(size(fft_frames, 2), num_filters);

% Generate the MFCCs for each frame
for i = 1:size(fft_frames, 2)

    % Get the current frame
    current_frame = fft_frames(:, i);

    % Apply the filter bank to create a mel spectrogram
    mel_spec = fb * current_frame;

    % Calculate the MFCCs
    melcc = cepstralCoefficients(mel_spec);
    mfcc_frames(i) = melcc;

end

% Initialize matrix to store sums of filtered signals for each frame
% sums_per_frame = zeros(size(windowed_frames, 2), num_filters);
% cepstralCoefficients()
% 
% % Iterate over each frame
% for i = 1:size(windowed_frames, 2)
%     % Extract the current frame
%     frame = windowed_frames(:, i);
% 
%     % Filter the frame with each filter in the filter bank and sum the results
%     for j = 1:num_filters
%         % Extract the filter coefficients for the j-th filter
%         filter_coefficients = fb(j, :);
% 
%         % Filter the frame with the j-th filter coefficients
%         filtered_frame = filter(filter_coefficients, 1, frame);
% 
%         % Calculate the sum of the absolute values of the filtered frame
%         sums_per_frame(i, j) = sum(abs(filtered_frame));
%     end
% end

%c_n = dct(s_k);

% Visualize the filterbank (optional)
% F = (0:frame_length/2) * (sample_rate / frame_length);
% plot(F, fb.');
% title('Mel-spaced Filterbank');
% xlabel('Frequency (Hz)');
% ylabel('Magnitude');

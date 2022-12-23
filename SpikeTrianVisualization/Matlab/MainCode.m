%#########################################################################
% This code was written by Milad Qolami as a part of a tutorial on spike
% train visualization
% The data is comming from an unpublished dataset of spikes recoreded from
% inferior temporal cortex of a Macaque monkey in response to rapid
% presentation of images on a monitor (RSVP task), in october 2022
% #######################################################################
%% Clearing memory and closing open figures
clear all
close all
clc
%% Loadng data and defining initial parameters
load SpikesIT.mat               % Loading the spike train data

size(Spikes)                    % Look at dimensions of the data
plot(Spikes(109,:))

NTrials = size(Spikes, 1);      % Number of trials 
T = -199:size(Spikes,2)-200;    % Time vector relative to stimulus onset
StimPresentTime = 1;          % Time of stimulus presentation (ms)

size(TrialTags)                  % Trial tags??
TrialTags(1:10)                  % This vector contains tags that indicate
                                 % which stimulus was presented during each
                                 % trials
% Note: In total 155 images were presented, each 5 times, so 775 presentation/
% trials in total.
% The matrix FaceIdx contains tags of of the stimuli that presented in each trial.
% Tags number 1 to 29 indicate face images and the rest of them stad for non-face
% images. For example in the first trial stimulus number 84 was presented
% which is a non-face image. Face and non-face images were presented
% randomly.

%% Raster plot 
% Here we want to compare raster plots of two conditions, face vs non-face
% trials

FaceIdx = find(TrialTags>0 & TrialTags<30); % Extracting tags of face
                                            % presented trials

RandomNonFace = randperm(155-29,29) + 29;   % Randomly selecting 29 non-face
                                            % images 
NonFaceIdx = find(ismember(TrialTags,RandomNonFace));


FaceSpikes = Spikes(FaceIdx,:);         % Extracting spikes for face presented trials
NonFaceSpikes = Spikes(NonFaceIdx,:);   % Extracting spikes for non-face presented trials

figure;
subplot(2,1,1)     
rectangle('Position',[0,0,200,150],'FaceColor',[1 .9 .9], 'linestyle','none') % Visualizing stimulus presentation
hold on
for Triali = 1:length(FaceIdx) % Loop over trials
    Spikesi = find(FaceSpikes(Triali,:))-200; % Find Time points that a spike occurs
    plot([Spikesi;Spikesi],[Triali * ones(1,length(Spikesi)); (Triali+1)*ones(1,length(Spikesi))],'k') % Raster for each trial
end
set(gca,'XLim',[T(1) T(end)],'layer','top')
ylabel("Trial's number")

subplot(2,1,2)      % Rastr for non-face trials
rectangle('Position',[0,0,200,150],'FaceColor',[1 .9 .9],'linestyle','none')
hold on
for Triali = 1:length(NonFaceIdx)
    Spikesi = find(NonFaceSpikes(Triali,:))-200;
    plot([Spikesi;Spikesi],[Triali * ones(1,length(Spikesi)); (Triali+1)*ones(1,length(Spikesi))],'k')
    hold on
end
set(gca,'XLim',[T(1) T(end)],'layer','top')
xlabel('Time(ms)')
ylabel("Trial's number")
sgtitle('Raster plots for face and non-face conditions') % Adding subplot to a grid of subplots

% A simple and easy version of raster plot
figure
subplot(2,1,1)
imagesc(FaceSpikes)
set(gca,'YDir','normal')

subplot(2,1,2)
imagesc(NonFaceSpikes)
set(gca,'YDir','normal')
colormap gray
%% Plotting pre-stimulus time histogram(PSTH)

% Barplot version
bin_size = 25;      % Determine number of bins
bins = [(1:bin_size:1100)' (bin_size:bin_size:1100)'];  % Deviding time vector into discrete bins
SumSpikeFace = sum(FaceSpikes);     % Summing spike for each time point 
SpikesSumNonface = sum(NonFaceSpikes);      % Initializing a vector of number of spikes in each bin for face condition
SumSpikeFaceInBin = zeros(1,size(bins,1));       % Initializing a vector of number of spikes in each bin for face condition


for bini = 1:size(bins,1) % Looping over each time bin
    SpikesSumi = sum(SumSpikeFace(bins(bini,1):bins(bini,2))); % Calculate number of spikes in that bin
    SumSpikeFaceInBin(bini) = SpikesSumi;  
end

SumSpikenonFaceInBin = zeros(1,size(bins,1));
for bini = 1:size(bins,1)
    SpikesSumi = sum(SpikesSumNonface(bins(bini,1):bins(bini,2)));
    SumSpikenonFaceInBin(bini) = SpikesSumi;
end

t = tiledlayout(2,1)
ax1 = nexttile
rectangle('Position',[0,0,200/bin_size,500],'FaceColor',[1 .9 .9], 'linestyle','none')
hold on
bar(ax1,(1:size(bins,1)) - 200/bin_size, SumSpikenonFaceInBin)
ylim(ax1,[0 500])

ax2 = nexttile
rectangle('Position',[0,0,200/bin_size,500],'FaceColor',[1 .9 .9], 'linestyle','none')
hold on
bar(ax2,(1:size(bins,1)) - 200/bin_size,SumSpikeFaceInBin)
ylim(ax2,[0 500])

title(t,'PSTH (Barplot version)')
xlabel(t,'Time bins')
ylabel(t,'Spikes in each bin')


% PSTH (curve)
x = mean(FaceSpikes);
x_pirm =mean(NonFaceSpikes);
figure
plot(T,x,'DisplayName','Without smoothing') % the curve is rough and should be smoothed

% Creating a gaussian window
w = gausswin(25,.5);
w = w/sum(w);
y = filter(w,1,x);      % Applying guassian window to our signal
hold on
plot(T,y,'r','LineWidth',2,'DisplayName','Smoothed by gaussian window') 
plot(T,smooth(x,25),'LineWidth',2,'DisplayName','Smoothed by "smooth" function')    % Using smooth function (curve fitting toolbox)
legend

% Adding confidence interval to the curves
SEFace = std(FaceSpikes)/sqrt(size(FaceSpikes,2));
SENonface = std(NonFaceSpikes)/sqrt(size(NonFaceSpikes,2));
figure
plot(T,y,'r','LineWidth',2,'DisplayName','Smoothed by gaussian window') 
hold on
shade(T,y+SEFace,T,y-SEFace,'color','w','Fillcolor',[1,.5,.5], 'FillType',[1 2;2 1])

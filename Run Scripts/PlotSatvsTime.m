%function PlotSatvsTime(gnssRaw)

% gnssRaw.Svid
% gnssRaw.ConstellationType
% gnssRaw.CarrierFrequencyHz
% gnssRaw.Cn0DbHz

constmult = 1000;
ConstStr = ['GPS';'SBA'; 'GLO'; 'QZS'; 'BDS'; 'GAL'];
    
%  #define GNSS_CONSTELLATION_SBAS         2
% %   #define GNSS_CONSTELLATION_GLONASS      3
% %   #define GNSS_CONSTELLATION_QZSS         4
% %   #define GNSS_CONSTELLATION_BEIDOU       5
% %   #define GNSS_CONSTELLATION_GALILEO      6

% Find unique satellite signals
FreqNum = ones(size(gnssRaw.CarrierFrequencyHz));
L5idx = find(gnssRaw.CarrierFrequencyHz < 1.2e9);
FreqNum(L5idx) = 5;

ConstSVFreq = gnssRaw.Svid + constmult*gnssRaw.ConstellationType + i*FreqNum;
UniqueConstSVFreq = unique(ConstSVFreq);
nUniqueConstSVFreq = length(UniqueConstSVFreq);


%%
% Plot Cn0 of each unique constellation svid frequency combination

for n = 1:nUniqueConstSVFreq
    satsigidx = find(ConstSVFreq == UniqueConstSVFreq(n));
    svTimeNanos = gnssRaw.TimeNanos(satsigidx);
    svCn0Db = gnssRaw.Cn0DbHz(satsigidx);
    svAgcDb = gnssRaw.AgcDb(satsigidx);
        
   figure(n),
     yyaxis left
     plot(svTimeNanos./1e9,svCn0Db, 'b.-')
     ylabel('Cn0 [dB-Hz]')
     yyaxis right
     plot(svTimeNanos./1e9,svAgcDb, 'ro')     
     ylabel('AGC [dB]')
     xlabel('time of day (sec)')
     const = floor(UniqueConstSVFreq(n)/constmult);
     svid = real(UniqueConstSVFreq(n))- const*constmult;

     title([ConstStr(const,:) ' PRN ' num2str(svid) ' L' num2str(imag(UniqueConstSVFreq(n))) ' ' datestrtest]);
     
     %Set file names and save figure as both MATLAB figure and PNG in repos
     fileNameMATLAB = "Figure %d CN0 %s PRN%d L%d %d-%d-%d (%d-%d-%d).fig";
     fileNameImage = "Figure %d CN0 %s PRN%d L%d %d-%d-%d (%d-%d-%d).png";
     saveas(gcf,sprintf(fileNameMATLAB, n, ConstStr(const,:), svid, imag(UniqueConstSVFreq(n)), datayear, datamonth, dataday, datahour, datamin, datasec))
     saveas(gcf,sprintf(fileNameImage, n, ConstStr(const,:), svid, imag(UniqueConstSVFreq(n)), datayear, datamonth, dataday, datahour, datamin, datasec))
     
%      close(gcf)
%      pause
end
pause


%%
%Create & Organize Data into CSV File

csvFileName = [num2str(datayear) '-' num2str(datamonth) '-' num2str(dataday) ' ' num2str(datahour) '-' num2str(datamin) '-' num2str(datasec) '.csv'];
fileID = fopen(csvFileName, 'w');
fprintf(fileID, '%s,%s,%s,%s,%s,%s,%s\n', 'SVID', 'Constellation', 'Frequency', 'Min C/No', 'Max C/No', 'Ave C/No', 'NaN');

minTimeNanos = min(gnssRaw.TimeNanos);
maxTimeNanos = max(gnssRaw.TimeNanos);
maxLength = double((maxTimeNanos./1e9 - minTimeNanos./1e9) + 1);

for n = 1:nUniqueConstSVFreq
    satsigidx = find(ConstSVFreq == UniqueConstSVFreq(n));
    svTimeNanos = gnssRaw.TimeNanos(satsigidx);
    svCn0Db = gnssRaw.Cn0DbHz(satsigidx);
    svAgcDb = gnssRaw.AgcDb(satsigidx);
    const = floor(UniqueConstSVFreq(n)/constmult);
    svid = real(UniqueConstSVFreq(n))- const*constmult;
    freq = imag(UniqueConstSVFreq(n));
    nanRatio = 1- double(length(satsigidx)/maxLength);
    
    fprintf(fileID, '%d,%d,%d,%f,%f,%f,%f\n', svid, const, freq, min(svCn0Db,[],'omitnan'), max(svCn0Db,[],'omitnan'), mean(svCn0Db,'omitnan'), nanRatio);
end

fclose(fileID);



%%
% Plot CN0 for each satellite's all frequencies on the same window

% UniqueSV = unique(gnssRaw.Svid);
% nUniqueSV = length(UniqueSV);
% 
% for i=1:nUniqueSV
%     svIdx = find(real(UniqueConstSVFreq)-constmult == UniqueSV(i)); %GPS ONLY
%     nCurrentFreq = length(svIdx);
%     
%     figure(i),
%         yyaxis left
%         %for j=1:nCurrentFreq
%         freqIdx = find(ConstSVFreq == UniqueConstSVFreq(svIdx(1)));
%         freqTime = gnssRaw.TimeNanos(freqIdx);
%         freqCN0 = gnssRaw.Cn0DbHz(freqIdx);
%         plot(freqTime./1e9, freqCN0, 'b.-')
%         ylabel(['L' num2str(imag(UniqueConstSVFreq(svIdx(1))))])
%         %end
%         if(nCurrentFreq > 1)
%             yyaxis right
%             freqIdx = find(ConstSVFreq == UniqueConstSVFreq(svIdx(2)));
%             freqTime = gnssRaw.TimeNanos(freqIdx);
%             freqCN0 = gnssRaw.Cn0DbHz(freqIdx);
%             plot(freqTime./1e9, freqCN0, 'r.-')
%             ylabel(['L' num2str(imag(UniqueConstSVFreq(svIdx(2))))])
%         end
%     title(['GPS PRN ' num2str(UniqueSV(i)) ' ' datestrtest]);
%     %pause
% end




%%
%Plot CN0 for all unique ConstSvidx on L1 and L5 on 2 sets of windows (disables pvt functionality)

ConstSvidx = gnssRaw.ConstellationType + 1i*gnssRaw.Svid;
% uniqueConstSvidx = unique(ConstSvid);

L1idx = find(FreqNum == 1);
uniqueL1ConstSvidx = unique(ConstSvidx(L1idx));
nuniqueL1ConstSvidx = length(uniqueL1ConstSvidx);

nFiguresL1 = nuniqueL1ConstSvidx / 7;
% nConstSvidInFigure = 7;

if(nFiguresL1<1)
    nFiguresL1 = 1;
%     addFigureFlag = false;
%     nConstSvidInFigure = nuniqueL1ConstSvidx;
elseif(floor(nFiguresL1) == nFiguresL1)
%     addFigureFlag = false;
else
%     addFigureFlag = true;
    nFiguresL1 = floor(nFiguresL1) + 1;
end

for m=1:nFiguresL1
    figure('Name','L1 Cn0'),
        for j=(m-1)*7+1:min(m*7, nuniqueL1ConstSvidx)
            currentConstSvidx = find(ConstSvidx(L1idx) == uniqueL1ConstSvidx(j));
            currentL1svTimeNanos = gnssRaw.TimeNanos(L1idx(currentConstSvidx));
            currentL1svCn0DbHz = gnssRaw.Cn0DbHz(L1idx(currentConstSvidx));
            plot(currentL1svTimeNanos./1e9, currentL1svCn0DbHz, '.-', 'DisplayName', [ConstStr(real(uniqueL1ConstSvidx(j)),:) ' PRN ' num2str(imag(uniqueL1ConstSvidx(j)))]);
            hold on
            %pause
        end
        hold off
        ylabel('Cn0 (dB-Hz)');
        xlabel('Time of Day (sec)');
        legend
        title(['L1 Figure ' num2str(m) ' ' datestrtest]);
        fileName = "L1 Figure %d %d-%d-%d (%d-%d-%d).png";
        saveas(gcf, sprintf(fileName, m, datayear, datamonth, dataday, datahour, datamin, datasec));
        fileName = "L1 Figure %d %d-%d-%d (%d-%d-%d).fig";
        saveas(gcf, sprintf(fileName, m, datayear, datamonth, dataday, datahour, datamin, datasec));
end

pause
%HERE BEGINS L5 SET PLOTS

L5idx = find(FreqNum == 5);
uniqueL5ConstSvidx = unique(ConstSvidx(L5idx));
nuniqueL5ConstSvidx = length(uniqueL5ConstSvidx);

nFiguresL5 = nuniqueL5ConstSvidx / 7;
% nConstSvidInFigure = 7;

if(nFiguresL5<1)
    nFiguresL5 = 1;
%     addFigureFlag = false;
%     nConstSvidInFigure = nuniqueL5ConstSvidx;
elseif(floor(nFiguresL5) == nFiguresL5)
%     addFigureFlag = false;
else
%     addFigureFlag = true;
    nFiguresL5 = floor(nFiguresL5) + 1;
end

for m = 1:nFiguresL5
    figure('Name','L5 Cn0'),
        for j=(m-1)*7+1:min(m*7, nuniqueL5ConstSvidx)
            currentConstSvidx = find(ConstSvidx(L5idx) == uniqueL5ConstSvidx(j));
            currentL5svTimeNanos = gnssRaw.TimeNanos(L5idx(currentConstSvidx));
            currentL5svCn0DbHz = gnssRaw.Cn0DbHz(L5idx(currentConstSvidx));
            plot(currentL5svTimeNanos./1e9, currentL5svCn0DbHz, '.-', 'DisplayName', [ConstStr(real(uniqueL5ConstSvidx(j)),:) ' PRN ' num2str(imag(uniqueL5ConstSvidx(j)))]);
            hold on
        end
        hold off
        ylabel('Cn0 (dB-Hz)');
        xlabel('Time of Day (sec)');
        legend
        title(['L5 Figure ' num2str(m) ' ' datestrtest]);
        fileName = "L5 Figure %d %d-%d-%d (%d-%d-%d).png";
        saveas(gcf, sprintf(fileName, m, datayear, datamonth, dataday, datahour, datamin, datasec));
        fileName = "L5 Figure %d %d-%d-%d (%d-%d-%d).fig";
        saveas(gcf, sprintf(fileName, m, datayear, datamonth, dataday, datahour, datamin, datasec));
end



%%
%Plot CN0 average of all frequencies for each satellite

%%
%Plot AGC for each freq

% uniqueFreq = unique(gnssRaw.CarrierFrequencyHz);
% nuniqueFreq = length(uniqueFreq);
% 
% for m = 1: nuniqueFreq
%     uniqueFreqidx = find(uniqueFreq(m)== gnssRaw.CarrierFrequencyHz);    
%     uniqueConstFreq = unique(gnssRaw.ConstellationType(uniqueFreqidx));
%     nconstfreq = length(uniqueConstFreq);
%     
%     for n = 1:nconstfreq
%         
%         uniqueFreqConstidx = find(gnssRaw.ConstellationType(uniqueFreqidx) == uniqueConstFreq(n));        
%         freqTimeNanos = gnssRaw.TimeNanos(uniqueFreqidx(uniqueFreqConstidx));
%         %     freqCn0Db = gnssRaw.Cn0DbHz(uniqueFreqidx);
%         freqAgcDb = gnssRaw.AgcDb(uniqueFreqidx(uniqueFreqConstidx));
%         
%         figure(m*100+n),
%         plot(freqTimeNanos./1e9,freqAgcDb, 'ro')
%         ylabel('AGC [dB]')
%         xlabel('time of day (sec)')
%         title([ConstStr(uniqueConstFreq(n),:) ' Freq ' num2str(round(uniqueFreq(m)/1e6)) ' MHz ' datestrtest]);
%         
%         fileNameMATLAB = "Figure %d AGC %s %dMHz %d-%d-%d (%d-%d-%d).fig";
%         fileNameImage = "Figure %d AGC %s %dMHz %d-%d-%d (%d-%d-%d).png";
%         saveas(gcf,sprintf(fileNameMATLAB, m*100+n, ConstStr(const,:), round(uniqueFreq(m)/1e6), datayear, datamonth, dataday, datahour, datamin, datasec))
%         saveas(gcf,sprintf(fileNameImage, m*100+n, ConstStr(const,:), round(uniqueFreq(m)/1e6), datayear, datamonth, dataday, datahour, datamin, datasec))
%     end
%     
% end
%
%
%
%
% %%
% 
% uniqueTimeNanos = unique(gnssRaw.TimeNanos);
% nuniqueTimeNanos = length(uniqueTimeNanos);
% 
% %initialize
% nfreq = zeros(nuniqueTimeNanos,2);
% nconst = zeros(nuniqueTimeNanos,6);
% nconstL1 = zeros(nuniqueTimeNanos,6);
% nconstL5 = zeros(nuniqueTimeNanos,6);
% nsigs = zeros(nuniqueTimeNanos,1)
% % nL1 = zeros(1, nuniqueTimeNanos); nL5 = nL1;
% % nGPSL1 = nL1; nGPSL5 = nL1;
% % nGALL1 = nL1; nGALL5 = nL1;
% % nGOLL1 = nL1; nBDSL1 = nL1;
% % nQZSL1 = nL1; nSBSL5 = nL1;
% 
% for m = 1: nuniqueTimeNanos
%     uniqueTimeidx = find(uniqueTimeNanos(m) == gnssRaw.TimeNanos);
%     FreqNumTime = FreqNum(uniqueTimeidx); %unique(gnssRaw.CarrierFrequencyHz(uniqueTimeidx));  
%     uniqueFreqNum = unique(FreqNumTime);
%     nuniqueFreqNum = length(uniqueFreqNum);
%     
%     [GC,GR] = groupcounts(FreqNum(uniqueTimeidx));
%     nsigs(m) = length(uniqueTimeidx);
%     nfreq(m,ceil(GR./4)) = GC;  % divide by 4 results in the correct index GC =1 => 1 and GC = 5 => 2 
%             
% %     pause
%     [GC,GR] = groupcounts(gnssRaw.ConstellationType(uniqueTimeidx));           
%     nconst(m, GR) = GC;
%     
%     for n = 1:nuniqueFreqNum
%        idx2 = find(FreqNumTime == uniqueFreqNum(n));
%        [GC,GR] = groupcounts(gnssRaw.ConstellationType(uniqueTimeidx(idx2)));
% 
%        if uniqueFreqNum(n) == 1 % L1
%            nconstL1(m, GR) = GC;
%        else % L5
%            nconstL5(m, GR) = GC;
%        end
%     end
% end
% 
% figure(1000), plot(uniqueTimeNanos./1e9, nsigs, '.-'), ylabel('Number Sigs'); xlabel('time of day (sec)'),
% title(['Num Signals ' datestrtest]);
%     
% figure(1001), plot(uniqueTimeNanos./1e9, nfreq, '.-'), ylabel('Number Sigs'); xlabel('time of day (sec)'), legend('L1', 'L5')
% title(['Num Signals at Freq ' datestrtest]);
% 
% figure(1002), plot(uniqueTimeNanos./1e9, nconst, '.-'), ylabel('Number Sigs'); xlabel('time of day (sec)'), legend(ConstStr)
% title(['Num Signals of Const ' datestrtest]);
% 
% figure(1003), plot(uniqueTimeNanos./1e9, nconstL1, '.-'), ylabel('Number Sigs L1'); xlabel('time of day (sec)'), legend(ConstStr)
% title(['Num Signals of Const ' datestrtest]);
% 
% if sum(nfreq(2,:)) > 0
% figure(1004), plot(uniqueTimeNanos./1e9, nconstL5, '.-'), ylabel('Number Sigs L5'); xlabel('time of day (sec)'), legend(ConstStr)
% title(['Num Signals of Const ' datestrtest]);
% end
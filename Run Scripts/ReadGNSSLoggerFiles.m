clear all, close all

dirName = 'C:\Users\yuan_\Desktop\8.4'

fileName = ['(Dry) gnss_log_2020_08_04_16_51_03.txt'];

under_idx   = strfind(fileName, '_');
datayear    = str2num(fileName(under_idx(2)+1:under_idx(3)-1));
datamonth   = str2num(fileName(under_idx(3)+1:under_idx(4)-1));
dataday     = str2num(fileName(under_idx(4)+1:under_idx(5)-1));
datahour    = str2num(fileName(under_idx(5)+1:under_idx(6)-1));
datamin     = str2num(fileName(under_idx(6)+1:under_idx(7)-1));
datasec     = str2num(fileName(under_idx(7)+1:under_idx(7)+2));
datefile    = fileName(under_idx(2)+1:under_idx(7)+2)
datefileplot = [fileName(under_idx(2)+1:under_idx(3)-1) '/' fileName(under_idx(3)+1:under_idx(4)-1) '/' fileName(under_idx(4)+1:under_idx(5)-1) ' ' fileName(under_idx(5)+1:under_idx(6)-1) ":" fileName(under_idx(6)+1:under_idx(7)-1)];
datestrtest = datestr([datayear datamonth dataday datahour datamin datasec], 'yyyy-mm-dd HH:MM:SS')

% addpathname = 'C:\Users\Sherman\Dropbox\MATLAB\gpstools\opensource';
addpathname = 'C:\Users\yuan_\Documents\GitHub\gps-measurement-tools\opensource';
path(path,addpathname);

% addpathname = 'C:\Users\Sherman\Dropbox\MATLAB\gpstools\opensource';
% path(path,addpathname);
dataFilter = SetDataFilter
[gnssRaw,gnssAnalysis] = ReadGnssLogger(dirName,fileName,dataFilter);

% [gnssRaw,gnssAnalysis]=ReadGnssLogger(dirName,fileName,dataFilter);
%% Get online ephemeris from Nasa ftp, first compute UTC Time from gnssRaw:
fctSeconds = 1e-3*double(gnssRaw.allRxMillis(end));
utcTime = Gps2Utc([],fctSeconds);
allGpsEph = GetNasaHourlyEphemeris(utcTime,dirName);
if isempty(allGpsEph), return, end

%%
PlotSatvsTime; %(gnssRaw)

pause
%% process raw measurements, compute pseudoranges:
[gnssMeas] = ProcessGnssMeas(gnssRaw);


% pause

% pvt currently only works for GPS only
% gpsPvt = GpsWlsPvt(gnssMeas,allGpsEph)
% 
% %%
% pause
% datedash = strfind(datefile,'_')
% 
% gpslat = gpsPvt.allLlaDegDegM(:,1);
% gpslon = gpsPvt.allLlaDegDegM(:,2);
% gpsht  = gpsPvt.allLlaDegDegM(:,3);
% gpstime = gpsPvt.FctSeconds;
% 
% savestr = ['save gpsproc' datefile ' gpslat gpslon gpsht gpstime'];
% eval(savestr);
% 
% 
% %% Plot google earth
% 
% path(path, 'C:\Users\yuan_\Documents\plot_google_map')
% % path(path, 'C:\Users\daeda\Documents\GitHub\gps-measurement-tools\Run Scripts\plot_google_map')
% path(path,dirName);
% 
% % path(path, 'C:\Users\Sherman\Dropbox\MATLAB\SharkTag\CoarseTimePosition\utilities\plot_google_map')
% figure(100),
% plot(gpslon, gpslat,'x')
% %plot_google_map_with_key
% % plot_google_map('MapType', 'hybrid')
% 
% %save figure 100 in repository
% % saveas(gcf,"Figure 100.fig")
% % saveas(gcf,"Figure 100.png")
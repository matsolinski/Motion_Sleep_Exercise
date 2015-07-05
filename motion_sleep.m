%-----------------------------
%--- MOTION & SLEEP - EXERCISE
%-----------------------------
%--- MATEUSZ SOLINSKI --------
%-----------------------------

%-----------------------------
%  LOAD DATA

%---- phone.csv

fid = fopen('phone.csv');
out = textscan(fid,'%s%f%f%f','delimiter',',');
fclose(fid);

timestamp = out{1};
Xacc = out{2};
Yacc = out{3};
Zacc = out{4};

%---- sleep_phases.csv

fid = fopen('sleep_phases.csv');
out = textscan(fid,'%s%f','delimiter',',');
fclose(fid);

timestampSP = out{1};
sleepP = out{2};


%----- print
figure(1)
plot(sleepP)
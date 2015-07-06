%-----------------------------
%--- MOTION & SLEEP - EXERCISE
%-----------------------------
%--- MATEUSZ SOLINSKI --------
%-----------------------------

%-----------------------------
%  LOAD DATA


  
%---- sleep_phases.csv

  fid = fopen('sleep_phases2.csv');
      outSP = textscan(fid,'%s%f','delimiter',',');
  fclose(fid);

  timestampSP = outSP{1};
  
%---- phone.csv  
  fid = fopen('phone.csv');
     outMot = textscan(fid,'%s%f%f%f','delimiter',',');
  fclose(fid);
  timestamp = outMot{1};
  
formatIn = '%Y-%m-%d %H:%M:%S';
  
  sleepP = outSP{2};

  Xacc = outMot{2};
  Yacc = outMot{3};
  Zacc = outMot{4};
  
%----- create motion vector

  absInstMot = sqrt(Xacc(1:end).^2 + Yacc(1:end).^2 + Zacc(1:end).^2 );
  motionVect =  abs(diff(absInstMot));
  
  
%----- align
%- get indexes for which the signals are covered
[inxMotionSTART,inxSPSTART] = alignSignals(timestamp,timestampSP,'begin')
[inxMotionEND,inxSPEND] = alignSignals(timestamp,timestampSP,'end')

% get time in sec for sleep phase signal
timestampSP=timestampSP(inxSPSTART:inxSPEND);
SECtimestampSP=zeros(length(timestampSP),1);
  for o=1:length(timestampSP)
    [tm_structSP]=strptime(timestampSP{o}, formatIn);
    SECtimestampSP(o,1)=mktime(tm_structSP);
  end

% get time in sec for  signal  from accelerometer
timestampMot=timestamp(inxMotionSTART:inxMotionEND);
SECtimestampMot=zeros(length(timestampMot),1);
  for o=1:length(SECtimestampMot)
    [tm_structMot]=strptime(timestampMot{o}, formatIn);
    SECtimestampMot(o,1)=mktime(tm_structMot);
  end
  
% create array with aligned signals (sampled according to  timestamp from accelometer signal)
  alignedSig=zeros(length(SECtimestampMot),3); 
  alignedSig(:,1)=SECtimestampMot; %time in seconds
  alignedSig(:,2)=motionVect(inxMotionSTART:inxMotionEND); %aligned motionVector
  
  o=1;
  %get aligned sleep phase vector
  for i=1:length(SECtimestampMot)
    alignedSig(i,3)=sleepP(inxSPSTART+o-1); 
    if(alignedSig(i,1) >= SECtimestampSP(o+1))
      o++;
    end
    if(o==length(SECtimestampSP)) break; end
  end
  

%----- print


show=1;
if(show)
%  figure(1)
%    subplot(4,1,1)
%      plot(Xacc);
%      title('Accelerometer X-axis');
%    subplot(4,1,2)
%      plot(Yacc)
%      title('Accelerometer Y-axis');
%    subplot(4,1,3)
%      plot(Zacc)
%      title('Accelerometer Z-axis');
%    subplot(4,1,4)
%      plot(sleepP)
%      title('Sleep Phases'); 
     
    
   figure(3)
   subplot(2,1,1)
     plot(alignedSig(:,2))
   subplot(2,1,2)
     plot(alignedSig(:,3))  
end
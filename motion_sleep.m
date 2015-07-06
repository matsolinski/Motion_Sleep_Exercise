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
    
  sleepP = outSP{2};

  Xacc = outMot{2};
  Yacc = outMot{3};
  Zacc = outMot{4};
  
%----- create motion vector

  absInstMot = sqrt(Xacc(1:end).^2 + Yacc(1:end).^2 + Zacc(1:end).^2 );
  motionVect =  abs(diff(absInstMot));
  
  
%----- align
  formatIn = '%Y-%m-%d %H:%M:%S';
  %- get indexes for which the signals are covered
  [inxMotionSTART,inxSPSTART] = alignSignals(timestamp,timestampSP,formatIn,'begin')
  [inxMotionEND,inxSPEND] = alignSignals(timestamp,timestampSP,formatIn,'end')

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
  alignedSig=zeros(length(SECtimestampMot),5); 
  alignedSig(:,1)=SECtimestampMot; %time in seconds
  alignedSig(:,2)=motionVect(inxMotionSTART:inxMotionEND); %aligned motionVector
  
  o=1;
  %get aligned sleep phase vector
  for i=1:length(SECtimestampMot)
    alignedSig(i,4)=sleepP(inxSPSTART+o-1); 
    if(alignedSig(i,1) >= SECtimestampSP(o+1))
      o++;
    end
    if(o==length(SECtimestampSP)) break; end
  end
  
%----- create phase change vector

    alignedSig(:,5)=[0 ; diff(alignedSig(:,4))]!=0;

%----- maximum value of noise

     window=200;
     offset=50;
     motionVectSTD=zeros(floor(length(alignedSig(:,2))/offset)-window,1);
  %find subset of motion vector with the smallest STD
  len=length(motionVectSTD)
  for  j=1:len

      motionVectSTD(j,1)=std(alignedSig(1 + offset*(j-1) : 1+window + offset*(j-1) ,2));
  end 
  [~,minSTD] = min( motionVectSTD ) %index of the subset of motion vector with the smallest STD
  
  %compute maximum value of noise
  noise=alignedSig(1 + offset*(minSTD-1) : 1+window + offset*(minSTD-1) ,2);

  [thresh,~]=max(noise)
  
%----- motion vector denoising

  alignedSig(:,3)=alignedSig(:,2)>thresh;
  
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
     
%   n=1:length( alignedSig );
   figure(3)
   subplot(4,1,1)
     plot(alignedSig(:,2)); hold on;
     noiseSTART=1 + offset*(minSTD-1)
     noiseEND=1 + offset*(minSTD-1)+window
     plot([noiseSTART noiseSTART],[0 0.1],'-r', 'markersize',15); hold on; 
     plot([noiseEND noiseEND],[0 0.1],'-r','markersize',15); hold off; 
     title('motion vector')
   subplot(4,1,2)
    plot(alignedSig(:,3)); 
    axis([-inf inf 0 1.2]);
    title('motion vector 0-1')
   subplot(4,1,3)
     plot(alignedSig(:,4));
     axis([-inf inf 0 6]);
     title('sleep phases')
   subplot(4,1,4)
     plot(alignedSig(:,5));
     axis([-inf inf 0 1.2]);
     title('sleep phase changes')    
end
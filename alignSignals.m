function [inxSig1, inxSig2] = alignSignals(timestampSig1,timestampSig2,option)

    warning off;
    formatIn = '%Y-%m-%d %H:%M:%S';

    if(strcmp(option,'end')) %invert signal
      timestampSig1=timestampSig1(end:-1:1);
      timestampSig2=timestampSig2(end:-1:1);
    end  

      [tm_struct1]=strptime(timestampSig1{1}, formatIn); %get struct of date for the first (last) sample od signals
      [tm_struct2]=strptime(timestampSig2{1}, formatIn);
   
   firstSig={};
   %---------- comparison - which signal started/ended first?
   % assumption: signals were measured in the same year, month and day
    sig1BegInSec=tm_struct1.hour*3600+tm_struct1.min*60+tm_struct1.sec;
    sig2BegInSec=tm_struct2.hour*3600+tm_struct2.min*60+tm_struct2.sec;
    
    if( (strcmp(option,'begin') & sig1BegInSec < sig2BegInSec) | ...
        (strcmp(option,'end') & sig1BegInSec > sig2BegInSec))     
      firstSig=timestampSig1; %this signal started earlier or ended later
      secondSig=timestampSig2; %this signal started later or ended earlier
      secondBegSig=sig2BegInSec; %save seconds for signal which started later or ended earlier
    else
      firstSig=timestampSig2;
      secondSig=timestampSig1;
      secondBegSig=sig1BegInSec;
    end
    
    %find first sample in the signal started earlier (or ended later) which is >= 
    %( or <= ) than the first sample from the signal which started later (or ended earlier)
    for o=1:length(firstSig); 
      
      [tm_structFirst]=strptime(firstSig{o}, formatIn);
      firstBegSig=tm_structFirst.hour*3600+tm_structFirst.min*60+tm_structFirst.sec;
      if( (strcmp(option,'begin') & firstBegSig >= secondBegSig) | ...
          (strcmp(option,'end') & firstBegSig <= secondBegSig)) 
          firstInx=o; 
          secToFindInSecond=firstBegSig;
          break;
      end
    
    end
    
    %find the same time as secToFindInSecond in the signal started later or ended earlier
    for o=1:length(secondSig);
    
       [tm_structSecond]=strptime(secondSig{o}, formatIn);
       secondBegSig=tm_structSecond.hour*3600+tm_structSecond.min*60+tm_structSecond.sec;
       if( secondBegSig-secToFindInSecond >= 0 ) 
          secondInx=o; 
          break; 
       end
    end
    
    %get indexes for align signals
    if(strcmp(option,'begin') )
      if( sig1BegInSec < sig2BegInSec )
        inxSig1=firstInx-1;
%        inxSig2=secondInx; 
        inxSig2=1;
      else
%        inxSig1=secondInx;
        inxSig1=1;
        inxSig2=firstInx-1;
      end
    end
    
    if(strcmp(option,'end') )
      if( sig1BegInSec > sig2BegInSec )
        inxSig1= length(firstSig) + 1 - firstInx;
%        inxSig2= length(secondSig) + 1 - secondInx;
        inxSig2= length(secondSig);
      else
        inxSig1= length(secondSig) + 1 - secondInx;
        inxSig1= length(secondSig) ;
        inxSig2= length(firstSig) + 1 - firstInx;
      end
    end
    
    
   
end
function ep=getEpochsVR_OG(nantype)

names={'TMbase','TMtied','SplitPos','SplitNeg','OGbase','Adaptation','OGpostEarly'};

ep=defineEpochs(names,...
                {'TM base','TM tied 1','Pos Short','Neg Short',...
                'OG Base','Adaptation','OG post'},...
                [-40 -40 20 20 -40  -40 20],...
                [0,0, 1,1,0,0,1],...
                [5,5,0,0,5,5,0],...
                nantype);
            
            
% summ='nanmedian'; 
% earlyStrides=5;
% lateStrides=-40; 
% vEarlyStrides=1;
% names={'Slow','vShort','Short',...
%     'vEarly B','early B','Base',...
%     'vEarly A','early A15','early A','late A',...
%     'vEarly P','early P15','early P','late P'};
% names={'TMSlow','vShort','Short',...
%     'vEarly B','early B','Base',...
%     'vEarly A','early A15','early A','late A',...
%     'vEarly P','early P15','early P','late P'};
% 
% names=names(1:end); %Excluding Slow
% conds=cell(size(names));
% exemptF=nan(size(names));
% exemptL=nan(size(names));
% strides=nan(size(names));
% shortNames=cell(size(names));
% for i=1:length(names)
%     switch names{i}
%         case 'vShort'
%             eF=0;
%             eL=0;
%             s=vEarlyStrides;
%             c='Short Exposure';
%             sN='veS';
%         case 'Short'
%             eF=1;
%             eL=1;
%             s=8;
%             c='Short Exposure';
%             sN='S';
%         case 'vEarly B'
%             eF=0;
%             eL=0;
%             s=vEarlyStrides;
%             c='TM Base';
%             sN='veB';
%         case 'early B'
%             eF=1;
%             eL=1;
%             s=earlyStrides;
%             c='TM Base';
%             sN='eB';
%         case 'Base'
%             eF=1;
%             eL=1;
%             s=lateStrides;
%             c='TM Base';
%             sN='B';
%         case 'vEarly A'
%             eF=0;
%             eL=0;
%             s=vEarlyStrides;
%             c='gradual adaptation';%c='Adaptation';
%             sN='veA';
%         case 'early A'
%             eF=1;
%             eL=1;
%             s=earlyStrides;
%             c='gradual adaptation';%c='Adaptation';
%             sN='eA';
%         case 'early A15'
%             eF=1;
%             eL=1;
%             s=15;
%             c='gradual adaptation';%c='Adaptation';
%             sN='e15A';
%         case 'late A'
%             eF=1;
%             eL=1;
%             s=lateStrides;
%             c='gradual adaptation';%c='Adaptation';
%             sN='lA';
%         case 'vEarly P'
%             eF=0;
%             eL=0;
%             s=vEarlyStrides;
%             c='TM post';%c='Washout';
%             sN='veP';
%         case 'early P'
%             eF=1;
%             eL=1;
%             s=earlyStrides;
%             c='TM post';%c='Washout';
%             sN='eP';
%         case 'early P15'
%             eF=1;
%             eL=1;
%             s=15;
%             c='TM post';%c='Washout';
%             sN='e15P';
%         case 'late P'
%             eF=1;
%             eL=1;
%             s=lateStrides;
%             c='TM post';%c='Washout';
%             sN='lP';
%         case 'Slow'
%             eF=1;
%             eL=1;
%             s=-30;
%             c='TM slow';
%             sN='Sl';
%     end
%     conds{i}=c;
%     exemptF(i)=eF;
%     exemptL(i)=eL;
%     strides(i)=s;
%     shortNames{i}=sN;
% end
% ep=defineEpochs(names,conds,strides,exemptF,exemptL,summ,shortNames);
% end
% 

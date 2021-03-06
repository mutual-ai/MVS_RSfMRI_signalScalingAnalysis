function [H,ax] = DispOverview_ParamEstMVSscalingTest(MVSscalingTest)
% This function displays the core results from performing the parameter estimates and signrank
% statistics contained in the structure "MVSscalingTest".
%
% NB: since V1.1 this will create two kinds of outputs for the two kinds of data creation, see comment for V1.1 below.
%
%Figures:
%   1.Boxplots:
%     A. parameter estimates, each time (i.e. labels are:) for median subject, aggregate data and median searchlight.
%        subplots(2,2,1); Median   ||   subplots(2,2,2); CIwidth
%        subplots(2,2,3); 1stQrt   ||   subplots(2,2,2); 3rdQrt
%     B. signed-rank test, each time (i.e. labels are:) for median subject, aggregate data and median searchlight.
%        subplots(3,1,1);  zVals   ||   subplots(3,1,2);  pVals   ||   subplots(3,1,3); signedrank
%   2.scatter & stem plots: 
%     A. abs(zVals)-over-Median  with marker size as sqrt(2)./CIwidth and color by d=log2(CutOff./abs(zVals))
%     B. pVals-over-Median  with marker size as sqrt(2)./CIwidth and color by d=log2(CutOff./abs(zVals))
%     C. stem3: d=log2(CutOff./abs(zVals)): d(Agg)-over-(d(MedS) VS d(MedSL))
%     D. stem3: d=log2(CutOff./abs(zVals))-over-(Median VS CIwidth) use CutOff = 1.96 (or user input)
%        one figure for  MedS  ||   Agg  ||   MedSL   each
%     Questions: 
%               1.subtract hypothesized median from parameter estimate, i.e. center data?
%               2.use CutOff of 1.96 (97.5%-point, i.e.+-2.5%-->5%==0.05) or input, i.e. set zero point for d=log2(CutOff./abs(zVals))?
%
%
%
%Usage:
%      [H,ax] = DispOverview_ParamEstMVSscalingTest(MVSscalingTest);
%
%
%V1.1
%Date: V1.1(04.09.2015): allow plot with two possible data approaches (voxel-wise & SLavg over amplitudes for scaling data calculation). V1.0(26.07.2015) (initial implementation based on test script for analysis of scaling data.)
%Author: Rainer.Boegle (Rainer.Boegle@googlemail.com)

%% init IC message string
if(isfield(MVSscalingTest,'ICnum'))
    if(isnumeric(MVSscalingTest.ICnum))
        ICinfoStr = ['IC ',num2str(MVSscalingTest.ICnum),': '];
    else
        ICinfoStr =  'IC <unknown>: ';
    end
else
    warning('MATLAB:struct:missing','Field "ICnum" missing in structure "MVSscalingTest"');
    ICinfoStr = 'IC <???>: ';
end

%% do for all possible approaches
ApproachesInfo = MVSscalingTest.ApproachesInfo;
for IndApproach = 1:size(ApproachesInfo,1)
    %% 1.Boxplots
    %% A.Parameter estimates
    MedianQrtCIwidth = MVSscalingTest.ParamEstLambdaTest.MedianQrtCIwidth{IndApproach};
    H{IndApproach,1} = figure;
        ax{IndApproach,1,1}= subplot(2,2,1); boxplot(squeeze(MedianQrtCIwidth(:,1,:)),'labels',{'MedS';'Agg';'MedSL'}); title([ICinfoStr,'Medians (Data is from ',ApproachesInfo{IndApproach,1},')']);
        ax{IndApproach,2,1}= subplot(2,2,2); boxplot(squeeze(MedianQrtCIwidth(:,4,:)),'labels',{'MedS';'Agg';'MedSL'}); title([ICinfoStr,'CIwidths (Data is from ',ApproachesInfo{IndApproach,1},')']);
        ax{IndApproach,3,1}= subplot(2,2,3); boxplot(squeeze(MedianQrtCIwidth(:,2,:)),'labels',{'MedS';'Agg';'MedSL'}); title([ICinfoStr,'1stQrt (Data is from ',ApproachesInfo{IndApproach,1},')']);
        ax{IndApproach,4,1}= subplot(2,2,4); boxplot(squeeze(MedianQrtCIwidth(:,3,:)),'labels',{'MedS';'Agg';'MedSL'}); title([ICinfoStr,'3rdQrt (Data is from ',ApproachesInfo{IndApproach,1},')']);
        linkaxes([ax{IndApproach,1,1},ax{IndApproach,2,1},ax{IndApproach,3,1},ax{IndApproach,4,1}],'x'); %closer inspection of a boxplot should make the others follow it, but not in Y-direction.
    
    %% B. signed-rank test
    zVals = MVSscalingTest.ParamEstLambdaTest.SignRankTest.zVals{IndApproach}; %(NVoxel,3);   %z-score values from signed rank test for median subject, aggregate data and median searchlight
    pVals = MVSscalingTest.ParamEstLambdaTest.SignRankTest.pVals{IndApproach}; %(NVoxel,3);   %   p    values from signed rank test for median subject, aggregate data and median searchlight
    signedrank =  MVSscalingTest.ParamEstLambdaTest.SignRankTest.signedrank{IndApproach}; %(NVoxel,3);
    
    H{IndApproach,2} = figure;
        ax{IndApproach,1,2}= subplot(3,1,1); boxplot(abs(zVals),'labels',{'MedS';'Agg';'MedSL'}); title([ICinfoStr,'abs(zVals) (Data is from ',ApproachesInfo{IndApproach,1},')']);
        ax{IndApproach,2,2}= subplot(3,1,2); boxplot(pVals,     'labels',{'MedS';'Agg';'MedSL'}); title([ICinfoStr,'pVals (Data is from ',ApproachesInfo{IndApproach,1},')']);
        ax{IndApproach,3,2}= subplot(3,1,3); boxplot(signedrank,'labels',{'MedS';'Agg';'MedSL'}); title([ICinfoStr,'signedrank (Data is from ',ApproachesInfo{IndApproach,1},')']);
        linkaxes([ax{IndApproach,1,2},ax{IndApproach,2,2},ax{IndApproach,3,2}],'x'); %closer inspection of a boxplot should make the others follow it, but not in Y-direction.
    
    
    %% 2.scatter & stem plots:
    MedianOffset = 0; %no centering
    if(MedianOffset==0)
        MedCenteringStr = '';
    else
        MedCenteringStr = ['(Centered@',num2str(round(MedianOffset*1000)/1000),')'];
    end
    CutOff = 1.96; %cutoff for d=log2(CutOff./abs(zVals))
    
    %% A. subplots indicate MedS,Agg&MedSL: abs(zVals)-over-Median  with marker size as sqrt(2)./CIwidth and d=log2(CutOff./abs(zVals)) as color
    Medians = squeeze(MedianQrtCIwidth(:,1,:))-MedianOffset;
    CIwidths= squeeze(MedianQrtCIwidth(:,4,:));
    d=log2(CutOff./abs(zVals));
    XLimits = [0; 3*sqrt(2)];
    % YLimits = [-0.01; max(abs(zVals(:)))];
    CLimits = [-median([max(abs(d(:,1)));max(abs(d(:,2)));max(abs(d(:,3)))]) median([max(abs(d(:,1)));max(abs(d(:,2)));max(abs(d(:,3)))])];
    if(any(isinf(CLimits)))
        CLimits(isinf(CLimits)) = sign(CLimits(isinf(CLimits))).*3;
    end
    
    H{IndApproach,3} = figure;
        ax{IndApproach,1,3}= subplot(3,1,1); scatter(Medians(:,1),abs(zVals(:,1)),sqrt(2)./CIwidths(:,1),d(:,1)); title([ICinfoStr,'MEDIAN-SUBJECT: abs(zVals)-over-Median',MedCenteringStr,'  with marker size as sqrt(2)./CIwidth and d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),'] as color (Data is from ',ApproachesInfo{IndApproach,1},')']); colorbar; xlim(XLimits); ylim([-0.01; ceil(max(abs(zVals(:,1)))*10)/10]); caxis(CLimits); xlabel('Median \Lambda'); ylabel(['abs(zVals)[H0: \Lambda=',num2str(round(MVSscalingTest.ParamEstLambdaTest.mH0*10000)/10000),']']);
        ax{IndApproach,2,3}= subplot(3,1,2); scatter(Medians(:,2),abs(zVals(:,2)),sqrt(2)./CIwidths(:,2),d(:,2)); title([ICinfoStr,'AGGREGATE Data: abs(zVals)-over-Median',MedCenteringStr,'  with marker size as sqrt(2)./CIwidth and d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),'] as color (Data is from ',ApproachesInfo{IndApproach,1},')']); colorbar; xlim(XLimits); ylim([-0.01; ceil(max(abs(zVals(:,2)))*10)/10]); caxis(CLimits); xlabel('Median \Lambda'); ylabel(['abs(zVals)[H0: \Lambda=',num2str(round(MVSscalingTest.ParamEstLambdaTest.mH0*10000)/10000),']']);
        ax{IndApproach,3,3}= subplot(3,1,3); scatter(Medians(:,3),abs(zVals(:,3)),sqrt(2)./CIwidths(:,3),d(:,3)); title([ICinfoStr,'MEDIAN- SLight: abs(zVals)-over-Median',MedCenteringStr,'  with marker size as sqrt(2)./CIwidth and d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),'] as color (Data is from ',ApproachesInfo{IndApproach,1},')']); colorbar; xlim(XLimits); ylim([-0.01; ceil(max(abs(zVals(:,3)))*10)/10]); caxis(CLimits); xlabel('Median \Lambda'); ylabel(['abs(zVals)[H0: \Lambda=',num2str(round(MVSscalingTest.ParamEstLambdaTest.mH0*10000)/10000),']']);
        linkaxes([ax{IndApproach,1,3},ax{IndApproach,2,3},ax{IndApproach,3,3}],'x'); %closer inspection of a scatterplot should make the others follow it, IN X-&Y-direction.
    
    %% B. pVals-over-Median  with marker size as sqrt(2)./CIwidth and color by d=log2(CutOff./abs(zVals))
    YLimits = [-0.01; 1.01]; %only ylimits need to change
    H{IndApproach,4} = figure;
        ax{IndApproach,1,4}= subplot(3,1,1); scatter(Medians(:,1),pVals(:,1),sqrt(2)./CIwidths(:,1),d(:,1)); title([ICinfoStr,'MEDIAN-SUBJECT: pVals-over-Median',MedCenteringStr,'  with marker size as sqrt(2)./CIwidth and d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),'] as color (Data is from ',ApproachesInfo{IndApproach,1},')']); colorbar; xlim(XLimits); ylim(YLimits); caxis(CLimits); xlabel('Median \Lambda'); ylabel(['pVals[H0: \Lambda=',num2str(round(MVSscalingTest.ParamEstLambdaTest.mH0*10000)/10000),']']);
        ax{IndApproach,2,4}= subplot(3,1,2); scatter(Medians(:,2),pVals(:,2),sqrt(2)./CIwidths(:,2),d(:,2)); title([ICinfoStr,'AGGREGATE Data: pVals-over-Median',MedCenteringStr,'  with marker size as sqrt(2)./CIwidth and d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),'] as color (Data is from ',ApproachesInfo{IndApproach,1},')']); colorbar; xlim(XLimits); ylim(YLimits); caxis(CLimits); xlabel('Median \Lambda'); ylabel(['pVals[H0: \Lambda=',num2str(round(MVSscalingTest.ParamEstLambdaTest.mH0*10000)/10000),']']);
        ax{IndApproach,3,4}= subplot(3,1,3); scatter(Medians(:,3),pVals(:,3),sqrt(2)./CIwidths(:,3),d(:,3)); title([ICinfoStr,'MEDIAN- SLight: pVals-over-Median',MedCenteringStr,'  with marker size as sqrt(2)./CIwidth and d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),'] as color (Data is from ',ApproachesInfo{IndApproach,1},')']); colorbar; xlim(XLimits); ylim(YLimits); caxis(CLimits); xlabel('Median \Lambda'); ylabel(['pVals[H0: \Lambda=',num2str(round(MVSscalingTest.ParamEstLambdaTest.mH0*10000)/10000),']']);
        linkaxes([ax{IndApproach,1,4},ax{IndApproach,2,4},ax{IndApproach,3,4}],'xy'); %closer inspection of a scatterplot should make the others follow it, IN X-&Y-direction.
    
    %% C. stem3: d=log2(CutOff./abs(zVals)): d(Agg)-over-(d(MedS) VS d(MedSL))
    x = 0:ceil(max(d(~isinf(d(:,1)),1)));
    y = 0:ceil(max(d(~isinf(d(:,3)),3)));
    
    H{IndApproach,5} = figure;
        stem3(d(d(:,2)>0 ,1),d(d(:,2)>0 ,3),d(d(:,2)>0 ,2),'or-'); hold on;
        stem3(d(d(:,2)<=0,1),d(d(:,2)<=0,3),d(d(:,2)<=0,2),'ob-');
        plot3(           x  ,zeros(size(x)),zeros(size(x)),'k-');
        plot3(zeros(size(y)),           y  ,zeros(size(y)),'k-');
        plot3(                     x,  max(y(:)).*ones(size(x)),zeros(size(x)),'k-');
        plot3(max(x(:)).*ones(size(y)),                     y  ,zeros(size(y)),'k-');
        set(gca,'XDir','reverse','YDir','reverse'); %turn axes around
        xlabel('d(MedS)'); ylabel('d(MedSL)'); zlabel('d(Agg)');
        title([ICinfoStr,'d=log2(CutOff./abs(zVals)): d(Agg)-over-(d(MedS) VS d(MedSL)) [CutOff==',num2str(round(CutOff*100)/100),']  (Data is from ',ApproachesInfo{IndApproach,1},')']);
    
    %% D. stem3: d=log2(CutOff./abs(zVals))-over-(Median VS CIwidth) use CutOff = 1.96 (or user input)
    XLimits = [0; 3*sqrt(2)];
    
    H{IndApproach,6} = figure;
        stem3(Medians(d(:,1)>0 ,1),CIwidths(d(:,1)>0 ,1),d(d(:,1)>0 ,1),'or-'); hold on;
        stem3(Medians(d(:,1)<=0,1),CIwidths(d(:,1)<=0,1),d(d(:,1)<=0,1),'ob-');
        title([ICinfoStr,'MEDIAN-SUBJECT: d-over-(Median',MedCenteringStr,' VS CIwidth)  with d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),']  (Data is from ',ApproachesInfo{IndApproach,1},')']);
        xlim(XLimits); ylim([0; ceil(max(CIwidths(:,1))*10)/10]); xlabel('Median \Lambda'); ylabel('CIwidth'); zlabel('d');
    H{IndApproach,7} = figure;
        stem3(Medians(d(:,2)>0 ,2),CIwidths(d(:,2)>0 ,2),d(d(:,2)>0 ,2),'or-'); hold on;
        stem3(Medians(d(:,2)<=0,2),CIwidths(d(:,2)<=0,2),d(d(:,2)<=0,2),'ob-');
        title([ICinfoStr,'AGGREGATE Data: d-over-(Median',MedCenteringStr,' VS CIwidth)  with d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),']  (Data is from ',ApproachesInfo{IndApproach,1},')']);
        xlim(XLimits); ylim([0; ceil(max(CIwidths(:,2))*10)/10]); xlabel('Median \Lambda'); ylabel('CIwidth'); zlabel('d');
    H{IndApproach,8} = figure;
        stem3(Medians(d(:,3)>0 ,3),CIwidths(d(:,3)>0 ,3),d(d(:,3)>0 ,3),'or-'); hold on;
        stem3(Medians(d(:,3)<=0,3),CIwidths(d(:,3)<=0,3),d(d(:,3)<=0,3),'ob-');
        title([ICinfoStr,'MEDIAN- SLight: d-over-(Median',MedCenteringStr,' VS CIwidth)  with d=log2(CutOff./abs(zVals))[CutOff==',num2str(round(CutOff*100)/100),']  (Data is from ',ApproachesInfo{IndApproach,1},')']);
        xlim(XLimits); ylim([0; ceil(max(CIwidths(:,3))*10)/10]); xlabel('Median \Lambda'); ylabel('CIwidth'); zlabel('d');
    
    %% Done.
    disp('Done.');
end
disp('ALL DONE.');

end

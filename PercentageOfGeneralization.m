    % %Generalization

    group=2;
    if group==1

    %     load OlderAdultsIndv
    %     color=[0.9290 0.6940 0.1250];
    %      color2=[0.4940 0.1840 0.5560];
         gg=1;

    elseif group==2
%         load NimbusIndv
    %      color=[0.9290 0.6940 0.1250];
    %      color2=[0.4940 0.1840 0.5560];
         gg=1:2:3;  
    end

    figure(1)
    h1=subplot(2,3,5);
    cla(h1) 

    figure(2)
    h2=subplot(2,3,5);
    cla(h2) 

    for g=gg

        if g==1
            if  group==1
                color=[0.9290 0.6940 0.1250];
                color2=[0.4940 0.1840 0.5560];

            elseif group==2
                color=[0.3010 0.7450 0.9330];
                color2=[0.6350 0.0780 0.1840];
            end

        elseif g==3

            color=p_fade_green;
            color2=p_red;

        end    
        %Reactive
    %     dem= nanmean(data{1}.epost_ind(:,g));
    %     num=data{1}.epost_ind(:,g+1);
    %     
    %     perC_reactive=(num./dem)*100;

    training= nanmean(data{1}.epost_ind(:,g));
    testing=nanmean(data{1}.epost_ind(:,g+1));
    delta= abs(testing)-abs(training);

    figure(1)
    subplot(2,3,5)

%          bar(g,delta,'FaceColor',color2,'BarWidth',0.9,'EdgeColor',color,'LineWidth',1.5)
    plot(g,delta,"o","MarkerSize",25, 'MarkerFaceColor',color2,'MarkerEdgeColor',color);
    hold on
    title('Delta')
    %      set(gca, 'XTick', 1, 'XTickLabels', 'OA_{TS}-OA_{TR}')
    %     perC_reactive(isnan(perC_reactive))=[];
    %     E=std(perC_reactive,1,'omitnan')./sqrt(size(perC_reactive,1)); %Standar error
    %     
    %     bar(g,nanmean(perC_reactive),'FaceColor',color2,'BarWidth',0.9,'EdgeColor',color,'LineWidth',1.5)
    %     hold on
    %     errorbar(g,nanmean(perC_reactive),E,'LineStyle','none','color','k','LineWidth',2)
    %     for ss=1:size(perC_reactive,1)
    %         plot(g-0.03,perC_reactive(ss),'.','MarkerSize', 20, 'Color',[150 150 150]./255)
    %         
    %     end
    %     title('%Generalization')

        %Learning
    %     dem_learning= nanmean(data{2}.epost_ind(:,g));
    %     num_learning=data{2}.epost_ind(:,g+1);
    %     
    %     perC_learning=(num_learning./dem_learning)*100;



    figure(2)
    subplot(2,3,5)

    training_learning= nanmean(data{2}.epost_ind(:,g));
    testing_learning=nanmean(data{2}.epost_ind(:,g+1));
    delta_learning= abs(testing_learning)-abs(training_learning);

      bar(g,delta_learning,'FaceColor',color2,'BarWidth',0.9,'EdgeColor',color,'LineWidth',1.5)
    plot(g,delta_learning,"o","MarkerSize",25, 'MarkerFaceColor',color2,'MarkerEdgeColor',color);
    hold on
    title('Delta')
    %      set(gca, 'XTick', 1, 'XTickLabels', 'OA_{TS}-OA_{TR}')

    %     perC_learning(isnan(perC_learning))=[];
    %     E=std(perC_learning,1,'omitnan')./sqrt(size(perC_learning,1)); %Standar error
    %     
    %     bar(g,nanmean(perC_learning),'FaceColor',color2,'BarWidth',0.9,'EdgeColor',color,'LineWidth',1.5)
    %     hold on
    %     errorbar(g,nanmean(perC_learning),E,'LineStyle','none','color','k','LineWidth',2)
    %     for ss=1:size(perC_learning,1)
    %         plot(g-0.03,perC_learning(ss),'.','MarkerSize', 20, 'Color',[150 150 150]./255)
    %         
    %     end
    %     title('%Generalization')
    end
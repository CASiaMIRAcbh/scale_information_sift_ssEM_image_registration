loop_time = 30;

pic1_path = 'E:\cbh\realpic\4k\1.tif';
pic2_path = 'E:\cbh\realpic\4k\2.tif';
pic3_path = 'E:\cbh\realpic\4k\3.tif';
pic4_path = 'E:\cbh\realpic\4k\4.tif';
pic5_path = 'E:\cbh\realpic\4k\5.tif';

aims{1} = single(imread(pic1_path));
aims{2} = single(imread(pic2_path));
aims{3} = single(imread(pic3_path));
aims{4} = single(imread(pic4_path));
aims{5} = single(imread(pic5_path));

% for i=1:5
%     %resize
%     temp_ims = aims{i};
%     small_aims{i} = imresize(temp_ims,0.5);
% end

tic
[fa{1}, da{1}] = vl_sift(aims{1});
toc
tic
[fa{2}, da{2}] = vl_sift(aims{2});
toc
tic
[fa{3}, da{3}] = vl_sift(aims{3});
toc
tic
[fa{4}, da{4}] = vl_sift(aims{4});
toc
tic
[fa{5}, da{5}] = vl_sift(aims{5});
toc

% ssim_ori_value = [];
% for loop_i=1:4
%     temp_ims1 = aims{loop_i};
%     temp_ims2 = aims{loop_i};
%     ssim_ori_value(end+1) = ssim(temp_ims1,temp_ims2);
% end
% 
% tform = maketform('affine',distort_matrix);
% for loop_i=1:5
%     temp_ims = aims{loop_i};
%     temp_ims = imtransform(temp_ims,tform,'XData',[1 size(temp_ims,2)],'YData',[1 size(temp_ims,1)]);
%     distort_ims{loop_i} = temp_ims;
% end

% tic
% [dfa{1}, dda{1}] = vl_sift(distort_ims{1});%40.45
% toc
% tic
% [dfa{2}, dda{2}] = vl_sift(distort_ims{2});%40.06
% toc
% tic
% [dfa{3}, dda{3}] = vl_sift(distort_ims{3});%40.22
% toc
% tic
% [dfa{4}, dda{4}] = vl_sift(distort_ims{4});%39.76
% toc
% tic
% [dfa{5}, dda{5}] = vl_sift(distort_ims{5});%39.61
% toc

% for i=1:4
%     temp_fa1 = fa{i};
%     temp_fa2 = fa{i+1};
%     temp_da1 = da{i};
%     temp_da2 = da{i+1};
%     
%     [bigmatch{i},bigmatch_scores{i}] = bigScalePointMatch(temp_da1,temp_da2,temp_fa1,temp_fa2);
%     [smallmatch{i},smallmatch_scores{i}] = smallScalePointMatch(temp_da1,temp_da2,temp_fa1,temp_fa2);
% end


for i=1:4
    disp(i)
    temp_fa1 = fa{i};
    temp_fa2 = fa{i+1};
    temp_da1 = da{i};
    temp_da2 = da{i+1};
    matches_ubc{i} = vl_ubcmatch(temp_da1,temp_da2);
    [bigmatch{i},bigmatch_scores{i}] = bigScalePointMatch(temp_da1,temp_da2,temp_fa1,temp_fa2);
    [smallmatch{i},smallmatch_scores{i}] = smallScalePointMatch(temp_da1,temp_da2,temp_fa1,temp_fa2);
end

for i=1:4
    temp_ims1 = aims{i};
    temp_ims2 = aims{i+1};
    temp_fa1 = fa{i};
    temp_fa2 = fa{i+1};
    temp_da1 = da{i};
    temp_da2 = da{i+1};
    temp_ubc_matches = matches_ubc{i};
    temp_bigmatch = bigmatch{i};
    temp_smallmatch = smallmatch{i};
    
    %classical sift
    ssim_value_fitgeo = [];
    for loop_i=1:loop_time;
        ubc_matches_ransac = matches_ransac_func(temp_ubc_matches,temp_fa1,temp_fa2);
        matchedPoints1 = temp_fa1(1:2,ubc_matches_ransac(1,:))';
        matchedPoints2 = temp_fa2(1:2,ubc_matches_ransac(2,:))';
        
        %fitgeo
        tform = fitgeotrans(matchedPoints2,matchedPoints1,'affine');
        tform.T(3,1:2) = tform.T(3,1:2);
        mat = tform.T;
        tform_full = maketform('affine',mat);
        tform = maketform('affine',tform.T);
        temp_ims2_t = imtransform(temp_ims2,tform,'XData',[1 size(temp_ims1,2)],'YData',[1 size(temp_ims1,1)]);
        ssim_value_fitgeo(end+1) = ssim(temp_ims1,temp_ims2_t);
    end
    sift_matches_ubc_ssim{i} = mean(ssim_value_fitgeo);
    
    
    %sr-sift
    temp_SD = round(temp_fa1(3,temp_ubc_matches(1,:)) - temp_fa2(3,temp_ubc_matches(2,:)),1);
    SD{i} = temp_SD;
    [nums_sd,~,c_sd] = unique(temp_SD);
    nums_sd(2,:) = histcounts(uint8(c_sd),size(nums_sd(1,:),2));
    nums_sd(3,:) = nums_sd(2,:).*(1/sum(nums_sd(2,:)));
    NUMS_SD{i} = nums_sd;
    [~,sd_val_index] = max(nums_sd(3,:));
    temp_save = abs(temp_SD - nums_sd(1,sd_val_index)) <= 0.2;
    ubc_matches = temp_ubc_matches(:,temp_save);
    
    ssim_value_fitgeo = [];
    for loop_i=1:loop_time;
        ubc_matches_ransac = matches_ransac_func(ubc_matches,temp_fa1,temp_fa2);
        matchedPoints1 = temp_fa1(1:2,ubc_matches_ransac(1,:))';
        matchedPoints2 = temp_fa2(1:2,ubc_matches_ransac(2,:))';
        
        %fitgeo
        tform = fitgeotrans(matchedPoints2,matchedPoints1,'affine');
        tform.T(3,1:2) = tform.T(3,1:2);
        mat = tform.T;
        tform_full = maketform('affine',mat);
        tform = maketform('affine',tform.T);
        temp_ims2_t = imtransform(temp_ims2,tform,'XData',[1 size(temp_ims1,2)],'YData',[1 size(temp_ims1,1)]);
        ssim_value_fitgeo(end+1) = ssim(temp_ims1,temp_ims2_t);
    end
    sr_sift_matches_ubc_ssim{i} = mean(ssim_value_fitgeo);
    
    
    %ours
    ssim_value_fitgeo = [];
    for loop_i = 1:loop_time
        [bigransacmatches,resultH] = matches_ransac_bigscale(temp_bigmatch,temp_fa1,temp_fa2);
        matches_ransac = matches_ransac_allscale(bigransacmatches,resultH,temp_smallmatch,temp_fa1,temp_fa2);
        
        matchedPoints1 = temp_fa1(1:2,matches_ransac(1,:))';
        matchedPoints2 = temp_fa2(1:2,matches_ransac(2,:))';

        %fitgeo
        tform = fitgeotrans(matchedPoints2,matchedPoints1,'affine');
        tform.T(3,1:2) = tform.T(3,1:2);
        tform = maketform('affine',tform.T);
        temp_ims2_t = imtransform(temp_ims2,tform,'XData',[1 size(temp_ims1,2)],'YData',[1 size(temp_ims1,1)]);
        ssim_value_fitgeo(end+1) = ssim(temp_ims1,temp_ims2_t);
    end
    ssim_allscale_change{i} = mean(ssim_value_fitgeo);

end

% % for i=1:4
% %     i
% %     temp_fa1 = fa{i};
% %     temp_fa2 = fa{i+1};
% %     temp_da1 = da{i};
% %     temp_da2 = da{i+1};
% % %     [bigmatch{i},bigmatch_scores{i}] = bigScalePointMatch(temp_da1,temp_da2,temp_fa1,temp_fa2);
% % %     [smallmatch{i},smallmatch_scores{i}] = smallScalePointMatch(temp_da1,temp_da2,temp_fa1,temp_fa2);
% %     [my_matches{i},~] = my_match(temp_fa1, temp_fa2, temp_da1, temp_da2, 1.5);
% % end

% % % for i=1:4
% % %     temp_ims1 = aims{i};
% % %     temp_ims2 = aims{i+1};
% % %     temp_fa1 = fa{i};
% % %     temp_fa2 = fa{i+1};
% % %     temp_da1 = da{i};
% % %     temp_da2 = da{i+1};
% % %     temp_ubc_matches = matches_ubc{i};
% % %     temp_bigmatch = bigmatch{i};
% % %     temp_smallmatch = smallmatch{i};
% % %     
% % % 
% % %     ssim_value_fitgeo = [];
% % %     for loop_i = 1:loop_time
% % %         [bigransacmatches,resultH] = matches_ransac_bigscale(temp_bigmatch,temp_fa1,temp_fa2);
% % %         matches_ransac = matches_ransac_allscale(bigransacmatches,resultH,temp_smallmatch,temp_fa1,temp_fa2);
% % %         
% % %         matchedPoints1 = temp_fa1(1:2,matches_ransac(1,:))';
% % %         matchedPoints2 = temp_fa2(1:2,matches_ransac(2,:))';
% % % 
% % %         %fitgeo
% % %         tform = fitgeotrans(matchedPoints2,matchedPoints1,'affine');
% % %         tform.T(3,1:2) = tform.T(3,1:2);
% % %         tform = maketform('affine',tform.T);
% % %         temp_ims2_t = imtransform(temp_ims2,tform,'XData',[1 size(temp_ims1,2)],'YData',[1 size(temp_ims1,1)]);
% % %         ssim_value_fitgeo(end+1) = ssim(temp_ims1,temp_ims2_t);
% % %     end
% % %     ssim_allscale_change{i} = mean(ssim_value_fitgeo);
% % % 
% % % end

% for i=1:4
%     clear temp_fa1 temp_fa2 temp_da1 temp_da2 temp_my_matches temp_ubc_matches sub_scale_all
%     temp_ims1 = aims{i};
%     temp_ims2 = aims{i+1};
%     temp_fa1 = fa{i};
%     temp_fa2 = fa{i+1};
%     temp_da1 = da{i};
%     temp_da2 = da{i+1};
%     temp_ubc_matches = smallmatch{i};
%     temp_bigmatch = bigmatch{i};
%     temp_ubc_matches(:,end+1:end+size(temp_bigmatch,2)) = temp_bigmatch;
%     
%     
%     for loop_j = 1:3
%         if loop_j == 1
%             temp_save = round(temp_fa1(3,temp_ubc_matches(1,:))) <= 10;
%             ubc_matches = temp_ubc_matches(:,temp_save);
%         else if loop_j == 3
%                 temp_save = round(temp_fa1(3,temp_ubc_matches(1,:))) > 20;
%                 ubc_matches = temp_ubc_matches(:,temp_save);
%             else
%                 temp_save = round(temp_fa1(3,temp_ubc_matches(1,:))) > 10;
%                 temp_save(2,:) = round(temp_fa1(3,temp_ubc_matches(1,:))) <= 20;
%                 ubc_matches = temp_ubc_matches(:,and(temp_save(1,:),temp_save(2,:)));
%             end
%         end
%         i
%         loop_j
%         size(ubc_matches,2)
%         %得到某个小区间/删除小区间的配准
%         ssim_value_fitgeo = [];
%         for loop_i=1:loop_time;
% %             ubc_matches_ransac = ubc_matches(:,vl_colsubset(1:size(ubc_matches,2), 3));
%             ubc_matches_ransac = matches_ransac_func(ubc_matches,temp_fa1,temp_fa2);
%             matchedPoints1 = temp_fa1(1:2,ubc_matches_ransac(1,:))';
%             matchedPoints2 = temp_fa2(1:2,ubc_matches_ransac(2,:))';
%             
%             %fitgeo
%             tform = fitgeotrans(matchedPoints2,matchedPoints1,'affine');
%             tform.T(3,1:2) = tform.T(3,1:2);
%             mat = tform.T;
%             tform_full = maketform('affine',mat);
%             tform = maketform('affine',tform.T);
%             temp_ims2_t = imtransform(temp_ims2,tform,'XData',[1 size(temp_ims1,2)],'YData',[1 size(temp_ims1,1)]);
%             ssim_value_fitgeo(end+1) = ssim(temp_ims1,temp_ims2_t);
%         end
%         
%         matches_my_bin_ssim_fitgeo{i,loop_j} = mean(ssim_value_fitgeo);
%     end
% end


% for i=1:4
%     temp_fa1 = fa{i};
%     temp_fa2 = dfa{i+1};
%     temp_da1 = da{i};
%     temp_da2 = dda{i+1};
%     
%     [bigmatch{i},bigmatch_scores{i}] = bigScalePointMatch(temp_da1,temp_da2,temp_fa1,temp_fa2);
%     [smallmatch{i},smallmatch_scores{i}] = smallScalePointMatch(temp_da1,temp_da2,temp_fa1,temp_fa2);
% end


% data = [0.7814 0.7716 0.7875 .7797];
% data = [.8846 .8875 .8897 .8758];
% h = figure(1);
% axis([0.5 4.5 0 1]);
% 
% hold on
% x=[1 2 3 4];
% bar(x,data,0.4)
% 
% set(gca,'YGrid','on')
% set(gca,'xtick',[1 2 3 4]);
% set(gca,'xticklabel',{'1st' '2nd' '3rd' '4th'});
% title('Repetition rate                         of every EM image set')
% xlabel('Set number')
% ylabel('% matches')

% for i=1:4
% 
%      temp_ims1 = aims{i};
%      temp_ims2 = aims{i+1};
%      
%      temp_fa1 = fa{i};
%      temp_fa2 = fa{i+1};
%      temp_my_matches = smallmatch{i};
%      temp_ubc_matches = matches_ubc{i};
%      
%      temp_sum = 0;
%      temp_my_sub_ubc_matches = [];
%      for j=1:size(temp_my_matches,2)
%           clear temp_pos
%           temp_pos = find(temp_ubc_matches(1,:) == temp_my_matches(1,j));
%           if isempty(temp_pos)
%               temp_ubc_matches(1:2,end+1) = temp_my_matches(1:2,j);
%               temp_my_sub_ubc_matches(1:2,end+1) = temp_my_matches(1:2,j);
%           end
%      end
% 
%      show_compare_sift_points( temp_ims1, temp_ims2, temp_fa1, temp_fa2, temp_my_sub_ubc_matches )
% %      temp_sum/size(temp_my_matches,2)
% 
%     ssim_value_fitgeo = [];
%     for loop_i=1:loop_time;
%     %             ubc_matches_ransac = ubc_matches(:,vl_colsubset(1:size(ubc_matches,2), 3));
%         ubc_matches_ransac = matches_ransac_func(temp_ubc_matches,temp_fa1,temp_fa2);
%         matchedPoints1 = temp_fa1(1:2,ubc_matches_ransac(1,:))';
%         matchedPoints2 = temp_fa2(1:2,ubc_matches_ransac(2,:))';
% 
%         %fitgeo
%         tform = fitgeotrans(matchedPoints2,matchedPoints1,'affine');
%         tform.T(3,1:2) = tform.T(3,1:2);
%         mat = tform.T;
%         tform_full = maketform('affine',mat);
%         tform = maketform('affine',tform.T);
%         temp_ims2_t = imtransform(temp_ims2,tform,'XData',[1 size(temp_ims1,2)],'YData',[1 size(temp_ims1,1)]);
%         ssim_value_fitgeo(end+1) = ssim(temp_ims1,temp_ims2_t);
%     end
% 
%     matches_my_bin_ssim_fitgeo{i,loop_j} = mean(ssim_value_fitgeo);
% 
% end

% 10年的尺度比例
% for i=1:4
%      temp_ims1 = aims{i};
%      temp_ims2 = aims{i+1};
%      
%      temp_fa1 = fa{i};
%      temp_fa2 = fa{i+1};
%      temp_my_matches = my_matches{i};
%      
% 
%     ssim_value_fitgeo = [];
%     for loop_i=1:loop_time;
%         my_matches_ransac = matches_ransac_func(temp_my_matches,temp_fa1,temp_fa2);
%         matchedPoints1 = temp_fa1(1:2,my_matches_ransac(1,:))';
%         
%         matchedPoints2 = temp_fa2(1:2,my_matches_ransac(2,:))';
% 
%         %fitgeo
%         tform = fitgeotrans(matchedPoints2,matchedPoints1,'affine');
%         tform.T(3,1:2) = tform.T(3,1:2) ./ 0.5;
%         mat = tform.T;
%         tform_full = maketform('affine',mat);
%         tform = maketform('affine',tform.T);
%         temp_ims2_t = imtransform(temp_ims2,tform,'XData',[1 size(temp_ims1,2)],'YData',[1 size(temp_ims1,1)]);
%         ssim_value_fitgeo(end+1) = ssim(temp_ims1,temp_ims2_t);
%         imshow(uint8(temp_ims2_t))
%     end
% 
%     matches_my_bin_ssim_fitgeo{i} = mean(ssim_value_fitgeo);
% 
% end
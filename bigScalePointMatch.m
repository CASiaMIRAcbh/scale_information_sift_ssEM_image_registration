function [ bigScale_matches,scores ] = bigScalePointMatch( da1, da2, fa1, fa2 )
%BIGSCALEPOINTMATCH 对图片中大尺度点进行配准，不进行尺度筛选（暂定）
%   对4k图像配准过程中，尺度>=6的特征点进行配准。目标追求高正确率，指导小尺度点的配准过程
%   可能之后考虑只有值在一定范围内的才加入
scale_size = 6;

fa1_temp = fa1;
fa2_temp = fa2;
da1_temp = da1;
da2_temp = da2;

fa1_del = round(fa1(3,:))<scale_size;
fa2_del = round(fa2(3,:))<scale_size;

fa1_temp_back_index = [];
fa2_temp_back_index = [];

for i=1:size(fa1,2)
    if fa1_del(i) == false
        fa1_temp_back_index(end+1) = i;
    end
end
for i=1:size(fa2,2)
    if fa2_del(i) == false
        fa2_temp_back_index(end+1) = i;
    end
end

fa1_temp(:,fa1_del) = [];
da1_temp(:,fa1_del) = [];
fa2_temp(:,fa2_del) = [];
da2_temp(:,fa2_del) = [];

[matches_1,scores_1] = vl_ubcmatch(da1_temp,da2_temp,3);
matches_2 = vl_ubcmatch(da2_temp,da1_temp,3);

matches_1_del = false(1,size(matches_1,2));
for i=1:size(matches_1,2)
    temp_find = find(matches_2(1,:) == matches_1(2,i));
    if isempty(temp_find)
        matches_1_del(i) = true;
        continue;
    end
    if size(temp_find,2) > 1
        matches_1_del(i) = true;
        continue;
    end
    if matches_2(2,temp_find) ~= matches_1(1,i)
        matches_1_del(i) = true;
        continue;
    end
end
matches_1(:,matches_1_del) = [];
scores_1(:,matches_1_del) = [];
[scores,index] = sort(scores_1);
matches_1 = matches_1(:,index);
bigScale_matches(1,:) = fa1_temp_back_index(matches_1(1,:));
bigScale_matches(2,:) = fa2_temp_back_index(matches_1(2,:));



function [ smallScale_matches,scores ] = smallScalePointMatch( da1, da2, fa1, fa2 )
%SMALLSCALEPOINTMATCH 对图片中小尺度点进行尺度筛选的粗配准
%   尺度阈值设置为0.15 0.6/4 由0417尺度差数据得来 只配准4k图下 尺度<6的特征点
scale_size = 6;
threshold = 0.15;

fa1_temp = fa1;
fa2_temp = fa2;
da1_temp = da1;
da2_temp = da2;

fa1_del = round(fa1(3,:))>=scale_size;
fa2_del = round(fa2(3,:))>=scale_size;

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

[matches_1,scores] = my_match(da1_temp,da2_temp,fa1_temp,fa2_temp,threshold,1.5);

smallScale_matches(1,:) = fa1_temp_back_index(matches_1(1,:));
smallScale_matches(2,:) = fa2_temp_back_index(matches_1(2,:));



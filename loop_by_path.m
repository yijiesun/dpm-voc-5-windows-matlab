startup;
global name;
load('F:\voc\INRIA_2019\2019\person_final');
model.class = 'person grammar';
model.vis = @() visualize_person_grammar_model(model, 6);
% test('000061.jpg', model, -0.6);
cls = model.class;
clf;
% axis equal; 
% axis on;
% model.vis();
% clf;
fileFolder=fullfile('F:\pepoleDetect\');
dirOutput=dir(fullfile(fileFolder,'*'));
fileNames={dirOutput.name};
 for x = 1 : size(fileNames,2)% 读取数据
     name = char(fileNames(x));
%      name = '9.jpg';
     if(strcmp(name,'.')||strcmp(name,'..'))
         continue;
     end
     fprintf('%s\n',[fileFolder,name]);
     frame = imread([fileFolder,name]);
     test(frame, model, -0.6);
%      imshow(frame);
%      imwrite(frame,strcat(num2str(k),'.jpg'),'jpg');% 保存帧
 end

 function test(im, model, thresh)

% fprintf('///// Running demo for %s /////\n\n', cls);

% load and display image
% clf;

% disp([cls ' model visualization']);
% disp('press any key to continue'); pause;
% disp('continuing...');

% detect objects
[ds, bs] = imgdetect(im, model, thresh);
top = nms(ds, 0.5);
clf;
if model.type == model_types.Grammar
    if(size(ds,2)~=0)
     bs = [ds(:,1:4) bs];
    end
end
showboxes(im, reduceboxes(model, bs(top,:)));
% disp('detections');
% disp('press any key to continue'); pause;
% disp('continuing...');

if model.type == model_types.MixStar
  % get bounding boxes
  bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
  bbox = clipboxes(im, bbox);
  top = nms(bbox, 0.5);
  clf;
  showboxes(im, bbox(top,:));
  disp('bounding boxes');
%   disp('press any key to continue'); pause;
end


 end
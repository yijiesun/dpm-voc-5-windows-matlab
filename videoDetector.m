startup;
global x;
load('VOC2007/person_grammar_final');
model.class = 'person grammar';
model.vis = @() visualize_person_grammar_model(model, 6);
% test('000061.jpg', model, -0.6);
cls = model.class;
clf;
% axis equal; 
% axis on;
% model.vis();
% clf;
fileName = 'F:\\video_dataset\\test0.avi'; 
obj = VideoReader(fileName);
numFrames = obj.NumberOfFrames;% 帧的总数
 for x = 1 : numFrames% 读取数据
     fprintf('%d\n',x);
     frame = read(obj,x);
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
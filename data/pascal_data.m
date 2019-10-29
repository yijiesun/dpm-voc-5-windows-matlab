function [pos, neg, impos] = pascal_data(cls, year)
% Get training data from the PASCAL dataset.
%   [pos, neg, impos] = pascal_data(cls, year)
%
% Return values
%   pos     Each positive example on its own
%   neg     Each negative image on its own
%   impos   Each positive image with a list of foreground boxes
%
% Arguments
%   cls     Object class to get examples for
%   year    PASCAL dataset year

conf       = voc_config('pascal.year', year);
dataset_fg = conf.training.train_set_fg;
dataset_bg = conf.training.train_set_bg;
cachedir   = conf.paths.model_dir;
VOCopts    = conf.pascal.VOCopts;

try
  load([cachedir cls '_' dataset_fg '_' year]);
catch
  % Positive examples from the foreground dataset
  
    % InriaPersonPos.txt是从Inria人体数据集获得的50个正样本的标注文件，格式为[x1 y1 x2 y2 RelativePath]
%     [a,b,c,d,p] = textread('InriaPersonPos.txt','%d %d %d %d %s'); % 注意：读取后p的类型是50*1的cell类型

  ids      = textread(sprintf(VOCopts.imgsetpath, dataset_fg), '%s');
  pos      = [];% 存储正样本目标信息的数组，每个元素是一个结构，{im, x1, y1, x2, y2}
  impos    = [];
  numpos   = 0;% 正样本目标个数(一个图片中可能含有多个正样本目标)
  numimpos = 0;
  dataid   = 0;
  % 遍历训练图片文件名数组ids
  for i = 1:length(ids)
    tic_toc_print('%s: parsing positives (%s %s): %d/%d\n', ...
                  cls, dataset_fg, year, i, length(ids));
    % Parse record and exclude difficult examples
    rec           = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
%     rec           = PASreadrecord('F:\voc\VOCdevkit\INRIA\Annotations\0.xml');
    clsinds       = strmatch(cls, {rec.objects(:).class}, 'exact');
    diff          = [rec.objects(clsinds).difficult];
    clsinds(diff) = [];
    count         = length(clsinds(:));
    % Skip if there are no objects in this image
    if count == 0
      continue;
    end

    % Create one entry per bounding box in the pos array
    for j = clsinds(:)'
      numpos = numpos + 1;% 正样本目标个数
      dataid = dataid + 1;
      bbox   = rec.objects(j).bbox;
      
      pos(numpos).im      = [VOCopts.datadir rec.imgname];%图片路径补全为绝对路径
      pos(numpos).x1      = bbox(1);
      pos(numpos).y1      = bbox(2);
      pos(numpos).x2      = bbox(3);
      pos(numpos).y2      = bbox(4);
      pos(numpos).boxes   = bbox;
      pos(numpos).flip    = false;
      pos(numpos).trunc   = rec.objects(j).truncated;
      pos(numpos).dataids = dataid;
      pos(numpos).sizes   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);

      % Create flipped example
      numpos  = numpos + 1;
      dataid  = dataid + 1;
      oldx1   = bbox(1);
      oldx2   = bbox(3);
      bbox(1) = rec.imgsize(1) - oldx2 + 1;
      bbox(3) = rec.imgsize(1) - oldx1 + 1;

      pos(numpos).im      = [VOCopts.datadir rec.imgname];
      pos(numpos).x1      = bbox(1);
      pos(numpos).y1      = bbox(2);
      pos(numpos).x2      = bbox(3);
      pos(numpos).y2      = bbox(4);
      pos(numpos).boxes   = bbox;
      pos(numpos).flip    = true;
      pos(numpos).trunc   = rec.objects(j).truncated;
      pos(numpos).dataids = dataid;
      pos(numpos).sizes   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
    end

    % Create one entry per foreground image in the impos array
    numimpos                = numimpos + 1;
    impos(numimpos).im      = [VOCopts.datadir rec.imgname];
    impos(numimpos).boxes   = zeros(count, 4);
    impos(numimpos).dataids = zeros(count, 1);
    impos(numimpos).sizes   = zeros(count, 1);
    impos(numimpos).flip    = false;

    for j = 1:count
      dataid = dataid + 1;
      bbox   = rec.objects(clsinds(j)).bbox;
      
      impos(numimpos).boxes(j,:) = bbox;
      impos(numimpos).dataids(j) = dataid;
      impos(numimpos).sizes(j)   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
    end

    % Create flipped example
    numimpos                = numimpos + 1;
    impos(numimpos).im      = [VOCopts.datadir rec.imgname];
    impos(numimpos).boxes   = zeros(count, 4);
    impos(numimpos).dataids = zeros(count, 1);
    impos(numimpos).sizes   = zeros(count, 1);
    impos(numimpos).flip    = true;
    unflipped_boxes         = impos(numimpos-1).boxes;
    
    for j = 1:count
      dataid  = dataid + 1;
      bbox    = unflipped_boxes(j,:);
      oldx1   = bbox(1);
      oldx2   = bbox(3);
      bbox(1) = rec.imgsize(1) - oldx2 + 1;
      bbox(3) = rec.imgsize(1) - oldx1 + 1;

      impos(numimpos).boxes(j,:) = bbox;
      impos(numimpos).dataids(j) = dataid;
      impos(numimpos).sizes(j)   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
    end
  end

  % Negative examples from the background dataset
  ids    = textread(sprintf(VOCopts.imgsetpath, dataset_bg), '%s');
  neg    = [];
  numneg = 0;
  for i = 1:length(ids);
    tic_toc_print('%s: parsing negatives (%s %s): %d/%d\n', ...
                  cls, dataset_bg, year, i, length(ids));
%     rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
%     clsinds = strmatch(cls, {rec.objects(:).class}, 'exact');
%     if length(clsinds) == 0
      dataid             = dataid + 1;
      numneg             = numneg+1;
      neg(numneg).im     = [VOCopts.datadir,'INRIA/JPEGImages/', ids{i}];
      neg(numneg).flip   = false;
      neg(numneg).dataid = dataid;
%     end
  end
  
  save([cachedir cls '_' dataset_fg '_' year], 'pos', 'neg', 'impos');
end

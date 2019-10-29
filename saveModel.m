function saveModel()
% 将voc5训练产生的model保存至txt文件
% 
% by Yu Xianguo, NUDT, Changsha, China.
clear all
clc
% fid = fopen('F:\voc\voc-release5\2007\person_final500.txt','w');
% load('F:\voc\voc-release5\2007\person_final.mat');
% fid = fopen('VOC2007/person_grammar_final.txt','w');
% load('VOC2007/person_grammar_final.mat');
fid = fopen('F:\voc\INRIA_2019\2019\person_final.txt','w');
load('F:\voc\INRIA_2019\2019\person_final.mat');
% visualizemodel(model);
fprintf(fid,'class\t%s\n',model.class);
fprintf(fid,'year\t%s\n',model.year);
fprintf(fid,'note\t%s\n',model.note);

fprintf(fid,'filters %i',length(model.filters));
for i=1:length(model.filters)
    F = model.filters(i);
    fprintf(fid,'\nmodel.filters(%i)',i);
    fprintf(fid,'\nblocklabel ');fprintf(fid,'%g ',F.blocklabel);
    fprintf(fid,'\nsize ');fprintf(fid,'%g ',F.size);
    fprintf(fid,'\nflip ');fprintf(fid,'%g ',F.flip);
    fprintf(fid,'\nsymbol ');fprintf(fid,'%g ',F.symbol);
end

fprintf(fid,'\nrules %i',length(model.rules));
for i=1:length(model.rules)
    R1 = model.rules{i};
    fprintf(fid,'\nmodel.rules{%i} %i',i,length(R1));
    for j=1:length(R1)
        R = R1(j);
        fprintf(fid,'\nmodel.rules{%i}(%i)',i,j);
        fprintf(fid,'\ntype %s ',R.type);
        fprintf(fid,'\nlhs %i ',length(R.lhs));fprintf(fid,'%g ',R.lhs);
        fprintf(fid,'\nrhs %i ',length(R.rhs));fprintf(fid,'%g ',R.rhs);
        fprintf(fid,'\ndetwindow ');fprintf(fid,'%g ',R.detwindow);
        fprintf(fid,'\nshiftwindow ');fprintf(fid,'%g ',R.shiftwindow);
        fprintf(fid,'\ni ');fprintf(fid,'%g ',R.i);
        if isfield(R,'anchor')
            fprintf(fid,'\nanchor %i',length(R.anchor));
            for k=1:length(R.anchor)
                fprintf(fid,'\n%i ',k);
                fprintf(fid,'%g ',R.anchor{k});
            end            
        else
            fprintf(fid,'\nanchor 0');
        end
        fprintf(fid,'\noffset.blocklabel %g',R.offset.blocklabel);
        fprintf(fid,'\nloc.blocklabel %g',R.loc.blocklabel);
        fprintf(fid,'\nblocks %i ',length(R.blocks));fprintf(fid,'%g ',R.blocks);
        if ~isfield(R,'def')
            R.def.blocklabel = 1;
            R.def.flip = false;
        end
        fprintf(fid,'\ndef.blocklabel %g def.flip %g',R.def.blocklabel,R.def.flip);        
    end
end

fprintf(fid,'\nsymbols %i',length(model.symbols));
for i=1:length(model.symbols)
    S = model.symbols(i);
    fprintf(fid,'\nmodel.symbols(%i)',i);
    fprintf(fid,'\ntype %s',S.type);
    if ~isempty(S.filter)
        fprintf(fid,'\nfilter %i',S.filter);
    else
        fprintf(fid,'\nfilter 0');
    end
end

fprintf(fid,'\nnumfilters %i',model.numfilters);
fprintf(fid,'\nnumblocks %i',model.numblocks);
fprintf(fid,'\nnumsymbols %i',model.numsymbols);
fprintf(fid,'\nstart %i',model.start);
fprintf(fid,'\nmaxsize %i %i',model.maxsize(1),model.maxsize(2));
fprintf(fid,'\nminsize %i %i',model.minsize(1),model.minsize(2));
fprintf(fid,'\ninterval %g',model.interval);
fprintf(fid,'\nsbin %i',model.sbin);
fprintf(fid,'\nthresh %g',model.thresh);
fprintf(fid,'\ntype %s',model.type);

fprintf(fid,'\nblocks %i',length(model.blocks));
for i=1:length(model.blocks)
    B = model.blocks(i);
    % 将lb和w中的元素以openCV的数据存储方式重排
    shape = B.shape;
    lb = reshape(B.lb,shape);
    w = reshape(B.w,shape);
    idx = 1;
    if length(shape)==2
        shape(3) = 1;
    end
    for r=1:shape(1)
        for c=1:shape(2)
            for d=1:shape(3)
                B.lb(idx) = lb(r,c,d);
                B.w(idx) = w(r,c,d);
                idx = idx + 1;
            end
        end
    end
    
    fprintf(fid,'\nmodel.blocks(%i)',i);     
    fprintf(fid,'\nw %i ',length(B.w));fprintf(fid,'%g ',B.w);
    fprintf(fid,'\nlb %i ',length(B.lb));fprintf(fid,'%g ',B.lb);
    fprintf(fid,'\nlearn %g',B.learn);
    fprintf(fid,'\nreg_mult %g',B.reg_mult);
    fprintf(fid,'\ndim %i',B.dim);
    fprintf(fid,'\nshape %i ',length(B.shape));fprintf(fid,'%g ',B.shape);
    fprintf(fid,'\ntype %s',B.type);
end

fprintf(fid,'\nfeatures');
F2 = model.features;
fprintf(fid,'\nsbin %g',F2.sbin);
fprintf(fid,'\ndim %g',F2.dim);
fprintf(fid,'\ntruncation_dim %g',F2.truncation_dim);
fprintf(fid,'\nextra_octave %g',F2.extra_octave);
fprintf(fid,'\nbias %g',F2.bias);

fprintf(fid,'\nstats');
if ~isfield(model,'stats')
    model.stats.slave_problem_time = [];
    model.stats.data_mining_time = [];
    model.stats.pos_latent_time = [];
    model.stats.filter_usage = [];
end
S2 = model.stats;
fprintf(fid,'\nslave_problem_time %i ',length(S2.slave_problem_time));fprintf(fid,'%g ',S2.slave_problem_time);
fprintf(fid,'\ndata_mining_time %i ',length(S2.data_mining_time));fprintf(fid,'%g ',S2.data_mining_time);
fprintf(fid,'\npos_latent_time %i ',length(S2.pos_latent_time));fprintf(fid,'%g ',S2.pos_latent_time);
fprintf(fid,'\nfilter_usage %i ',length(S2.filter_usage));fprintf(fid,'%g ',S2.filter_usage);

if isfield(model,'bboxpred')
    fprintf(fid,'\nbboxpred %i',length(model.bboxpred));
    for i=1:length(model.bboxpred)
        B2 = model.bboxpred{i};
        fprintf(fid,'\nmodel.bboxpred(%i)',i);
        fprintf(fid,'\nx1 %i ',length(B2.x1));fprintf(fid,'%g ',B2.x1);
        fprintf(fid,'\ny1 %i ',length(B2.y1));fprintf(fid,'%g ',B2.y1);
        fprintf(fid,'\nx2 %i ',length(B2.x2));fprintf(fid,'%g ',B2.x2);
        fprintf(fid,'\ny2 %i ',length(B2.y2));fprintf(fid,'%g ',B2.y2);
    end
else
    fprintf(fid,'\nbboxpred 0');
end

fclose(fid);
            





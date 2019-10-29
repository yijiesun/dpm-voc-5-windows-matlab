
clc
clear all
inria_lst_2_voc();
function inria_lst_2_voc()
    pos_txt_file='F:\INRIAPerson\Train\neg.lst';
    fp = fopen('F:\voc\VOCdevkit\INRIA\ImageSets\Main\tranval_inria.txt','wt','n','UTF-8');
    ids = textread(pos_txt_file, '%s');
    pathstr=[];
    name=[];
    dox=[];
    for i=1:size(ids,1)
        [pathstr(i).a,name(i).a,dox(i).a]=fileparts(char(ids(i)));
    end

    for i =1 : size(ids,1)
    fprintf(fp, '%s%s\n', name(i).a,dox(i).a);
    end
    fclose(fp);
end

function save_dir_img_file()
    fp = fopen('F:\voc\VOCdevkit\INRIA\ImageSets\Main\test.txt','wt','n','UTF-8');
    pathstr=[];
    name=[];
    fileFolder=fullfile('F:\pepoleDetect\');
    dirOutput=dir(fullfile(fileFolder,'*'));
    fileNames={dirOutput.name};
    for i=3:size(fileNames,2)
        [pathstr(i-2).a,name(i-2).a]=fileparts(char(fileNames(i)));
    end
    for i =1 : size(fileNames,2)-2
    fprintf(fp, '%s\n', name(i).a);
    end
    fclose(fp);
end

function inria_annotation_2_voc()
    pathstr=[];
    name=[];
    dox=[];
    annotationPath='F:\voc\VOCdevkit\INRIA\Annotations\';
    fileFolder=fullfile('F:\INRIAPerson\Train\annotations\');
    dirOutput=dir(fullfile(fileFolder,'*'));
    fileNames={dirOutput.name};
    for i=3:size(fileNames,2)
        [pathstr(i-2).a,name(i-2).a,dox(i-2).a]=fileparts(char(fileNames(i)));
    end
    for i =1 : size(fileNames,2)-2
        disp(name(i).a)
%         fp=fopen([path,char(name(i).a),'.xml'],'wt');
%         fprintf(fp,'<annotation>\n');
%         fprintf(fp,'</annotation>\n');
%         fclose(fp);
         
  
        annotationNode = com.mathworks.xml.XMLUtils.createDocument('annotation');
        annotationRoot = annotationNode.getDocumentElement;
        addNode(annotationNode,annotationRoot,'folder','INRIA');
        
        tline3=dataread([fileFolder,char(name(i).a),'.txt'],3);
        regImgName = regexp(tline3,'(?<=Train/pos/)\w.*','match');%得到对应的图片名例如：crop001001.png
        regImgName = regexp(char(regImgName),'\w.*(?=\")','match');
        addNode(annotationNode,annotationRoot,'filename',char(regImgName));
        
        sourceRoot = annotationNode.createElement('source');   
        annotationRoot.appendChild(sourceRoot);  
        addNode(annotationNode,sourceRoot,'database','The INRIA Database');
        addNode(annotationNode,sourceRoot,'annotation','INRIA');
        addNode(annotationNode,sourceRoot,'image','flickr');
        addNode(annotationNode,sourceRoot,'flickrid','123456789');
        
        ownerRoot = annotationNode.createElement('owner');   
        annotationRoot.appendChild(ownerRoot);  
        addNode(annotationNode,ownerRoot,'flickrid','abcd');
        addNode(annotationNode,ownerRoot,'name','abcdef');
        
        sizeRoot = annotationNode.createElement('size');   
        annotationRoot.appendChild(sizeRoot);  
        tline4=dataread([fileFolder,char(name(i).a),'.txt'],4);
        wid = regexp(tline4,'(?<=:\s)\d*','match');
        hgt_dep = regexp(tline4,'(?<=x\s)\d*','match');
        addNode(annotationNode,sizeRoot,'width',char(wid));
        addNode(annotationNode,sizeRoot,'height',char(hgt_dep(1)));
        addNode(annotationNode,sizeRoot,'depth',char(hgt_dep(2)));
        
        addNode(annotationNode,annotationRoot,'segmented','0');

        tline6=dataread([fileFolder,char(name(i).a),'.txt'],6);
        numPerson = regexp(tline6,'(?<=:\s)\d','match');
        
        for k=1:eval(numPerson{1})
            objectRoot = annotationNode.createElement('object');   
            annotationRoot.appendChild(objectRoot);  
            addNode(annotationNode,objectRoot,'name','person');
            addNode(annotationNode,objectRoot,'pose','Unspecified');
            addNode(annotationNode,objectRoot,'truncated','0');
            addNode(annotationNode,objectRoot,'difficult','0');
        
            bndboxRoot = annotationNode.createElement('bndbox');   
            objectRoot.appendChild(bndboxRoot);  
            tlineN=dataread([fileFolder,char(name(i).a),'.txt'],11+k*7);
            xyXYTmp = regexp(tlineN,'[0-9]\d*,\s[0-9]\d*','match');
            xyXY = regexp(xyXYTmp, ',', 'split');
            addNode(annotationNode,bndboxRoot,'xmin',char(xyXY{1,1}(1)));
            addNode(annotationNode,bndboxRoot,'ymin',char(xyXY{1,1}(2)));
            addNode(annotationNode,bndboxRoot,'xmax',char(xyXY{1,2}(1)));
            addNode(annotationNode,bndboxRoot,'ymax',char(xyXY{1,2}(2)));
        end
       

        
        xmlwrite([annotationPath,char(name(i).a),'.xml'],annotationNode);  
%         type([annotationPath,char(name(i).a),'.xml']);  
        fid_t=fopen([annotationPath,char(name(i).a),'.xml'],'r','n','UTF-8');
        fout_t=fopen([annotationPath,'tmp.xml'],'w','n','UTF-8');
        tline=fgetl(fid_t);
        while ~feof(fid_t) %判断是否为文件末尾
            tline=fgetl(fid_t);%读取一行
            fprintf(fout_t,'%s\n',tline);%不是空行则将该行写入'new.txt'  
        end
        fclose(fid_t);
        fclose(fout_t);
        delete([annotationPath,char(name(i).a),'.xml']);
        fid_n=fopen([annotationPath,'tmp.xml'],'r','n','UTF-8');
        fout_n=fopen([annotationPath,char(name(i).a),'.xml'],'w','n','UTF-8');
        while ~feof(fid_n) %判断是否为文件末尾
            tline=fgetl(fid_n);%读取一行
            ss=regexp(tline, ' ', 'match');
            tline(find(isspace(tline))) = [];
%             strrep(tline,'      ', '');
%             strrep(tline,'   ', '');
            if(size(ss,2)>=9)
                fprintf(fout_n,'\t\t\t%s\n',tline);%不是空行则将该行写入'new.txt'  
            elseif (size(ss,2)>=6)
                fprintf(fout_n,'\t\t%s\n',tline);
            elseif (size(ss,2)>=3)
                fprintf(fout_n,'\t%s\n',tline);
            else
                fprintf(fout_n,'%s\n',tline);   
            end
        end
        fclose(fid_n);
        fclose(fout_n);
        delete([annotationPath,'tmp.xml']);
    end
    


end

function  addNode(docNode,docRootNode,node,content)

        NEWNode = docNode.createElement(node); 
        NEWNode.appendChild(docNode.createTextNode(content));
        docRootNode.appendChild(NEWNode);  
end

function tline=dataread(filein,line)
    fidin=fopen(filein,'r');
    nline=0;
    while ~feof(fidin) % 判断是否为文件末尾
    tline=fgetl(fidin); % 从文件读行
    nline=nline+1;
    if nline==line
        disp(tline);
        fclose(fidin);
        break;
    end
    
    end
end


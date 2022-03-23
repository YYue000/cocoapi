type = 'bbox'

resFileRoot = '/repair_workspace/mmdetection/corruption_benchmarks/retinanet'

Models = {'retinanet_r50_fpn_1x_coco'};

Corruption={'gaussian_noise', 'shot_noise', 'impulse_noise', 'defocus_blur','glass_blur', 'motion_blur', 'zoom_blur', 'snow', 'frost', 'fog', 'brightness', 'contrast', 'elastic_transform', 'pixelate', 'jpeg_compression'};

dataDir='/repair_workspace/data/coco'; prefix='instances'; dataType='val2017';
if(strcmp(type,'keypoints')), prefix='person_keypoints'; end
annFile=sprintf('%s/annotations/%s_%s.json',dataDir,prefix,dataType);
cocoGt=CocoApi(annFile);
imgIds=cocoGt.getImgIds(); %imgIds=imgIds(1:100);


allDirName = {'clean'};
cnt=2;
for j=1:length(Corruption)
    for s=1:5
        allDirName{cnt} = sprintf("%s-%d",Corruption{j},s);
    end
end

for i=1:length(Models)
    model=Models{i}
    for j=1:length(allDirName)
        if(j==1), suf='output.bbox.json';
        else suf='output.pkl.bbox.json'; end
        resFile = sprintf("%s/%s/%s/%s",resFileRoot, model, allDirName{j},suf)
        outDir=sprintf('%s/%s/%s/analyze', resFileRoot, model, allDirName{j});
        cocoDt=cocoGt.loadRes(resFile);
        cocoEval=CocoEval(cocoGt,cocoDt,type);
        cocoEval.params.imgIds=imgIds;
        cocoEval.evaluate();
        cocoEval.accumulate();
        cocoEval.summarize();
        cocoEval.analyze(outDir);
    end

end



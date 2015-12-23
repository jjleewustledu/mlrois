classdef BlockedRoisBuilder    
    %% ROIBUILDER creates ROIs, reads from and writes to a filesystem.
    %
    %  Created by John Lee on 2009-01-27.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to <email = "bugs.perfusion.neuroimage.wustl.edu@gmail.com"/>.
    
    properties (Constant)
        MODES   = { 'h15o'    'asl1'       'ssvd'}; % 'bip' };
        ROIS    = { 'modelok' 'parenchyma' 'mca'  'pca' 'gray' 'deepgray' 'white' 'left' 'right' 'Cerebellum' };
        ATLASES = { '' ...
                    'parenchyma-sub-maxprob-thr25-2mm' ...
                    'MNI152_T1_2mm_JoshsMCA_bilat' ...
                    'MNI152_T1_2mm_PCA_bilat' ...
                          'gray-sub-maxprob-thr25-2mm' ...
                      'deepgray-sub-maxprob-thr25-2mm' ...
                         'white-sub-maxprob-thr25-2mm' ...
                         'left-MNI152-2mm' ...
                        'right-MNI152-2mm' ...
               'Cerebellum-MNIfnirt-maxprob-thr25-2mm' };
        EP2D    = 'ep2d'; % 'ep2d2'
    end
    
    properties (SetAccess = 'protected')
        theMetric
        theRois % cell-array of NIfTIs
    end
    
    properties (Dependent)
        metricLabel
        roiLabels
    end
    
    methods (Static)
        function   binnii = threshRoiByStd(fpmsk, numstd)
        
            %% THRESHOLDROIBYSTD determines a statistical threshold for a floating-point mask
            %                    and uses that threshold to generate a binary mask;
            %                    uses a multiplier for std
            %  Usage:  binnii = mlfourd.BlockedRoisBuilder.threshRoiByStd(fpmsk, numstd)
            %          numstd:  set threshold to be max intensity - numstd*std (optional)
            %                   otherwise mask coverage will be set to 1 percent of voxels
            %  OBSOLETE, DEPRECATED
            mlfourd.NIfTI.isNIfTI
            maxfp  = dipmax(fpmsk.img);
            stdfp  = dipstd(fpmsk.img);
            switch (nargin)
                case 1
                    thresh = maxfp;
                    for n = 1:floor(maxfp/stdfp) 
                        thresh   = thresh - stdfp;
                        coverage = dipsum(double(fpmsk.img > thresh))/ ...
                                   dipprod(fpmsk.hdr.dime.dim(2:4)); 
                        if (coverage > 0.01)
                            break;
                        end
                    end    
                case 2
                    thresh = maxfp - numstd*stdfp;
                otherwise
                    error('mlfourd:InputParamsErr', ...
                         ['BlockedRoisBuilder.threshRoiByStd does not support ' num2str(nargin) ' input params']);
            end
            bin    = double(fpmsk.img > thresh);
            binnii = fpmsk.makeSimilar(bin, 'BlockedRoisBuilder.threshRoiByStd'); 
            disp(['BlockedRoisBuilder.threshRoiByStd.maxfp -> ' num2str(maxfp)]);
            disp(['                        stdfp -> ' num2str(stdfp)]);
            disp(['                       thresh -> ' num2str(thresh)]);
        end % static threshRoiByStd
        function   binnii = threshRoiByCoverage(fpmsk, cover)
            
            %% Static  THRESHOLDROI_COVERAGE determines a statistical threshold for 
            %          a floating-point mask and uses that threshold to generate a binary mask;
            %          uses a fractional coverage parameter
            %  Usage:  binnii = mlfourd.BlockedRoisBuilder.threshRoiByCoverage(fpmsk, cover)
            %          numstd:  set threshold to be max intensity - numstd*std (optional)
            %                   otherwise mask coverage will be set to 1 percent of voxels
            %  OBSOLETE, DEPRECATED
            mlfourd.NIfTI.isNIfTI
            maxfp  = dipmax(fpmsk.img);
            stdfp  = dipstd(fpmsk.img);
            if (1 == nargin); cover = 0.00667; end
            if (nargin < 1 || nargin > 2)
                error('mlfourd:InputParamsErr', ...
                     ['BlockedRoisBuilder.threshRoiByStd does not support ' ...
                       num2str(nargin) ' input params']);
            end
            thresh = maxfp;
            for n = 1:floor(maxfp/stdfp) 
                thresh   = thresh - stdfp;
                coverage = dipsum(double(fpmsk.img > thresh))/ ...
                           dipprod(fpmsk.hdr.dime.dim(2:4)); 
                if (coverage > cover)
                    break;
                end
            end
            bin    = double(fpmsk.img > thresh);
            binnii = fpmsk.makeSimilar(bin, 'BlockedRoisBuilder.threshRoiByStd'); 
            disp(['BlockedRoisBuilder.threshRoiByStd.maxfp -> ' num2str(maxfp)]);
            disp(['                          stdfp -> ' num2str(stdfp)]);
            disp(['                         thresh -> ' num2str(thresh)]);
        end % static threshRoiByCoverage        
        function   nii    = makeArteryRoi(epinii, fgnii)
                       
            %% MAKEARTERIESROI constructs a probability map of arteries from DSC data
            %  Usage:  nii = mlfourd.BlockedRoisBuilder.makeArteryRoi(epinii, fgnii)
            %  Requires:  diplib
            %
            assert(mlfourd.NIfTI.isNIfTI(epinii));
            assert(mlfourd.NIfTI.isNIfTI(fgnii));
            assert(4 == size(size(epinii.img), 2));                 % assert 4D time-series
            assert(numel(squeeze(epinii.img(:,:,:,1))) == numel(fgnii.img));
            fg = double(squeeze(fgnii.img) > 0);         % binary mask
            
            T_SSTATE       = 4; % frame at which M is in steady-state
            T_BEFORE_BOLUS = 1; % look slightly before the bolus peak 
                                % to avoid saturation effects, adjustable
            T_LAST         = size(epinii.img, 4);
                                
            % determine time of bolus-passage, tBolus
            epiImg = double(epinii.img(:,:,:,T_SSTATE:T_LAST-T_SSTATE));
            epimip = zeros(size(epiImg, 4), 1);
            for t = 1:size(epiImg, 4)
                epimip(t) = dipsum(squeeze(epiImg(:,:,:,t)) .* fg);
            end
            tBolus = indexOfMin(epimip);
            
            % estimate the bolus width from <t - <t>>
            distr      = epimip - epimip(tBolus);
            distr      = max(epimip) - distr;
            times      = (0:length(epimip) - 1)';
            sumdistr   = sum(distr);
            if (sumdistr < eps); sumdistr = 1; end
            bolusWidth = sum(distr .* times)/sumdistr;
            
            
            % estimate the baseline EPI image
            if (bolusWidth/2 < T_BEFORE_BOLUS)
                T_BEFORE_BOLUS = floor(bolusWidth/2); end
            tfBaseline = floor(tBolus - T_BEFORE_BOLUS - bolusWidth/2);  
            if (tfBaseline < T_SSTATE)
                tfBaseline = T_SSTATE; end
            epiBaseline = zeros(size(fg));
            for t = T_SSTATE:tfBaseline
                epiBaseline = epiBaseline + ...
                    squeeze(epiImg(:,:,:,t))/(tfBaseline - T_SSTATE + 1);
            end        
            
            % assemble arteries ROI as NIfTI
            arteries = epiBaseline/refValue(epiBaseline) - ...
                       squeeze( epiImg(:,:,:,tBolus-T_BEFORE_BOLUS)/ ...
                       refValue(epiImg(:,:,:,tBolus-T_BEFORE_BOLUS)));
            msk      = (arteries > eps) .* fg;
            arteries = msk.*arteries/dipsum(msk.*arteries); 
                       % normalize image values to be probabilities
            nii      = fgnii.makeSimilar( ...
                       arteries, 'from BlockedRoisBuilder.make_arteriesRois');
            
            function val = refValue(img)
                val = mode( ...
                                mlfourd.NiiBrowser.makeSampleVoxels( ...
                                img, double(img > eps)));
            end
        end % static makeArteryRoi
        
        function            prepareMatrices(bldr)
            import mlfsl.* mlfourd.*;
            tpth   = bldr.transformationsPath;
            flirtf = FlirtBuilder(bldr);
            
            iopts.inverse = matFqfn(tpth, 'bt1_rot', 'MNI_brain.mat');
            flirtf.invertTransform(iopts);
            copyfile(       matFqfn(tpth,  't1_rot', 'hosum_rot_susan5p52mm.mat'),  matFqfn(tpth, 't1', 'h15o.mat'));
            copyfile(       matFqfn(tpth, 'bpasl_rot_mcf_meanvol', 'bt1_rot.mat'),  matFqfn(tpth, 'asl1', 't1.mat'));
            
            iopts.inverse = matFqfn(tpth, 'asl1', 't1.mat');
            flirtf.invertTransform(iopts);
            copyfile(       matFqfn(tpth, 'bt1_rot', ['b' BlockedRoisBuilder.EP2D '_rot_mcf_meanvol.mat']),  ...
                                                                                    matFqfn(tpth, 't1', 'ssvd.mat'));
        end % static prepareMatrices
        function fqfn     = matFqfn(pth, pre, post)
            import mlfsl.*;
            assert(lexist(pth, 'dir'));
            fqfn = filename(...
                fullfile(pth, [pre FslRegistry.INTERIMAGE_TOKEN post]), FlirtVisitor.XFM_SUFFIX);
        end
        function            prepareRoisOnT1(bldr)            
            import mlfourd.* mlfsl.*;
            rois   = BlockedRoisBuilder.ROIS;
            flirtf = FlirtBuilder(bldr);
            for r = 2:numel(rois) %#ok<*FORFLG>
                try
                    opts = FlirtOptions;
                    opts.ref  = flirtf.t1;
                    opts.in   = fullfile(flirtf.atlasPath, BlockedRoisBuilder.ATLASES{r});
                    opts.out  = BlockedRoisBuilder.onT1(rois{r});
                    opts.init = filename( ...
                        fullfile(bldr.transformationsPath, ['MNI' FslRegistry.INTERIMAGE_TOKEN 't1']), FlirtVisitor.XFM_SUFFIX);
                    flirtf.applyTransform(opts);
                catch ME
                    handexcept(ME, msg)
                end
            end
            
        end % static prepareRoisOnT1
        function            prepareModelok(bldr)
            import mlfourd.* mlfsl.*;
            flirtf             = FlirtBuilder(bldr);
            cbf_asl1           = NIfTI.load('cbf_asl1');
            modelok            = (cbf_asl1 > 1) & (cbf_asl1 < 120);
            modelok.fileprefix = 'modelok';
            modelok.save;
            try
                opts = FlirtOptions;
                opts.ref  = flirtf.t1;
                opts.in   = 'modelok';
                opts.out  = BlockedRoisBuilder.onT1('modelok');
                opts.init = filename( ...
                            fullfile(bldr.transformationsPath, ...
                            ['asl1' FslRegistry.INTERIMAGE_TOKEN 't1']), FlirtVisitor.XFM_SUFFIX);
                flirtf.applyTransform(opts); 
            catch ME
                handexcept(ME)
            end
        end % static prepareModelok
        function            registerToModalities(bldr)
            
            %% REGISTERTOMODALITIES
            %  theRois should be preregistered onto MPRAGE; done on filesystem with fsl; combine from there---
            import mlfourd.* mlfsl.*;
            modes  = BlockedRoisBuilder.MODES;            
            rois   = BlockedRoisBuilder.ROIS;  %#ok<*PROP>
            flirtf = FlirtBuilder(bldr);
            for r = 1:length(rois) %#ok<PROP>
                if (strcmp(rois{r}, 'white'))
                    trimroi(BlockedRoisBuilder.onT1(rois{r}), ...
                           {BlockedRoisBuilder.onT1(rois{4}) BlockedRoisBuilder.onT1(rois{5})});
                end
                for m = 1:length(modes)
                    try
                        copyfile(BlockedRoisBuilder.t1ToMode(          modes{m}), ...
                                 BlockedRoisBuilder.roiToMode(rois{r}, modes{m}), 'f'); %#ok<PROP>
                        opts = FlirtOptions;
                        opts.ref  = BlockedRoisBuilder.theMetrics{m};
                        opts.in   = BlockedRoisBuilder.onT1(     rois{r});
                        opts.out  = BlockedRoisBuilder.roiOnMode(rois{r}, modes{m});
                        opts.init = BlockedRoisBuilder.inits(    rois{r}, modes{m});
                        flirtf.applyTransform(opts); %#ok<PROP>                        
                    catch ME
                        handexcept(ME);
                    end
                end                
            end
        end % static registerToModalities
         
        function fp = onT1(roi)
            fp = [roi mlfsl.mlfsl.FslRegistry.INTERIMAGE_TOKEN 't1'];
        end
        function fn = roiToT1(roi, bldr)
            import mlfourd.* mlfsl.*;
            tp = bldr.transformationsPath;
            fn = filename( ...
                fullfile(tp, [roi FslRegistry.INTERIMAGE_TOKEN 't1']), FlirtVisitor.XFM_SUFFIX);
        end        
        function fn = t1ToMode(mode, bldr)
            import mlfourd.* mlfsl.*;
            fn = filename( ...
                fullfile(bldr.transformationsPath, ['t1' FslRegistry.INTERIMAGE_TOKEN mode]), FlirtVisitor.XFM_SUFFIX);
        end        
        function fn = roiToMode(roi, mode, bldr)
            import mlfourd.* mlsfl.*;
            fn = filenames( ...
                fullfile(bldr.transformationsPath, [roi FslRegistry.INTERIMAGE_TOKEN mode]), FlirtVisitor.XFM_SUFFIX);
        end        
        function ms = theMetrics
            import mlfourd.*;
            ms = cell(size(BlockedRoisBuilder.MODES));
            for m = 1:length(BlockedRoisBuilder.MODES)
                ms{m} = ['cbf_' BlockedRoisBuilder.MODES{m}];
            end
        end        
        function fp = roiOnMode(roi, mode)
            fp = [roi mlfsl.FslRegistry.INTERIMAGE_TOKEN mode];
        end        
        function fn = inits(roi, mode, bldr)
            fn = filename( ...
                fullfile(bldr.transformationsPath,[roi mlfsl.FslRegistry.INTERIMAGE_TOKEN mode]), mlfsl.FlirtVisitor.XFM_SUFFIX);
        end
        
        function [metrics,rois] = assembleModalRois(andContinue)
            
            import mlfourd.* mlchoosers.*;
            rf      = BlockedRoisBuilder;
            modes   = rf.MODES;
            nModes  = numel(modes);
            
            if (lexist(  'modelok.nii.gz','file'))
                copyfile('modelok.nii.gz', ['modelok' FslRegistry.INTERIMAGE_TOKEN 'asl1.nii.gz'], 'f');
            end
            rois    = cell(numel(rf.ROIS), nModes);
            for r = 1:numel(rf.ROIS)
                for m = 1:nModes
                    rois{r,m} = NIfTI.load([rf.ROIS{r} FslRegistry.INTERIMAGE_TOKEN rf.MODES{m}]);
                end
            end
            
            metrics    = BlockedRoisBuilder.toNIfTI( ...
                         arrayfun(@(str) ['cbf_' char(str)], rf.MODES, 'UniformOutput', false));
            assert(lstrfind(metrics{2}.label, 'asl'));
            aslImg     = metrics{2}.img;
            metrics{2}.img = aslImg .* (aslImg > 1) .* (aslImg < 120); % KLUDGE to bound ASL
            
            if (exist('andContinue','var') && andContinue)
                movefile('assembleModalRois.txt', 'assembleModalRois.bak', 'f');
                diary(   'assembleModalRois.txt');
                [metrics, modelOks, parenchymas, mcas, grays, deepgrays, whites, lefts, rights, Cerebellums] = ...
                BlockedRoisBuilder.tabulateModalRois( ...
                    metrics, ...
                    slicecell(rois,1), slicecell(rois,2), slicecell(rois,3), slicecell(rois,4), slicecell(rois,5), ...
                    slicecell(rois,6), slicecell(rois,7), slicecell(rois,8), slicecell(rois,9));
                diary off;
                for m = 1:numel(rf.MODES) %#ok<FORFLG>
                    rois{1,m} = metrics{m} .* (parenchymas{m} + modelOks{m});
                    rois{2,m} = metrics{m} .*  parenchymas{m}; 
                    rois{3,m} = metrics{m} .* (parenchymas{m} + mcas{m});
                    rois{4,m} = metrics{m} .* (parenchymas{m} + grays{m});
                    rois{5,m} = metrics{m} .* (parenchymas{m} + deepgrays{m});
                    rois{6,m} = metrics{m} .* (parenchymas{m} + whites{m});
                    rois{7,m} = metrics{m} .* (parenchymas{m} + lefts{m});
                    rois{8,m} = metrics{m} .* (parenchymas{m} + rights{m});
                    rois{9,m} = metrics{m} .* (parenchymas{m} + Cerebellums{m});
                end
            end
        end % assembleModalRois
        function [metrics, modelOks, parenchymas, mcas, grays, deepgrays, whites, lefts, rights, Cerebellums] = ...
                       tabulateModalRois(metrics, modelOks, parenchymas, mcas, grays, deepgrays, whites, lefts, rights, Cerebellums)
            
            %% TABULATEMODALROIS displays a table of cell-array metrics
            %  as evaluated by row over ROIs for ASL-model-limits, no-CSF, MCA territory, ipsilateral hemisphere, 
            %  cortical tissue, deep basal ganglia, white matter.   Metrics is evaluated by columns over the 
            %  various imaging modalities, e.g., PET, ASL, DSC, LAIF
            %  See also:   assembleModalRois
            import mlfourd.*; 
            fprintf('BlockedRoisBuilder.tabulateModalRois:\n');            
            
            %% prepare all inputs as RoiFactories
            metrics     = BlockedRoisBuilder.toNIfTI(metrics);
            modelOks    = BlockedRoisBuilder.toNIfTI(modelOks);
            parenchymas = BlockedRoisBuilder.toNIfTI(parenchymas);
            mcas        = BlockedRoisBuilder.toNIfTI(mcas);
            grays       = BlockedRoisBuilder.toNIfTI(grays);
            deepgrays   = BlockedRoisBuilder.toNIfTI(deepgrays);
            whites      = BlockedRoisBuilder.toNIfTI(whites);
            lefts       = BlockedRoisBuilder.toNIfTI(lefts);
            rights      = BlockedRoisBuilder.toNIfTI(rights);            
            Cerebellums = BlockedRoisBuilder.toNIfTI(Cerebellums);
            
            for m = 1:length(grays)
                grays{m} = grays{m} + whites{m};
                gtone    = grays{m} > 1;
                grays{m} = grays{m} .* (~gtone) + gtone;
                grays{m}.fileprefix = ['cortical' mlfsl.FslRegistry.INTERIMAGE_TOKEN BlockedRoisBuilder.MODES{m}];
                grays{m}.save;
            end
            
            
            
            % permutations will be with fg, tissue, hemisphere RoiFactories
            % each modality gets separate, m-indexe RoiFactories
            nModes           = length(metrics);
            metricFactories  = cell(1,nModes);
            modelokFactories = cell(1,nModes);           
            mcaFactories     = cell(1,nModes);
            fgFactories      = cell(1,nModes);
            ipsiFactories    = cell(1,nModes);            
            contraFactories  = cell(1,nModes);
            grayFactories    = cell(1,nModes);
            deepFactories    = cell(1,nModes);            
            whiteFactories   = cell(1,nModes);
            bellumFactories  = cell(1,nModes);
            
            %% prepare rescaled metrics
            h15oMeanVoxels = nan;
            for m = 1:nModes 
                
                metricFactories{m} = BlockedRoisBuilder(metrics{m}, parenchymas{m} .* mcas{m} .* rights{m} .* whites{m});
                switch (m)
                    case 1
                        h15oMeanVoxels    = metricFactories{1}.meanVoxels;
                        h15oMeanVoxels    = h15oMeanVoxels{1};
                    case {3,4}                   
                        metricFactories{m}.roiLabels = {'contraNormalWhite'};
                        metricFactories{m} = metricFactories{m}.rescaleByReference(metricFactories{m}.theRois{1}, ...
                                                                                   h15oMeanVoxels);
                        metrics{m}         = metricFactories{m}.theMetric;
                end
                metricFactories{m}.printStats;
            end
            fprintf('\n\n');
            
            
            
            %% initialize modelOks, mcas, fg
            for m = 1:nModes
                fg             = modelOks{m} .* parenchymas{m} .* mcas{m};
                fg.fileprefix  = 'fg';
                modelokFactories{m} = BlockedRoisBuilder(metrics{m}, modelOks{m} .* parenchymas{m});
                modelokFactories{m}.roiLabels = repmat({'modelOk'}, size(modelokFactories{m}.roiLabels));
                modelokFactories{m}.printStats('modelok');
            end            
            fprintf('\n');
            for m = 1:nModes
                fg             = modelOks{m} .* parenchymas{m} .* mcas{m};
                fg.fileprefix  = 'fg';
                mcaFactories{m} = BlockedRoisBuilder(metrics{m}, mcas{m} .* modelOks{m});
                mcaFactories{m}.roiLabels = repmat({'mca'}, size(mcaFactories{m}.roiLabels));
                mcaFactories{m}.printStats('mca');
            end
            fprintf('\n');
            for m = 1:nModes
                fg             = modelOks{m} .* parenchymas{m} .* mcas{m};
                fg.fileprefix  = 'fg';
                fgFactories{m} = BlockedRoisBuilder(metrics{m}, fg);
                fgFactories{m}.roiLabels = repmat({'fg'}, size(fgFactories{m}.roiLabels));
                fgFactories{m}.printStats('fg');
            end
            fprintf('\n\n');         
            
            
            
            %% ipsi(modelOks), contra(modelOks)
            fprintf('modelOks:');
            for m = 1:nModes
                ipsiFactories{m} = BlockedRoisBuilder(metrics{m}, lefts{m});
                ipsiFactories{m} = ipsiFactories{m}.restrictAllRois(modelokFactories{m});
                ipsiFactories{m}.printStats(lefts{m}.label); 
            end
            fprintf('\n');
            fprintf('modelOks:');
            for m = 1:nModes
                contraFactories{m} = BlockedRoisBuilder(metrics{m}, rights{m});
                contraFactories{m} = contraFactories{m}.restrictAllRois(modelokFactories{m});
                contraFactories{m}.printStats(rights{m}.label); 
            end            
            fprintf('\n\n');
            
            %% ipsi(mcas), contra(mcas); reset ipsi/contra-factories
            fprintf('mcas:');
            for m = 1:nModes
                ipsiFactories{m} = BlockedRoisBuilder(metrics{m}, lefts{m});
                ipsiFactories{m} = ipsiFactories{m}.restrictAllRois(mcaFactories{m});
                ipsiFactories{m}.printStats(lefts{m}.label); 
            end
            fprintf('\n');
            fprintf('mcas:');
            for m = 1:nModes
                contraFactories{m} = BlockedRoisBuilder(metrics{m}, rights{m});
                contraFactories{m} = contraFactories{m}.restrictAllRois(mcaFactories{m});
                contraFactories{m}.printStats(rights{m}.label); 
            end            
            fprintf('\n\n');
                        
            %% ipsi(fg), contra(fg); reset ipsi/contra-factories
            fprintf('fg:');
            for m = 1:nModes
                ipsiFactories{m} = BlockedRoisBuilder(metrics{m}, lefts{m});
                ipsiFactories{m} = ipsiFactories{m}.restrictAllRois(fgFactories{m});
                ipsiFactories{m}.printStats(lefts{m}.label); 
            end
            fprintf('\n');
            fprintf('fg:');
            for m = 1:nModes
                contraFactories{m} = BlockedRoisBuilder(metrics{m}, rights{m});
                contraFactories{m} = contraFactories{m}.restrictAllRois(fgFactories{m});
                contraFactories{m}.printStats(rights{m}.label); 
            end            
            fprintf('\n\n');
            
            
            
            %% gray(fg), deep(fg), white(fg), bellum(fg); reset factories
            for m = 1:nModes 
                  grayFactories{m} = BlockedRoisBuilder(metrics{m}, grays{m});               
                  grayFactories{m} = grayFactories{m}.restrictAllRois(fgFactories{m});
                  grayFactories{m}.printStats(grays{m}.label, 'fg'); 
            end            
            fprintf('\n');
            for m = 1:nModes 
                  deepFactories{m} = BlockedRoisBuilder(metrics{m}, deepgrays{m});               
                  deepFactories{m} = deepFactories{m}.restrictAllRois(fgFactories{m});
                  deepFactories{m}.printStats(deepgrays{m}.label, 'fg'); 
            end            
            fprintf('\n');
            for m = 1:nModes 
                 whiteFactories{m} = BlockedRoisBuilder(metrics{m}, whites{m});               
                 whiteFactories{m} = whiteFactories{m}.restrictAllRois(fgFactories{m});
                 whiteFactories{m}.printStats(whites{m}.label, 'fg'); 
            end            
            fprintf('\n');
            for m = 1:nModes 
                bellumFactories{m} = BlockedRoisBuilder(metrics{m}, Cerebellums{m});               
                bellumFactories{m} = bellumFactories{m}.restrictAllRois(fgFactories{m});
                bellumFactories{m}.printStats(Cerebellums{m}.label, 'fg'); 
            end            
            fprintf('\n\n');
            
            %% gray(ipsi), deep(ipsi), white(ipsi), bellum(ipsi); reset factories
            for m = 1:nModes   
                  grayFactories{m} = BlockedRoisBuilder(metrics{m}, grays{m});            
                  grayFactories{m} = grayFactories{m}.restrictAllRois(ipsiFactories{m});
                  grayFactories{m}.printStats(grays{m}.label, 'ipsi'); 
            end            
            fprintf('\n');
            for m = 1:nModes  
                  deepFactories{m} = BlockedRoisBuilder(metrics{m}, deepgrays{m});              
                  deepFactories{m} = deepFactories{m}.restrictAllRois(ipsiFactories{m});
                  deepFactories{m}.printStats(deepgrays{m}.label, 'ipsi'); 
            end            
            fprintf('\n');
            for m = 1:nModes
                 whiteFactories{m} = BlockedRoisBuilder(metrics{m}, whites{m});              
                 whiteFactories{m} = whiteFactories{m}.restrictAllRois(ipsiFactories{m});
                 whiteFactories{m}.printStats(whites{m}.label, 'ipsi'); 
            end            
            fprintf('\n');
            for m = 1:nModes    
                bellumFactories{m} = BlockedRoisBuilder(metrics{m}, Cerebellums{m});          
                bellumFactories{m} = bellumFactories{m}.restrictAllRois(ipsiFactories{m});
                bellumFactories{m}.printStats(Cerebellums{m}.label, 'ipsi'); 
            end            
            fprintf('\n\n');            
           
            %% gray(contra), deep(contra), white(contra), bellum(contra); reset factories
            for m = 1:nModes    
                  grayFactories{m} = BlockedRoisBuilder(metrics{m}, grays{m});           
                  grayFactories{m} = grayFactories{m}.restrictAllRois(contraFactories{m});
                  grayFactories{m}.printStats(grays{m}.label, 'contra'); 
            end            
            fprintf('\n');
            for m = 1:nModes    
                  deepFactories{m} = BlockedRoisBuilder(metrics{m}, deepgrays{m});            
                  deepFactories{m} = deepFactories{m}.restrictAllRois(contraFactories{m});
                  deepFactories{m}.printStats(deepgrays{m}.label, 'contra'); 
            end            
            fprintf('\n');
            for m = 1:nModes    
                 whiteFactories{m} = BlockedRoisBuilder(metrics{m}, whites{m});          
                 whiteFactories{m} = whiteFactories{m}.restrictAllRois(contraFactories{m});
                 whiteFactories{m}.printStats(whites{m}.label, 'contra'); 
            end            
            fprintf('\n');           
            for m = 1:nModes  
                bellumFactories{m} = BlockedRoisBuilder(metrics{m}, Cerebellums{m});             
                bellumFactories{m} = bellumFactories{m}.restrictAllRois(contraFactories{m});
                bellumFactories{m}.printStats(Cerebellums{m}.label, 'contra'); 
            end            
            fprintf('\n\n');
            
        end % tabulateModalRois
        function fp  = toFileprefix(nii)
            
            %% TOFILEPREFIX converts fileprefixes or NIfTIs to well-formed fileprefixes
            import mlfourd.*;
            if (iscell(nii))
                fp = cell(1,length(nii));
                for f = 1:length(nii)
                    fp{f} = BlockedRoisBuilder.toNIfTI(nii{f});
                end
            else
                if (isa(nii, 'mlfourd.NIfTIInterface'))
                    fp = nii.fileprefix;
                elseif (ischar(nii))
                    fp = fileprefix(nii);
                else
                    error('mlfourd:UnsupportedType', 'class(nii)->%s', class(nii));
                end
            end
        end        
        function nii = toNIfTI(fp)
            
            %% TONIFTI converts fileprefixes or NIfTIs to well-formed NIfTIs
            import mlfourd.*;
            if (iscell(fp))
                nii = cell(1,length(fp));
                for f = 1:length(fp)
                    nii{f} = BlockedRoisBuilder.toNIfTI(fp{f});
                end
            else
                if (ischar(fp))
                    nii = NIfTI.load(fp);
                elseif (isa(fp, 'mlfourd.NIfTIInterface'))
                    nii = NIfTI(fp);
                elseif (isa(fp, 'mlfourd.BlockedRoisBuilder'))
                    nii = NIfTI(fp.intersectionRois);
                else
                    error('mlfourd:UnsupportedType', 'class(fp)->%s', class(fp));
                end
            end
        end
    end 
    
    methods %% GET/SET
        function lbl  = get.metricLabel(this)
            lbl = this.theMetric.label;
        end
        function lbls = get.roiLabels(this)
            Nrois = numel(this.theRois);
            lbls  = cell(1,Nrois);
            for r = 1:Nrois
                lbls{r} = this.theRois{r}.label;
            end
        end
        function this = set.roiLabels(this, lbls)
            Nrois = numel(this.theRois);
            assert(Nrois == length(lbls));
            for r = 1:Nrois
                this.theRois{r}.label = lbls{r};
            end
        end
    end
    
    methods 
        function vecs = sampleVoxels(this, choice)
            
            %% SAMPLEVOXELS samples metric-voxels with some or all internal ROIs
            import mlfourd.*;            
            niib = NiiBrowser(this.theMetric);
            switch (nargin)
                case 1
                    vecs = cell(1,length(this.theRois));
                    for v = 1:length(vecs)
                        vecs{v} = niib.sampleVoxels(this.theRois{v});
                    end
                case 2
                    v = 1;
                    if (ischar(choice))
                        for r = 1:length(this.theRois)
                            if (lstrfind(this.theRois{r}.label, choice))
                                v = r; break;
                            end
                        end
                    else
                        assert(isnumeric(choice));
                        v = choice;
                    end
                    vecs = ensureCell(niib.sampleVoxels(this.theRois{v}));
            end
        end % sampleVoxels
        function n    = nVoxels(this, choice)
            switch (nargin)
                case 1
                    sv = this.sampleVoxels;
                case 2
                    sv = this.sampleVoxels(choice);
            end
            sv = ensureCell(sv);
            n = cell(1,length(sv));
            for nidx = 1:numel(n)
                n{nidx} = numel(sv{nidx});
            end
        end
        function m    = meanVoxels(this, choice)
            switch (nargin)
                case 1
                    sv = this.sampleVoxels;
                case 2
                    sv = this.sampleVoxels(choice);
            end
            m = cell(size(sv));
            for midx = 1:numel(m)
                m{midx} = mean(sv{midx});
            end
        end
        function s    = stdVoxels(this, choice)
            sv = this.sampleVoxels(choice);
            if (iscell(sv)); sv = sv{1}; end
            s = std(sv);
        end
        function        printStats(this, choice, lbl)
            chstr = 1; 
            if (nargin > 1)
                if (isnumeric(choice))
                    chstr = ['roi#' num2str(choice)];
                else
                    chstr = char(choice);
                end
            end
            if (nargin > 2)
                chstr = [chstr '(x)' lbl];
            end
            fprintf('%s(x)%s: \t %s \t %s \t %s; \t', ...
                this.metricLabel, chstr, ...
                cell2str(this.nVoxels(   chstr)), ...
                cell2str(this.meanVoxels(chstr)), ...
                cell2str(this.stdVoxels( chstr)));
        end
    end
    
    %% PROTECTED
    
    methods (Access = 'protected')        
        function this = BlockedRoisBuilder(metric, rois)
            
            %% CTOR
            %  Usage: this = mlfourd.BlockedRoisBuilder(metric [, rois])
            %         ^ Builder                 ^         ^ fileprefixes or NIfTIs
            import mlfourd.*;
            if (nargin > 0)
                this.theMetric = BlockedRoisBuilder.toNIfTI(metric);
            end
            if (nargin > 1)
                        rois = ensureCell(        rois);
                this.theRois = BlockedRoisBuilder.toNIfTI(rois);
            end
        end % ctor
        function this = load(this, object)
            
            %% LOAD appends object, converted to NIfTI, to this.theRois
            import mlfourd.*;            
            nNiis0 = length(this.theRois);
            object = ensureCell(object);
            for o = 1:length(object)
                this.theRois{nNiis0 + o} = BlockedRoisBuilder.toNIfTI(object{o});
            end
        end % load        
        function this = restrictAllRois(this, fg)
            
            import mlfourd.*;
            fg = BlockedRoisBuilder.toNIfTI(fg);
            for n = 1:length(this.theRois)
                tmp = this.theRois{n};
                tmp = fg .* tmp;
                tmp.fileprefix = [fg.fileprefix '(x)' this.theRois{n}.fileprefix];
                this.theRois{n} = tmp;
            end
        end % restrictAllRois        
        function iroi = intersectionRois(this)
            iroi = this.theMetric.ones;
            for r = 1:length(this.theRois)
                iroi = iroi .* this.theRois{r};
            end
        end        
        function this = intersectNbyM(this, miis)
            
            %% INTERSECTNBYM intersects all this.theRois with the intersection of all miis,
            %  placing the product of intersections back in this.theRois
            import mlfourd.*;
            miis = ensureCell(miis);
            for n = 1:length(this.theRois)
                for m = 1:length(miis)
                    miis{m} = BlockedRoisBuilder.toNIfTI(miis{m});
                    tmp = this.theRois{n};
                    tmp = miis{m} .* tmp;
                    tmp.fileprefix = [miis{m}.fileprefix '(x)' this.theRois{n}.fileprefix];
                    this.theRois{n} = tmp;
                end
            end
        end  % intersectNbyM        
        function this = rescaleByReference(this, refRoi, refMean)
            
            %% RESCALEBYREFERENCE
            import mlfourd.*;
            metricb     = NiiBrowser(this.theMetric);
            metricMean  = mean(metricb.sampleVoxels(refRoi));
            this.theMetric = this.theMetric .* (refMean/metricMean);
            this.theMetric.fileprefix = [this.theMetric.fileprefix '_scaled2ref'];
        end
    end 
    
end % classdef BlockedRoisBuilder


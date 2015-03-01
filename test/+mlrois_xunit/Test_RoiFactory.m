% TEST_ROIFACTORY tests methods used to create ROIs
%
% Instantiation:
%		runner = mlunit.text_test_runner(1, verbosity); % verbosity has values 0..1
%		loader = mlunit.test_loader;
%		run(runner, load_tests_from_test_case(loader, 'mlfourd_xunit.Test_RoiFactory'))
%
% See Also:
%		help text_test_runner
%		http://mlunit.dohmke.de/Main_Page
%		http://mlunit.dohmke.de/Unit_Testing_With_MATLAB
%		thomi@users.sourceforge.net
%
% Created by John Lee on 2009-02-09.
% Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
% Report bugs to <email="bugs.perfusion.neuroimage.wustl.edu@gmail.com"/>.

classdef Test_RoiFactory < mlunit.test_case
    
    properties
        pnum        = 'p7377';
        aRoiFactory = 0;
        petcbfStem  = '';
        fg          = '';
        arteries    = 'arteries';
        csf         = 'csf';
        parenchyma  = 'parenchyma';
        grey        = 'grey';
        white       = 'white';
        roisuff     = '';
        imaging       = 0;
        tol         = 0.05;
        datenow     = '';
        niis        = {};
        coverage    = 0.00667; % fractional coverage of arterial masks
        %torun       = [0 0 0 0 0 0 0 0 1]; 
        torun       = [0 0 0 0 1 0 0 0]; 
        %torun       = [0 1 1 0 0 0 0 0];  
        blockSz     = [];
        blur        = [];
        flipEpiY    = true;
        deprecated
    end % properties

    methods

        %%  CTOR
        function obj = Test_RoiFactory(varargin)
            
            import mlfourd.* mlpet.*;
            obj            = obj@mlunit.test_case(varargin{:});
            obj.pldr       = PETBuilder;
            obj.datenow    = datestr(now, 29);
            obj.petcbfStem = ['petcbf' obj.pbldr.pet_ref_series NIfTIInterface.FILETYPE_EXT];
            obj.fg         = ['fg'     obj.pbldr.ref_series     NIfTIInterface.FILETYPE_EXT];
            obj.roisuff    = [         obj.pbldr.ref_series     NIfTIInterface.FILETYPE_EXT];
            obj.blockSz    = obj.pbldr.blockSize;
            obj.blur       = PETBuilder.petPointSpread;
            obj.deprecated = mlfsl.DeprecatedImagingFeatures.instance;
        end % ctor
        
         %% TEST_MAKEMLEMCBF
		function obj = test_makeMlemCbf(obj)
            if (~obj.torun(8)); return; end;
			import mlfourd.*;
            
            mlemcbfnii = NIfTI.load([obj.pbldr.mr_path ...
               'SHIMONY_CBF_MLEM_LOGFRACTAL_VONKEN_LOWPASS' ...
                mlemVersion(obj.pbldr.pnum) ...
                mlemDate(   obj.pbldr.pnum) ...
                '.4dfp']);
            disp('please examine the dip_image for mlemcbfnii.img..........'); 
            dipshow(dip_image(mlemcbfnii.img), 'percentile', 'grey')
            mlemcbfniib  = NiiBrowser(mlemcbfnii,   obj.blur);
            mlemcbfniib.save(fullfile(obj.pbldr.mr_path, 'mlemcbf.nii.gz'));
            mlemcbfniibb = mlemcbfniib.blockBrowser(obj.blockSz);
            %mlemcbfniibb.save(fullfile(obj.pbldr.mr_path, ['mlemcbf' obj.blockSuff]));
            disp(['test_makeBlocNiis:  showing mlemcbfniibb.nii.img']);
            dipshow(dip_image(mlemcbfniibb.nii.img), 'percentile', 'grey')
        end
        
        %% TEST_CBFIMAGES
        function obj = test_cbfImages(obj)
            if (~obj.torun(7)); return; end;
            import mlfourd.*;
            pet_nii   = NIfTI.load([obj.pbldr.pet_path 'petcbf.nii.gz']);
            pet_bnii  = NIfTI.load([obj.pbldr.pet_path 'petcbf' obj.pbldr.block_suffix NIfTIInterface.FILETYPE_EXT]);
            laif_nii  = NIfTI.load([obj.pbldr.patient_path '4dfp/F_mean_xr3d.4dfp.nii.gz']);
            mlem_nii  = NIfTI.load((getMlemFilename(obj.pbldr.pnum2vnum(obj.pbldr.pnum), 'cbf'));
            laif_bnii = NIfTI.load([obj.pbldr.mr_path 'laifcbf' obj.pbldr.block_suffix NIfTIInterface.FILETYPE_EXT]);
            mlem_bnii = NIfTI.load([obj.pbldr.mr_path 'mlemcbf' obj.pbldr.block_suffix NIfTIInterface.FILETYPE_EXT]);
            dipshow(dip_image(pet_nii.img),   'lin')
            diptruesize
            dipshow(dip_image(pet_bnii.img),  'lin')
            diptruesize
            dipshow(dip_image(laif_nii.img),  'lin')
            diptruesize
            dipshow(dip_image(laif_bnii.img), 'lin')
            diptruesize
            dipshow(dip_image(mlem_nii.img),  'lin')
            diptruesize
            dipshow(dip_image(mlem_bnii.img), 'lin')
            diptruesize
        end
        
        %% TEST_CHECKSUMS
        function obj = test_checkSums(obj)
            if (~obj.torun(6)); return; end;
            [fg_nii  fg_bnii ] = obj.checkSums(obj.fg);
            [art_nii art_bnii] = obj.checkSums(obj.arteries);
            [csf_nii csf_bnii] = obj.checkSums(obj.csf);
            [par_nii par_bnii] = obj.checkSums(obj.parenchyma);
            dipshow(dip_image(fg_nii.img  + 1.1*par_nii.img  + 2.2*csf_nii.img  + 1.3*art_nii.img ), 'lin', 'saturation')
            diptruesize
            dipshow(dip_image(fg_bnii.img + 1.1*par_bnii.img + 2.2*csf_bnii.img + 1.3*art_bnii.img), 'lin', 'saturation')
            diptruesize
        end
        
        %% CHECKSUMS
        function [nii bnii] = checkSums(obj, filestem)
            import mlfourd.*;
            nii  = NIfTI.load([obj.pbldr.roi_path ...
                   strrep(filestem, [obj.pbldr.block_suffix '.4dfp.nii.gz'], '') '.4dfp.nii.gz']);
            bnii = NIfTI.load([obj.pbldr.roi_path filestem]);
            sigma1 = sum(dip_image( nii.img));
            sigma2 = sum(dip_image(bnii.img))*prod(obj.blockSz);
            assert(abs(sigma1 - sigma2)/abs(min(sigma1,sigma2)) < obj.tol, ...
                 ['checkSums on ' filestem ':  sigma1 -> ' num2str(sigma1) ', sigma2 -> ' num2str(sigma2)]);            
        end   
        
        %% MAKEBLOCKNII
        function nii = makeBlockNii(obj, fqfn, fqfnb)
            import mlfourd.*;
            nii   = NIfTI.load((fqfn);
            disp(['please examine dip_image of ' fqfn '..........']); 
            dipshow(dip_image( nii.img), 'percentile', 'grey')
            niib  = NiiBrowser(nii,   obj.pbldr.baseBlur);
            niibb = niib.blockBrowser(obj.pbldr.blockSize);
            niibb.save(fqfnb);
            disp(['makeBlocNii:  showing niibb.nii.img based on ' fqfn]);
            dipshow(dip_image(   niibb.nii.img), 'percentile', 'grey')
        end % function test_makeBlockNii
        
        %% SAVEASBLOCKNII
        function saveAsBlockNii(obj, nii, fqfn)
            import mlfourd.*;
            disp(['please examine dip_image of nii.img from ' nii.fileprefix '..........']); 
            dipshow(dip_image(nii.img), 'percentile', 'grey')
            niib  = NiiBrowser(nii, obj.pbldr.baseBlur);
            niibb = niib.blockBrowser(obj.pbldr.blockSize);
            niibb.save(fqfn);
            disp(['saveAsBlockNii:  showing niibb.nii.img from ' nii.fileprefix]);
            dipshow(dip_image(niibb.nii.img), 'percentile', 'grey')
        end % function saveAsBlockNii
        
        %% TEST_MAKEBLOCKNIIS2
		function obj = test_makeBlockNiis2(obj)
            if (~obj.torun(5)); return; end;
			import mlfourd.*;
            
            fgnii           = NIfTI.load(      obj.pbldr.fg_filename);
            fgniibb         = obj.makeBlockNii(obj.pbldr.fg_filename,         obj.pbldr.fg_filename(        true, true));            
            petcbfniibb     = obj.makeBlockNii(obj.pbldr.pet_filename('cbf'), obj.pbldr.pet_filename('cbf', true, true)); 
                            % mlpet.PETBuilder.PETfactory(obj.pnum, 'cbf');
            parenchymaNiibb = obj.makeBlockNii(obj.pbldr.parenchyma_filename, obj.pbldr.parenchyma_filename(true, true)); 
            greyNiibb       = obj.makeBlockNii(obj.pbldr.grey_filename,       obj.pbldr.grey_filename(      true, true));            
            whiteNiibb      = obj.makeBlockNii(obj.pbldr.white_filename,      obj.pbldr.white_filename(     true, true));
            csfniibb        = obj.makeBlockNii(obj.pbldr.csf_filename,        obj.pbldr.csf_filename(       true, true));
            artnii          = obj.makeBlockNii(obj.pbldr.art_filename,        obj.pbldr.art_filename(       true, true));
            
            qstruct   = load(obj.deprecated.jessy_filename);
            if (obj.flipEpiY)
                qimg  = flip4d(flip4d(qstruct.images{14}, 't'), 'y'); % 14 or 16
            else
                qimg  = flip4d(qstruct.images{14}, 't');              % 14 or 16
            end
            qcbfnii   = fgnii.makeSimilar(qimg, ['MR qCBF, patient ' obj.pbldr.pnum]);
            qcbfnii.save(fullfile(obj.pbldr.mr_path, 'qcbf.nii.gz'));
            obj.saveAsBlockNii(  qcbfnii, [obj.pbldr.mr_path 'qcbf' obj.blockSuff '.nii.gz']);
            if (obj.flipEpiY)
                simg  = flip4d(flip4d(qstruct.images{2}, 't'), 'y');
            else
                simg  = flip4d(qstruct.images{2}, 't');
            end
            scbfnii   = fgnii.makeSimilar(simg, ['MR SVD CBF, patient ' obj.pbldr.pnum]);
            scbfnii.save(fullfile(obj.pbldr.mr_path, 'scbf.nii.gz'));
            obj.saveAsBlockNii(  scbfnii, [obj.pbldr.mr_path 'scbf' obj.blockSuff '.nii.gz']);
                        
            %system(['cd ' obj.pbldr.mr_path]);
            %system('list=$(echo *.hdr); for h in $list; do fslchfiletype NIFTI_GZ $h; done');
            %system('gzip *.nii')
		end % function makeBlockNiis2
        
               
        
        %% TEST_MAKEBLOCKNIIS
		function obj = test_makeBlockNiis(obj)
            if (~obj.torun(4)); return; end;
			import mlfourd.*;
            
            petcbfnii = NIfTI.load([obj.pbldr.pet_path obj.petcbfStem]);
                        % mlpet.PETBuilder.PETfactory(obj.pnum, 'cbf');
            disp('please examine the dip_image for petcbfnii.img..........'); 
            dipshow(dip_image(petcbfnii.img), 'percentile', 'grey')
            petcbfniib  = NiiBrowser(petcbfnii,   obj.blur);
            petcbfniibb = petcbfniib.blockBrowser(obj.blockSz);
            petcbfniibb.save(fullfile(obj.pbldr.pet_path, ['petcbf' obj.blockSuff]));
            disp(['test_makeBlocNiis:  showing petcbfniibb.nii.img']);
            dipshow(dip_image(petcbfniibb.nii.img), 'percentile', 'grey')
            
            mlemcbfnii = NIfTI.load([obj.pbldr.mr_path ...
               'SHIMONY_CBF_MLEM_LOGFRACTAL_VONKEN_LOWPASS' ...
                mlemVersion(obj.pbldr.pnum) ...
                mlemDate(   obj.pbldr.pnum) ...
                '.4dfp']);
            disp('please examine the dip_image for mlemcbfnii.img..........'); 
            dipshow(dip_image(mlemcbfnii.img), 'percentile', 'grey')
            mlemcbfniib  = NiiBrowser(mlemcbfnii,   obj.blur);
            mlemcbfniibb = mlemcbfniib.blockBrowser(obj.blockSz);
            mlemcbfniibb.save([obj.pbldr.mr_path 'mlemcbf' obj.blockSuff]);
            disp(['test_makeBlocNiis:  showing mlemcbfniibb.nii.img']);
            dipshow(dip_image(mlemcbfniibb.nii.img), 'percentile', 'grey')
            
            laifcbfnii   = NIfTI.load([obj.pbldr.patient_path 'Bayes/F_mean_xr3d.4dfp']);
            disp('please examine the dip_image for laifcbfnii.img..........'); 
            dipshow(dip_image(laifcbfnii.img), 'percentile', 'grey')
            laifcbfniib  = NiiBrowser(laifcbfnii,   obj.blur);
            laifcbfniibb = laifcbfniib.blockBrowser(obj.blockSz);
            laifcbfniibb.save(fullfile(obj.pbldr.mr_path, ['laifcbf' obj.blockSuff]));
            disp(['test_makeBlocNiis:  showing laifcbfniibb.nii.img']);
            dipshow(dip_image(laifcbfniibb.nii.img), 'percentile', 'grey')
            
            fgnii   = NIfTI.load((obj.pbldr.fg_filename(true));
            disp('please examine the dip_image for fgnii.img..........'); 
            dipshow(dip_image(fgnii.img), 'percentile', 'grey')
            fgniib  = NiiBrowser(fgnii,   obj.blur);
            fgniibb = fgniib.blockBrowser(obj.blockSz);
            Nfgniibb.save([obj.pbldr.fg_filename obj.blockSuff ]);
            disp(['test_makeBlocNiis:  showing fgniibb.nii.img']);
            dipshow(dip_image(fgniibb.nii.img), 'percentile', 'grey')
            
            parenchymaNii   = NIfTI.load([obj.pbldr.roi_path obj.parenchyma obj.pbldr.ref_series '.nii.gz']);
            disp('please examine the dip_image for parenchymaNii.img..........'); 
            dipshow(dip_image(parenchymaNii.img), 'percentile', 'grey')
            parenchymaNiib  = NiiBrowser(parenchymaNii,   obj.blur);
            parenchymaNiibb = parenchymaNiib.blockBrowser(obj.blockSz);
            parenchymaNiibb.save([obj.pbldr.roi_path obj.parenchyma obj.pbldr.ref_series obj.blockSuff]);
            disp(['test_makeBlocNiis:  showing parenchymaNiibb.nii.img']);
            dipshow(dip_image(parenchymaNiibb.nii.img), 'percentile', 'grey')
            
            csfnii   = NIfTI.load([obj.pbldr.csf_filename]);
            disp('please examine the dip_image for csfnii.img..........');
            dipshow(dip_image(csfnii.img), 'percentile', 'grey')
            csfniib  = NiiBrowser(csfnii,   obj.blur);
            csfniibb = csfniib.blockBrowser(obj.blockSz);
            csfniibb.save([obj.pbldr.csf_filename obj.blockSuff ]);            
            disp(['test_makeBlocNiis:  showing csfniibb.nii.img']);
            dipshow(dip_image(csfniibb.nii.img), 'percentile', 'grey')
            
            artnii   = NIfTI.load([obj.pbldr.art_filename]);
            disp('please examine the dip_image for artnii.img..........'); 
            dipshow(dip_image(artnii.img), 'percentile', 'grey')
            artniib  = NiiBrowser(artnii,   obj.blur);
            artniibb = artniib.blockBrowser(obj.blockSz);   
            artniibb.save([obj.pbldr.art_filename obj.blockSuff ]);          
            disp(['test_makeBlocNiis:  showing artniibb.nii.img']);
            dipshow(dip_image(artniibb.nii.img), 'percentile', 'grey')

		end % function test_makeBlockNiis
        
        
        %% TEST_MAKEROINIIS generates some commonly useful ROIs
		function obj = test_makeRoiNiis(obj)
            if (~obj.torun(3)); return; end;
			import mlfourd.*;            
            
            % read fg, art NIfTIs presumed to exist
            fgnii  = NIfTI.load(obj.pbldr.fg_filename(true));
            artnii = NIfTI.load(obj.pbldr.art_filename(true));
            fgnii1 = fgnii.makeSimilar( ...
                       fgnii.img                +   artnii.img, ...
                      [fgnii.hdr.hist.descrip ' + ' artnii.hdr.hist.descrip]);
            fnames = { ...
                 obj.pbldr.csf_filename, ...
                [obj.pbldr.roi_path 'white'       obj.roisuff], ...
                [obj.pbldr.roi_path 'grey'        obj.roisuff]};
			labels = {             obj.csf,  ...
                                   'white'    ...
                                   'grey'};
            descrips = {['ROIs Xr3d ' obj.csf]...
                         'ROIs Xr3d white'    ...
                         'ROIs Xr3d grey'};
                     
            % make artnii mutually exclusive of NIFTIS with labels
            % obj.csf, putamen, caudate, thalamus, white, grey, hippocampus 
            obj.niis = RoiFactory.makeRoiNiis(fgnii1, fnames, labels, descrips);
            for p = 1:length(obj.niis)
                niis1       = cell(2,1);
                niis1{1}    = artnii;
                niis1{2}    = obj.niis{p};
                niis1       = RoiFactory.makeBinaryRoisMutuallyExclusive(fgnii1, niis1);
                obj.niis{p} = niis1{2};
            end
                       
            % parenchyma ROI
            parenchymaimg = zeros(size(obj.niis{1}.img));
            for q = 1:length(obj.niis)
                if (0 == numel(findstr(obj.csf,      labels{q})) && ...
                    0 == numel(findstr(obj.arteries, labels{q})) && ...
                    0 == numel(findstr(obj.fg,       labels{q})))
                    parenchymaimg = parenchymaimg + obj.niis{q}.img; 
                end
            end
            parenchymanii = fgnii.makeSimilar( ...
                 parenchymaimg, ['ROIs Xr3d ' obj.parenchyma]);    
            obj.niis{1}.save([obj.pbldr.csf_filename ]);
            obj.niis{2}.save([obj.pbldr.white_filename ]);
            obj.niis{3}.save([obj.pbldr.grey_filename ]);
            parenchymanii.save([obj.pbldr.roi_path obj.parenchyma obj.pbldr.ref_series NIfTIInterface.FILETYPE_EXT ]);
            artnii.save([obj.pbldr.art_filename ]);
            fgnii1.save([obj.pbldr.fg_filename ]);
            
            % check ROIs & union of ROIs
                union = dip_image(zeros(size(fgnii1.img)));
            for s = 1:length(obj.niis)
                disp(['please examine the dip_image for ' descrips{s} '..........']);
                dipshow(        dip_image(obj.niis{s}.img), 'percentile', 'grey')
                union = union + dip_image(obj.niis{s}.img);
            end
                disp(['please examine the dip_image for ' obj.fg ' ..........']);
                dipshow(dip_image(fgnii1.img), 'percentile', 'grey')
                disp(['please examine the dip_image for ' obj.parenchyma ' ..........']);          
                dipshow(dip_image(parenchymanii.img), 'percentile', 'grey')
                disp(['please examine the dip_image for ' obj.arteries ' ..........']);          
                dipshow(dip_image(artnii.img), 'percentile', 'grey')                
                disp('please examine the union of dip_images ..........');
                union
		end % function test_makeRoiNiis
        
        %% TEST_MAKEARTERIES generates an ROI for arteries
        function obj = test_makeArteriesRoi(obj)
            if (~obj.torun(2)); return; end;
            import mlfourd.*;            
            epinii = NIfTI.load((obj.pbldr.epi_filename(true));
            if (obj.flipEpiY)
                epinii.img = flip4d(epinii.img, 'y'); end
            fgnii  = NIfTI.load((obj.pbldr.fg_filename(true));            
            artnii = mlfourd.RoiFactory.make_arteriesRoi(epinii, fgnii);
            artnii = mlfourd.RoiFactory.thresholdRoi_coverage(artnii, obj.coverage);
            dipshow(dip_image(epinii.img), 'percentile', 'grey')
            dipshow(dip_image(fgnii.img),  'percentile', 'grey')
            dipshow(dip_image(artnii.img), 'percentile', 'grey')
            artnii.save(obj.pbldr.art_filename(true));
        end % function test_makeArteriesRoi
        
        %% TEST_NULL assures that mlunit.assert functions are working correctly
        function obj = test_null(obj)
            if (~obj.torun(1)); return; end;
            mlunit.assert_equals(0, 0);
        end % function test_null
        
        %% BLOCKSTEM
        function stm = blockSuff(obj)
            stm = ['_' num2str(obj.blockSz(1)) 'x' num2str(obj.blockSz(2)) 'x' num2str(obj.blockSz(3))];
        end
    end % methods
end

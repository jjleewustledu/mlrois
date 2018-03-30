classdef Test_BlockedRoisBuilder < mlrois_xunit.Test_mlrois 
	%% TEST_ROIBUILDER 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_BlockedRoisBuilder % in . or the matlab path 
 	%          >> runtests Test_BlockedRoisBuilder:test_nameoffunc 
 	%          >> runtests(Test_BlockedRoisBuilder, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	
    %  Version $Revision: 2537 $ was created $Date: 2013-08-18 18:06:07 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 18:06:07 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlrois/test/+mlrois_xunit/trunk/Test_BlockedRoisBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_BlockedRoisBuilder.m 2537 2013-08-18 23:06:07Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties
        pnum        = 'p7377';
        aBlockedRoisBuilder = 0;
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

        %% TEST_MAKEMLEMCBF
		function this = test_makeMlemCbf(this)
            if (~this.torun(8)); return; end;
			import mlfourd.*;
            
            mlemcbfnii = NIfTI.load([this.pbldr.mr_path ...
               'SHIMONY_CBF_MLEM_LOGFRACTAL_VONKEN_LOWPASS' ...
                mlemVersion(this.pbldr.pnum) ...
                mlemDate(   this.pbldr.pnum) ...
                '.4dfp']);
            disp('please examine the dip_image for mlemcbfnii.img..........'); 
            dipshow(dip_image(mlemcbfnii.img), 'percentile', 'grey')
            mlemcbfniib  = NiiBrowser(mlemcbfnii,   this.blur);
            mlemcbfniib.save(fullfile(this.pbldr.mr_path, 'mlemcbf.nii.gz'));
            mlemcbfniibb = mlemcbfniib.blockBrowser(this.blockSz);
            %mlemcbfniibb.save(fullfile(this.pbldr.mr_path, ['mlemcbf' this.blockSuff]));
            disp(['test_makeBlocNiis:  showing mlemcbfniibb.nii.img']);
            dipshow(dip_image(mlemcbfniibb.nii.img), 'percentile', 'grey')
        end
        
        %% TEST_CBFIMAGES
        function this = test_cbfImages(this)
            if (~this.torun(7)); return; end;
            import mlfourd.*;
            pet_nii   = NIfTI.load([this.pbldr.pet_path 'petcbf.nii.gz']);
            pet_bnii  = NIfTI.load([this.pbldr.pet_path 'petcbf' this.pbldr.block_suffix NIfTIInterface.FILETYPE_EXT]);
            laif_nii  = NIfTI.load([this.pbldr.patient_path '4dfp/F_mean_xr3d.4dfp.nii.gz']);
            mlem_nii  = NIfTI.load((getMlemFilename(this.pbldr.pnum2vnum(this.pbldr.pnum), 'cbf'));
            laif_bnii = NIfTI.load([this.pbldr.mr_path 'laifcbf' this.pbldr.block_suffix NIfTIInterface.FILETYPE_EXT]);
            mlem_bnii = NIfTI.load([this.pbldr.mr_path 'mlemcbf' this.pbldr.block_suffix NIfTIInterface.FILETYPE_EXT]);
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
        
        function this = test_checkSums(this)
            if (~this.torun(6)); return; end;
            [fg_nii  fg_bnii ] = this.checkSums(this.fg);
            [art_nii art_bnii] = this.checkSums(this.arteries);
            [csf_nii csf_bnii] = this.checkSums(this.csf);
            [par_nii par_bnii] = this.checkSums(this.parenchyma);
            dipshow(dip_image(fg_nii.img  + 1.1*par_nii.img  + 2.2*csf_nii.img  + 1.3*art_nii.img ), 'lin', 'saturation')
            diptruesize
            dipshow(dip_image(fg_bnii.img + 1.1*par_bnii.img + 2.2*csf_bnii.img + 1.3*art_bnii.img), 'lin', 'saturation')
            diptruesize
        end

		function this = test_makeBlockNiis2(this)
            if (~this.torun(5)); return; end;
			import mlfourd.*;
            
            fgnii           = NIfTI.load(      this.pbldr.fg_filename);
            fgniibb         = this.makeBlockNii(this.pbldr.fg_filename,         this.pbldr.fg_filename(        true, true));            
            petcbfniibb     = this.makeBlockNii(this.pbldr.pet_filename('cbf'), this.pbldr.pet_filename('cbf', true, true)); 
                            % mlpet.PETBuilder.PETfactory(this.pnum, 'cbf');
            parenchymaNiibb = this.makeBlockNii(this.pbldr.parenchyma_filename, this.pbldr.parenchyma_filename(true, true)); 
            greyNiibb       = this.makeBlockNii(this.pbldr.grey_filename,       this.pbldr.grey_filename(      true, true));            
            whiteNiibb      = this.makeBlockNii(this.pbldr.white_filename,      this.pbldr.white_filename(     true, true));
            csfniibb        = this.makeBlockNii(this.pbldr.csf_filename,        this.pbldr.csf_filename(       true, true));
            artnii          = this.makeBlockNii(this.pbldr.art_filename,        this.pbldr.art_filename(       true, true));
            
            qstruct   = load(this.deprecated.jessy_filename);
            if (this.flipEpiY)
                qimg  = flip4d(flip4d(qstruct.images{14}, 't'), 'y'); % 14 or 16
            else
                qimg  = flip4d(qstruct.images{14}, 't');              % 14 or 16
            end
            qcbfnii   = fgnii.makeSimilar(qimg, ['MR qCBF, patient ' this.pbldr.pnum]);
            qcbfnii.save(fullfile(this.pbldr.mr_path, 'qcbf.nii.gz'));
            this.saveAsBlockNii(  qcbfnii, [this.pbldr.mr_path 'qcbf' this.blockSuff '.nii.gz']);
            if (this.flipEpiY)
                simg  = flip4d(flip4d(qstruct.images{2}, 't'), 'y');
            else
                simg  = flip4d(qstruct.images{2}, 't');
            end
            scbfnii   = fgnii.makeSimilar(simg, ['MR SVD CBF, patient ' this.pbldr.pnum]);
            scbfnii.save(fullfile(this.pbldr.mr_path, 'scbf.nii.gz'));
            this.saveAsBlockNii(  scbfnii, [this.pbldr.mr_path 'scbf' this.blockSuff '.nii.gz']);
                        
            %system(['cd ' this.pbldr.mr_path]);
            %system('list=$(echo *.hdr); for h in $list; do fslchfiletype NIFTI_GZ $h; done');
            %system('gzip *.nii')
		end % function makeBlockNiis2
		function this = test_makeBlockNiis(this)
            if (~this.torun(4)); return; end;
			import mlfourd.*;
            
            petcbfnii = NIfTI.load([this.pbldr.pet_path this.petcbfStem]);
                        % mlpet.PETBuilder.PETfactory(this.pnum, 'cbf');
            disp('please examine the dip_image for petcbfnii.img..........'); 
            dipshow(dip_image(petcbfnii.img), 'percentile', 'grey')
            petcbfniib  = NiiBrowser(petcbfnii,   this.blur);
            petcbfniibb = petcbfniib.blockBrowser(this.blockSz);
            petcbfniibb.save(fullfile(this.pbldr.pet_path, ['petcbf' this.blockSuff]));
            disp(['test_makeBlocNiis:  showing petcbfniibb.nii.img']);
            dipshow(dip_image(petcbfniibb.nii.img), 'percentile', 'grey')
            
            mlemcbfnii = NIfTI.load([this.pbldr.mr_path ...
               'SHIMONY_CBF_MLEM_LOGFRACTAL_VONKEN_LOWPASS' ...
                mlemVersion(this.pbldr.pnum) ...
                mlemDate(   this.pbldr.pnum) ...
                '.4dfp']);
            disp('please examine the dip_image for mlemcbfnii.img..........'); 
            dipshow(dip_image(mlemcbfnii.img), 'percentile', 'grey')
            mlemcbfniib  = NiiBrowser(mlemcbfnii,   this.blur);
            mlemcbfniibb = mlemcbfniib.blockBrowser(this.blockSz);
            mlemcbfniibb.save([this.pbldr.mr_path 'mlemcbf' this.blockSuff]);
            disp(['test_makeBlocNiis:  showing mlemcbfniibb.nii.img']);
            dipshow(dip_image(mlemcbfniibb.nii.img), 'percentile', 'grey')
            
            laifcbfnii   = NIfTI.load([this.pbldr.patient_path 'Bayes/F_mean_xr3d.4dfp']);
            disp('please examine the dip_image for laifcbfnii.img..........'); 
            dipshow(dip_image(laifcbfnii.img), 'percentile', 'grey')
            laifcbfniib  = NiiBrowser(laifcbfnii,   this.blur);
            laifcbfniibb = laifcbfniib.blockBrowser(this.blockSz);
            laifcbfniibb.save(fullfile(this.pbldr.mr_path, ['laifcbf' this.blockSuff]));
            disp(['test_makeBlocNiis:  showing laifcbfniibb.nii.img']);
            dipshow(dip_image(laifcbfniibb.nii.img), 'percentile', 'grey')
            
            fgnii   = NIfTI.load((this.pbldr.fg_filename(true));
            disp('please examine the dip_image for fgnii.img..........'); 
            dipshow(dip_image(fgnii.img), 'percentile', 'grey')
            fgniib  = NiiBrowser(fgnii,   this.blur);
            fgniibb = fgniib.blockBrowser(this.blockSz);
            Nfgniibb.save([this.pbldr.fg_filename this.blockSuff ]);
            disp(['test_makeBlocNiis:  showing fgniibb.nii.img']);
            dipshow(dip_image(fgniibb.nii.img), 'percentile', 'grey')
            
            parenchymaNii   = NIfTI.load([this.pbldr.roi_path this.parenchyma this.pbldr.ref_series '.nii.gz']);
            disp('please examine the dip_image for parenchymaNii.img..........'); 
            dipshow(dip_image(parenchymaNii.img), 'percentile', 'grey')
            parenchymaNiib  = NiiBrowser(parenchymaNii,   this.blur);
            parenchymaNiibb = parenchymaNiib.blockBrowser(this.blockSz);
            parenchymaNiibb.save([this.pbldr.roi_path this.parenchyma this.pbldr.ref_series this.blockSuff]);
            disp(['test_makeBlocNiis:  showing parenchymaNiibb.nii.img']);
            dipshow(dip_image(parenchymaNiibb.nii.img), 'percentile', 'grey')
            
            csfnii   = NIfTI.load([this.pbldr.csf_filename]);
            disp('please examine the dip_image for csfnii.img..........');
            dipshow(dip_image(csfnii.img), 'percentile', 'grey')
            csfniib  = NiiBrowser(csfnii,   this.blur);
            csfniibb = csfniib.blockBrowser(this.blockSz);
            csfniibb.save([this.pbldr.csf_filename this.blockSuff ]);            
            disp(['test_makeBlocNiis:  showing csfniibb.nii.img']);
            dipshow(dip_image(csfniibb.nii.img), 'percentile', 'grey')
            
            artnii   = NIfTI.load([this.pbldr.art_filename]);
            disp('please examine the dip_image for artnii.img..........'); 
            dipshow(dip_image(artnii.img), 'percentile', 'grey')
            artniib  = NiiBrowser(artnii,   this.blur);
            artniibb = artniib.blockBrowser(this.blockSz);   
            artniibb.save([this.pbldr.art_filename this.blockSuff ]);          
            disp(['test_makeBlocNiis:  showing artniibb.nii.img']);
            dipshow(dip_image(artniibb.nii.img), 'percentile', 'grey')

		end % function test_makeBlockNiis       
		function this = test_makeRoiNiis(this)
            if (~this.torun(3)); return; end;
			import mlfourd.*;            
            
            % read fg, art NIfTIs presumed to exist
            fgnii  = NIfTI.load(this.pbldr.fg_filename(true));
            artnii = NIfTI.load(this.pbldr.art_filename(true));
            fgnii1 = fgnii.makeSimilar( ...
                       fgnii.img                +   artnii.img, ...
                      [fgnii.hdr.hist.descrip ' + ' artnii.hdr.hist.descrip]);
            fnames = { ...
                 this.pbldr.csf_filename, ...
                [this.pbldr.roi_path 'white'       this.roisuff], ...
                [this.pbldr.roi_path 'grey'        this.roisuff]};
			labels = {             this.csf,  ...
                                   'white'    ...
                                   'grey'};
            descrips = {['ROIs Xr3d ' this.csf]...
                         'ROIs Xr3d white'    ...
                         'ROIs Xr3d grey'};
                     
            % make artnii mutually exclusive of NIFTIS with labels
            % this.csf, putamen, caudate, thalamus, white, grey, hippocampus 
            this.niis = BlockedRoisBuilder.makeRoiNiis(fgnii1, fnames, labels, descrips);
            for p = 1:length(this.niis)
                niis1       = cell(2,1);
                niis1{1}    = artnii;
                niis1{2}    = this.niis{p};
                niis1       = BlockedRoisBuilder.makeBinaryRoisMutuallyExclusive(fgnii1, niis1);
                this.niis{p} = niis1{2};
            end
                       
            % parenchyma ROI
            parenchymaimg = zeros(size(this.niis{1}.img));
            for q = 1:length(this.niis)
                if (0 == numel(findstr(this.csf,      labels{q})) && ...
                    0 == numel(findstr(this.arteries, labels{q})) && ...
                    0 == numel(findstr(this.fg,       labels{q})))
                    parenchymaimg = parenchymaimg + this.niis{q}.img; 
                end
            end
            parenchymanii = fgnii.makeSimilar( ...
                 parenchymaimg, ['ROIs Xr3d ' this.parenchyma]);    
            this.niis{1}.save([this.pbldr.csf_filename ]);
            this.niis{2}.save([this.pbldr.white_filename ]);
            this.niis{3}.save([this.pbldr.grey_filename ]);
            parenchymanii.save([this.pbldr.roi_path this.parenchyma this.pbldr.ref_series NIfTIInterface.FILETYPE_EXT ]);
            artnii.save([this.pbldr.art_filename ]);
            fgnii1.save([this.pbldr.fg_filename ]);
            
            % check ROIs & union of ROIs
                union = dip_image(zeros(size(fgnii1.img)));
            for s = 1:length(this.niis)
                disp(['please examine the dip_image for ' descrips{s} '..........']);
                dipshow(        dip_image(this.niis{s}.img), 'percentile', 'grey')
                union = union + dip_image(this.niis{s}.img);
            end
                disp(['please examine the dip_image for ' this.fg ' ..........']);
                dipshow(dip_image(fgnii1.img), 'percentile', 'grey')
                disp(['please examine the dip_image for ' this.parenchyma ' ..........']);          
                dipshow(dip_image(parenchymanii.img), 'percentile', 'grey')
                disp(['please examine the dip_image for ' this.arteries ' ..........']);          
                dipshow(dip_image(artnii.img), 'percentile', 'grey')                
                disp('please examine the union of dip_images ..........');
                union
		end % function test_makeRoiNiis
        function this = test_makeArteriesRoi(this)
            if (~this.torun(2)); return; end;
            import mlfourd.*;            
            epinii = NIfTI.load((this.pbldr.epi_filename(true));
            if (this.flipEpiY)
                epinii.img = flip4d(epinii.img, 'y'); end
            fgnii  = NIfTI.load((this.pbldr.fg_filename(true));            
            artnii = mlfourd.BlockedRoisBuilder.make_arteriesRoi(epinii, fgnii);
            artnii = mlfourd.BlockedRoisBuilder.thresholdRoi_coverage(artnii, this.coverage);
            dipshow(dip_image(epinii.img), 'percentile', 'grey')
            dipshow(dip_image(fgnii.img),  'percentile', 'grey')
            dipshow(dip_image(artnii.img), 'percentile', 'grey')
            artnii.save(this.pbldr.art_filename(true));
        end % function test_makeArteriesRoi
        

        
        function [nii bnii] = checkSums(this, filestem)
            import mlfourd.*;
            nii  = NIfTI.load([this.pbldr.roi_path ...
                   strrep(filestem, [this.pbldr.block_suffix '.4dfp.nii.gz'], '') '.4dfp.nii.gz']);
            bnii = NIfTI.load([this.pbldr.roi_path filestem]);
            sigma1 = sum(dip_image( nii.img));
            sigma2 = sum(dip_image(bnii.img))*prod(this.blockSz);
            assert(abs(sigma1 - sigma2)/abs(min(sigma1,sigma2)) < this.tol, ...
                 ['checkSums on ' filestem ':  sigma1 -> ' num2str(sigma1) ', sigma2 -> ' num2str(sigma2)]);            
        end        
        function nii = makeBlockNii(this, fqfn, fqfnb)
            import mlfourd.*;
            nii   = NIfTI.load((fqfn);
            disp(['please examine dip_image of ' fqfn '..........']); 
            dipshow(dip_image( nii.img), 'percentile', 'grey')
            niib  = NiiBrowser(nii,   this.pbldr.baseBlur);
            niibb = niib.blockBrowser(this.pbldr.blockSize);
            niibb.save(fqfnb);
            disp(['makeBlocNii:  showing niibb.nii.img based on ' fqfn]);
            dipshow(dip_image(   niibb.nii.img), 'percentile', 'grey')
        end        
        function       saveAsBlockNii(this, nii, fqfn)
            import mlfourd.*;
            disp(['please examine dip_image of nii.img from ' nii.fileprefix '..........']); 
            dipshow(dip_image(nii.img), 'percentile', 'grey')
            niib  = NiiBrowser(nii, this.pbldr.baseBlur);
            niibb = niib.blockBrowser(this.pbldr.blockSize);
            niibb.save(fqfn);
            disp(['saveAsBlockNii:  showing niibb.nii.img from ' nii.fileprefix]);
            dipshow(dip_image(niibb.nii.img), 'percentile', 'grey')
        end        
        function stm = blockSuff(this)
            stm = ['_' num2str(this.blockSz(1)) 'x' num2str(this.blockSz(2)) 'x' num2str(this.blockSz(3))];
        end
        
        function this = Test_BlockedRoisBuilder(varargin)
            
            import mlfourd.* mlpet.*;
            this            = this@mlrois_xunit.Test_mlrois (varargin{:});
            this.pldr       = PETBuilder;
            this.datenow    = datestr(now, 29);
            this.petcbfStem = ['petcbf' this.pbldr.pet_ref_series NIfTIInterface.FILETYPE_EXT];
            this.fg         = ['fg'     this.pbldr.ref_series     NIfTIInterface.FILETYPE_EXT];
            this.roisuff    = [         this.pbldr.ref_series     NIfTIInterface.FILETYPE_EXT];
            this.blockSz    = this.pbldr.blockSize;
            this.blur       = PETBuilder.petPointSpread;
            this.deprecated = mlfsl.DeprecatedImagingFeatures.instance;
        end % ctor
        
    end % methods
end

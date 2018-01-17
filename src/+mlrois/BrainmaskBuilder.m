classdef BrainmaskBuilder < mlrois.RoisBuilder
	%% BRAINMASKBUILDER builds binary masks of the brain, cerebellum and brainstem for use by 
    %  various project directors, e.g., mlraichle.HyperglycemiaDirector, mlraichle.HoDirector.
    %  Access the roi with property product.

	%  $Revision$
 	%  was created 01-Jun-2017 16:50:52 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlraichle/src/+mlraichle.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties (Dependent)
 		brainmask % mlfourd.ImagingContext
 	end

	methods 	
        
        %% GET
        
        function g = get.brainmask(this)
            g = this.brainmask_;
        end
        
        %%
        
        function [bmbb,ct4rb] = brainmaskBinarized(this, varargin)
            %% BRAINMASKBINARIZED resolves brainmaskBinarizeBlended to tracer
            %  @param named tracer is an mlfourd.ImagingContext.
            %  @param named reuse is logical; reusing existing brainmaskBinarizeBlended is default.
            %  @returns bmbb, brainmaskBinarizeBlended, as mlfourd.ImagingContext.
            %  @returns ct4rb as mlfourdfp.CompositeT4ResolveBuilder.
            
            ip = inputParser;
            addParameter(ip, 'tracerIC', [],  @(x) isa(x, 'mlfourd.ImagingContext')); 
            addParameter(ip, 'reuse', true, @islogical);
            parse(ip, varargin{:});
            
            pwd0    = pushd(ensureFolderExists(this.sessionData.tracerLocation));
            sessd   = this.sessionData;
            tr      = ip.Results.tracerIC;
            if (~lexist([tr.fileprefix '_brain.4dfp.ifh'], 'file'))
                [~,msktNorm] = this.msktgenImg; % ImagingContext
                msktNormNN   = msktNorm.numericalNiftid;
                tr_sumtNN    = tr.numericalNiftid;
                tr           = mlfourd.ImagingContext(tr_sumtNN.*msktNormNN);
                tr.filepath  = pwd;
                tr.filename  = [ip.Results.tracerIC.fileprefix '_brain.4dfp.ifh'];
                tr.save;
            end
            
            if (~lexist(this.brainmask.filename, 'file')) % in cwd
                this.buildVisitor.lns_4dfp(this.brainmask.fqfileprefix);
            end            
            ct4rb = mlfourdfp.CompositeT4ResolveBuilder( ...
                'sessionData', sessd, 'theImages', {tr.fileprefix this.brainmask.fileprefix});
            bmbbFn = sessd.brainmaskBinarizeBlended('suffix', ['_' ct4rb.resolveTag], 'typ', 'fn.4dfp.ifh');
            if (ip.Results.reuse && lexist(bmbbFn))
                bmbb = mlfourd.ImagingContext(bmbbFn);
                return
            end
            ct4rb = ct4rb.resolve;
            bmbb  = ct4rb.product{2};
            bmbb.numericalNiftid; % retain ImagingContext
            bmbb  = bmbb.binarizeBlended;
            bmbb.saveas(bmbbFn);
            
            % teardown
            this.teardown('tracerIC', ip.Results.tracerIC, 'sessionData', ct4rb.sessionData);
            popd(pwd0);
        end
        function [bmbb,ct4rb] = brainmaskBinarized__(this, varargin)
            %% BRAINMASKBINARIZED resolves brainmaskBinarizeBlended to tracerIC
            %  @param named tracerIC is an mlfourd.ImagingContext.
            %  @param named ignoreTouchfile is logical; default is false; calls teardown if true.
            %  @returns bmbb, brainmaskBinarizeBlended, as mlfourd.ImagingContext.
            %  @returns ct4rb as mlfourdfp.CompositeT4ResolveBuilder.
            
            ip = inputParser;
            addParameter(ip, 'tracerIC', [], ...
                                                       @(x) isa(x, 'mlfourd.ImagingContext')); 
            addParameter(ip, 'ignoreTouchfile', false, @islogical);
            parse(ip, varargin{:});
            
            pwd0 = pushd(ensuredir(this.sessionData.tracerLocation));
            if (~lexist(this.brainmask.filename, 'file')) % in cwd
                this.buildVisitor.lns_4dfp(this.brainmask.fqfileprefix);
            end
            
            trIC = ip.Results.tracerIC;
            if (~lexist([trIC.fileprefix '_brain.4dfp.ifh'], 'file'))
                [~,mskt]      = this.msktgenImg; % ImagingContext
                msktNN        = mskt.numericalNiftid;
                tr_sumtNN     = trIC.numericalNiftid;
                trIC          = mlfourd.ImagingContext(tr_sumtNN.*msktNN);
                trIC.filepath = pwd;
                trIC.filename = [ip.Results.tracerIC.fileprefix '_brain.4dfp.ifh'];
                trIC.save;
            end
            
            ct4rb = mlfourdfp.CompositeT4ResolveBuilder( ...
                'sessionData', this.sessionData, ...
                'theImages', {trIC.fileprefix this.brainmask.fileprefix}, ...
                'ignoreTouchfile', ip.Results.ignoreTouchfile);
            bmbbFn = this.sessionData.brainmaskBinarizeBlended('suffix', ['_' ct4rb.resolveTag], 'typ', 'fn.4dfp.ifh');
            if (~ip.Results.ignoreTouchfile && lexist(bmbbFn))
                bmbb = mlfourd.ImagingContext(bmbbFn);
                return
            end
            ct4rb = ct4rb.resolve;
            bmbb  = ct4rb.product{2};
            bmbb.numericalNiftid; % retain ImagingContext
            bmbb  = bmbb.binarizeBlended;
            bmbb.saveas(bmbbFn);
            
           this.teardown('tracerIC', ip,results.tracerIC, 'sessionData', ct4rb.sessionData);
           popd(pwd0);
        end
        function ic = tracerRevisionSumt_brain(this, varargin)
            ip = inputParser;
            addParameter(ip, 'tracerIC', this.sessionData.tracerRevisionSumt('typ', 'mlfourd.ImagingContext'), ...
                @(x) isa(x, 'mlfourd.ImagingContext'));
            parse(ip, varargin{:});            
            
            ic = ip.Results.tracerIC;
            if (~lexist([ic.fileprefix '_brain.4dfp.ifh'], 'file'))
                [~,mskt]    = this.msktgenImg; % ImagingContext
                msktNN      = mskt.numericalNiftid;
                tr_sumtNN   = ic.numericalNiftid;
                ic          = mlfourd.ImagingContext(tr_sumtNN.*msktNN);
                ic.filepath = pwd;
                ic.filename = [ip.Results.tracerIC.fileprefix '_brain.4dfp.ifh'];
                ic.save;
            end
        end
        function teardown(this, varargin)
            ip = inputParser;
            addParameter(ip, 'tracerIC', [], @(x) isa(x, 'mlfourd.ImagingContext')); 
            addParameter(ip, 'sessionData', this.sessionData, @(x) isa(x, 'mlpipeline.SessionData'));
            parse(ip, varargin{:});
            
            sessd = ip.Results.sessionData;
            tmpdir = fullfile(tempdir, datestr(now, 30));
            mkdir(tmpdir);
            movefileExisting(sprintf('brainmaskr%i_op_*', sessd.rnumber-1), tmpdir);
            movefileExisting(sprintf('%s_brainr%i_op_*', ip.Results.tracerIC.fileprefix, sessd.rnumber-1), tmpdir);
            %ensuredir('T4');
            %movefileExisting('*_t4', 'T4')
            deleteExisting('brainmaskr*');
            deleteExisting(sprintf('%s_brainr*', ip.Results.tracerIC.fileprefix));
            deleteExisting('*_b15.4dfp.*');
            movefileExisting(fullfile(tmpdir, '*'));
            rmdir(tmpdir);
        end
        
 		function this = BrainmaskBuilder(varargin)
 			%% BRAINMASKBUILDER ensures there exists sessionData.vLocation/brainmask.4dfp.ifh;
            %  it is set as the initial state of this.product.
            %  @param named 'logger' is an mlpipeline.AbstractLogger.
            %  @param named 'product' is the initial state of the product to build.
 			%  @param named 'sessionData' is an 'mlpipeline.ISessionData'.

 			this = this@mlrois.RoisBuilder(varargin{:});
            
            sessd = this.sessionData;
            bmfp  = fullfile(sessd.vLocation, sessd.brainmask('typ', 'fp'));
            bmnii = [bmfp '.nii'];
            bmifh = [bmfp '.4dfp.ifh'];
            if (~lexist_4dfp(bmifh))
                sessd.mri_convert(sessd.brainmask('typ', 'fqfn'), bmnii);
                sessd.nifti_4dfp_4(bmfp);
            end
            this.product_ = mlfourd.ImagingContext(bmifh);
            this.brainmask_ = this.product_;
 		end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        brainmask_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end


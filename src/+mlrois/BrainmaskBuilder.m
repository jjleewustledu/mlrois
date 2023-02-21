classdef BrainmaskBuilder < mlrois.AbstractRoisBuilder
	%% BRAINMASKBUILDER builds binary masks of the brain, cerebellum and brainstem for use by 
    %  various project directors, e.g., mlraichle.HyperglycemiaDirector, mlraichle.HoDirector.
    %  Access the roi with property product.  Brainmask is especially useful for registration with PET;
    %  its ct4rb may be used for alignment of other ROIs to PET.  

	%  $Revision$
 	%  was created 01-Jun-2017 16:50:52 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlraichle/src/+mlraichle.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
    properties (Dependent)
        ct4rb
    end
    
	methods
        
        %% GET
        
        function g = get.ct4rb(this)
            g = this.ct4rb_;
        end
        
        %%
        
        function this = buildBrainmaskBinarized(this, varargin)
            %% BUILDBRAINMASKBINARIZED resolves brainmask to tracerIC, then binarizes.
            %  @param named cwd is the current working directory.
            %  @param named tracerIC is an mlfourd.ImagingContext.
            %  @param named ignoreFinishMark is logical; default is false.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'cwd', this.tracerLocation, @isdir);
            addParameter(ip, 'tracerIC', [], @(x) isa(x, 'mlfourd.ImagingContext2')); 
            addParameter(ip, 'ignoreFinishMark', false, @islogical);
            parse(ip, varargin{:});
            
            pwd0 = pushd(ip.Results.cwd);            
            
            if (this.brainmaskMissing) % in cwd
                this.buildVisitor_.convertImageToLocal4dfp( ...
                    this.sessionData.brainmask('typ', 'mgz'));
            end
            this = this.buildCompositeT4ResolveBuilder(ip.Results);
            if (this.bmbbCacheAvailable(ip.Results))
                this.product_ = mlfourd.ImagingContext2(this.bmbbFilename);
            else
                this.product_ = this.bmbbResolved;
            end
            this.teardown('sessionData', this.ct4rb_.sessionData);
            
            popd(pwd0);
        end
        
 		function this = BrainmaskBuilder(varargin)
 			%% BRAINMASKBUILDER ensures there exists sessionData.sessionPath/brainmask.4dfp.hdr;
            %  it is set as the initial state of this.product.
            %  @param named 'logger' is an mlpipeline.ILogger.
            %  @param named 'product' is the initial state of the product to build.
 			%  @param named 'sessionData' is an 'mlpipeline.ISessionData'.

 			this = this@mlrois.AbstractRoisBuilder(varargin{:});
            
            % prepare FreeSurfer brainmask at the top-level visit location
            pwd0 = pushd(this.sessionPath);
            this.product_ = this.buildVisitor_.convertImageToLocal4dfp( ...
                this.sessionData.brainmask('typ', 'mgz'));
            popd(pwd0);
        end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        ct4rb_
    end
    
    methods (Access = protected)    
        function this = buildCompositeT4ResolveBuilder(this, ipr)
            trIC = this.tracerImg_brain('tracerIC', ipr.tracerIC);                 
            this.ct4rb_ = mlfourdfp.CompositeT4ResolveBuilder( ...
                'sessionData', this.sessionData, ...
                'theImages', {trIC.fileprefix this.sessionData.brainmask.fileprefix}, ...
                'ignoreFinishMark', ipr.ignoreFinishMark);  
        end
        function teardown(this, varargin)
            this.teardown@mlrois.AbstractRoisBuilder(varargin{:});
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'sessionData', this.sessionData, @(x) isa(x, 'mlpipeline.ISessionData'));
            parse(ip, varargin{:});
            
            %sessd = ip.Results.sessionData;
            %tmpdir = fullfile(tempdir, datestr(now, 30));
            %mkdir(tmpdir);
            %movefileExisting(sprintf('brainmaskr%i_op_*', sessd.rnumber-1), tmpdir);
            %movefileExisting(sprintf('%s_brainr%i_op_*', ip.Results.tracer.fileprefix, sessd.rnumber-1), tmpdir);
            %ensuredir('T4');
            %movefileExisting('*_t4', 'T4')
            %deleteExisting('brainmaskr*');
            %deleteExisting(sprintf('%s_brainr*', ip.Results.tracer.fileprefix));
            %deleteExisting('*_b15.4dfp.*');
            %movefileExisting(fullfile(tmpdir, '*'));
            %rmdir(tmpdir);
        end
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function tf = brainmaskMissing(this)
            tf = ~lexist(this.sessionData.brainmask('typ', '4dfp.hdr'), 'file');
        end
        function tf = bmbbCacheAvailable(this, ipr)
            tf = ~ipr.ignoreFinishMark && lexist(this.bmbbFilename, 'file');
        end
        function fn = bmbbFilename(this)
            fn = this.sessionData.brainmaskBinarizeBlended('typ', '4dfp.hdr');
        end
        function ic = bmbbResolved(this)
            this.ct4rb_ = this.ct4rb_.resolve;
            bmbb = this.ct4rb_.product{2}; % retain ImagingContext2
            assert(isa(bmbb, 'mlfourd.ImagingContext2'));
            bmbb = bmbb.binarizeBlended;
            bmbb.filename = this.bmbbFilename;
            bmbb.save;
            ic = bmbb;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end


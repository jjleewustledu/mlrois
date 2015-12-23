classdef AbstractRois < mlrois.RoisInterface
	%% ABSTRACTROIS provides default implementations
    %  abstract properties:  atlasFileprefix, maskFileprefix, structuralFileprefix
    
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    
    properties (Constant)
        ROOT = '/';
    end    

    properties (Abstract) 
        atlasFolder
    end
    
    properties (Dependent)
        atlas        
        atlasesPath   
        fslPath
        mask
        roisBuilder
        sessionId
        sessionPath
        structural
        studyPath
        surfPath
        mriPath
    end
    
	methods %% GET/SET
        function ic   = get.atlas(this)
           ic = mlfourd.ImagingContext.load( ...
                fullfile(this.atlasesPath, this.atlasFolder, filename(this.atlasFileprefix)));
        end
 		function fldr = get.atlasesPath(this) %#ok<MANU>
            fldr = fullfile(getenv('FSLDIR'), 'data', 'atlases', '');
        end 
        function pth  = get.fslPath(this)
            pth = fullfile(this.sessionPath, 'fsl');
        end
        function ic   = get.mask(this)
            fqfn = fullfile(this.fslPath, filename(this.maskFileprefix));
            if (~lexist(fqfn, 'file'))
                try
                    this.makeMask(fqfn);                   
                catch ME
                    handexcept(ME);
                end
            end
            ic = mlfourd.ImagingContext.load(fqfn);
        end
        function bldr = get.roisBuilder(this)
            assert(isa(this.builder_, 'mlrois.RoisBuilder'));
            bldr = this.builder_;
        end
        function this = set.sessionId(this, sid)
            assert(ischar(sid));
            this.sessionId_ = sid;
        end
        function sid  = get.sessionId(this)
            assert(~isempty(this.sessionId_));
            sid = this.sessionId_;
        end
        function this = set.sessionPath(this, pth)
            assert(lexist(pth, 'dir'));
            [this.studyPath, this.sessionId] = fileparts(trimpath(pth));
        end
        function pth  = get.sessionPath(this)
            pth = fullfile(this.studyPath, this.sessionId, '');
        end 
        function pth  = get.mriPath(this)
            pth = fullfile(this.sessionPath, 'mri', '');
        end
        function sdir = get.surfPath(this)
            sdir = fullfile(this.studyPath, this.sessionId, 'surf');
        end
        function this = set.studyPath(this, spth)
            assert(lexist(spth, 'dir'));
            assert(strcmp(this.ROOT, spth(1)), 'Rois.set.studyPath received non-fully-qualified %s', spth);
            this.studyPath_ = spth;
        end
        function spth = get.studyPath(this)
            assert(~isempty(this.studyPath_))
            spth = this.studyPath_;
        end
        function ic   = get.structural(this)
           ic = mlfourd.ImagingContext.load( ...
                fullfile(this.fslPath, filename(this.structuralFileprefix)));
        end
        function this = set.surfPath(this, spth)
            [this.studyPath, this.sessionId] = fileparts(trimpath(spth));
        end
    end
    
    %% PROTECTED

    properties (Access = 'protected')
        builder_
    end
    
    methods (Access = 'protected')
        function this = AbstractRois(varargin)
            %% ABSTRACTROIS
            %  Usage:  instantiate child class with varargin described in mlrois.RoisBuilder
            
            this.builder_ = mlrois.RoisBuilder(varargin{:});
        end
        function ic   = makeImageFileAsNeeded(this, imobj, immaker)
            ic = this.makeImageAsNeeded(imobj, immaker);
            ic.nifti.save;
        end
        function ic   = makeImageAsNeeded(this, imobj, immaker)
            ic = mlfourd.ImagingContext(imobj);
            if (~lexist(ic.fqfilename, 'file'))
                assert(ismethod(this, immaker));
                this.(immaker);
            end
        end
        function        makeMask(this, fqfn)
            this.roisBuilder.atlas2mask(this.atlas, fqfn);
        end
    end
    
    %% PRIVATE
    
    properties (Access = 'private')
        studyPath_
        sessionId_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end


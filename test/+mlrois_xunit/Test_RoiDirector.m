classdef Test_RoiDirector < mlfsl_xunit.Test_mlfsl

    properties (Constant)
        NS       = [0 0 0 0];
        MEANS    = [0 0 0 0];
        STDS     = [0 0 0 0];
        SEMS     = [0 0 0 0];
        SKEWNESS = [0 0 0 0];
        KURTOSIS = [0 0 0 0];
    end
    
    properties
        roidir
        hosum
    end
    
    properties (Dependent)
        rois
        mniAtlas
        t1ref
        mniStd
    end
    
    methods
        function rs    = get.rois(this)
            rs = this.roidir.roisAsImagingComponent;
        end
        function rs    = get.mniAtlas(this)
            rs = this.roidir.mniRoisAsImagingComponent;
        end
        function imser = get.t1ref(this)
            imser = mlfourd.ImagingSeries.createFromFilename(this.t1_fqfn);
        end
        function imser = get.mniStd(this)
            imser = mlfourd.ImagingSeries.createFromFilename(this.mniStd_fqfn);
        end
        
        function test_ensureOnReference(this)
            imcmp = this.roidir.ensureOnReference(this.hosum);
            assertEqual(t1ref.size, imcmp.size);
            assertEqual(t1ref.mmppix, imcmp.mmppix);
            assertEqual(0, imcmp.entropy);
            assertTrue(lstrfind(imcmp.fileprefix, '_on_t1'));
        end
        function test_ensureOnMniReference(this)
            imcmp = this.roidir.ensureOnMniReference(this.hosum);
            assertEqual(mniStd.size, imcmp.size);
            assertEqual(mniStd.mmppix, imcmp.mmppix);
            assertEqual(0, imcmp.entropy);
            assertTrue(lstrfind(imcmp.fileprefix, '_on_MNI'));
        end        
        function test_createFromRois(this)
            rdir = mlfourd.RoiDirector.createFromRois(this.rois); 
            for r = 1:length(this.rois)
                assert(isequal(this.rois.get(r), rdir.roisAsImagingComponent.get(r))); 
            end
        end
        function test_createFromT1(this)
            rdir = mlfourd.RoiDirector.createFromT1(this.t1_fqfn);
            rdir.roisAsImagingComponent = this.rois;
        end
        function test_createFromMniRois(this)
            rdir = mlfourd.RoiDirector.createFromMniRois(this.mniAtlas);            
            for r = 1:length(this.mniAtlas)
                assert(isequal(this.minrois.get(r), rdir.mniRoisAsImagingComponent.get(r))); 
            end
        end
        function test_warp(this)
            mniroi = this.roidir.warp(this.rois{1});
            assert(isequal(this.mniAtlas{1}, mniroi));
        end
        function test_invwarp(this)
            roi = this.roidir.warp(this.mniAtlas{1});
            assert(isequal(this.rois{1}, roi));
        end
        function test_NsOf(this)
            assertEqual(this.NS, this.roidir.NsOf(this.hosum));
        end
        function test_meansOf(this)
            assertEqual(this.MEANS, this.roidir.meansOf(this.hosum));
        end
        function test_stdsOf(this)
            assertEqual(this.STDS, this.roidir.stdsOf(this.hosum));
        end
        function test_semsOf(this)
            assertEqual(this.SEMS, this.roidir.semsOf(this.hosum));
        end
        function test_skewnessOf(this)
            assertEqual(this.SKEWNESS, this.roidir.skewnessOf(this.hosum));
        end
        function test_kurtosisOf(this)
            assertEqual(this.KURTOSIS, this.roidir.kurtosisOf(this.hosum));
        end
        
        function this = Test_RoiDirector(varargin)
 			this = this@mlfsl_xunit.Test_fnirt(varargin{:});
        end
        function setUp(this)
            this.setUp@mlfourd_xunit.Test_fnirt;
            import mlfourd.*;
                if (isempty(this.roidir))
                this.roidir = RoiDirector.createFromRois( ...
                    ImagingComponent.load( ...
                        this.fslFullfilenames( ...
                            { '' '' '' '' })));
                assertEqual(length(this.NS), this.roidir.length);
            end
            if (isempty(this.hosum))
                this.hosum = ImagingSeries.load(this.ho_fqfn);
            end            
        end
    end    
end


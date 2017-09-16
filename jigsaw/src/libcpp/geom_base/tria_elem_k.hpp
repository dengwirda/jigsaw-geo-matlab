
    /*
    --------------------------------------------------------
     * TRIA-ELEM-K: operations on simplexes in R^k. 
    --------------------------------------------------------
     *
     * This program may be freely redistributed under the 
     * condition that the copyright notices (including this 
     * entire header) are not removed, and no compensation 
     * is received through use of the software.  Private, 
     * research, and institutional use is free.  You may 
     * distribute modified versions of this code UNDER THE 
     * CONDITION THAT THIS CODE AND ANY MODIFICATIONS MADE 
     * TO IT IN THE SAME FILE REMAIN UNDER COPYRIGHT OF THE 
     * ORIGINAL AUTHOR, BOTH SOURCE AND OBJECT CODE ARE 
     * MADE FREELY AVAILABLE WITHOUT CHARGE, AND CLEAR 
     * NOTICE IS GIVEN OF THE MODIFICATIONS.  Distribution 
     * of this code as part of a commercial system is 
     * permissible ONLY BY DIRECT ARRANGEMENT WITH THE 
     * AUTHOR.  (If you are not directly supplying this 
     * code to a customer, and you are instead telling them 
     * how they can obtain it for free, then you are not 
     * required to make any arrangement with me.) 
     *
     * Disclaimer:  Neither I nor: Columbia University, The
     * Massachusetts Institute of Technology, The 
     * University of Sydney, nor The National Aeronautics
     * and Space Administration warrant this code in any 
     * way whatsoever.  This code is provided "as-is" to be 
     * used at your own risk.
     *
    --------------------------------------------------------
     *
     * Last updated: 09 September, 2017
     *
     * Copyright 2013-2017
     * Darren Engwirda
     * de2363@columbia.edu
     * https://github.com/dengwirda/
     *
    --------------------------------------------------------
     */

#   pragma once

#   ifndef __TRIA_ELEM_K__
#   define __TRIA_ELEM_K__

    namespace geometry {

    /*
    --------------------------------------------------------
     * tria. area/volume/normals/etc. 
    --------------------------------------------------------
     */

    template <
    typename      data_type
             > 
	__normal_call data_type tria_area_2d (
	__const_ptr  (data_type) _p1,
	__const_ptr  (data_type) _p2,
	__const_ptr  (data_type) _p3
		)
	{
		data_type _ev12[2];
		vector_2d(_p1, _p2, _ev12);
		
		data_type _ev13[2];
		vector_2d(_p1, _p3, _ev13);
		
        data_type _aval = 
            _ev12[0] * _ev13[1] - 
            _ev12[1] * _ev13[0] ;

        _aval *= (data_type)+.5 ;

		return ( _aval )  ;
	}

    template <
    typename      data_type
             > 
	__normal_call data_type tria_area_3d (
	__const_ptr  (data_type) _p1,
	__const_ptr  (data_type) _p2,
	__const_ptr  (data_type) _p3
		)
	{
		data_type _ev12[3], _ev13[3] ;
		vector_3d(_p1, _p2, _ev12);
		vector_3d(_p1, _p3, _ev13);

        data_type  _avec[3] = {
		_ev12[1] * _ev13[2] - 
        _ev12[2] * _ev13[1] ,
		_ev12[2] * _ev13[0] - 
        _ev12[0] * _ev13[2] ,
		_ev12[0] * _ev13[1] - 
        _ev12[1] * _ev13[0] } ;

		data_type _aval = 
            geometry::length_3d(_avec) ;

        return (data_type)+.5 * _aval  ;
    }

    template <
    typename      data_type
             >
	__inline_call void_type tria_norm_3d (
	__const_ptr  (data_type) _p1,
	__const_ptr  (data_type) _p2,
	__const_ptr  (data_type) _p3,
	__write_ptr  (data_type) _nv
		 )
	{
		data_type _ev12[3], _ev13[3] ;
		vector_3d(_p1, _p2, _ev12);
		vector_3d(_p1, _p3, _ev13);

		_nv[0] = _ev12[1] * _ev13[2] - 
			     _ev12[2] * _ev13[1] ;
		_nv[1] = _ev12[2] * _ev13[0] - 
			     _ev12[0] * _ev13[2] ;
		_nv[2] = _ev12[0] * _ev13[1] - 
			     _ev12[1] * _ev13[0] ;
	}

    template <
    typename      data_type
             >
	__inline_call data_type tetra_vol_3d (
	__const_ptr  (data_type) _p1,
	__const_ptr  (data_type) _p2,
	__const_ptr  (data_type) _p3,
	__const_ptr  (data_type) _p4    // +ve if CCW from _p4
		)
	{
		data_type _v14[3], _v24[3], 
                  _v34[3];
		vector_3d(_p1, _p4, _v14);
		vector_3d(_p2, _p4, _v24);
		vector_3d(_p3, _p4, _v34);
		
		data_type _vdet = 
      + _v14[0] * (_v24[1] * _v34[2] - 
			       _v24[2] * _v34[1] )
      - _v14[1] * (_v24[0] * _v34[2] - 
		           _v24[2] * _v34[0] )
      + _v14[2] * (_v24[0] * _v34[1] - 
		           _v24[1] * _v34[0]);
		           
		return _vdet / (data_type)6. ;
	}

    /*
    --------------------------------------------------------
     * tria. "quality" scores. 
    --------------------------------------------------------
     */

    template <
    typename      data_type
             > 
	__normal_call 
	    data_type tria_quality_2d (
	__const_ptr  (data_type) _p1,
	__const_ptr  (data_type) _p2,
	__const_ptr  (data_type) _p3
		)
	{
	    // 4. * std::sqrt(3.)
		data_type static 
		    constexpr _scal = 
	   (data_type)+6.928203230275509 ;
	
		data_type _elen = 
		    lensqr_2d(_p1, _p2) + 
		    lensqr_2d(_p2, _p3) + 
		    lensqr_2d(_p3, _p1) ;

		data_type _area = 
		tria_area_2d(_p1, _p2, _p3);

		return _scal * _area / _elen ;
	}

    template <
    typename      data_type
             > 
	__normal_call 
	    data_type tria_quality_3d (
	__const_ptr  (data_type) _p1,
	__const_ptr  (data_type) _p2,
	__const_ptr  (data_type) _p3
		)
	{
	    // 4. * std::sqrt(3.)
		data_type static 
		    constexpr _scal = 
	   (data_type)+6.928203230275509 ;
	
		data_type _elen = 
		    lensqr_3d(_p1, _p2) + 
		    lensqr_3d(_p2, _p3) + 
		    lensqr_3d(_p3, _p1) ;

		data_type _area = 
		tria_area_3d(_p1, _p2, _p3);

		return _scal * _area / _elen ;
	}

    template <
    typename      data_type
             > 
	__normal_call 
	    data_type tria_quality_3d (
	__const_ptr  (data_type) _p1,
	__const_ptr  (data_type) _p2,
	__const_ptr  (data_type) _p3,
	__const_ptr  (data_type) _p4
		)
	{
		// 6. * std::sqrt(2.)
		data_type static 
		    constexpr _scal = 
	   (data_type)+8.485281374238571 ;

		data_type _tvol = tetra_vol_3d (
			_p1, _p2, _p3, _p4);

		data_type _lrms = 
		    lensqr_3d(_p1, _p2) +
		    lensqr_3d(_p2, _p3) +
		    lensqr_3d(_p3, _p1) +
		    lensqr_3d(_p1, _p4) +
		    lensqr_3d(_p2, _p4) +
		    lensqr_3d(_p3, _p4) ;

        _lrms =  _lrms/ (data_type)6.0 ;
	    _lrms = 
        std::pow(_lrms, (data_type)1.5);

		return _scal * _tvol / _lrms ;
	}


    }

#   endif//__TRIA_ELEM_K__



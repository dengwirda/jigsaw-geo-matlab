
    /*
    --------------------------------------------------------
     * ITER-NODE-2: optim. schemes to reposition nodes.
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
     * Last updated: 13 September, 2017
     *
     * Copyright 2013-2017
     * Darren Engwirda
     * de2363@columbia.edu
     * https://github.com/dengwirda/
     *
    --------------------------------------------------------
     */
    
    // from iter_mesh_2.hpp
    

    /*
    --------------------------------------------------------
     * CCVT-MOVE: a "ccvt"-style node movement vector.
    --------------------------------------------------------
     */
   
    template <
        typename  node_iter
             >
    __static_call
    __normal_call void_type ccvt_move (
        geom_type &_geom ,
        mesh_type &_mesh ,
        size_type &_hfun ,
        pred_type &_pred ,
        real_list &_hval ,
        iptr_list &_tset ,
        node_iter  _node ,
        real_type *_line ,
        real_type &_long
        )
    {
        real_type _move[_dims] = {
            (real_type) +0.0 } ;

        _long = 
            (real_type) +0.0 ;
    
        real_type _wval = 
       +std::numeric_limits<real_type>::epsilon();
        real_type _wsum = 
       +std::numeric_limits<real_type>::epsilon();
    
        iptr_type _tnum = +0 ;
    
        for (auto _tria  = _tset.head() ,
                  _tend  = _tset.tend() ;
                  _tria != _tend ; 
                ++_tria, ++_tnum )
        {     
             auto _tptr = 
            _mesh._set3.head()+*_tria ;
            
            iptr_type _tnod[3] ;
            _tnod[ 0] = _tptr->node( 0) ;
            _tnod[ 1] = _tptr->node( 1) ;
            _tnod[ 2] = _tptr->node( 2) ;
            
             auto _inod = 
            _mesh._set1.head()+_tnod[0] ;
             auto _jnod = 
            _mesh._set1.head()+_tnod[1] ;
             auto _knod = 
            _mesh._set1.head()+_tnod[2] ;
            
            real_type _ball [_dims + 1] ;
            _pred.mini(_ball, 
                &_inod->pval(0) ,
                    &_jnod->pval(0) ,
                        &_knod->pval(0) ) ;
     
            if (_hval[_tnod[0]] < (real_type)+0.)
            {
                _hval[_tnod[0]] = _hfun.eval (
                   &_inod->pval(0) , 
                    _inod->hidx()) ;
            }            
            
            if (_hval[_tnod[1]] < (real_type)+0.)
            {
                _hval[_tnod[1]] = _hfun.eval (
                   &_jnod->pval(0) , 
                    _jnod->hidx()) ;
            }
            
            if (_hval[_tnod[2]] < (real_type)+0.)
            {
                _hval[_tnod[2]] = _hfun.eval (
                   &_knod->pval(0) , 
                    _knod->hidx()) ;
            }
            
            real_type _trad = std::sqrt(_ball[_dims]) ;
            
            real_type _hbar = _hval[_tnod[0]] +
                              _hval[_tnod[1]] +
                              _hval[_tnod[2]] ;
            _hbar /= (real_type) +3.0 ; 
            
            real_type static 
                constexpr _tmul = (real_type) +0.67 ;
            real_type static 
                constexpr _hmul = (real_type) +0.33 ;
            
            _wval  = (real_type) +1.0 / 
                (_hmul*_hbar + _tmul*_trad) ;
            
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _move[_idim] 
                    += _wval * _ball[_idim] ;
            }
            
            _wsum   += _wval ;
            _long   += _trad ;
        }
        
        if (_tnum > +0)
        {
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _line[_idim] = 
                    _move[_idim] / _wsum
                        - _node->pval(_idim) ;
            }
            
            _long /= _tnum ;
        }
        
    }
    
    /*
    --------------------------------------------------------
     * SPRG-MOVE: "spring"-based node movement vector. 
    --------------------------------------------------------
     */
   
    template <
        typename  node_iter
             >
    __static_call
    __normal_call void_type sprg_move (
        geom_type &_geom ,
        mesh_type &_mesh ,
        size_type &_hfun ,
        pred_type &_pred ,
        real_list &_hval , 
        iptr_list &_eset ,
        iptr_list &_tset ,
        node_iter  _node ,
        real_type *_line ,
        real_type &_long
        )
    {
        real_type _move[_dims] = {
            (real_type) +0.0 } ;

        _long = 
            (real_type) +0.0 ;
    
        real_type _wval = 
       +std::numeric_limits<real_type>::epsilon();
        real_type _wsum = 
       +std::numeric_limits<real_type>::epsilon();
   
        iptr_type _enum = (iptr_type)+0  ;

        real_type _smin = (real_type)-1. ;
        real_type _smax = (real_type)+1. ;
   
        for (auto _edge  = _eset.head(),
                  _eend  = _eset.tend();
                  _edge != _eend; 
                ++_edge, ++_enum )
        {     
             auto _eptr = 
            _mesh._set2.head()+*_edge ;
        
            iptr_type  _enod[2] ;
            _enod[0] = _eptr->node(0) ==
                       _node->node(0) ?
                       _eptr->node(0) :
                       _eptr->node(1) ;
                       
            _enod[1] = _eptr->node(0) ==
                       _node->node(0) ?
                       _eptr->node(1) :
                       _eptr->node(0) ;
        
             auto _inod = 
            _mesh._set1.head()+_enod[0] ;
             auto _jnod = 
            _mesh._set1.head()+_enod[1] ;
        
            real_type _ipos  [_dims] ;
            real_type _jpos  [_dims] ;
            real_type _evec  [_dims] ;
            real_type _proj  [_dims] ;
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _ipos[_idim] =_inod->
                               pval(_idim) ;
                _jpos[_idim] =_jnod->
                               pval(_idim) ;
                
                _evec[_idim] =_ipos[_idim] -
                              _jpos[_idim] ;
            }
  
            real_type _elen = 
                std::sqrt(_pred.lsqr(_evec)) ;
  
            if (_hval[_enod[0]] 
                    < (real_type)+0.)
            {
                _hval[_enod[0]] = 
            _hfun.eval(_ipos, _inod->hidx()) ;
            }            
            
            if (_hval[_enod[1]] 
                    < (real_type)+0.)
            {
                _hval[_enod[1]] = 
            _hfun.eval(_jpos, _jnod->hidx()) ;
            }
            
            _long +=   _elen ;

            real_type  _hbar = 
           (real_type) +.5 * _hval[_enod[0]] +
           (real_type) +.5 * _hval[_enod[1]] ;
  
            real_type  _scal = 
               (_hbar - _elen) / _elen ;
              
            _scal = std::max(_scal, 
                             _smin) ;
            _scal = std::min(_scal, 
                             _smax) ;
            
          //_wval = std::abs(_scal) ;
          //_wval = (real_type) +1. ;
            _wval = 
            std::sqrt(std::abs(_scal)) ;
            
            _wsum   += _wval ;
            
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _proj[_idim] = 
                _ipos[_idim] + 
                    _scal * _evec[_idim] ;
            
                _move[_idim]+= 
                    _wval * _proj[_idim] ;
            }
        }
            
        if (_enum > +0)
        {
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _line[_idim] = 
                    _move[_idim] / _wsum
                        - _node->pval(_idim) ;   
            }
            
            _long /= _enum ;
        }

    }
    
    /*
    --------------------------------------------------------
     * GRAD-MOVE: "local-ascent" node movement vector. 
    --------------------------------------------------------
     */
    
    template <
        typename  node_iter
             >
    __static_call
    __normal_call void_type grad_move (
        geom_type &_geom ,
        mesh_type &_mesh ,
        size_type &_hfun ,
        pred_type &_pred ,
        iptr_list &_tset ,
        node_iter  _node ,
        real_list &_cost ,
        real_type *_line ,
        real_type &_long
        )
    {
        real_type static constexpr _ZERO = 
            (real_type) +1.0E-12 ;
    
        real_type _qmin =
            +std::numeric_limits
                <real_type>::infinity() ;
        
        iptr_type _tnum = +0 ;
        
        _long = (real_type)0.;
        
        real_type _bmin[_dims] = {
           +std::numeric_limits
                <real_type>::infinity()
            } ;
        real_type _bmax[_dims] = {
           -std::numeric_limits
                <real_type>::infinity()
            } ;
        
        real_type _dqdx[_dims] = {
            (real_type) +0.0 } ;
        
        real_type _save  [_dims] ;
        for (auto _idim = _dims; _idim-- != +0; )
        {
            _save[_idim] = 
                _node->pval(_idim) ;
        }
            
        for (auto _tria  = _tset.head(),
                  _tend  = _tset.tend();
                  _tria != _tend;
                ++_tria, ++_tnum)
        {     
             auto _tptr  = 
            _mesh._set3.head()+*_tria ;
         
             auto _inod = _mesh.
            _set1 .head()+_tptr->node(0) ;
             auto _jnod = _mesh.
            _set1 .head()+_tptr->node(1) ;
             auto _knod = _mesh.
            _set1 .head()+_tptr->node(2) ;
         
            _qmin = std::min(
                _qmin, _cost[_tnum]) ;
         
            real_type _pmid[_dims] = {
                (real_type) +0.0 } ;
         
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _pmid[_idim] += 
                    _inod->pval(_idim) ;
                _pmid[_idim] += 
                    _jnod->pval(_idim) ;
                _pmid[_idim] += 
                    _knod->pval(_idim) ;
            }
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _pmid[_idim] 
                    /= (real_type) +3. ;
            }
            
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _bmin[_idim] = std::min(
                    _bmin[_idim], 
                    _pmid[_idim])  ;
                
                _bmax[_idim] = std::max(
                    _bmax[_idim], 
                    _pmid[_idim])  ;
            }
            
            real_type _llen = 
                std::sqrt(_pred.lsqr(
                    _pmid, &_node->pval(0)))  ;
            
            _long +=  _llen ;
        }

        _tnum = +0 ;

        real_type _gsum, _qbar, _qlev ;
        _gsum = (real_type) +0. ;
        _qbar = (real_type) +0. ;
        _qlev = (real_type) +1. ;

        for (auto _tria  = _tset.head(),
                  _tend  = _tset.tend();
                  _tria != _tend;
                ++_tria, ++_tnum)
        {     
             auto _tptr  = 
            _mesh._set3.head()+*_tria ;
        
            real_type _qtri = _cost[_tnum] ;
        
            real_type _DQDX[_dims];
            real_type _qlim = 
           (real_type)1.E-2*_qmin ;
        
            _qlim = _qmin + _qlim ;
        
            if (_cost[_tnum] <= _qlim)
            {
            
            for(auto _idim = _dims; _idim-- != +0; )
            {
                real_type _hdel = 
                    (real_type)+1.E-08 * 
              (_bmax[_idim] - _bmin[_idim]) ;
                
                _node->pval(_idim) = 
                    _save[_idim] + _hdel ;

                real_type _scr1 = _pred.cost (
               &_mesh._set1[
                _tptr->node(0)].pval(0),
               &_mesh._set1[
                _tptr->node(1)].pval(0),
               &_mesh._set1[
                _tptr->node(2)].pval(0)) ;                
                
                _node->pval(_idim) = 
                    _save[_idim] - _hdel ;

                real_type _scr0 = _pred.cost (
               &_mesh._set1[
                _tptr->node(0)].pval(0),
               &_mesh._set1[
                _tptr->node(1)].pval(0),
               &_mesh._set1[
                _tptr->node(2)].pval(0)) ;                    
            
                _DQDX[_idim] = 
                    (_scr1 - _scr0) / 
               ((real_type)+2. * _hdel) ;
                
                _node->pval(_idim) = _save[_idim] ;
            }
            
            real_type _wval = 
           (real_type)+1./_cost[_tnum] ;
        
            _wval = std::pow(_wval,+2) ;
        
            _gsum  += _wval ;
        
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _dqdx[_idim] += 
                    _wval * _DQDX[_idim] ;
            }
        
            _qbar  += _wval*_qtri ;
            
            }
            else
            {
                _qlev = 
                    std::max(_qlev, _qtri) ;
            }
        }
 
        if (_tnum > +0)  
        {
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _dqdx[_idim] /= _gsum ;
            }
        
            _qbar /=  _gsum ;
            _long /=  _tnum ;            
        }
        
        real_type _scal = 
            std::sqrt( _pred.lsqr (_dqdx)) ;
        
        if (_scal < _ZERO * _long)
        {
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _line[_idim] 
                    = (real_type) +0. ;
            }
        }
        else
        {    
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _line[_idim] = 
                    _dqdx[_idim] / _scal ;
            }
        
            _scal = (_qlev - _qbar) 
                / _pred.lsqr(_line, _dqdx) ;
            
            _scal = std::min(_scal, _long) ;
            
            for (auto _idim = _dims; _idim-- != +0; )
            {
                _line[_idim] *= _scal ;
            }
        }
    
    }
    
    
    

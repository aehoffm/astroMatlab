%-Abstract
%
%   CSPICE_TERMPT finds terminator points on a target body. The terminator
%   is the set of points of tangency on the target body of planes tangent
%   to both this body and to a light source. The caller specifies half-planes,
%   bounded by the illumination source center-target center vector, in
%   which to search for terminator points.
%
%   The terminator can be either umbral or penumbral. The umbral
%   terminator is the boundary of the region on the target surface
%   where no light from the source is visible. The penumbral
%   terminator is the boundary of the region on the target surface
%   where none of the light from the source is blocked by the target
%   itself.
%
%   The surface of the target body may be represented either by a
%   triaxial ellipsoid or by topographic data.
%
%-Disclaimer
%
%   THIS SOFTWARE AND ANY RELATED MATERIALS WERE CREATED BY THE
%   CALIFORNIA  INSTITUTE OF TECHNOLOGY (CALTECH) UNDER A U.S.
%   GOVERNMENT CONTRACT WITH THE NATIONAL AERONAUTICS AND SPACE
%   ADMINISTRATION (NASA). THE SOFTWARE IS TECHNOLOGY AND SOFTWARE
%   PUBLICLY AVAILABLE UNDER U.S. EXPORT LAWS AND IS PROVIDED
%   "AS-IS" TO THE RECIPIENT WITHOUT WARRANTY OF ANY KIND, INCLUDING
%   ANY WARRANTIES OF PERFORMANCE OR MERCHANTABILITY OR FITNESS FOR
%   A PARTICULAR USE OR PURPOSE (AS SET FORTH IN UNITED STATES UCC
%   SECTIONS 2312-2313) OR FOR ANY PURPOSE WHATSOEVER, FOR THE
%   SOFTWARE AND RELATED MATERIALS, HOWEVER USED.
%
%   IN NO EVENT SHALL CALTECH, ITS JET PROPULSION LABORATORY,
%   OR NASA BE LIABLE FOR ANY DAMAGES AND/OR COSTS, INCLUDING,
%   BUT NOT LIMITED TO, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF
%   ANY KIND, INCLUDING ECONOMIC DAMAGE OR INJURY TO PROPERTY
%   AND LOST PROFITS, REGARDLESS OF WHETHER CALTECH, JPL, OR
%   NASA BE ADVISED, HAVE REASON TO KNOW, OR, IN FACT, SHALL
%   KNOW OF THE POSSIBILITY.
%
%   RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE
%   OF THE SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO
%   INDEMNIFY CALTECH AND NASA FOR ALL THIRD-PARTY CLAIMS RESULTING
%   FROM THE ACTIONS OF RECIPIENT IN THE USE OF THE SOFTWARE.
%
%-I/O
%
%   Given:
%
%      method   is a short string providing parameters defining
%               the computation method to be used. In the syntax
%               descriptions below, items delimited by angle brackets
%               "<>" are to be replaced by actual values. Items
%               delimited by brackets "[]" are optional.
%
%               [1,c1] = size(method); char = class(method)
%
%                  or
%
%               [1,1] = size(method); cell = class(method)
%
%               `method' may be assigned the following values:
%
%                  '<shadow>/<curve type>/<shape specification>'
%
%               An example of such a string is
%
%                  'UMBRAL/TANGENT/DSK/UNPRIORITIZED'
%
%               In the `method' string
%
%                  <shadow> may be either of the strings
%
%                     'UMBRAL'    indicates the terminator is the
%                                 boundary of the portion of the surface
%                                 that receives no light from the
%                                 illumination source. The shape of
%                                 the source is modeled as a sphere.
%
%                     'PENUMBRAL' indicates the terminator is the
%                                 boundary of the portion of the
%                                 surface that receives all possible
%                                 light from the illumination source.
%                                 The shape of the source is modeled as
%                                 a sphere.
%
%                                 The penumbral terminator bounds the
%                                 portion of the surface that is not
%                                 subject to self-occultation of light
%                                 from the illumination source. Given
%                                 that the light source is modeled as a
%                                 sphere, from any target surface point
%                                 nearer to the source than the
%                                 penumbral terminator, the source
%                                 appears to be a lit disc.
%
%
%                  <curve type> may be either of the strings
%
%                     'TANGENT'   for topographic (DSK) target models
%                                 indicates that a terminator point is
%                                 defined as the point of tangency, on
%                                 the surface represented by the
%                                 specified data, of a line also tangent
%                                 to the illumination source. For
%                                 ellipsoidal target models, a
%                                 terminator point is a point of
%                                 tangency of a plane that is also
%                                 tangent to the illumination source.
%                                 See the Particulars section below for
%                                 details.
%
%                                 Terminator points are generated within a
%                                 specified set of "cutting" half-planes
%                                 that have as an edge the line containing
%                                 the illumination source-target vector.
%                                 Multiple terminator points may be found
%                                 within a given half-plane, if the target
%                                 body shape allows for this.
%
%                                 This is the highest-accuracy method
%                                 supported by this subroutine. It
%                                 generally executes much more slowly
%                                 than the GUIDED method described
%                                 below.
%
%                     'GUIDED'    indicates that terminator points are
%                                 "guided" so as to lie on rays
%                                 emanating from the target body's
%                                 center and passing through the
%                                 terminator on the target body's
%                                 reference ellipsoid. The terminator
%                                 points are constrained to lie on the
%                                 target body's surface. As with the
%                                 'TANGENT' method (see above), cutting
%                                 half-planes are used to generate
%                                 terminator points.
%
%                                 The GUIDED method produces a unique
%                                 terminator point for each cutting
%                                 half-plane. If multiple terminator
%                                 point candidates lie in a given
%                                 cutting half-plane, the outermost one
%                                 is chosen.
%
%                                 This method may be used only with the
%                                 CENTER aberration correction locus
%                                 (see the description of REFLOC below).
%
%                                 Terminator points generated by this
%                                 method are approximations; they are
%                                 generally not true ray-surface tangent
%                                 points. However, these approximations
%                                 can be generated much more quickly
%                                 than tangent points.
%
%
%                  <shape specification> may be either of the strings
%
%                     'DSK/UNPRIORITIZED[/SURFACES = <surface list>]'
%
%                        The DSK option indicates that terminator point
%                        computation uses topographic data provided by
%                        DSK files (abbreviated as "DSK data" below) to
%                        model the surface of the target body.
%
%                        The surface list specification is optional. The
%                        syntax of the list is
%
%                           <surface 1> [, <surface 2>...]
%
%                        If present, it indicates that data only for the
%                        listed surfaces are to be used; however, data
%                        need not be available for all surfaces in the
%                        list. If the list is absent, loaded DSK data
%                        for any surface associated with the target body
%                        are used.
%
%                        The surface list may contain surface names or
%                        surface ID codes. Names containing blanks must
%                        be delimited by double quotes, for example
%
%                           'SURFACES = "Mars MEGDR 128 PIXEL/DEG"'
%
%                        If multiple surfaces are specified, their names
%                        or IDs must be separated by commas.
%
%                        See the Particulars section below for details
%                        concerning use of DSK data.
%
%
%                     'ELLIPSOID'
%
%                        The ELLIPSOID shape option generates terminator
%                        points on the target body's reference
%                        ellipsoid. When the ELLIPSOID shape is
%                        selected, The TANGENT curve option may be used
%                        with any aberration correction locus, while the
%                        GUIDED option may be used only with the CENTER
%                        locus (see the description of REFLOC below).
%
%                        When the locus is set to 'CENTER', the
%                        'TANGENT' and 'GUIDED' curve options produce
%                        the same results.
%
%                  Neither case nor white space are significant in
%                  `method', except within double-quoted strings. For
%                  example, the string ' eLLipsoid/tAnGenT ' is valid.
%
%                  Within double-quoted strings, blank characters are
%                  significant, but multiple consecutive blanks are
%                  considered equivalent to a single blank. Case is
%                  not significant. So
%
%                     "Mars MEGDR 128 PIXEL/DEG"
%
%                  is equivalent to
%
%                     " mars megdr  128  pixel/deg "
%
%                  but not to
%
%                     "MARS MEGDR128PIXEL/DEG"
%
%
%      ilusrc      is the name of the illumination source. This source
%                  may be any ephemeris object. Case, blanks, and
%                  numeric values are treated in the same way as for the
%                  input `target'.
%
%                  [1,c2] = size(ilusrc); char = class(ilusrc)
%
%                     or
%
%                  [1,1] = size(ilusrc); cell = class(ilusrc)
%
%                  The shape of the illumination source is considered
%                  to be spherical. The radius of the sphere is the
%                  largest radius of the source's reference ellipsoid.
%
%
%      target      is the name of the target body. The target body is
%                  an extended ephemeris object.
%
%                  [1,c3] = size(target); char = class(target)
%
%                     or
%
%                  [1,1] = size(target); cell = class(target)
%
%                  The string `target' is case-insensitive, and leading
%                  and trailing blanks in `target' are not significant.
%                  Optionally, you may supply a string containing the
%                  integer ID code for the object. For example both
%                  'MOON' and '301' are legitimate strings that indicate
%                  the Moon is the target body.
%
%                  When the target body's surface is represented by a
%                  tri-axial ellipsoid, this routine assumes that a
%                  kernel variable representing the ellipsoid's radii is
%                  present in the kernel pool. Normally the kernel
%                  variable would be defined by loading a PCK file.
%
%
%      et          is the epoch of participation of the observer,
%                  expressed as TDB seconds past J2000 TDB: `et' is
%                  the epoch at which the observer's state is computed.
%
%                  When aberration corrections are not used, `et' is also
%                  the epoch at which the position and orientation of
%                  the target body are computed.
%
%                  When aberration corrections are used, the position
%                  and orientation of the target body are computed at
%                  et-lt, where `lt' is the one-way light time between the
%                  aberration correction locus and the observer. The
%                  locus is specified by the input argument `corloc'.
%                  See the descriptions of `abcorr' and `corloc' below for
%                  details.
%
%
%      fixref      is the name of a body-fixed reference frame centered
%                  on the target body. `fixref' may be any such frame
%                  supported by the SPICE system, including built-in
%                  frames (documented in the Frames Required Reading)
%                  and frames defined by a loaded frame kernel (FK). The
%                  string `fixref' is case-insensitive, and leading and
%                  trailing blanks in `fixref' are not significant.
%
%                  [1,c4] = size(fixref); char = class(fixref)
%
%                     or
%
%                  [1,1] = size(fixref); cell = class(fixref)
%
%                  The output terminator points in the array `points' and
%                  the output observer-terminator vectors in the array
%                  `tangts' are expressed relative to this reference frame.
%
%
%      abcorr      indicates the aberration corrections to be applied
%                  when computing the target's position and orientation.
%                  Corrections are applied at the location specified by
%                  the aberration correction locus argument `corloc',
%                  which is described below.
%
%                  [1,c5] = size(abcorr); char = class(abcorr)
%
%                     or
%
%                  [1,1] = size(abcorr); cell = class(abcorr)
%
%                  For remote sensing applications, where apparent
%                  terminator points seen by the observer are desired,
%                  normally either of the corrections
%
%                     'LT+S'
%                     'CN+S'
%
%                  should be used. These and the other supported options
%                  are described below. `abcorr' may be any of the
%                  following:
%
%                     'NONE'     Apply no correction. Return the
%                                geometric terminator points on the
%                                target body.
%
%                  Let `lt' represent the one-way light time between the
%                  observer and the aberration correction locus. The
%                  following values of `abcorr' apply to the "reception"
%                  case in which photons depart from the locus at the
%                  light-time corrected epoch et-lt and *arrive* at the
%                  observer's location at `et':
%
%
%                     'LT'       Correct for one-way light time (also
%                                called "planetary aberration") using a
%                                Newtonian formulation. This correction
%                                yields the locus at the moment it
%                                emitted photons arriving at the
%                                observer at `et'.
%
%                                The light time correction uses an
%                                iterative solution of the light time
%                                equation. The solution invoked by the
%                                'LT' option uses one iteration.
%
%                                Both the target position as seen by the
%                                observer, and rotation of the target
%                                body, are corrected for light time. The
%                                position of the illumination source as
%                                seen from the target is corrected as
%                                well.
%
%                     'LT+S'     Correct for one-way light time and
%                                stellar aberration using a Newtonian
%                                formulation. This option modifies the
%                                locus obtained with the 'LT' option to
%                                account for the observer's velocity
%                                relative to the solar system
%                                barycenter. These corrections yield
%                                points on the apparent terminator.
%
%                     'CN'       Converged Newtonian light time
%                                correction. In solving the light time
%                                equation, the 'CN' correction iterates
%                                until the solution converges. Both the
%                                position and rotation of the target
%                                body are corrected for light time. The
%                                position of the illumination source as
%                                seen from the target is corrected as
%                                well.
%
%                     'CN+S'     Converged Newtonian light time and
%                                stellar aberration corrections. This
%                                option produces a solution that is at
%                                least as accurate at that obtainable
%                                with the 'LT+S' option. Whether the
%                                'CN+S' solution is substantially more
%                                accurate depends on the geometry of the
%                                participating objects and on the
%                                accuracy of the input data. In all
%                                cases this routine will execute more
%                                slowly when a converged solution is
%                                computed.
%
%
%      corloc      is a string specifying the aberration correction
%                  locus: the point or set of points for which
%                  aberration corrections are performed.
%
%                  [1,c6] = size(corloc); char = class(corloc)
%
%                     or
%
%                  [1,1] = size(corloc); cell = class(corloc)
%
%                  `corloc' may be assigned the values:
%
%                     'CENTER'
%
%                         Light time and stellar aberration corrections
%                         are applied to the vector from the observer to
%                         the center of the target body. The one way
%                         light time from the target center to the
%                         observer is used to determine the epoch at
%                         which the target body orientation is computed.
%
%                         This choice is appropriate for small target
%                         objects for which the light time from the
%                         surface to the observer varies little across
%                         the entire target. It may also be appropriate
%                         for large, nearly ellipsoidal targets when the
%                         observer is very far from the target.
%
%                         Computation speed for this option is faster
%                         than for the ELLIPSOID TERMINATOR option.
%
%                     'ELLIPSOID TERMINATOR'
%
%                         Light time and stellar aberration corrections
%                         are applied to individual terminator points on
%                         the reference ellipsoid. For a terminator
%                         point on the surface described by topographic
%                         data, lying in a specified cutting half-plane,
%                         the unique reference ellipsoid terminator
%                         point in the same half-plane is used as the
%                         locus of the aberration corrections.
%
%                         This choice is appropriate for large target
%                         objects for which the light time from the
%                         terminator to the observer is significantly
%                         different from the light time from the target
%                         center to the observer.
%
%                         Because aberration corrections are repeated
%                         for individual terminator points,
%                         computational speed for this option is
%                         relatively slow.
%
%
%      obsrvr      is the name of the observing body. The observing body
%                  is an ephemeris object: it typically is a spacecraft,
%                  the earth, or a surface point on the earth. `obsrvr' is
%                  case-insensitive, and leading and trailing blanks in
%                  `obsrvr' are not significant. Optionally, you may
%                  supply a string containing the integer ID code for
%                  the object. For example both 'MOON' and '301' are
%                  legitimate strings that indicate the Moon is the
%                  observer.
%
%                  [1,c7] = size(obsrvr); char = class(obsrvr)
%
%                     or
%
%                  [1,1] = size(obsrvr); cell = class(obsrvr)
%
%      refvec,
%      rolstp,
%      ncuts       are, respectively, a reference vector, a roll step
%                  angle, and a count of cutting half-planes.
%
%                  [3,1] = size(refvec); double = class(refvec)
%                  [1,1] = size(rolstp); double = class(rolstp)
%                  [1,1] = size(ncuts); int32 = class(ncuts)
%
%                  `refvec' defines the first of a sequence of cutting
%                  half-planes in which terminator points are to be found.
%                  Each cutting half-plane has as its edge the line
%                  containing the target-illumination source vector; the
%                  first half-plane contains `refvec'.
%
%                  `refvec' is expressed in the body-fixed reference frame
%                  designated by `fixref'.
%
%                  `rolstp' is an angular step by which to roll the cutting
%                  half-planes about the target-illumination source vector,
%                  which we'll call the "axis." The ith half-plane is
%                  rotated from `refvec' about the axis in the
%                  counter-clockwise direction by i*rolstp. Units are
%                  radians. `rolstp' should be set to
%
%                     2*pi/ncuts
%
%                  to generate an approximately uniform distribution of
%                  points along the terminator.
%
%                  `ncuts' is the number of cutting half-planes used to
%                  find terminator points; the angular positions of
%                  consecutive half-planes increase in the positive
%                  (counterclockwise) sense about the axis and are
%                  distributed roughly equally about that vector: each
%                  half-plane has angular separation of approximately
%
%                     `rolstp' radians
%
%                  from each of its neighbors. When the aberration
%                  correction locus is set to "CENTER", the angular
%                  separation is the value above, up to round-off.
%                  When the locus is "TANGENT", the separations are
%                  less uniform due to differences in the aberration
%                  corrections used for the respective terminator points.
%
%      schstp,
%      soltol      are used only for DSK-based surfaces. These inputs
%                  are, respectively, the search angular step size and
%                  solution convergence tolerance used to find tangent
%                  rays and associated terminator points within each cutting
%                  half plane.
%
%                  [1,1] = size(schstp); double = class(schstp)
%                  [1,1] = size(soltol); double = class(soltol)
%
%                  These values are used when the `method'
%                  argument includes the TANGENT option. In this case,
%                  terminator points are found by a two-step search
%                  process:
%
%                     1) Bracketing: starting with a direction
%                        having sufficiently small angular separation from
%                        the axis, rays emanating from the illumination
%                        source are generated within the half-plane at
%                        successively greater angular separations from the
%                        axis, where the increment of angular separation is
%                        `schstp'. The rays are tested for intersection
%                        with the target surface. When a transition from
%                        non-intersection to intersection is found, the
%                        angular separation of a tangent ray has been
%                        bracketed.
%
%                     2) Root finding: each time a tangent ray is
%                        bracketed, a search is done to find the angular
%                        separation from the axis at which a tangent ray
%                        exists. The search terminates when successive rays
%                        are separated by no more than `soltol'. When the
%                        search converges, the last ray-surface
%                        intersection point found in the convergence
%                        process is considered to be a terminator point.
%
%
%                   `schstp' and `soltol' have units of radians.
%
%                   Target bodies with simple surfaces---for example,
%                   convex shapes---will have a single terminator point
%                   within each cutting half-plane. For such surfaces,
%                   `schstp' can be set large enough so that only one
%                   bracketing step is taken. A value greater than pi,
%                   for example 4., is recommended.
%
%                   Target bodies with complex surfaces can have multiple
%                   terminator points within a given cutting half-plane. To
%                   find all terminator points, `schstp' must be set to a
%                   value smaller than the minimum angular separation of any two
%                   terminator points in any cutting half-plane, where the
%                   vertex of the angle is on the illumination source.
%                   `schstp' must not be too small, or the search will be
%                   excessively slow.
%
%                   For both kinds of surfaces, `soltol' must be chosen so
%                   that the results will have the desired precision.
%                   Note that the choice of `soltol' required to meet a
%                   specified bound on terminator point height errors
%                   depends on the illumination source-target distance.
%
%
%      maxn         is the maximum number of terminator points that can
%                   be stored in the output array `points'.
%
%                   [1,1] = size(maxn); int32 = class(maxn)
%
%   the call:
%
%      [npts, points, epochs, tangts] = cspice_termpt( method, ilusrc,...
%                                       target, et,   fixref, abcorr, ...
%                                       corloc, obsrvr, refvec,       ...
%                                       rolstp, ncuts,  schstp,       ...
%                                       soltol, maxn )
%
%   returns:
%
%      npts         is an array of counts of terminator points within
%                   the specified set of cutting half-planes. The Ith
%                   element of `npts' is the terminator point count in the
%                   Ith half-plane.
%
%                   [1,n] = size(npts); int32 = class(npts)
%                   with n>= maxn
%
%      points       is an array containing the terminator points found
%                   by this routine.
%
%                   [3,n] = size(points); double = class(soltol)
%                   with n>= maxn
%
%                   Terminator points are ordered by the
%                   indices of the half-planes in which they're found. The
%                   terminator points in a given half-plane are ordered by
%                   decreasing angular separation from the illumination
%                   source-target direction; the outermost terminator point
%                   in a given half-plane is the first of that set.
%
%                   The terminator points for the half-plane containing
%                   `refvec' occupy array elements
%
%                      points(1,1)                       through
%                      points(3,npts(1))
%
%                   Terminator points for the second half plane occupy
%                   elements
%
%                      points(1,npts(1)+1)               through
%                      points(3,npts(1)+npts(2))
%
%                   and so on.
%
%                   Terminator points are expressed in the reference
%                   frame designated by `fixref'. For each terminator
%                   point, the orientation of the frame is evaluated at
%                   the epoch corresponding to the terminator point; the
%                   epoch is provided in the output array `epochs'
%                   (described below).
%
%                   Units of the terminator points are km.
%
%
%      epochs       is an array of epochs associated with the terminator
%                   points, accounting for light time if aberration
%                   corrections are used. `epochs' contains one element
%                   for each terminator point.
%
%                   [1,n] = size(epochs); double = class(epochs)
%                   with n>= maxn
%
%                   The element
%
%                      epochs(i)
%
%                   is associated with the terminator point
%
%                      points(j,i), j = 1 to 3
%
%                   If `corloc' is set to 'CENTER', all values of `epochs'
%                   will be the epoch associated with the target body
%                   center. That is, if aberration corrections are used,
%                   and if `lt' is the one-way light time from the target
%                   center to the observer, the elements of `epochs' will
%                   all be set to
%
%                      et - lt
%
%                   If `corloc' is set to 'ELLIPSOID TERMINATOR', all
%                   values of `epochs' for the terminator points in a
%                   given half plane will be those for the reference
%                   ellipsoid terminator point in that half plane. That
%                   is, if aberration corrections are used, and if lt(i)
%                   is the one-way light time to the observer from the
%                   reference ellipsoid terminator point in the Ith half
%                   plane, the elements of `epochs' for that half plane
%                   will all be set to
%
%                      et - lt(i)
%
%
%      tangts       is an array of vectors connecting the observer to the
%                   terminator points. The terminator vectors are expressed
%                   in the frame designated by `fixref'. For the Ith
%                   vector, the orientation of the frame is evaluated at
%                   the Ith epoch provided in the output array `epochs'
%                   (described above).
%
%                   [3,n] = size(tangts); double = class(tangts)
%                   with n>= maxn
%
%                   The elements
%
%                      tangts(j,i), j = 1 to 3
%
%                   are associated with the terminator point
%
%                      points(j,i), j = 1 to 3
%
%                   Units of the terminator vectors are km.
%
%-Examples
%
%   Any numerical results shown for this example may differ between
%   platforms as the results depend on the SPICE kernels used as input
%   and the machine specific arithmetic implementation.
%
%   Example(1):
%
%      Find apparent terminator points on Phobos as seen from Mars.
%      Use the "umbral" shadow definition.
%
%      Due to Phobos' irregular shape, the TANGENT terminator point
%      definition will be used. It suffices to compute light time and
%      stellar aberration corrections for the center of Phobos, so
%      the CENTER aberration correction locus will be used. Use
%      converged Newtonian light time and stellar aberration
%      corrections in order to model the apparent position and
%      orientation of Phobos.
%
%      For comparison, compute terminator points using both ellipsoid
%      and topographic shape models.
%
%      Use the target body-fixed +Z axis as the reference direction
%      for generating cutting half-planes. This choice enables the
%      user to see whether the first terminator point is near the
%      target's north pole.
%
%      For each option, use just three cutting half-planes in order
%      to keep the volume of output manageable. In most applications,
%      the number of cuts and the number of resulting terminator
%      points would be much greater.
%
%      Use the meta-kernel below to load the required SPICE
%      kernels.
%
%
%         KPL/MK
%
%         File: limbpt_ex1.tm
%
%         This meta-kernel is intended to support operation of SPICE
%         example programs. The kernels shown here should not be
%         assumed to contain adequate or correct versions of data
%         required by SPICE-based user applications.
%
%         In order for an application to use this meta-kernel, the
%         kernels referenced here must be present in the user's
%         current working directory.
%
%         The names and contents of the kernels referenced
%         by this meta-kernel are as follows:
%
%            File name                        Contents
%            ---------                        --------
%            de430.bsp                        Planetary ephemeris
%            mar097.bsp                       Mars satellite ephemeris
%            pck00010.tpc                     Planet orientation and
%                                             radii
%            naif0011.tls                     Leapseconds
%            phobos512.bds                    DSK based on
%                                             Gaskell ICQ Q=512
%                                             Phobos plate model
%         \begindata
%
%            PATH_SYMBOLS    = 'GEN'
%            PATH_VALUES     = '/ftp/pub/naif/generic_kernels'
%
%            KERNELS_TO_LOAD = ( 'de430.bsp',
%                                'mar097.bsp',
%                                'pck00010.tpc',
%                                'naif0011.tls',
%                                '$GEN/dsk/phobos/phobos512.bds' )
%         \begintext
%
%
%      function termpt_t
%
%         MAXN = 10000;
%
%         method = { 'UMBRAL/TANGENT/ELLIPSOID', ...
%                    'UMBRAL/TANGENT/DSK/UNPRIORITIZED' };
%
%         z = [ 0.0, 0.0, 1.0 ]';
%
%         %
%         % Load kernel files via the meta-kernel.
%         %
%         cspice_furnsh( 'termpt_t.tm' )
%
%         %
%         % Set illumination source, target, observer,
%         % and target body-fixed, body-centered reference frame.
%         %
%         ilusrc = 'SUN';
%         obsrvr = 'MARS';
%         target = 'PHOBOS';
%         fixref = 'IAU_PHOBOS';
%
%         %
%         % Set aberration correction and correction locus.
%         %
%         abcorr = 'CN+S';
%         corloc = 'CENTER';
%
%         %
%         % Convert the UTC request time string to seconds past
%         % J2000, TDB.
%         %
%         et = cspice_str2et( '2008 AUG 11 00:00:00' );
%
%         %
%         % Compute a set of terminator points using light
%         % time and stellar aberration corrections. Use
%         % both ellipsoid and DSK shape models. Use an
%         % angular step size corresponding to a height of
%         % about 100 meters to ensure we don't miss the
%         % terminator. Set the convergence tolerance to limit
%         % the height convergence error to about 1 meter.
%         % Compute 3 terminator points for each computation
%         % method.
%         %
%         % Get the approximate light source-target distance
%         % at ET. We'll ignore the observer-target light
%         % time for this approximation.
%         %
%
%         [pos, lt] = cspice_spkpos( ilusrc, et, 'J2000', abcorr, target );
%
%         dist   = norm( pos );
%
%         schstp = 1.0e-1 / dist;
%         soltol = 1.0e-3 / dist;
%         ncuts  = 3;
%
%         fprintf ( ['\n'                    ...
%                  'Light source:   %s\n'    ...
%                  'Observer:       %s\n'    ...
%                  'Target:         %s\n'    ...
%                  'Frame:          %s\n'    ...
%                  '\n'                      ...
%                  'Number of cuts: %d\n' ], ...
%                  char(ilusrc),             ...
%                  char(obsrvr),             ...
%                  char(target),             ...
%                  char(fixref),             ...
%                  ncuts            );
%
%         delrol = cspice_twopi()/ ncuts;
%
%
%         for i = 1:numel(method)
%
%            [npts, points, trgeps, tangts] = cspice_termpt( method(i),...
%                                        ilusrc, target, et, fixref,   ...
%                                        abcorr, corloc, obsrvr, z,    ...
%                                        delrol, ncuts,  schstp,       ...
%                                        soltol, MAXN);
%
%            %
%            % Write the results.
%            %
%            fprintf ( ['\n'                      ...
%                     'Computation method = %s\n' ...
%                     'Locus              = %s\n' ...
%                     '\n'],                      ...
%                     char(method(i)),            ...
%                     corloc                     )
%
%            strt = 0;
%
%            for j = 1:ncuts
%
%               roll = (j-1) * delrol;
%
%               fprintf( [ '\n'                                ...
%                          '  Roll angle (deg) = %17.9f\n'     ...
%                          '     Target epoch  = %17.9f\n'     ...
%                          '     Number of terminator points ' ...
%                          'at this roll angle: %d\n'],        ...
%                          roll * cspice_dpr(),                ...
%                          trgeps(j),                          ...
%                          npts(j)                          )
%
%               fprintf( '      Terminator points:\n' )
%
%               for k = 1:npts(j)
%                  fprintf( ' %20.9f %20.9f %20.9f\n', points(1:3, k+strt) );
%                end
%
%                strt = npts(j) + strt;
%
%            end
%
%          end
%
%         fprintf( '\n' )
%
%   Matlab outputs:
%
%      Light source:   SUN
%      Observer:       MARS
%      Target:         PHOBOS
%      Frame:          IAU_PHOBOS
%
%      Number of cuts: 3
%
%      Computation method = UMBRAL/TANGENT/ELLIPSOID
%      Locus              = CENTER
%
%
%        Roll angle (deg) =       0.000000000
%           Target epoch  = 271684865.152078211
%           Number of terminator points at this roll angle: 1
%            Terminator points:
%                2.010972609          4.940189426          8.079440845
%
%        Roll angle (deg) =     120.000000000
%           Target epoch  = 271684865.152078211
%           Number of terminator points at this roll angle: 1
%            Terminator points:
%              -11.094156190          0.078493393         -4.743071402
%
%        Roll angle (deg) =     240.000000000
%           Target epoch  = 271684865.152078211
%           Number of terminator points at this roll angle: 1
%            Terminator points:
%                8.165936806         -6.165700043         -5.090383970
%
%      Computation method = UMBRAL/TANGENT/DSK/UNPRIORITIZED
%      Locus              = CENTER
%
%
%        Roll angle (deg) =       0.000000000
%           Target epoch  = 271684865.152078211
%           Number of terminator points at this roll angle: 1
%            Terminator points:
%                1.626396122          3.995432317          8.853689531
%
%        Roll angle (deg) =     120.000000000
%           Target epoch  = 271684865.152078211
%           Number of terminator points at this roll angle: 1
%            Terminator points:
%              -11.186659739         -0.142366278         -4.646137201
%
%        Roll angle (deg) =     240.000000000
%           Target epoch  = 271684865.152078211
%           Number of terminator points at this roll angle: 1
%            Terminator points:
%                9.338447077         -6.091352469         -5.960849305
%
%   Example(2):
%
%      Find apparent terminator points on Mars as seen from the
%      earth.
%
%      Use both the "umbral" and "penumbral" shadow definitions. Use
%      only ellipsoid shape models for easier comparison. Find
%      distances between corresponding terminator points on the
%      umbral and penumbral terminators.
%
%      Use the ELLIPSOID TERMINATOR aberration correction locus
%      in order to perform separate aberration corrections for
%      each terminator point. Because of the large size of Mars,
%      corrections for the target center are less accurate.
%
%      For each option, use just three cutting half-planes in order
%      to keep the volume of output manageable. In most applications,
%      the number of cuts and the number of resulting terminator
%      points would be much greater.
%
%      Use the meta-kernel below to load the required SPICE
%      kernels.
%
%
%         KPL/MK
%
%         File: termpt_ex2.tm
%
%         This meta-kernel is intended to support operation of SPICE
%         example programs. The kernels shown here should not be
%         assumed to contain adequate or correct versions of data
%         required by SPICE-based user applications.
%
%         In order for an application to use this meta-kernel, the
%         kernels referenced here must be present in the user's
%         current working directory.
%
%         The names and contents of the kernels referenced
%         by this meta-kernel are as follows:
%
%            File name                        Contents
%            ---------                        --------
%            de430.bsp                        Planetary ephemeris
%            mar097.bsp                       Mars satellite ephemeris
%            pck00010.tpc                     Planet orientation and
%                                             radii
%            naif0011.tls                     Leapseconds
%            megr90n000cb_plate.bds           Plate model based on
%                                             MEGDR DEM, resolution
%                                             4 pixels/degree.
%
%         \begindata
%
%            KERNELS_TO_LOAD = ( 'de430.bsp',
%                                'mar097.bsp',
%                                'pck00010.tpc',
%                                'naif0011.tls',
%                                'megr90n000cb_plate.bds' )
%
%         \begintext
%
%
%      function termpt_t2
%
%         META = 'termpt_t2.tm';
%
%         MAXN = 10000;
%
%         corloc = { 'ELLIPSOID TERMINATOR', 'ELLIPSOID TERMINATOR' };
%
%         ilumth = { 'ELLIPSOID', 'ELLIPSOID' };
%
%         method = { 'UMBRAL/TANGENT/ELLIPSOID', ...
%                    'PENUMBRAL/TANGENT/ELLIPSOID' };
%
%         z = [ 0.0, 0.0, 1.0 ]';
%
%         %
%         % Load kernel files via the meta-kernel.
%         %
%         cspice_furnsh( META )
%
%         %
%         % Set illumination source, target, observer,
%         % and target body-fixed, body-centered reference frame.
%         %
%         ilusrc = 'SUN';
%         obsrvr = 'EARTH';
%         target = 'MARS';
%         fixref = 'IAU_MARS';
%
%         %
%         % Set the aberration correction.
%         %
%         abcorr = 'CN+S';
%
%         %
%         % Convert the UTC request time string to seconds past
%         % J2000, TDB.
%         %
%         et = cspice_str2et( '2008 AUG 11 00:00:00' );
%
%
%         %
%         % Look up the target body's radii. We'll use these to
%         % convert Cartesian to planetographic coordinates. Use
%         % the radii to compute the flattening coefficient of
%         % the reference ellipsoid.
%         %
%         radii = cspice_bodvrd( target, 'RADII', 3 );
%
%         %
%         % Compute the flattening coefficient for planetodetic
%         % coordinates
%         %
%         re = radii(1);
%         rp = radii(3);
%         f  = ( re - rp ) / re;
%
%         %
%         % Get the radii of the illumination source as well.
%         % We'll use these radii to compute the angular radius
%         % of the source as seen from the terminator points.
%         %
%         srcrad = cspice_bodvrd( ilusrc, 'RADII', 3 );
%
%         %
%         % Compute a set of terminator points using light time and
%         % stellar aberration corrections. Use both ellipsoid
%         % and DSK shape models.
%         %
%         % Get the approximate light source-target distance
%         % at ET. We'll ignore the observer-target light
%         % time for this approximation.
%
%         [ilupos, lt] = cspice_spkpos( ilusrc, et, fixref, abcorr, target );
%
%         dist = cspice_vnorm( ilupos );
%
%         %
%         % Set the angular step size so that a single step will
%         % be taken in the root bracketing process; that's all
%         % that is needed since we don't expect to have multiple
%         % terminator points in any cutting half-plane.
%         %
%         schstp = 4.0;
%
%         %
%         % Set the convergence tolerance to minimize the
%         % height error. We can't achieve the precision
%         % suggested by the formula because the sun-Mars
%         % distance is about 2.4e8 km. Compute 3 terminator
%         % points for each computation method.
%         %
%         soltol = 1.e-7/dist;
%
%         %
%         % Set the number of cutting half-planes and roll step.
%         %
%         ncuts  = 3;
%         delrol = cspice_twopi() / ncuts;
%
%
%         fprintf( ['\n'                    ...
%                  'Light source:   %s\n'   ...
%                  'Observer:       %s\n'   ...
%                  'Target:         %s\n'   ...
%                  'Frame:          %s\n'   ...
%                  '\n'                     ...
%                  'Number of cuts: %d\n'], ...
%                  ilusrc,   ...
%                  obsrvr,   ...
%                  target,   ...
%                  fixref,   ...
%                  ncuts            );
%
%         delrol = cspice_twopi() / ncuts;
%
%
%         for i = 1:numel(method)
%
%            [npts, points, trgeps, tangts] = cspice_termpt( method(i), ...
%                                   ilusrc, target, et,                 ...
%                                   fixref, abcorr, corloc(i), obsrvr,  ...
%                                   z,      delrol, ncuts,  schstp,     ...
%                                   soltol, MAXN  );
%            %
%            % Write the results.
%            %
%            fprintf(['\n\n'                        ...
%                     'Computation method = %s\n'   ...
%                     'Locus              = %s\n'], ...
%                     char(method(i)),              ...
%                     char(corloc(i))                );
%
%            start = 0;
%
%
%            for j = 1:ncuts
%
%               roll = (j-1) * delrol;
%
%               fprintf(['\n'                                  ...
%                        '   Roll angle (deg) = %17.9f\n'      ...
%                        '    Target epoch  = %17.9f\n'        ...
%                        '    Number of terminator points at ' ...
%                        'this roll angle: %d\n'],             ...
%                        roll * cspice_dpr(),                  ...
%                        trgeps(j),                            ...
%                        npts(j)                            );
%
%               for k = 1:npts(j)
%
%                  fprintf( ['    Terminator point planetodetic ' ...
%                            'coordinates:\n'] );
%
%                  m = k+start;
%
%                  [lon, lat, alt] = cspice_recgeo( points(1:3, m), re, f );
%
%                  fprintf(['      Longitude        (deg): %20.9f\n'  ...
%                           '      Latitude         (deg): %20.9f\n'  ...
%                           '      Altitude          (km): %20.9f\n'],...
%                           lon * cspice_dpr(),                       ...
%                           lat * cspice_dpr(),                       ...
%                           alt                                     );
%
%                  %
%                  % Get illumination angles for this terminator point.
%                  %
%
%                  [trgepc, srfvec, phase, solar, emissn ] =            ...
%                     cspice_illumg ( ilumth(i), target,  ilusrc, et,   ...
%                                     fixref,    abcorr,  obsrvr,       ...
%                                     points(1:3, m) );
%
%                  fprintf( '      Incidence angle  (deg): %20.9f\n', ...
%                                               solar * cspice_dpr() );
%
%                  %
%                  % Adjust the incidence angle for the angular
%                  % radius of the illumination source. Use the
%                  % epoch associated with the terminator point
%                  % for this lookup.
%                  %
%                  [tptilu, lt] = cspice_spkpos( ilusrc, trgeps(m), fixref, ...
%                                                abcorr, target);
%
%                  dist   = cspice_vnorm( tptilu );
%
%                  angsrc = asin( max( srcrad ) / dist );
%
%                  if  i == 1
%
%                     %
%                     % For points on the umbral terminator,
%                     % the ellipsoid outward normal is tilted
%                     % away from the terminator-source center
%                     % direction by the angular radius of the
%                     % source. Subtract this radius from the
%                     % illumination incidence angle to get the
%                     % angle between the local normal and the
%                     % direction to the corresponding tangent
%                     % point on the source.
%                     %
%                     adjang = solar - angsrc;
%
%                  else
%
%                     %
%                     % For the penumbral case, the outward
%                     % normal is tilted toward the illumination
%                     % source by the angular radius of the
%                     % source. Adjust the illumination
%                     % incidence angle for this.
%                     %
%                     adjang = solar + angsrc;
%
%                  end
%
%                  fprintf( '      Adjusted angle   (deg): %20.9f\n', ...
%                                              adjang * cspice_dpr() );
%
%                   if  i == 1
%
%                     %
%                     % Save terminator points for comparison.
%                     %
%                     svpnts(1:3,m) = points(1:3,m);
%
%                  else
%
%                     %
%                     % Compare terminator points with last
%                     % saved values.
%                     %
%                     dist = cspice_vdist( points(1:3,m), svpnts(1:3,m) );
%
%                     fprintf( '      Distance offset  (km):  %20.9f\n', dist );
%                  end
%
%
%               end
%
%               start = start + npts(j);
%
%            end
%
%         end
%
%         fprintf( '\n' );
%
%   Matlab outputs:
%
%      Light source:   SUN
%      Observer:       EARTH
%      Target:         MARS
%      Frame:          IAU_MARS
%
%      Number of cuts: 3
%
%
%      Computation method = UMBRAL/TANGENT/ELLIPSOID
%      Locus              = ELLIPSOID TERMINATOR
%
%         Roll angle (deg) =       0.000000000
%          Target epoch  = 271683700.369686961
%          Number of terminator points at this roll angle: 1
%          Terminator point planetodetic coordinates:
%            Longitude        (deg):          4.189318082
%            Latitude         (deg):         66.416480232
%            Altitude          (km):          0.000000000
%            Incidence angle  (deg):         90.163495329
%            Adjusted angle   (deg):         89.999652424
%
%         Roll angle (deg) =     120.000000000
%          Target epoch  = 271683700.372003794
%          Number of terminator points at this roll angle: 1
%          Terminator point planetodetic coordinates:
%            Longitude        (deg):        107.074700561
%            Latitude         (deg):        -27.604369253
%            Altitude          (km):          0.000000000
%            Incidence angle  (deg):         90.163695259
%            Adjusted angle   (deg):         89.999852354
%
%         Roll angle (deg) =     240.000000000
%          Target epoch  = 271683700.364983678
%          Number of terminator points at this roll angle: 1
%          Terminator point planetodetic coordinates:
%            Longitude        (deg):        -98.696194105
%            Latitude         (deg):        -27.604306943
%            Altitude          (km):          0.000000000
%            Incidence angle  (deg):         90.163557125
%            Adjusted angle   (deg):         89.999714220
%
%
%      Computation method = PENUMBRAL/TANGENT/ELLIPSOID
%      Locus              = ELLIPSOID TERMINATOR
%
%         Roll angle (deg) =       0.000000000
%          Target epoch  = 271683700.369747460
%          Number of terminator points at this roll angle: 1
%          Terminator point planetodetic coordinates:
%            Longitude        (deg):          4.189317837
%            Latitude         (deg):         66.744220775
%            Altitude          (km):          0.000000000
%            Incidence angle  (deg):         89.835754787
%            Adjusted angle   (deg):         89.999597692
%            Distance offset  (km):          19.486848029
%
%         Roll angle (deg) =     120.000000000
%          Target epoch  = 271683700.372064054
%          Number of terminator points at this roll angle: 1
%          Terminator point planetodetic coordinates:
%            Longitude        (deg):        107.404444520
%            Latitude         (deg):        -27.456375067
%            Altitude          (km):          0.000000000
%            Incidence angle  (deg):         89.835973222
%            Adjusted angle   (deg):         89.999816127
%            Distance offset  (km):          19.413571668
%
%         Roll angle (deg) =     240.000000000
%          Target epoch  = 271683700.365043938
%          Number of terminator points at this roll angle: 1
%          Terminator point planetodetic coordinates:
%            Longitude        (deg):        -99.025849383
%            Latitude         (deg):        -27.456352441
%            Altitude          (km):          0.000000000
%            Incidence angle  (deg):         89.835923040
%            Adjusted angle   (deg):         89.999765945
%            Distance offset  (km):          19.408359649
%
%-Particulars
%
%   Using DSK data
%   ==============
%
%      DSK loading and unloading
%      -------------------------
%
%      DSK files providing data used by this routine are loaded by
%      calling cspice_furnsh and can be unloaded by calling cspice_unload or
%      cspice_kclear. See the documentation of cspice_furnsh for limits on
%      numbers of loaded DSK files.
%
%      For run-time efficiency, it's desirable to avoid frequent
%      loading and unloading of DSK files. When there is a reason to
%      use multiple versions of data for a given target body---for
%      example, if topographic data at varying resolutions are to be
%      used---the surface list can be used to select DSK data to be
%      used for a given computation. It is not necessary to unload
%      the data that are not to be used. This recommendation presumes
%      that DSKs containing different versions of surface data for a
%      given body have different surface ID codes.
%
%
%      DSK data priority
%      -----------------
%
%      A DSK coverage overlap occurs when two segments in loaded DSK
%      files cover part or all of the same domain---for example, a
%      given longitude-latitude rectangle---and when the time
%      intervals of the segments overlap as well.
%
%      When DSK data selection is prioritized, in case of a coverage
%      overlap, if the two competing segments are in different DSK
%      files, the segment in the DSK file loaded last takes
%      precedence. If the two segments are in the same file, the
%      segment located closer to the end of the file takes
%      precedence.
%
%      When DSK data selection is unprioritized, data from competing
%      segments are combined. For example, if two competing segments
%      both represent a surface as sets of triangular plates, the
%      union of those sets of plates is considered to represent the
%      surface.
%
%      Currently only unprioritized data selection is supported.
%      Because prioritized data selection may be the default behavior
%      in a later version of the routine, the UNPRIORITIZED keyword is
%      required in the `method' argument.
%
%
%      Syntax of the `method' input argument
%      -------------------------------------
%
%      The keywords and surface list in the `method' argument
%      are called "clauses." The clauses may appear in any
%      order, for example
%
%         UMBRAL/TANGENT/DSK/UNPRIORITIZED/<surface list>
%         DSK/UMBRAL/TANGENT/<surface list>/UNPRIORITIZED
%         UNPRIORITIZED/<surface list>/DSK/TANGENT/UMBRAL
%
%      The simplest form of the `method' argument specifying use of
%      DSK data is one that lacks a surface list, for example:
%
%         'PENUMBRAL/TANGENT/DSK/UNPRIORITIZED'
%         'UMBRAL/GUIDED/DSK/UNPRIORITIZED'
%
%      For applications in which all loaded DSK data for the target
%      body are for a single surface, and there are no competing
%      segments, the above strings suffice. This is expected to be
%      the usual case.
%
%      When, for the specified target body, there are loaded DSK
%      files providing data for multiple surfaces for that body, the
%      surfaces to be used by this routine for a given call must be
%      specified in a surface list, unless data from all of the
%      surfaces are to be used together.
%
%      The surface list consists of the string
%
%         SURFACES =
%
%      followed by a comma-separated list of one or more surface
%      identifiers. The identifiers may be names or integer codes in
%      string format. For example, suppose we have the surface
%      names and corresponding ID codes shown below:
%
%         Surface Name                              ID code
%         ------------                              -------
%         "Mars MEGDR 128 PIXEL/DEG"                1
%         "Mars MEGDR 64 PIXEL/DEG"                 2
%         "Mars_MRO_HIRISE"                         3
%
%      If data for all of the above surfaces are loaded, then
%      data for surface 1 can be specified by either
%
%         'SURFACES = 1'
%
%      or
%
%         'SURFACES = "Mars MEGDR 128 PIXEL/DEG"'
%
%      Double quotes are used to delimit the surface name because
%      it contains blank characters.
%
%      To use data for surfaces 2 and 3 together, any
%      of the following surface lists could be used:
%
%         'SURFACES = 2, 3'
%
%         'SURFACES = "Mars MEGDR  64 PIXEL/DEG", 3'
%
%         'SURFACES = 2, Mars_MRO_HIRISE'
%
%         'SURFACES = "Mars MEGDR 64 PIXEL/DEG", Mars_MRO_HIRISE'
%
%      An example of a `method' argument that could be constructed
%      using one of the surface lists above is
%
%      'NADIR/DSK/UNPRIORITIZED/SURFACES= "Mars MEGDR 64 PIXEL/DEG",3'
%
%-Required Reading
%
%   For important details concerning this module's function, please refer to
%   the CSPICE routine termpt_c.
%
%   MICE.REQ
%   CK.REQ
%   DSK.REQ
%   FRAMES.REQ
%   NAIF_IDS.REQ
%   PCK.REQ
%   SPK.REQ
%   TIME.REQ
%
%-Version
%
%   -Mice Version 1.0.0, 15-DEC-2016, EDW (JPL), NJB (JPL), ML (JPL)
%
%-Index_Entries
%
%   find terminator points on target body
%
%-&

function [npts, points, epochs, tangts] = cspice_termpt( method, ilusrc,  ...
                                            target, et,   fixref, abcorr, ...
                                            corloc, obsrvr, refvec,       ...
                                            rolstp, ncuts,  schstp,       ...
                                            soltol, maxn )

   switch nargin
      case 14

         method = zzmice_str(method);
         ilusrc = zzmice_str(ilusrc);
         target = zzmice_str(target);
         et     = zzmice_dp(et);
         fixref = zzmice_str(fixref);
         abcorr = zzmice_str(abcorr);
         corloc = zzmice_str(corloc);
         obsrvr = zzmice_str(obsrvr);
         refvec = zzmice_dp(refvec);
         rolstp = zzmice_dp(rolstp);
         ncuts  = zzmice_int(ncuts);
         schstp = zzmice_dp(schstp);
         soltol = zzmice_dp(soltol);
         maxn   = zzmice_int(maxn);

      otherwise

         error ( ['Usage: [npts, points, epochs, tangts] = '      ...
                  'cspice_termpt( `method`, `ilusrc`, `target`, ' ...
                                 'et, `fixref`, `abcorr`, '       ...
                                 '`corloc`, `obsrvr`, refvec, '   ...
                                 'rolstp, ncuts, schstp, '        ...
                                 'soltol, maxn )' ]  )

   end

   %
   % Call the MEX library.
   %
   try
      [npts, points, epochs, tangts] = mice( 'termpt_c',                  ...
                                                  method, ilusrc, target, ...
                                                  et,     fixref, abcorr, ...
                                                  corloc, obsrvr, refvec, ...
                                                  rolstp, ncuts,  schstp, ...
                                                  soltol, maxn );
   catch
      rethrow(lasterror)
   end



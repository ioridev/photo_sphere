/************************************************************************/
/*                                                                      */
/*        Copyright 2008-2009 by Rahul Nair and Ullrich Koethe          */
/*                                                                      */
/*    This file is part of the VIGRA computer vision library.           */
/*    The VIGRA Website is                                              */
/*        http://hci.iwr.uni-heidelberg.de/vigra/                       */
/*    Please direct questions, bug reports, and contributions to        */
/*        ullrich.koethe@iwr.uni-heidelberg.de    or                    */
/*        vigra@informatik.uni-hamburg.de                               */
/*                                                                      */
/*    Permission is hereby granted, free of charge, to any person       */
/*    obtaining a copy of this software and associated documentation    */
/*    files (the "Software"), to deal in the Software without           */
/*    restriction, including without limitation the rights to use,      */
/*    copy, modify, merge, publish, distribute, sublicense, and/or      */
/*    sell copies of the Software, and to permit persons to whom the    */
/*    Software is furnished to do so, subject to the following          */
/*    conditions:                                                       */
/*                                                                      */
/*    The above copyright notice and this permission notice shall be    */
/*    included in all copies or substantial portions of the             */
/*    Software.                                                         */
/*                                                                      */
/*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND    */
/*    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES   */
/*    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND          */
/*    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT       */
/*    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,      */
/*    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      */
/*    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR     */
/*    OTHER DEALINGS IN THE SOFTWARE.                                   */
/*                                                                      */
/************************************************************************/

/*++++++++++++++++++++INCLUDES+and+Definitions++++++++++++++++++++++++*/

#include <vigra/matlab.hxx>

#include <vigra/resizeimage.hxx>



using namespace vigra;
using namespace matlab;

/*+++++++++++++++++++User data structure+++++++++++++++++++++++++++++*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
//This is not using base_data as base class. because input is 4D.



/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* This function does all the work
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/


//#define RN_DEBUG
#define cP2_(a, b) cP<(int)a, b>::value
template <class T>
void vigraMain(matlab::OutputArray outputs, matlab::InputArray inputs){
    /***************************************************************************************************
    **              INIT PART                                                                         **
    ****************************************************************************************************/
    //Load input Image
    MultiArrayView<3,T>         in3D        = inputs.getMultiArray<3,T>(0, v_required());

    //Load Method Option
    VIGRA_CREATE_ENUM_AND_STD_MAP3(MapName, BSpline, Catmull, Coscot)
    int method = inputs.getEnum("method", v_default(BSpline), MapName );


    //Load spline Order option
    Int32                         splineOrder = (method == BSpline)?
                                          inputs.getScalarMinMax<int>("splineOrder", v_default(3),0, 5)
                                        : 0;
    //Load new Shape
    TinyVector<double, 2>       defaultShape(2*in3D.shape(0) -1, 2*in3D.shape(1)-1);
    TinyVectorView<double, 2>   newShape  = inputs.getTinyVector<double, 2> ( 1, v_default(defaultShape));
    MultiArrayShape<3>::type    newShape3      (Int32(newShape[0]), Int32(newShape[1]), in3D.shape(2));


    //Allocate Memory for output
    MultiArrayView<3,T>         out3D     = outputs.createMultiArray<3,T>   (0, v_required(), newShape3);

    /***************************************************************************************************
    **              CODE PART                                                                         **
    ****************************************************************************************************/
    // cantorPair maps 2 integers bijectively onto one dimension. (see Wikipedia Cantor pair Function)
    for(int k=0; k<in3D.shape(2); ++k)
    {

        BasicImageView<T> ink = makeBasicImageView(in3D.bindOuter(k));
        BasicImageView<T> outk = makeBasicImageView(out3D.bindOuter(k));

        switch(cantorPair(method, splineOrder))
        {
        case cP2_(BSpline, 0):
            #ifdef RN_DEBUG
            mexWarnMsgTxt("BSpline 0");
            #endif
            resizeImageNoInterpolation(srcImageRange(ink), destImageRange(outk));
            break;
        case cP2_(BSpline, 1):
            #ifdef RN_DEBUG
            mexWarnMsgTxt("BSpline 1");
            #endif
            resizeImageLinearInterpolation(srcImageRange(ink), destImageRange(outk));
            break;
        case cP2_(BSpline, 2):
            #ifdef RN_DEBUG
            mexWarnMsgTxt("BSpline 2");
            #endif
            resizeImageSplineInterpolation(srcImageRange(ink), destImageRange(outk), vigra::BSpline<2>());
            break;
        case cP2_(BSpline, 3):
            #ifdef RN_DEBUG
            mexWarnMsgTxt("BSpline 3");
            #endif
            resizeImageSplineInterpolation(srcImageRange(ink), destImageRange(outk), vigra::BSpline<3>());
            break;
        case cP2_(BSpline, 4):
            #ifdef RN_DEBUG
            mexWarnMsgTxt("BSpline 4");
            #endif
            resizeImageSplineInterpolation(srcImageRange(ink), destImageRange(outk), vigra::BSpline<4>());
            break;
        case cP2_(BSpline, 5):
            #ifdef RN_DEBUG
            mexWarnMsgTxt("BSpline 5");
            #endif
            resizeImageSplineInterpolation(srcImageRange(ink), destImageRange(outk), vigra::BSpline<5>());
            break;
        case cP2_(Catmull, 0):
            #ifdef RN_DEBUG
            mexWarnMsgTxt("Catmull 0");
            #endif
            resizeImageCatmullRomInterpolation(srcImageRange(ink), destImageRange(outk));
            break;
        case cP2_(Coscot, 0):
            #ifdef RN_DEBUG
            mexWarnMsgTxt("Coscot 0");
            #endif
            resizeImageCoscotInterpolation(srcImageRange(ink), destImageRange(outk));
            break;
        default:
            mexErrMsgTxt("Internal Error");
        }
    }

}


/***************************************************************************************************
**           VIGRA GATEWAY                                                                        **
****************************************************************************************************/
void vigraMexFunction(vigra::matlab::OutputArray outputs, vigra::matlab::InputArray inputs)
{
    //Add classes as you feel
    switch(inputs.typeOf(0))
    {
        ALLOW_D
        default:
            mexErrMsgTxt("Type of input 0 not supported");
    }
}


/** MATLAB
function resized = vigraResize2(original)
function resized = vigraResize2(original, newShape)
function resized = vigraResize2(original, newShape, options)

D = vigraResize2(inputImage)   # resizes original image data with default options.
D = vigraResize2(inputImage, [200 300], options)  # does the same with user options.

    original    - Array with original 2D image data
                    (gray scale or multi-band/RGB, numeric type)
    newShape    - standard Array of length 2 that gives the new shape
                    (default: 2*size(original)-1 )
    options
        splineOrder - order of interpolation
            (0 <= splineOrder <= 5, default: 3, i.e. cubic splines)
            this option is only used for method 'BSpline'
        method - 'BSpline' (default), 'Coscot' or 'Catmull'
*/

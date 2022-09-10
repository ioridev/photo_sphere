/************************************************************************/
/*                                                                      */
/*               Copyright 1998-2002 by Ullrich Koethe                  */
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
 

#include <iostream>
#include "vigra/stdimage.hxx"
#include "vigra/stdimagefunctions.hxx"
#include "vigra/impex.hxx"

using namespace vigra; 

int main(int argc, char ** argv)
{
    if(argc != 3)
    {
        std::cout << "Usage: " << argv[0] << " infile outfile" << std::endl;
        std::cout << "(supported formats: " << vigra::impexListFormats() << ")" << std::endl;
        
        return 1;
    }
    
    try
    {
        vigra::ImageImportInfo info(argv[1]);
        
        // define upper left and lower right corners of a 
        // subimage (region of interest)
        int sub_x0 = info.width() / 4;
        int sub_y0 = info.height() / 4;
        int sub_x1 = info.width() - sub_x0;
        int sub_y1 = info.height() - sub_y0;
            
        if(info.isGrayscale())
        {
            vigra::BImage in(info.width(), info.height());
            
            importImage(info, destImage(in));
            
            // create output image of appropriate size
            vigra::BImage out(sub_x1 - sub_x0, sub_y1 - sub_y0);
            
            // copy region of interest by moving the input 
            // iterators to the appropriate positions
            copyImage(srcIterRange(in.upperLeft() + vigra::Diff2D(sub_x0, sub_y0),
                                   in.upperLeft() + vigra::Diff2D(sub_x1, sub_y1)),
                      destImage(out));
            
            exportImage(srcImageRange(out), vigra::ImageExportInfo(argv[2]));
        }
        else
        {
            vigra::BRGBImage in(info.width(), info.height());
            
            importImage(info, destImage(in));
            
            // create output image of appropriate size
            vigra::BRGBImage out(sub_x1 - sub_x0, sub_y1 - sub_y0);
            
            // copy region of interest by moving the input 
            // iterators to the appropriate positions
            copyImage(srcIterRange(in.upperLeft() + vigra::Diff2D(sub_x0, sub_y0),
                                   in.upperLeft() + vigra::Diff2D(sub_x1, sub_y1)),
                      destImage(out));
            
            exportImage(srcImageRange(out), vigra::ImageExportInfo(argv[2]));
        }
    }
    catch (vigra::StdException & e)
    {
        std::cout << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}

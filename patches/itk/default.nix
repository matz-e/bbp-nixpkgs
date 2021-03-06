{ stdenv, fetchurl, cmake, libX11, libuuid, xz, vtk, zlib, libjpeg, expat, vxl, gdcm }:

stdenv.mkDerivation rec {
  name = "itk-4.10.0";

  src = fetchurl {
    url = mirror://sourceforge/itk/InsightToolkit-4.10.0.tar.xz;
    sha256 = "0pxijhqsnwcp9jv1d8p11hsj90k8ajpwxhrnn8kk8c56k7y1207a";
  };

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=ON"

    # disable default modules
    "-DITK_BUILD_DEFAULT_MODULES=OFF"
     "-DModule_ITKImageGrid=ON"
#    "-DModule_ITKIOMINC=ON"
#    "-DModule_ITKVtkGlue=ON"
#    "-DModule_ITKReview=ON"



    # disable bundling
    "-DITK_USE_SYSTEM_HDF5=ON"
    "-DITK_USE_SYSTEM_ZLIB=ON"
    "-DITK_USE_SYSTEM_JPEG=ON"
    "-DITK_USE_SYSTEM_EXPAT=ON"
#    "-DITK_USE_SYSTEM_VXL=ON"
#    "-DITK_USE_SYSTEM_GDCM=ON"

  ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake xz ];
  buildInputs = [ libX11 libuuid vtk zlib expat libjpeg ];

  meta = {
    description = "Insight Segmentation and Registration Toolkit";
    homepage = http://www.itk.org/;
    license = stdenv.lib.licenses.asl20;
    maintainers = with stdenv.lib.maintainers; [viric];
    platforms = with stdenv.lib.platforms; linux ++ darwin;
  };
}

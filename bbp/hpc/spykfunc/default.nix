{ boost
, config
, fetchgitPrivate
, hdf5
, pythonPackages
, spark-bbp
, stdenv
}:

let
  python-env = with stdenv.lib; with pythonPackages; python.buildEnv.override {
    extraLibs = [
      docopt
      future
      h5py
      lazy_property
      lxml
      pip
      progress
      pyspark
      requests
      setuptools
      setuptools_scm
      snakebite
      sparkmanager
      spark-bbp
      sphinx
      sphinx_rtd_theme
    ]
    ++ optionals enum34Required [ enum34 ]
    ;
  };
  python = pythonPackages.python;
  enum34Required = !stdenv.lib.versionAtLeast python.pythonVersion "3.4";
in

  stdenv.mkDerivation rec {
    name = "spykfunc-${version}";
    version = "0.8.1";
    meta = {
      description = "New Functionalizer implementation on top of Spark";
      longDescription = ''
        Functionalizer takes as input the touches information output by the
        BlueDetector and applies the distributed approach of parallel
        transposition of a matrix (representing neurons connections), in order
        to perform several steps of filtering and output the final synapses as
        hdf5 files. It does all IO operations using MPI IO and hdf5 IO - uses
        parallel hdf5 when available.
      '';
      platforms = stdenv.lib.platforms.unix;
      homepage = "https://bbpteam.epfl.ch/project/spaces/display/BBPHPC/Spark+functionalizer";
      repository = "ssh://bbpcode.epfl.ch/building/Functionalizer";
      license = {
        fullName = "Copyright 2018, Blue Brain Project";
      };
      maintainers = [
        config.maintainers.ferdonline
        config.maintainers.matze
      ];
    };
    src = fetchgitPrivate {
      url = config.bbp_git_ssh + "/building/Functionalizer";
      rev = "245363f02b45dbeb2b0a0c9ee2b750541b891df8";
      sha256 = "0wj26w9y74vmjq8c3a0gzvnx3rrvkbjp95aahsa7dymcbgk2iv8z";
    };
    patches = [] ++ stdenv.lib.optionals (!enum34Required) [
      # old setuptools version does not support environment markers
      # this patch may not be required once migrated to Nix 2017.09
      ./0001-Do-not-depends-on-enum34-with-Python-3.5-or-higher.patch
    ];

    buildInputs = [ boost hdf5 ];
    nativeBuildInputs = [
      python-env
    ];
    outputs = [ "out" "doc" ];

    buildPhase = ''
      runHook preBuild

      mkdir -p $out
      pushd pyspark
      export PYTHONPATH=${pythonPackages.setuptools}/${python.sitePackages}:$PYTHONPATH}
      for target in build docs; do
        echo "buildPhase: executing target $target"
        ${python-env.interpreter} setup.py $target
      done
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/${python.sitePackages}"

      export PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH"
      echo $PYTHONPATH

      pushd pyspark
      echo "installPhase: install package in $out"
      ${python-env.interpreter} setup.py install \
        --install-lib=$out/${python.sitePackages} \
        --old-and-unmanageable \
        --prefix="$out"

      mkdir -p $out/share/doc
      cp -r docs/_build/html $out/share/doc/
      popd

      runHook postInstall
    '';

    passthru = {
      pythonPackages = pythonPackages;
    };
  }

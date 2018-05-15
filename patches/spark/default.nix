{ fetchzip
, stdenv
, sparkOrigin
}:

with stdenv.lib;

let
  version = "2.2.1";
in

(sparkOrigin.override {
  RSupport = false;
  mesosSupport = false;
}).overrideAttrs ( oldAttr: rec {
  version = "2.2.1";
  hadoopVersion = "hadoop2.7";

  name = "spark-${version}-bbp";
  src = fetchzip {
    url = "https://github.com/matz-e/bbp-spark/releases/download/${version}/${name}-bin-${hadoopVersion}.tgz";
    sha256 = "1lhp3jcrx7s1c6ph0wkc99vprbhq6qb3cqa88gwdwq6gf34j57yq";
  };
})

{ lib
, aenum
, buildPythonPackage
, fetchPypi
, pythonOlder
, requests
, simplejson
}:

buildPythonPackage rec {
  pname = "wallbox";
  version = "0.6.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-COZHMkAbTFZKi/b4e6toC4gPj1MPfGN4aBVi6SglrBI=";
  };

  propagatedBuildInputs = [
    aenum
    requests
    simplejson
  ];

  # no tests implemented
  doCheck = false;

  pythonImportsCheck = [
    "wallbox"
  ];

  meta = with lib; {
    description = "Module for interacting with Wallbox EV charger api";
    homepage = "https://github.com/cliviu74/wallbox";
    changelog = "https://github.com/cliviu74/wallbox/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ dotlambda ];
  };
}

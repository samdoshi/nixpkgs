{ lib
, python3
, fetchPypi
}:

let
  python = python3.override {
    packageOverrides = self: super: {
      django = super.django_3.overridePythonAttrs (old: rec {
        version = "3.1.14";
        src = old.src.override {
          inherit version;
          hash = "sha256-cqSloTaiFMOc8BbM3Wtp4qoIx0ecZtk/OpteS7nYo0c=";
        };
        meta = old.meta // {
          knownVulnerabilities = [
            "CVE-2021-45115"
            "CVE-2021-45116"
            "CVE-2021-45452"
            "CVE-2022-23833"
            "CVE-2022-22818"
            "CVE-2022-28347"
            "CVE-2022-28346"
          ];
        };
      });
    };
  };
in

python.pkgs.buildPythonApplication rec {
  pname = "archivebox";
  version = "0.6.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-zHty7lTra6yab9d0q3EqsPG3F+lrnZL6PjQAbL1A2NY=";
  };

  propagatedBuildInputs = with python.pkgs; [
    requests
    mypy-extensions
    django
    django-extensions
    dateparser
    youtube-dl
    python-crontab
    croniter
    w3lib
    ipython
  ];

  meta = with lib; {
    description = "Open source self-hosted web archiving";
    homepage = "https://archivebox.io";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

{ mkXfceDerivation, docbook_xsl, exo, gtk3, libburn, libisofs, libxfce4ui, libxslt }:

mkXfceDerivation {
  category = "apps";
  pname = "xfburn";
  version = "0.6.2";

  sha256 = "sha256-AUonNhMs2HBF1WBLdZNYmASTOxYt6A6WDKNtvZaGXQk=";

  nativeBuildInputs = [ libxslt docbook_xsl ];
  buildInputs = [ exo gtk3 libburn libisofs libxfce4ui ];
}

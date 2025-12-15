{ pkgs, ... }:
{
  # Document conversion tools
  # antiword - converts MS Word documents to text/PDF
  # catdoc - converts MS Word/Excel/PowerPoint to text
  # pandoc - universal document converter
  home.packages = with pkgs; [
    antiword
    catdoc
    pandoc
  ];
}

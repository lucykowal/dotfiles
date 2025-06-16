#!/usr/local/bin/gawk -f

# Generate a Markdown Table of Contents from headings in a Markdown file

$0 ~ /^#+ .*/ {
  # Create the bullet point, with indentation
  bullet = gensub(/^#([#]*) *([^ ].*)/, "\\1-", "g", $0);
  gsub(/#/, "  ", bullet);

  # Capture the title
  title = gensub(/^#([#]*) *([^ ].*)/, "\\2", "g", $0);

  # Create an unique anchor
  anchor = tolower(title);
  gsub(/^\s+|\s+$/, "", anchor);
  gsub(/\s+/, "-", anchor);
  gsub(/[_]/, "", anchor);
  gsub(/[^[:alnum:]-]/, "", anchor);
  if (anchor in arr)
  {
    arr[anchor]++;
    anchor = anchor "-" arr[anchor];
  }
  else
    arr[anchor] = 0;

  printf "%s [%s](#%s)\n", bullet, title, anchor;
}

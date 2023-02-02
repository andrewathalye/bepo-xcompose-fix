bepo-xcompose-fix
============
BÉPO have released an XCompose file for Linux, however its format is
syntactically invalid, and as a result it does not work on all distros or in
all programs.

This utility takes a released XCompose file and converts it into the correct
format. A converted XCompose file is available as `XCompose` in the repository root.

Technical Details
-----------------
The files released by BÉPO look like this:
> `<dead_abovedot> <U0249> : U025F`

The correct format is like this:
> `<dead_abovedot> <U0249> : "ɟ" 025F`

The same issue occurs with XKB symbols, so this utility looks those up using
libxkbcommon and then inserts the characters as needed.

License
-------
All code is licensed under the GPLv3, however the layout itself is
dual-licensed under CC-BY-SA and the GFDL, as is the original.


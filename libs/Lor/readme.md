# Libraries for addons written by Lorand

These contain functions that I use frequently in multiple addons that I have
written.  Rather than continuously duplicating functions and potentially having
them be slightly different in each location, I have put them all together here.

## Installation:

Create a folder called 'lor' in .../Windower/addons/libs/

I.e., place these files in .../Windower/addons/libs/lor/

## Notes:

When using lor_utils version 2016.07.24 and later, it is possible to require
specific lib file versions.  When the version of the lib that another addon
requires is higher than the version you have, an error is raised (usually caught
in your chat log) to indicate that you need to download the latest version.  The
lib will be loaded regardless of whether or not it meets the version
requirements, but errors may be thrown elsewhere by the addon using it due to
new required functionality that isn't available in the old version.

Any version >= the required version will be accepted.

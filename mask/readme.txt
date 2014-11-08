DOCUMENTATION OVERVIEW
======================
Documentation for this library can be found in the DOC_* classes (start with DOC_LIBRARY_MASK) and are best interactively viewed through the Eiffel Studio IDE from the "test" target in MASK.ECF.

NOTE: Except for Pick-and-Drop, all documentation files are "Notepad-friendly". Eiffel Studio is not required. However, for a better experience, Eiffel Studio is recommended.

ALSO: (if you prefer) Navigate to:

https://github.com/ljr1981/masking_library/blob/master/mask/documentation/doc_library_mask.e

For Cluster Documentation, navigate to:

https://github.com/ljr1981/masking_library/blob/master/mask/documentation/doc_cluster_common.e
https://github.com/ljr1981/masking_library/blob/master/mask/documentation/doc_cluster_misc.e
https://github.com/ljr1981/masking_library/blob/master/mask/documentation/doc_cluster_numeric.e
https://github.com/ljr1981/masking_library/blob/master/mask/documentation/doc_cluster_string.e

LEARNING PATH
=============
Starting with DOC_LIBRARY_MASK.E, you can learn about the library at a high level, then drill down to the clusters, and finally to the classes. You will also find examples in either the masking demo or in the *_TEST classes of the test target.


WHAT TO EXPECT
==============
When you open the DOC_LIBRARY_MASK class, notice the documentation structure.

Library, Cluster, Class, and Class-feature level notes are expressed as Note-entry constructs (see ECMA-367 8.4.3 Page 34). 

Each Note-name represents a category of information (e.g. title, description, purpose, how, and so on). 

The categories are arranged for top-down reading (e.g. Familiar-reader --> Less-familiar-reader). 

Familiar readers ought to find the information at the top of the notes sufficient.

Less-familiar readers will want to read more of the note items to gain orientation and understanding.

Notes are provided for the library, all clusters, and all classes of interest to you in order to use this library.


test


NEXT!
=====
Now--You are ready to open Eiffel Studio and open the "mask", "mask_demo", or "test" target for this library.

"mask" 		--> What you will reference in your own project for reuse.
"mask_demo"	--> To see a demonstration of the library at-work.
"test"		--> To learn more about the library and see how it is tested (as well as other examples).


NOTE
====
Running the "test" target does NOT run the tests (EiffelStudio AutoTest feature does that).
Targets that are purely for testing, have a root class and feature and will compile (finalize)
to an EXE.  However, this EXE is not intended for execution (e.g. "Run").  It is there to create
an EXE which the AutoTest feature can "hook into" for debugging and other purposes.

Additionally, we have used the root class and procedure as a convenience for bringing DOC_* classes into the system, which facilitates your access to and interaction with these classes for the purpose of documentation and learning (e.g. allowing you to navigate them with pick-and-drop and other Eiffel class and feature tools, like Clickable-view on the note clauses).

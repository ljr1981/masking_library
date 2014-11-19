MASK LIBRARY
============
Masking, in this context, is an application behavior when the user is displaying, entering or editing text.  It permits the programmer to specify a mask, such as "(999) 999-9999", and attach the "mask" object with all the text fields that need it, and without any further actions on the part of the programmer, the text field behaves as you would expect in a phone number entry field:  namely, keystrokes are limited to numbers only, and the numbers fall into the positions indicated by the '9' characters.  The edited text is then available in either the masked or unmasked form.


WHERE TO BEGIN
==============
Documentation for this library can be found in the DOC_* classes (start with DOC_LIBRARY_MASK) and are best interactively viewed through EiffelStudio from the "test" target in MASK.ECF.

NOTE: Except for Pick-and-Drop, all documentation files are "Notepad-friendly".  EiffelStudio is not required.  However, for a better experience, it is recommended.

ALSO: (if you prefer) Navigate to:

https://github.com/ljr1981/masking_library/blob/master/mask/_docs/doc_library_mask.e

For Cluster Documentation, navigate to:

https://github.com/ljr1981/masking_library/blob/master/mask/common/_docs/doc_cluster_common.e
https://github.com/ljr1981/masking_library/blob/master/mask/misc/_docs/doc_cluster_misc.e
https://github.com/ljr1981/masking_library/blob/master/mask/numeric/_docs/doc_cluster_numeric.e
https://github.com/ljr1981/masking_library/blob/master/mask/string/_docs/doc_cluster_string.e


DOCUMENTATION VIDEOS
====================

https://www.youtube.com/watch?v=OIvurIB8XN4 <-- Eiffel Masking: Learning the Library (start here)
https://www.youtube.com/watch?v=aDT-2MqQciQ <-- Eiffel Masking: Add Simple Repeating Mask
https://www.youtube.com/watch?v=EEafD4_cFRQ <-- Eiffel Masking: Phone Number Mask
https://www.youtube.com/watch?v=_BUWuwViYvY <-- Eiffel Masking: Complex Currency Mask


SUGGESTED LEARNING PATH
=======================
Starting with DOC_LIBRARY_MASK.E, you can learn about the library at a high level, then drill down to the clusters, and classes as you need more detail.  Some features are provided in the DOC_... classes to make it easier to navigate to the classes being discussed.  You will also find code examples in either the masking demo or in the *_TEST classes of the test target.


FROM EiffelStudio
=================
If you open MASK.ECF from EiffelStudio, notice that there are 3 targets:

"mask" 		--> What you will reference in your own project for reuse.
"mask_demo"	--> To see a demonstration of the library at-work.
"test"		--> To learn more about the library and see how it is tested (as well as other examples).


NOTE
====
Running the "test" target does NOT run the tests (EiffelStudio AutoTest feature does that).  The root class for the "test" target is for the purpose of testing.  Targets that are purely for testing, have a root class and feature and will compile to an EXE.  However, this EXE is not intended for execution (e.g. "Run").  Instead, it is there for AutoTest to work with for testing.

Additionally, we have used the root class and procedure as a convenience for bringing DOC_* classes into the system, which facilitates your access to and interaction with these classes for the purpose of documentation and learning (e.g. allowing you to navigate them with pick-and-drop and other Eiffel class and feature tools, like Clickable-view on the note clauses).

Please allow the curly braces around class names in the documentation (like this:  {CLASS_NAME}) be a reminder that switching to Clickable view causes those names to become click-and-droppable links and are very convenient to use that way.

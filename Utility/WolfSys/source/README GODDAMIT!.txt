---Dont Forget to copy the qmldir file to the build directory!!

--------------------------------
	Usage
--------------------------------
1) Copy the build folder (the one with the dll, plugins.qmlTypes and qmldir) into any project that may want to use this extension!
2) If its a qmlProject, add ["."] to importPaths if the dll build folder is at the root (ie in its own folder but located at the root)
			add ["Plugins"] to importPaths if the dll build folder is in the plugins folder in the project that uses the dll
3) Do the same thing for .pro projects but you have to use IMPORT_PATH variable instead

--------------------------------
your .proFile should have
--------------------------------
1) uri			//MUST BE THE SAME AS DESTDIR
2) DESTDIR		//MUST BE THE SAME AS uri
3) TARGET


--------------------------------
your qmlDir file should have
--------------------------------
module <moduleName> 	   //this MUST BE the same as uri and DESTDIR
plugin <pluginName> 	   //this MUST BE the same as TARGET!!
typeinfo plugins.qmltypes  //Tells qtCreator to read the plugins.qmltypes


--------------------------------------------------------------------------------------
your header/cpp file that has the implementation for registerTypes method should have
--------------------------------------------------------------------------------------
1) // @uri <uriName>	   //This MUST BE the same as uri and DESTDIR


--------------------------------------------------------------------------------------------
	YOU NEED TO GENERATE YOUR OWN plugins.qmlTypes file after you build your plugin!!
--------------------------------------------------------------------------------------------
1) open qt 5.2.1 console (MINGW)
2) CD to your project folder (the parent folder of where the dll is!)
2) type qmlplugindump <ModuleName> <Version> <ModuleDirectory> > <ModuleDirectory>/plugins.qmltypes -notrelocatable

example
qmlplugindump WolfMan 1.0 /WolfMan > WolfMan/plugins.qmltypes -notrelocatable


NOTE!!!!!!
-notrelocatable is necessary! it adds your module namespace infront of your type exports
E.g., instead of wolfSys 1.0 it will say WolfMan/WolfSys 1.0 as a type. 

THIS ALLOWS INTELLISENSE AND MAKES DUMB QT able to recognize our custom type. DONT FORGET THIS!!!!
#ifndef ZSYSTEM_H
#define ZSYSTEM_H

#include <cstdarg>

#include <cstring>
#ifdef __APPLE__
    #include <sys/uio.h>
#else
    #include <io.h>
#endif

#include <stdio.h>
#include <unistd.h>


#include<ios>
#include<iostream>
#include<fstream>
#include<string>
#include<cstdlib>
#include<sstream>
#include<sys/stat.h>
#include<vector>
#include <iomanip>


#if defined _WIN32 || defined _WIN64
    #include <windows.h>
    #include <tlhelp32.h>
    #include <direct.h>
    #include <dirent.h>
#elif defined __APPLE__
    #include <sys/dirent.h>
#endif


using namespace std;
class zSystem
{

public:

    zSystem()
    {

    }

    vector<int> getAvailableComPorts() //added function to find the present serial
    {
        vector<int> availablePorts;

        #if defined _WIN32 || defined _WIN64

            WCHAR lpTargetPath[5000]; // buffer to store the path of the COMPORTS
            for(int i=0; i< 255; i++) // checking ports from COM0 to COM255
            {
                stringstream ss;
                ss << i;

                string serialPortName = "COM" + ss.str();
                wstring str = str2wstr(serialPortName);

                // Test the return value and error if any
                if(QueryDosDevice(str.c_str(), lpTargetPath,  5000) != 0) //QueryDosDevice returns zero if it didn't find an object
                    availablePorts.push_back(i);

                if(::GetLastError()==ERROR_INSUFFICIENT_BUFFER)
                {
                    lpTargetPath[10000]; // in case the buffer got filled, increase size of the buffer.
                    continue;
                }

            }

        #elif defined __unix


        #endif


        return availablePorts;
    }


    void systemCmd(string cmd)
    {
        system(cmd.c_str());
    }

    vector<string> readFile(string path)
    {
        vector<string> lines;

        ifstream myfile;
        myfile.open (path);

        if(myfile.is_open())
        {
            string line = "";
            while( getline(myfile,line) != NULL)
                lines.push_back(line);

            myfile.close();
        }

        return lines;
    }

    bool writeFile(string path, string text)
    {
        ofstream file;
        file.open(path.c_str());
        if(file.is_open())
        {
           file << text;
           file.close();
           return true;
        }
        return false;
    }
    bool writeFile(string path, vector<string> lines)
    {
        ofstream file;
        file.open(path.c_str());
        if(file.is_open())
        {
            for(unsigned int i = 0; i < lines.size(); i++)
                file << lines[i] << '\n';

            file.close();
            return true;
        }
        return false;
    }




    bool isWindowOpen(string win)
    {
        #if defined _WIN32 || _WIN64
        HWND hwnd;

        hwnd = FindWindow(NULL,  str2wstr(win).c_str() );
        cout << hwnd << endl;
        if (hwnd != 0)        return true;
                              return false;
        #elif defined __unix
            return false;
        #endif
            return false;
    }
    bool isProcessRunning(string name)
    {
        #if defined _WIN32 || _WIN64
           HANDLE SnapShot = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );

            if( SnapShot == INVALID_HANDLE_VALUE )
                return false;

            PROCESSENTRY32 procEntry;
            procEntry.dwSize = sizeof( PROCESSENTRY32 );

            if( !Process32First( SnapShot, &procEntry ) )
                return false;

            do
            {

                if( strcmp( wstr2str(procEntry.szExeFile).c_str(), name.c_str() ) == 0 )
                    return true;
            }
            while( Process32Next( SnapShot, &procEntry ) );
            return false;
        #elif defined __unix
            return false;
        #endif
            return false;
     }




    void copyfile(string destDir, string srcPath)
    {
        ifstream source(srcPath, ios::binary);
        ofstream dest(destDir, ios::binary);

        //filesize
        source.seekg(0, ios::end);
        ifstream::pos_type size = source.tellg();
        source.seekg(0);

        //alloc memory for buffer
        char *buffer = new char[size];

        //copy file
        source.read(buffer,size);
        dest.write(buffer,size);

        //clean up
        delete[] buffer;
        source.close();
        dest.close();
    }

    string del(string path)
    {
        #if defined _WIN32 || defined _WIN64
            string cmd = "del \"" +   path + "\"";
            string res = shellCmd(cmd.c_str());
            return res;
        #elif defined __unix
            string res = shellCmd("sudo rm " + path);
            return res;
        #endif
        return "OS not supported\n";
    }


    void killProcess(string ProcName)
    {
        #if defined _WIN32 || defined _WIN64
            string cmd = "Taskkill /f /im " + ProcName;
            shellCmd(cmd.c_str());
        #elif defined __unix
            shellCmd("sudo pKill -9 " + ProcName);
        #endif
    }



    void runBinary(string path)
    {
        #if defined _WIN32 || defined _WIN64
             system(path.c_str());
        #elif defined __unix
             path = "sudo " + path;
             system(path.c_str());
        #endif
    }


    void restart()
    {
       #if defined _WIN32 || defined _WIN64
            system("shutdown -r -t 00");
       #elif defined __unix
            string res = shellCmd("sudo reboot");
            cout << res << endl;
       #endif
    }
    void shutDown()
    {
        #if defined _WIN32 || defined _WIN64
             system("shutdown -s -t 00");
        #elif defined __unix
            string res = shellCmd("sudo shutdown -h now");
            cout << res << endl;
        #endif
    }
    void logOff()
    {
        #if defined _WIN32 || defined _WIN64
             system("shutdown -l -t 00");
        #elif defined __unix
            string res = shellCmd("gnome-session-save --force-logout");
            cout << res << endl;
        #endif
    }
    void clearConsole()
    {
        #if defined _WIN32 || defined _WIN64
             system("cls");
        #elif defined __unix
             cout << "\033[2J\033[1;1H";
             //This magical cout is using ANSI escape codes.
             //(\033[2J) clears the entire screen (J) from top to bottom (2).
             //The second code (\033[1;1H) positions the cursor at row 1, column 1.
        #else
            cout << "no platform" << endl;
        #endif
    }


    inline bool fileExists(std::string name)
    {
      struct stat buffer;
      return (stat (name.c_str(), &buffer) == 0);
    }

    //Cross platform shell command! Returns output from the shell as well!
    std::string shellCmd (const char *command)
    {
        char tmpname [L_tmpnam];
        std::tmpnam ( tmpname );
        std::string scommand = command;
        std::string cmd = scommand + " >> " + tmpname;
        std::system(cmd.c_str());
        std::ifstream file(tmpname, std::ios::in );
        std::string result = "";

        if (file)
        {
          while (!file.eof())
              result.push_back(file.get());
          file.close();
        }

        remove(tmpname);
        return result;
    }


    std::string shellCmd(std::string cmd)
    {
        return shellCmd(cmd.c_str());
    }


    void createFolder(string path)
    {
        #if defined _WIN32 || defined _WIN64
            CreateDirectory(str2wstr(path).c_str(),NULL);
        #elif defined __unix
                cout << "createFolder(" + path + ") - Not yet implemented for linux" << endl;
        #endif
    }

    bool folderExists(string path)
    {
        #if defined _WIN32 || defined _WIN64
                DIR *dir = opendir(path.c_str());
                if(dir != NULL)
                    return true;
        #elif defined __unix
                cout << "folderExists(" + path + ") - Not yet implemented for linux" << endl;
        #endif
                return false;
    }

    //cross platform solution!
    vector<string> getFoldersInDirectory(string path)
    {
        vector<string> folders;

        char originalDirectory[_MAX_PATH];

        //Get the current directory so we can return to it!
        _getcwd(originalDirectory, _MAX_PATH);

        //Change to the dest directory (whose subdirs we want to find)
        _chdir(path.c_str());


        _finddata_t fileinfo;

        //This will grab the first file in the directory
        //"8" can be changed if you only want to look for specific files
        intptr_t handle = _findfirst("*",&fileinfo);

        if(handle != -1) //no files or directories found
        {
            do
            {
                if(strcmp(fileinfo.name,".") == 0 || strcmp(fileinfo.name,"..") == 0)   //ignore the dot and dot dot
                    continue;

                if(fileinfo.attrib & _A_SUBDIR) //Use bitmask to see if this is a directory
                    folders.push_back(fileinfo.name);

            }while(_findnext(handle, &fileinfo) == 0);
        }
        _findclose(handle);
        _chdir(originalDirectory);

        return folders;
    }


    vector<string> getFilesInFolder(string path, unsigned int numExtensions, ...)
    {
        vector<string> files, extensions;
        va_list ap;
        va_start (ap,numExtensions);
        for (unsigned int i = 0; i < numExtensions; i++)
        {
            char *ext = va_arg(ap,char*);
            extensions.push_back(string(ext));
            //delete[] ext;
        }
        va_end(ap);


        #if defined _WIN32 || defined _WIN64
            DIR *dir;
            struct dirent *ent;
            if ((dir = opendir (path.c_str())) != NULL)
            {
              //add files to the vector of string
              while ((ent = readdir (dir)) != NULL)
              {
                string item = string(ent->d_name);
                if(extensions.size() > 0)
                {
                    for(unsigned int i = 0; i < extensions.size(); i++)
                    {
                        if(contains(item, extensions[i]))
                            files.push_back(item);
                    }
                }
                else
                {
                    files.push_back(item);
                }
              }
              closedir (dir);
            }
            return files;
        #elif defined __unix
            ////TODO , do LINUX implementation here!
            return files;
        #else
            return files;
        #endif
    }



private:
    bool contains(string container, string sequence)
    {
        char *ptr = strstr(container.c_str(), sequence.c_str());
        if(ptr == NULL)
            return false;
        else
            return true;
    }



    std::wstring str2wstr(const std::string &s)
    {
        wstring ret;
        #if defined _WIN32 || _WIN64
            int len;
            int slength = (int)s.length() + 1;


            len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0);
            wchar_t* buf = new wchar_t[len];
            MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, buf, len);
            std::wstring r(buf);
            delete[] buf;
            return r;
        #elif defined __unix
            return ret;
        #endif

            return ret;
    }

    std::string wstr2str(const std::wstring &ws)
    {
        std::string ret(ws.begin(), ws.end());
        return ret;
    }




};

#endif // ZSYSTEM_H

import glob, os

def rename(find, replace, dir):
    if dir == "":
        dir = os.getcwd()
    print("running on " + dir)
    for pf in glob.iglob(os.path.join(dir,"*.*")):
        title,ext = os.path.splitext(os.path.basename(pf))
        #print(title + " " +  str(title.__contains__(find)) )
        if title.__contains__(find):
            name = title.replace(find,replace)
            os.rename(pf, os.path.join(dir, name + ext))

#usage , replace that weird str with nothingness!
#rename("-mgw49-mt","","")
rename("-gcc-mt","","")
#QMAKE_CXXFLAGS += -std=c++0x -pthread -w -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8

#TEMPLATE = lib
#CONFIG   += plugin

TEMPLATE = lib
CONFIG += plugin
QT       += qml quick

uri     = Zabaat.PdfTools
DESTDIR = Zabaat/PdfTools               #File
TARGET  = pdftoolsplugin             #filereaderplugin (the name of the executable if its an exe , otherwise the name of the .dll. THIS BE THE TARGET LADDIES)

OBJECTS_DIR = tmp
MOC_DIR = tmp

# Input
OTHER_FILES = qmldir

HEADERS     +=  Code/pdfwriter.h \
                Code/pdfwriterplugin.h
SOURCES     +=
DISTFILES   += Qml/derp.qml \
               Qml/Functions.js \
               Qml/ZPdfBook.qml \
               Qml/ZPdfSection.qml \
               Qml/ZPdfReportEditor.qml \
               Qml/main.qml \
               Qml/mainMenu.qml

install_QML.files     += $$PWD/Qml/*
install_QML.path      += $$OUT_PWD/$$DESTDIR/Qml

#install_Assets.files  += $$PWD/assets/*
#install_Assets.path   += $$OUT_PWD/assets/

#install_Plugins.files  += $$PWD/plugins/*
#install_Plugins.path   += $$OUT_PWD/plugins/

INSTALLS += install_QML

QML_IMPORT_PATH = C:\Users\vvolfster\Desktop\shareVm\ZabaatLibrary

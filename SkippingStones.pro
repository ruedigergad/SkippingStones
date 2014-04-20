TARGET = harbour-skippingstones

CONFIG += sailfishapp

SOURCES += \
    main.cpp \
    btconnector.cpp \
    btmessage.cpp \
    filesystemhelper.cpp \
    settingsadapter.cpp \
    dbusadapter.cpp

OTHER_FILES += \
    rpm/harbour-skippingstones.spec \
    harbour-skippingstones.desktop \
    qml/main.qml \
    qml/MainPage.qml \
    rpm/harbour-skippingstones.yaml \
    qml/Watch.qml \
    qml/PutBytes.qml \
    qml/AppInstallationBusyPage.qml \
    qml/AppMessageHandler.qml

HEADERS += \
    btconnector.h \
    btmessage.h \
    filesystemhelper.h \
    settingsadapter.h \
    dbusadapter.h

QT += bluetooth dbus

RESOURCES += \
    sailfish_resources.qrc

TARGET = harbour-skippingstones

CONFIG += sailfishapp Qt5Contacts

SOURCES += \
    main.cpp \
    btconnector.cpp \
    btmessage.cpp \
    filesystemhelper.cpp \
    settingsadapter.cpp \
    dbusadapter.cpp \
    dbusadapter_reminder.cpp \
    phonebook.cpp

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
    dbusadapter.h \
    dbusadapter_reminder.h \
    phonebook.h

QT += bluetooth dbus


PKGCONFIG += timed-qt5 timed-voland-qt5
PKGCONFIG += Qt5Contacts

RESOURCES += \
    sailfish_resources.qrc

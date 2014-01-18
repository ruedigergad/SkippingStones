TARGET = harbour-skippingstones

CONFIG += sailfishapp

SOURCES += \
    main.cpp \
    btconnector.cpp \
    btmessage.cpp

OTHER_FILES += \
    rpm/harbour-skippingstones.spec \
    harbour-skippingstones.desktop \
    qml/main.qml \
    qml/MainPage.qml \
    rpm/harbour-skippingstones.yaml \
    qml/Watch.qml

HEADERS += \
    btconnector.h \
    btmessage.h

QT += bluetooth

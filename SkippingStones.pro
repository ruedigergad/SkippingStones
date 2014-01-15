TARGET = harbour-skippingstones

CONFIG += sailfishapp

SOURCES += \
    main.cpp \
    btconnector.cpp

OTHER_FILES += \
    rpm/SkippingStones.spec \
    SkippingStones.desktop \
    qml/main.qml \
    qml/MainPage.qml \
    rpm/harbour-skippingstones.yaml

HEADERS += \
    btconnector.h

QT += bluetooth

/*
 * Copyright 2014 Ruediger Gad
 *
 * This file is part of SkippingStones.
 *
 * SkippingStones is largely based on libpebble by Liam McLoughlin
 * https://github.com/Hexxeh/libpebble
 *
 * SkippingStones is published under the same license as libpebble (as of 10-02-2014):
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#include <QGuiApplication>
#include <QQuickView>
#include <QtQml>

#include <sailfishapp.h>

#include "btconnector.h"
#include "btmessage.h"
#include "dbusadapter.h"
#include "dbusadapter_reminder.h"
#include "filesystemhelper.h"
#include "settingsadapter.h"
#include <grp.h>
#include <pwd.h>

int main(int argc, char *argv[])
{
    setuid(getpwnam("nemo")->pw_uid);
    setgid(getgrnam("privileged")->gr_gid);

    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();

    QCoreApplication::setOrganizationName("ruedigergad.com");
    QCoreApplication::setOrganizationDomain("ruedigergad.com");
    QCoreApplication::setApplicationName("SkippingStones");

    qmlRegisterType<BtConnector>("harbour.skippingstones", 1, 0, "BtConnector");
    qmlRegisterType<BtMessage>("harbour.skippingstones", 1, 0, "BtMessage");
    qmlRegisterType<DbusAdapter>("harbour.skippingstones", 1, 0, "DbusAdapter");
    qmlRegisterType<DbusAdapterReminder>("harbour.skippingstones", 1, 0, "DbusAdapterReminder");
    qmlRegisterType<FileSystemHelper>("harbour.skippingstones", 1, 0, "FileSystemHelper");
    qmlRegisterType<SettingsAdapter>("harbour.skippingstones", 1, 0, "SettingsAdapter");

    view->setSource(QUrl("/usr/share/harbour-skippingstones/qml/main.qml"));
    view->show();

    return app->exec();
}

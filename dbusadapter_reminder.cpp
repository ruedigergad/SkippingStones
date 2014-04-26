/*
 * Copyright 2014 Uladzislau Vasilyeu 
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

#include "dbusadapter_reminder.h"
#include <QDebug>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QVariant>

DbusAdapterReminder::DbusAdapterReminder(QObject *parent) :
    QObject(parent){
    QDBusConnection sessionConn = QDBusConnection::sessionBus();

    // The inspiration for this hack was taken from: http://stackoverflow.com/questions/22592042/qt-dbus-monitor-method-calls
    QDBusInterface busInterface("org.freedesktop.DBus", "/org/freedesktop/DBus",
                                "org.freedesktop.DBus");
    sessionConn.registerObject("/com/nokia/voland", this, QDBusConnection::ExportAllSlots);
    QString matchString = "interface='com.nokia.voland',member='open',type='method_call',eavesdrop='true'";
    busInterface.call("AddMatch", matchString);
}

bool DbusAdapterReminder::open(const QList<QVariant> &data) {
    qDebug() << "Got OPEN Reminder dbus message";
    foreach (const QVariant &v, data) {
        QDBusArgument a = v.value<QDBusArgument>();
        Maemo::Timed::Voland::Reminder r;
        a >> r;
        if (r.cookie()){ 
            qDebug() <<r.attr("TITLE");
            qDebug() <<r.attr("alarmtime");
            emit reminder (r.attr("alarmtime"), r.attr("TITLE"));
        }
    }
    return true;
}


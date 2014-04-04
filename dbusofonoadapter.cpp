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

#include "dbusofonoadapter.h"
#include <QDebug>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QVariant>

DbusOfonoAdapter::DbusOfonoAdapter(QObject *parent) :
    QObject(parent)
{
    QDBusConnection systemConn = QDBusConnection::systemBus();
    systemConn.connect("org.ofono", "/ril_0", "org.ofono.VoiceCallManager", "CallAdded",
                         this, SLOT(_phoneCall(QDBusMessage)));
    systemConn.connect("org.ofono", "/ril_0", "org.ofono.MessageManager", "IncomingMessage",
                         this, SLOT(_smsReceived(QDBusMessage)));

    QDBusConnection sessionConn = QDBusConnection::sessionBus();
//    sessionConn.connect("", "/org/nemo/transferengine",
//                 "org.nemo.transferengine", "transfersChanged",
//                 this, SLOT(_transfersChanged(QDBusMessage)));

    qDebug() << "Setting up hack for getting notifications...";
    // Hack taken from: http://stackoverflow.com/questions/22592042/qt-dbus-monitor-method-calls
    sessionConn.connect("", "", "org.freedesktop.Notifications", "Notify",
                        this, SLOT(_notification(QString,uint,QString,QString,QString,QStringList,QVariantHash,int)));
    // then ask the bus to send us a copy of each Notify call message
    QString matchString = "interface='org.freedesktop.Notifications',member='Notify',type='method_call',eavesdrop='true'";
    QDBusInterface busInterface("org.freedesktop.DBus", "/org/freedesktop/DBus",
                                "org.freedesktop.DBus");
    busInterface.call("AddMatch", matchString);
}

uint DbusOfonoAdapter::_notification(const QString &app_name, uint replaces_id, const QString &app_icon, const QString &summary, const QString &body, const QStringList &actions, const QVariantHash &hints, int expire_timeout) {
    qDebug() << "Got notification via dbus:";
}

void DbusOfonoAdapter::_phoneCall(QDBusMessage msg) {
    qDebug() << "Got phone call dbus message:" << msg;

    QDBusArgument *arg = (QDBusArgument *) msg.arguments().at(1).data();

    if (arg->currentType() == QDBusArgument::MapType) {
        QMap<QString, QString> argMap = unpackMessage(*arg);

        qDebug() << "Extracted argument map:" << argMap;
        emit phoneCall(argMap.value("LineIdentification"), argMap.value("Name"));
    }
}

void DbusOfonoAdapter::_smsReceived(QDBusMessage msg) {
    qDebug() << "Got sms dbus message:" << msg;

    QDBusArgument *arg = (QDBusArgument *) msg.arguments().at(1).data();

    if (arg->currentType() == QDBusArgument::MapType) {
        QMap<QString, QString> argMap = unpackMessage(*arg);

        qDebug() << "Extracted argument map:" << argMap;
        emit smsReceived(msg.arguments().at(0).toString(), argMap.value("Sender"));
    }
}

void DbusOfonoAdapter::_transfersChanged(QDBusMessage msg) {
    qDebug() << "received transfersChanged:" << msg;

    QDBusConnection sessionConn = QDBusConnection::sessionBus();
    QDBusMessage msgCall = QDBusMessage::createMethodCall("org.freedesktop.Notifications", "/org/freedesktop/Notifications", "org.freedesktop.Notifications", "GetNotifications");
    QList<QVariant> args;
    args << QVariant("messageserver5");
    msgCall.setArguments(args);
    bool ret = sessionConn.callWithCallback(msgCall, this, SLOT(_notification(QDBusMessage)));
    qDebug() << "DBus call returned with:" << ret;
}

QMap<QString, QString> DbusOfonoAdapter::unpackMessage(const QDBusArgument &arg) {
    QMap<QString, QString> argMap;

    arg.beginMap();
    while (! arg.atEnd()) {
        QString key;
        QVariant value;

        arg.beginMapEntry();
        arg >> key >> value;
        if (value.canConvert(QVariant::String)) {
            argMap.insert(key, value.toString());
        }
        arg.endMapEntry();
    }
    arg.endMap();

    return argMap;
}

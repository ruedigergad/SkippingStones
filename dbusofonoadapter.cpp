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
#include <QVariant>

DbusOfonoAdapter::DbusOfonoAdapter(QObject *parent) :
    QObject(parent)
{
    QDBusConnection conn = QDBusConnection::systemBus();
    conn.connect("org.ofono", "/ril_0", "org.ofono.VoiceCallManager", "CallAdded",
                         this, SLOT(_phoneCall(QDBusMessage)));
    conn.connect("org.ofono", "/ril_0", "org.ofono.MessageManager", "IncomingMessage",
                         this, SLOT(_smsReceived(QDBusMessage)));
    conn.connect("org.freedesktop.Notifications", "/org/freedesktop/Notifications",
                 "org.freedesktop.Notifications", "Notify",
                 this, SLOT(_notification(QDBusMessage)));
}

void DbusOfonoAdapter::_notification(QDBusMessage msg) {
    qDebug() << "Got notification via dbus:" << msg;

    QString origin = msg.arguments().at(0).toString();
    qDebug() << "Notification origin:" << origin;

    if (origin == "messageserver5") {
        qDebug() << "Got notification from messageserver. Assuming that this is an e-mail notification.";
        QString sender = msg.arguments().at(3).toString();
        QString header = msg.arguments().at(4).toString();

        QDBusArgument *arg = (QDBusArgument *) msg.arguments().at(6).data();

        QString body = "";
        if (arg->currentType() == QDBusArgument::MapType) {
            QMap<QString, QString> argMap = unpackMessage(*arg);

            qDebug() << "Extracted argument map:" << argMap;
            body = argMap.value("x-nemo.email.published-messages");
        }

        emit email(sender, header, body);
    }
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

/*
 *  Copyright 2012 Ruediger Gad
 *
 *  This file is part of QZeeControl.
 *
 *  QZeeControl is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  QZeeControl is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with QZeeControl.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef BTCONNECTOR_H
#define BTCONNECTOR_H

#include <QObject>
#include <QBluetoothAddress>
#include <QBluetoothSocket>

QT_USE_NAMESPACE_BLUETOOTH

class BtConnector : public QObject
{
    Q_OBJECT

public:
    /*
     * These values were taken from:
     * https://github.com/Hexxeh/libpebble/blob/master/pebble/pebble.py
     */
    enum EndPoint {
        Time = 11,
        Version = 16,
        PhoneVersion = 17,
        SystemMessage = 18,
        MusicControl = 32,
        PhoneControl = 33,
        ApplicationMessage = 48,
        Launcher = 49,
        Logs = 2000,
        Ping = 2001,
        LogDump = 2002,
        Reset = 2003,
        App = 2004,
        AppLogs = 2006,
        Notification = 3000,
        Resource = 4000,
        AppManager = 6000,
        Screenshot = 8000,
        PutBytes = 48879
    };

    explicit BtConnector(QObject *parent = 0);
    ~BtConnector();

    Q_INVOKABLE void connect(QString address, int port);
    Q_INVOKABLE void sendHex(QString hexString);
    Q_INVOKABLE void sendText(QString text, QString endpoint, QString prefix);

public slots:
    void disconnect();

signals:
    void connected();
    void disconnected();
    void error(QBluetoothSocket::SocketError errorCode);
    void textReply(QString text);

private slots:
    void readData();

private:
    QBluetoothSocket *_socket;
    int _port;

    void write(QByteArray data);

};

#endif // BTCONNECTOR_H

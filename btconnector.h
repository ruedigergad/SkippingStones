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

#ifndef BTCONNECTOR_H
#define BTCONNECTOR_H

#include <QObject>
#include <QBluetoothAddress>
#include <QBluetoothSocket>

#include "btmessage.h"

QT_USE_NAMESPACE_BLUETOOTH

class BtConnector : public QObject
{
    Q_OBJECT

public:
    explicit BtConnector(QObject *parent = 0);
    ~BtConnector();

    Q_INVOKABLE void connect(QString address, int port);
    Q_INVOKABLE qint64 send(BtMessage *msg);
    Q_INVOKABLE void sendHex(QString hexString);

public slots:
    void disconnect();

signals:
    void connected();
    void disconnected();
    void error(QBluetoothSocket::SocketError errorCode);
    void messageReceived(BtMessage *message);

private slots:
    void readData();

private:
    QBluetoothSocket *_socket;
    int _port;

    qint64 write(QByteArray data);

};

#endif // BTCONNECTOR_H

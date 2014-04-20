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

#include "btconnector.h"

#include <QDateTime>
#include <QDebug>
#include <QStringList>

BtConnector::BtConnector (QObject *parent)
    : QObject(parent) {

}

BtConnector::~BtConnector () {
    if(_socket)
        delete _socket;
}

void BtConnector::connect(QString address, int port){
    _port = port;
    qDebug("Trying to connect to: %s_%d", address.toUtf8().constData(), _port);

    if(_socket)
        delete _socket;

    if (_port == 23) {
        _socket = new QBluetoothSocket(QBluetoothSocket::L2capSocket);
    } else {
        _socket = new QBluetoothSocket(QBluetoothSocket::RfcommSocket);
    }

    QObject::connect(_socket, SIGNAL(connected()), this, SIGNAL(connected()));
    QObject::connect(_socket, SIGNAL(disconnected()), this, SIGNAL(disconnected()));
    QObject::connect(_socket, SIGNAL(error(QBluetoothSocket::SocketError)), this, SIGNAL(error(QBluetoothSocket::SocketError)));
    QObject::connect(_socket, SIGNAL(readyRead()), this, SLOT(readData()));

    qDebug("Connecting...");
    _socket->connectToService(QBluetoothAddress(address), _port);
}

void BtConnector::disconnect(){
    qDebug("Disconnecting...");

    if(!_socket)
        return;

    if(_socket->isOpen())
        _socket->close();

    delete _socket;
    _socket = 0;

    qDebug("Disconnected.");
}

void BtConnector::readData(){
    qDebug("Entering readData...");

    QByteArray data = _socket->readAll();
    qDebug() << "Data size:" << data.size();
    qDebug() << "Data[" + QString::number(_port) + "]:" << data.toHex();
    emit messageReceived(new BtMessage(data));
}

qint64 BtConnector::send(BtMessage *msg) {
    return write(msg->data());
}

void BtConnector::sendHex(QString hexString) {
    QByteArray data = QByteArray::fromHex(hexString.toLatin1());
    write(data);
}

qint64 BtConnector::write(QByteArray data) {
    qDebug() << "Writing:" << data.toHex();
    qint64 ret = _socket->write(data);
    qDebug() << "Write returned:" << ret;
    return ret;
}

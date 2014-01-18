/*
 *  Copyright 2014 Ruediger Gad
 *
 *  This file is part of SkippingStones.
 *
 *  SkippingStones is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  SkippingStones is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with SkippingStones.  If not, see <http://www.gnu.org/licenses/>.
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
    qDebug() << "Data[" + QString::number(_port) + "]:" << data.toHex();

    if (_port == 1) {
        unsigned int payloadSize = (data[0] << 8) | data[1];
        unsigned int endpoint = (data[2] << 8) | data[3];

        qDebug() << "Payload size:" << payloadSize << "Endpoint:" << endpoint;

        switch (endpoint) {
        case BtMessage::Time: {
            short c = data[4];
            unsigned int i = (data[5] << 24) | (data[6] << 16) | (data[7] << 8) | data[8];
            qDebug() << "Time data:" << i;
            qDebug() << "Got time:" << c << "_" << QDateTime::fromTime_t(i).toString();
            emit textReply(QDateTime::fromTime_t(i).toString());
            break;
        }
        default:
            emit textReply(data.toHex());
            break;
        }
    }
}

qint64 BtConnector::send(BtMessage msg) {
    return write(msg.data());
}

void BtConnector::sendHex(QString hexString) {
    QByteArray data = QByteArray::fromHex(hexString.toLatin1());
    write(data);
}

void BtConnector::sendText(QString text, BtMessage::EndPoint endpoint, BtMessage::Prefix prefix) {
    qDebug() << "sendText:" << text << "Endpoint:" << endpoint << "Prefix:" << prefix;
    QByteArray data;

    data.append((char) ((endpoint >> 8) & 255));
    data.append((char) (endpoint & 255));

    if (prefix != BtMessage::InvalidPrefix) {
        data.append((char) (prefix & 255));
    }

    QStringList sl = text.split("|", QString::SkipEmptyParts);
    foreach (QString const &tmp, sl) {
        QString s = tmp.left(30);
        data.append((char) s.length());
        qDebug() << "Adding text:" << s.toLatin1();
        data.append(s.toLatin1());
    }

    int dataLength = data.length() - 2;
    data.prepend((char) (dataLength & 255));
    data.prepend((char) ((dataLength >> 8) & 255));

    write(data);
}

qint64 BtConnector::write(QByteArray data) {
    qDebug() << "Writing:" << data.toHex();
    qint64 ret = _socket->write(data);
    qDebug() << "Write returned:" << ret;
    return ret;
}

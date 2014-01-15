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

#include <QDebug>

BtConnector::BtConnector (QObject *parent)
    : QObject(parent) {

}

BtConnector::~BtConnector () {
    if(socket)
        delete socket;
}

void BtConnector::connect(QString address, int port){
    _port = port;
    qDebug("Trying to connect to: %s_%d", address.toUtf8().constData(), _port);

    if(socket)
        delete socket;

    if (_port == 1) {
        socket = new QBluetoothSocket(QBluetoothSocket::RfcommSocket);
    } else {
        socket = new QBluetoothSocket(QBluetoothSocket::L2capSocket);
    }

    QObject::connect(socket, SIGNAL(connected()), this, SIGNAL(connected()));
    QObject::connect(socket, SIGNAL(disconnected()), this, SIGNAL(disconnected()));
    QObject::connect(socket, SIGNAL(error(QBluetoothSocket::SocketError)), this, SIGNAL(error(QBluetoothSocket::SocketError)));
    QObject::connect(socket, SIGNAL(readyRead()), this, SLOT(readData()));

    qDebug("Connecting...");
    socket->connectToService(QBluetoothAddress(address), _port);
}

void BtConnector::disconnect(){
    qDebug("Disconnecting...");

    if(!socket)
        return;

    if(socket->isOpen())
        socket->close();

    delete socket;
    socket = 0;

    qDebug("Disconnected.");
}

void BtConnector::readData(){
    qDebug("Entering readData...");

    QByteArray data = socket->readAll();
    qDebug() << "Data [" + QString::number(_port) + "]:" << data.toHex();

    if (_port == 1) {
        unsigned int payloadSize = (data[0] << 8) | data[1];
        unsigned int endpoint = (data[2] << 8) | data[3];

        qDebug() << "Payload size:" << payloadSize << "Endpoint:" << endpoint;
    }
}

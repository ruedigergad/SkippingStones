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

#ifndef BTMESSAGE_H
#define BTMESSAGE_H

#include <QByteArray>
#include <QObject>

class BtMessage : public QObject
{
    Q_OBJECT
    Q_ENUMS(EndPoint)
    Q_ENUMS(Prefix)
    Q_ENUMS(PutBytesTransferTypes)

public:
    /*
     * Enums
     */
    /*
     * These values were taken from:
     * https://github.com/Hexxeh/libpebble/blob/master/pebble/pebble.py
     */
    enum EndPoint {
        InvalidEndPoint = -1,
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

    enum Prefix {
        InvalidPrefix = -1,
        Email = 0,
        SMS = 1,
        NowPlayingData = 16
    };

    enum PutBytesTransferTypes {
        PutBytesFirmware = 1,
        PutBytesRecovery = 2,
        PutBytesSysResources = 3,
        PutBytesResources = 4,
        PutBytesBinary = 5
    };

    /*
     * Constructor, Methods, etc.
     */
    explicit BtMessage(QObject *parent = 0);
    BtMessage(const QByteArray &data, QObject *parent = 0);
    BtMessage(const BtMessage &msg, QObject *parent = 0);
    BtMessage& operator = (const BtMessage &msg);

    Q_INVOKABLE void appendInt8(int i);
    Q_INVOKABLE void appendInt16(int i);
    Q_INVOKABLE void appendInt32(int i);
    Q_INVOKABLE void appendString(QString str);
    Q_INVOKABLE void appendHex(QString data);

    Q_INVOKABLE void prependInt8(int i);
    Q_INVOKABLE void prependInt16(int i);
    Q_INVOKABLE void prependInt32(int i);
    Q_INVOKABLE void prependString(QString str);

    Q_INVOKABLE int nextInt8();
    Q_INVOKABLE int nextInt16();
    Q_INVOKABLE int nextInt32();

    Q_INVOKABLE int readInt8(int index);
    Q_INVOKABLE int readInt16(int index);
    Q_INVOKABLE int readInt32(int index);
    Q_INVOKABLE QString readString(int size);
    Q_INVOKABLE QString readString(int index, int size);

    Q_INVOKABLE QByteArray data();
    Q_INVOKABLE int endpoint();
    Q_INVOKABLE int payloadLength();
    Q_INVOKABLE int size();
    Q_INVOKABLE QString toHexString();

signals:

public slots:
    void resetIndex();

private:
    QByteArray _data;
    int _currentIndex;

};

#endif // BTMESSAGE_H

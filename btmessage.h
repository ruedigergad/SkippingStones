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
public:
    explicit BtMessage(QObject *parent = 0);

    Q_INVOKABLE void appendInt8(int i);
    Q_INVOKABLE void appendInt16(int i);
    Q_INVOKABLE void appendInt32(int i);
    Q_INVOKABLE void appendString(QString str);

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
    Q_INVOKABLE int readString(int size);
    Q_INVOKABLE int readString(int index, int size);

    Q_INVOKABLE int size();

signals:

public slots:
    void resetIndex();

private:
    QByteArray _data;
    int _currentIndex;

};

#endif // BTMESSAGE_H

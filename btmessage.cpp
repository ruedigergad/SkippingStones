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

#include "btmessage.h"

/*
 * Constructors and operators
 */
BtMessage::BtMessage(QObject *parent) :
    QObject(parent),
    _currentIndex(0)
{
}

BtMessage::BtMessage(const QByteArray &data, QObject *parent) :
    QObject(parent)
{
    _data = data;
    _currentIndex = 0;
}

BtMessage::BtMessage(const BtMessage &msg, QObject *parent) :
    QObject(parent)
{
    _data = msg._data;
    _currentIndex = msg._currentIndex;
}

BtMessage& BtMessage::operator = (const BtMessage &msg) {
    _data = msg._data;
    _currentIndex = msg._currentIndex;
    return *this;
}

/*
 * Append actions
 */
void BtMessage::appendInt8(int i) {
    _data.append((char) (i & 255));
}

void BtMessage::appendInt16(int i) {
    _data.append((char) ((i >> 8) & 255));
    _data.append((char) (i & 255));
}

void BtMessage::appendInt32(int i) {
    _data.append((char) ((i >> 24) & 255));
    _data.append((char) ((i >> 16) & 255));
    _data.append((char) ((i >> 8) & 255));
    _data.append((char) (i & 255));
}

void BtMessage::appendString(QString str) {
    _data.append(str);
}

void BtMessage::appendHex(QString data) {
    _data.append(QByteArray::fromHex(data.toLatin1()));
}

/*
 * Prepend actions
 */
void BtMessage::prependInt8(int i) {
    _data.prepend((char) (i & 255));
}

void BtMessage::prependInt16(int i) {
    _data.prepend((char) (i & 255));
    _data.prepend((char) ((i >> 8) & 255));
}

void BtMessage::prependInt32(int i) {
    _data.prepend((char) (i & 255));
    _data.prepend((char) ((i >> 8) & 255));
    _data.prepend((char) ((i >> 16) & 255));
    _data.prepend((char) ((i >> 24) & 255));
}

void BtMessage::prependString(QString str) {
    for (int i = str.length() - 1; i >= 0; i--) {
        _data.prepend(str.at(i).toLatin1());
    }
}

/*
 * Getters by index
 */
int BtMessage::readInt8(int index) {
    return _data[index];
}

int BtMessage::readInt16(int index) {
    return (_data[index] << 8) | _data[index + 1];
}

int BtMessage::readInt32(int index) {
    return (_data[index] << 24) | (_data[index + 1] << 16) | (_data[index + 2] << 8) | _data[index + 3];
}

QString BtMessage::readString(int index, int size) {
    return QString(_data.mid(index, size));
}

/*
 * Relative getters
 */
QString BtMessage::readString(int size) {
    QString ret = readString(_currentIndex, size);
    _currentIndex += size;
    return ret;
}

int BtMessage::nextInt8() {
    int ret = readInt8(_currentIndex);
    _currentIndex += 1;
    return ret;
}

int BtMessage::nextInt16() {
    int ret = readInt16(_currentIndex);
    _currentIndex += 2;
    return ret;
}

int BtMessage::nextInt32() {
    int ret = readInt32(_currentIndex);
    _currentIndex += 4;
    return ret;
}

/*
 * Other methods
 */
QByteArray BtMessage::data() {
    return _data;
}

int BtMessage::endpoint() {
    return readInt16(2);
}

int BtMessage::payloadLength() {
    return readInt16(0);
}

void BtMessage::resetIndex() {
    _currentIndex = 0;
}

int BtMessage::size() {
    return _data.size();
}

QString BtMessage::toHexString() {
    return QString(_data.toHex());
}

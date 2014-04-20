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

#include "btmessage.h"
#include <QDebug>

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

void BtMessage::appendMessage(BtMessage *msg) {
    _data.append(msg->_data);
}

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
    _data.append(str.toUtf8());
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

int BtMessage::readInt16le(int index) {
    return (_data[index + 1] << 8) | _data[index];
}

int BtMessage::readInt32(int index) {
    return (_data[index] << 24) | (_data[index + 1] << 16) | (_data[index + 2] << 8) | _data[index + 3];
}

int BtMessage::readInt32le(int index) {
    return (_data[index + 3] << 24) | (_data[index + 2] << 16) | (_data[index + 1] << 8) | _data[index];
}

QString BtMessage::readHexString(int index, int size) {
    return QString(_data.mid(index, size).toHex());
}

QString BtMessage::readString(int index, int size) {
    QByteArray tmp = _data.mid(index, size);

    for (int i = 0; i < tmp.length(); i++) {
        if (tmp.at(i) == 0) {
            tmp.remove(i, 1);
            i--;
        }
    }

    return QString(tmp);
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

int BtMessage::stringLength(QString str) {
    return QByteArray(str.toUtf8()).length();
}

QString BtMessage::toHexString() {
//    qDebug() << "Data size:" << _data.size()
//             << "; Hex Size:" << _data.toHex().size()
//             << "; Hex String Size:" << QString(_data.toHex()).size();
    return QString(_data.toHex());
}

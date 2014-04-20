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

import QtQuick 2.0
import harbour.skippingstones 1.0

Item {
    id: appMessageHandler

    property int _transactionId: 0

    function musicNowPlaying(track, album, artist) {
        _smartWaMusicNowPlaying(_padString(track, 30, " "), _padString(album, 30, " "), _padString(artist, 30, " "))
    }

    function processAppMessage(message) {
        console.log("Processing app message...")

        var command = message.readInt8(4)
        var transactionId = message.readInt8(5)
        console.log("Command: " + command + "; Transaction Id: " + transactionId)

        switch (command) {
        case BtMessage.AppMessageAck:
            console.log("ACK")
            if (_pendingMessages.count > 0) {
                console.log("Found pending message. Sending...")
                btConnectorSerialPort.sendMsg(_pendingMessages.get(0).msg)
                _pendingMessages.remove(0)
            }

            break
        case BtMessage.AppMessageNack:
            console.log("NACK")
            break
        case BtMessage.AppMessagePush:
            console.log("Push")

            var uuid = message.readHexString(6, 16)
            console.log("UUID: " + uuid)

            _sendAck(transactionId)

            var decodedDict = _decodeDictionaryFromMessage(message)
            console.log("Decoded dictionary: " + decodedDict)

            if (uuid === "e944c9197ae947378033ac073a1b8a90") {
                console.log("SmartWA message received.")

                var operation = decodedDict[1][0]
                console.log("Operation: " + operation)

                switch (operation) {
                case BtMessage.SM_NEXT_TRACK_KEY:
                    console.log("Next track")
                    musicControlReply(BtMessage.Next)
                    break
                case BtMessage.SM_PREVIOUS_TRACK_KEY:
                    console.log("Previous track")
                    musicControlReply(BtMessage.Previous)
                    break
                case BtMessage.SM_VOLUME_DOWN_KEY:
                    console.log("Volume down")
                    musicControlReply(BtMessage.VolumeDown)
                    break
                case BtMessage.SM_VOLUME_UP_KEY:
                    console.log("Volume up")
                    musicControlReply(BtMessage.VolumeUp)
                    break
                case BtMessage.SM_PLAYPAUSE_KEY:
                    console.log("Play/pause")
                    musicControlReply(BtMessage.PlayPause)
                    break
                }
            } else {
                console.log("Unknown app uuid: " + uuid)
            }

            break
        case BtMessage.AppMessageRequest:
            console.log("Request")
            break
        default:
            console.log("Unknown command: " + command)
        }
    }

    function _decodeDictionaryFromMessage(message) {
        var tupleCount = message.readInt8(22)
        console.log("_decodeDictionaryFromMessage, Tuple Count: " + tupleCount)

        var offset = 23
        var currentTuple = 0

        var ret = []

        while (currentTuple < tupleCount) {
            var entry = []

            var key = message.readInt32le(offset)
            var type = message.readInt8(offset + 4)
            var length = message.readInt16le(offset + 5)

            console.log("Tuple: " + currentTuple + "; Key: " + key + "; Type: " + type + "; Length: " + length)

            var data
            switch (type) {
            case BtMessage.AppMessageByteArray:
                data = message.readHexString(offset + 7, length)
                break
            case BtMessage.AppMessageCString:
                data = message.readString(offset + 7, length)
                break
            case BtMessage.AppMessageUInt:
                data = _readLeIntFrom(message, offset + 7, length)
                break
            case BtMessage.AppMessageInt:
                data = _readLeIntFrom(message, offset + 7, length)
                break
            default:
                console.log("Unknown data type: " + type)
            }
            console.log("Data: " + data)

            entry.push(key)
            entry.push(data)
            ret.push(entry)

            offset += 7 + length
            currentTuple++
        }

        return ret
    }

    function _incrementTransactionId() {
        _transactionId++
        if (_transactionId >= 255) {
            _transactionId = 0
        }
    }

    function _padString(orig, newLength, chr) {
        var ret = orig
        while (ret.length < newLength) {
            ret = ret + chr
        }
        return ret
    }

    function _readLeIntFrom(message, position, length) {
        var data
        switch (length) {
        case 1:
            data = message.readInt8(position)
            break
        case 2:
            data = message.readInt16le(position)
            break
        case 4:
            data = message.readInt32le(position)
            break
        default:
            console.log("Int length: " + length + "; Falling back to 8 bit operation.")
            data = message.readInt8(position)
        }
        return data
    }

    function _sendAck(transactionId) {
        console.log("Sending ack for transaction id: " + transactionId)

        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(2)
        msg.appendInt16(BtMessage.ApplicationMessage)
        msg.appendInt8(BtMessage.AppMessageAck)
        msg.appendInt8(transactionId)

        btConnectorSerialPort.sendMsg(msg)
    }

    function _smartWaMusicNowPlaying(track, album, artist) {
        console.log("Sending artist and track to SmartWA. Artist: " + artist + "; Track: " + track)

        _incrementTransactionId()
        var txId2 = _transactionId
        _incrementTransactionId()
        var txId1 = _transactionId

        var msg1 = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg1.appendInt16(BtMessage.ApplicationMessage)

        msg1.appendInt8(BtMessage.AppMessagePush)
        msg1.appendInt8(txId1)
        msg1.appendHex("e944c9197ae947378033ac073a1b8a90")
        msg1.appendInt8(3)

        msg1.appendInt32le(BtMessage.SM_STATUS_MUS_ARTIST_KEY)
        msg1.appendInt8(BtMessage.AppMessageCString)
        var len1 = msg1.stringLength(artist)
        msg1.appendInt16le(len1)
        msg1.appendString(artist)

        msg1.prependInt16(msg1.size() - 2)
        _pendingMessages.append({msg: msg1})


        var msg2 = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg2.appendInt16(BtMessage.ApplicationMessage)

        msg2.appendInt8(BtMessage.AppMessagePush)
        msg2.appendInt8(txId2)
        msg2.appendHex("e944c9197ae947378033ac073a1b8a90")
        msg2.appendInt8(3)

        msg2.appendInt32le(BtMessage.SM_STATUS_MUS_TITLE_KEY)
        msg2.appendInt8(BtMessage.AppMessageCString)
        var len2 = msg2.stringLength(track)
        msg2.appendInt16le(len2)
        msg2.appendString(track)

        msg2.prependInt16(msg2.size() - 2)
        btConnectorSerialPort.sendMsg(msg2)

    }

    ListModel {
        id: _pendingMessages
    }
}

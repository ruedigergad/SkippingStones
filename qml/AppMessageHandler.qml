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

    function processAppMessage(message) {
        console.log("Processing app message...")

        var command = message.readInt8(4)
        var transactionId = message.readInt8(5)
        var uuid = message.readHexString(6, 16)
        console.log("Command: " + command + "; Transaction Id: " + transactionId + "; UUID: " + uuid)

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
}

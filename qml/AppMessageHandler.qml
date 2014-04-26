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

    property bool smartStatusEnabled: smartStatusUuid.length === 32
    property string smartStatusUuid: ""

    property int _transactionId: 0

    function musicNowPlaying(track, album, artist) {
        if (smartStatusEnabled) {
            _smartStatusMusicNowPlaying(_padString(track, 30, " "), _padString(album, 30, " "), _padString(artist, 30, " "))
        }
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

            if (uuid === smartStatusUuid) {
                console.log("SmartStatus message received.")

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

    function updatePhoneBatteryStatus(chargeLevel) {
        if (smartStatusEnabled) {
            _smartStatusPhoneBatterStatusUpdate(chargeLevel)
        }
    }

    function updateTemperature(temperature) {
        if (smartStatusEnabled) {
            _smartStatusTemperatureUpdate(_padString(temperature, 3, " "))
        }
    }

    function updateVolume(vol) {
        if (smartStatusEnabled) {
            _smartStatusVolumeUpdate(vol)
        }
    }

    function updateWeatherIcon(icon) {
        if (smartStatusEnabled) {
            var iconId = _getSmIconId(icon)
            console.log("Got SmartStatus weather icon id: " + iconId)
            _smartStatusWeatherIconIdUpdate(iconId)
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

    function _getSmIconId(icon) {
        console.log("Converting icon name into SmartStatus icon id: " + icon)
        var sId = parseInt(icon.split(".")[0])
        console.log("Got sourceId: " + sId)
        if (sId === 31 || sId === 32 || sId === 36) {
            return 0
        } else if (sId === 1 || sId === 2 || (sId >= 8 && sId <= 12) || sId === 39 || sId === 40 || sId === 45) {
            return 1
        } else if (sId === 25 || sId === 26) {
            return 2
        } else if ((sId >= 27 && sId <= 30) || sId === 34 || sId === 37 || sId === 44) {
            return 3
        } else if (sId >= 19 && sId <= 22) {
            return 4
        } else if (sId === 23 || sId === 24) {
            return 5
        } else if ((sId >= 5 && sId <= 7) || (sId >= 13 && sId <= 16) || sId === 18 || (sId >= 41 && sId <= 43) || sId === 46) {
            return 6
        } else if (sId === 0 || sId === 3 || sId === 4 || sId === 17 || sId === 35 || sId === 37 || sId === 38 || sId === 44 || sId === 47) {
            return 7
        } else {
            return 8
        }
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

    function _smartStatusMusicNowPlaying(track, album, artist) {
        console.log("Sending artist and track to SmartStatus. Artist: " + artist + "; Track: " + track)

        _incrementTransactionId()
        var txId2 = _transactionId
        _incrementTransactionId()
        var txId1 = _transactionId

        var msg1 = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg1.appendInt16(BtMessage.ApplicationMessage)

        msg1.appendInt8(BtMessage.AppMessagePush)
        msg1.appendInt8(txId1)
        msg1.appendHex(smartStatusUuid)
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
        msg2.appendHex(smartStatusUuid)
        msg2.appendInt8(3)

        msg2.appendInt32le(BtMessage.SM_STATUS_MUS_TITLE_KEY)
        msg2.appendInt8(BtMessage.AppMessageCString)
        var len2 = msg2.stringLength(track)
        msg2.appendInt16le(len2)
        msg2.appendString(track)

        msg2.prependInt16(msg2.size() - 2)
        btConnectorSerialPort.sendMsg(msg2)

    }

    function _smartStatusTemperatureUpdate(temperature) {
        console.log("Sending new temperature to watch: " + temperature)

        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(BtMessage.ApplicationMessage)

        msg.appendInt8(BtMessage.AppMessagePush)
        _incrementTransactionId()
        msg.appendInt8(_transactionId)
        msg.appendHex(smartStatusUuid)
        msg.appendInt8(3)

        msg.appendInt32le(BtMessage.SM_WEATHER_TEMP_KEY)
        msg.appendInt8(BtMessage.AppMessageCString)
        msg.appendInt16le(msg.stringLength(temperature))
        msg.appendString(temperature)

        msg.prependInt16(msg.size() - 2)
        btConnectorSerialPort.sendMsg(msg)
    }

    function _smartStatusPhoneBatterStatusUpdate(chargeLevel) {
        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(BtMessage.ApplicationMessage)

        msg.appendInt8(BtMessage.AppMessagePush)
        _incrementTransactionId()
        msg.appendInt8(_transactionId)
        msg.appendHex(smartStatusUuid)
        msg.appendInt8(3)

        msg.appendInt32le(BtMessage.SM_COUNT_BATTERY_KEY)
        msg.appendInt8(BtMessage.AppMessageInt)
        msg.appendInt16le(1)
        msg.appendInt8(chargeLevel)

        msg.prependInt16(msg.size() - 2)
        btConnectorSerialPort.sendMsg(msg)
    }

    function _smartStatusVolumeUpdate(vol) {
        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(BtMessage.ApplicationMessage)

        msg.appendInt8(BtMessage.AppMessagePush)
        _incrementTransactionId()
        msg.appendInt8(_transactionId)
        msg.appendHex(smartStatusUuid)
        msg.appendInt8(3)

        msg.appendInt32le(BtMessage.SM_VOLUME_VALUE_KEY)
        msg.appendInt8(BtMessage.AppMessageInt)
        msg.appendInt16le(1)
        msg.appendInt8(vol)

        msg.prependInt16(msg.size() - 2)
        btConnectorSerialPort.sendMsg(msg)
    }

    function _smartStatusWeatherIconIdUpdate(iconId) {
        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(BtMessage.ApplicationMessage)

        msg.appendInt8(BtMessage.AppMessagePush)
        _incrementTransactionId()
        msg.appendInt8(_transactionId)
        msg.appendHex(smartStatusUuid)
        msg.appendInt8(3)

        msg.appendInt32le(BtMessage.SM_WEATHER_ICON_KEY)
        msg.appendInt8(BtMessage.AppMessageInt)
        msg.appendInt16le(1)
        msg.appendInt8(iconId)

        msg.prependInt16(msg.size() - 2)
        btConnectorSerialPort.sendMsg(msg)
    }

    ListModel {
        id: _pendingMessages
    }
}

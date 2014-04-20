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
    id: putBytes

    property string data
    property int dataIndex
    property int token

    signal error()
    signal internalError()
    signal messageReceived(var message)
    signal success()

    state: "NotStarted"

    states: [
        State {
            name: "NotStarted"
        },
        State {
            name: "WaitForToken"
        },
        State {
            name: "InProgress"
        },
        State {
            name: "Commit"
        },
        State {
            name: "Complete"
        },
        State {
            name: "Failed"
        }
    ]

    onInternalError: {
        console.log("Error in state: " + state)
        state = "NotStarted"
        _abort()
        error()
    }

    onMessageReceived: {
        console.log("PutBytes, message received. State: " + state)

        switch (state) {
        case "NotStarted":
            break
        case "WaitForToken":
            _handleTokenReply(message)
            break
        case "InProgress":
            _handleInProgress(message)
            break
        case "Commit":
            _handleCommit(message)
            break
        case "Complete":
            var replyStatus = message.readInt8(4)
            console.log("Got complete reply status: " + replyStatus)

            if (replyStatus !== 1) {
                console.log("Error while completing upload.")
                internalError()
                return
            }

            _notifySuccess()
            break
        case "Failed":
            break
        default:
            console.log("Unknown state: " + state)
        }
    }

    function _notifySuccess() {
        console.log("Upload to watch succeeded.")
        state = "NotStarted"
        success()
    }

    function uploadData(targetIndex, transferType, data) {
        console.log("Entering sendData, targetIndex: " + targetIndex
                    + "; transferType: " + transferType
                    + "; Data Length: " + data.length)
        // FIXME: Be either brute force or cautious.
        //        Choose one of the two below.
        state = "NotStarted"
        if (state !== "NotStarted") {
            console.log("Error, putBytes is in state: " + state)
            console.log("We have to be in NotStarted state in order to send new data.")
            internalError()
            return
        }

        putBytes.data = data

        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(7)
        msg.appendInt16(BtMessage.PutBytes)
        msg.appendInt8(1)
        msg.appendInt32(data.length)
        msg.appendInt8(transferType)
        msg.appendInt8(targetIndex)

        state = "WaitForToken"
        btConnectorSerialPort.send(msg)
    }

    function _handleTokenReply(message) {
        var replyStatus = message.readInt8(4)
        console.log("Got token reply status: " + replyStatus)

        if (replyStatus !== 1) {
            console.log("Error while waiting for token.")
            internalError()
            return
        }

        token = message.readInt32(5)
        console.log("Got token: " + token)

        dataIndex = 0
        state = "InProgress"
        _send()
    }

    function _send() {
        console.log("_send, token: " + token + "; dataIndex: " + dataIndex)

        var sendLength = Math.min(((data.length / 2) - dataIndex), 2000)
        console.log("sendLength: " + sendLength)

        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(BtMessage.PutBytes)
        msg.appendInt8(2)
        msg.appendInt32(token & 0xffffffff)
        msg.appendInt32(sendLength)
        msg.appendHex(data.substring((dataIndex * 2), ((dataIndex + sendLength) * 2)))
        msg.prependInt16(sendLength + 9)

        dataIndex += sendLength

        btConnectorSerialPort.send(msg)
    }

    function _handleInProgress(message) {
        var replyStatus = message.readInt8(4)
        console.log("Got in-progress reply status: " + replyStatus)

        if (replyStatus !== 1) {
            console.log("Error while transferring data.")
            internalError()
            return
        }

        if (data.length > (dataIndex * 2)) {
            console.log("Continueing to send...")
            _send()
            return
        } else {
            console.log("Finished sending data. Going to commit now.")
            _commit()
        }
    }

    function _commit() {
        console.log("_commit")

        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(9)
        msg.appendInt16(BtMessage.PutBytes)
        msg.appendInt8(2)
        msg.appendInt32(token & 0xffffffff)
        msg.appendInt32(0)

        state = "Commit"
        btConnectorSerialPort.send(msg)
    }

    function _handleCommit(message) {
        var replyStatus = message.readInt8(4)
        console.log("Got commit reply status: " + replyStatus)

        if (replyStatus !== 1) {
            console.log("Error while commiting.")
            internalError()
            return
        }

        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(5)
        msg.appendInt16(BtMessage.PutBytes)
        msg.appendInt8(5)
        msg.appendInt32(token & 0xffffffff)

        state = "Complete"
        btConnectorSerialPort.send(msg)
    }

    function _abort() {
        console.log("Aborting...")

        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);
        msg.appendInt16(5)
        msg.appendInt16(BtMessage.PutBytes)
        msg.appendInt8(4)
        msg.appendInt32(token & 0xffffffff)

        btConnectorSerialPort.send(msg)
    }
}

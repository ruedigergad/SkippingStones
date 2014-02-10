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

            success()
            break
        case "Failed":
            break
        default:
            console.log("Unknown state: " + state)
        }
    }

    onSuccess: {
        console.log("Upload to watch succeeded.")
        state = "NotStarted"
    }

    function uploadData(targetIndex, transferType, data) {
        console.log("Entering sendData, targetIndex: " + targetIndex
                    + "; transferType: " + transferType
                    + "; Data Length: " + data.length)
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

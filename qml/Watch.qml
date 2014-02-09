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
    id: watch

    state: "NotConnected"

    signal textReply(string text)

    states: [
        State {
            name: "Connected"
        },
        State {
            name: "Connecting"
        },
        State {
            name: "NotConnected"
        }
    ]

    function connect(address) {
        watch.state = "Connecting"
        btConnectorSerialPort.connect(address, 1)
        btConnectorAVRemoteControl.connect(address, 23)
    }

    function disconnect() {
        btConnectorSerialPort.disconnect()
        btConnectorAVRemoteControl.disconnect()
    }

    function getAppBankStatus() {
        sendInt8(1, BtMessage.AppManager)
    }

    function listAppsByUuid() {
        sendInt8(5, BtMessage.AppManager)
    }

    function musicNowPlaying(track, album, artist) {
        var data = new Array(track, album, artist)
        sendTextArray(data, BtMessage.MusicControl, BtMessage.NowPlayingData)
    }

    function notificationEmail(sender, subject, body) {
        var data = new Array(sender, body, "" + new Date(), subject)
        sendTextArray(data, BtMessage.Notification, BtMessage.Email)
    }

    function notificationSms(sender, body) {
        var data = new Array(sender, body, "" + new Date())
        sendTextArray(data, BtMessage.Notification, BtMessage.SMS)
    }

    function sendHex(hexCommand) {
        btConnectorSerialPort.sendHex(hexCommand)
    }

    function sendInt8(data, endpoint) {
        console.log("Sending int8: " + data + " Endpoint:" + endpoint)
        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);

        msg.appendInt16(1)
        msg.appendInt16(endpoint)
        msg.appendInt8(data)

        btConnectorSerialPort.send(msg)
    }

    function sendTextArray(data, endpoint, prefix) {
        console.log("Sending data: " + data + " Endpoint:" + endpoint + " Prefix:" + prefix)
        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);

        msg.appendInt16(endpoint)
        if (prefix !== BtMessage.InvalidPrefix) {
            msg.appendInt8(prefix)
        }

        for (var i = 0; i < data.length; ++i) {
            var d = data[i]
            var len = d.length
            console.log("Adding text \"" + d + "\" with length " + len + ".")
            msg.appendInt8(len)
            msg.appendString(d)
        }
        msg.prependInt16(msg.size() - 2)

        btConnectorSerialPort.send(msg)
    }

    function sendTextString(message, endpoint, prefix) {
        console.log("Sending message: " + message + " Endpoint:" + endpoint + " Prefix:" + prefix)
        sendTextArray(message.split("|"), endpoint, prefix)
    }

    BtConnector {
        id: btConnectorSerialPort

        onConnected: {
            console.log("BtConnectorSerialPort connected.")
            watch.state = "Connected"
        }

        onDisconnected: {
            console.log("BtConnectorSerialPort disconnected.")
            watch.state = "NotConnected"
        }

        onError: {
            console.log("BtConnectorSerialPort error: " + errorCode)
            watch.state = "NotConnected"
        }

        onMessageReceived: {
            console.log("Received message: " + message.toHexString())

            switch(message.endpoint()) {
            case BtMessage.Time:
                console.log("Received a time message.")
                var date = new Date(message.readInt32(5) * 1000)
                console.log("Got date: " + date)
                watch.textReply("" + date)
                break;
            default:
                console.log("Unknown endpoint: " + message.endpoint())
                watch.textReply(message.toHexString())
            }
        }
    }

    BtConnector {
        id: btConnectorAVRemoteControl

        onConnected: {
            console.log("BtConnectorAVRemoteControl connected.")
        }

        onDisconnected: {
            console.log("BtConnectorAVRemoteControl disconnected.")
        }

        onError: {
            console.log("BtConnectorAVRemoteControl error: " + errorCode)
        }
    }

}

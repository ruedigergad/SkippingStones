import QtQuick 2.0
import harbour.skippingstones 1.0

Item {
    id: watch

    state: "NotConnected"

    signal textReply(string text)

//    states: [
//        State {
//            name: "Connected"
//        },
//        State {
//            name: "Connecting"
//        },
//        State {
//            name: "NotConnected"
//        }
//    ]

    function connect() {
        watch.state = "Connecting"
        btConnectorSerialPort.connect(pebbleLabel.text, 1)
        btConnectorAVRemoteControl.connect(pebbleLabel.text, 23)
    }

    function disconnect() {
        btConnectorSerialPort.disconnect()
        btConnectorAVRemoteControl.disconnect()
    }

    function sendHex(hexCommand) {
        btConnectorSerialPort.sendHex(hexCommand)
    }

    function sendText(message, endpoint, prefix) {
        console.log("Sending text: " + message + " Endpoint:" + endpoint + " Prefix:" + prefix)
        var msg = Qt.createQmlObject('import harbour.skippingstones 1.0; BtMessage {}', parent);

        msg.appendInt16(endpoint)
        if (prefix !== BtMessage.InvalidPrefix) {
            msg.appendInt8(prefix)
        }

        var messageParts = message.split("|")
        for (var i = 0; i < messageParts.length; ++i) {
            var mp = messageParts[i]
            var len = mp.length
            console.log("Adding text \"" + mp + "\" with length " + len + ".")
            msg.appendInt8(len)
            msg.appendString(mp)
        }
        msg.prependInt16(msg.size() - 2)

        btConnectorSerialPort.send(msg)
//        btConnectorSerialPort.sendText(commandData, endpoint, prefix)
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

        onTextReply: {
            watch.textReply(text)
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

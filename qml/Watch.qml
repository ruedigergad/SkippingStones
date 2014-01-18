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

    function sendText(commandData, endpoint, prefix) {
        btConnectorSerialPort.sendText(commandData, endpoint, prefix)
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

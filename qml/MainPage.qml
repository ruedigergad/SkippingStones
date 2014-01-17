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
import QtBluetooth 5.0
import Sailfish.Silica 1.0
import harbour.skippingstones 1.0

Page {
    id: mainPage

    state: "NotConnected"

    property string commandData;
    property int endpoint: -1
    property string hexCommand: ""
    property int prefix: -1
    property bool initializing: true

    Component.onCompleted: {
        initializing = false
    }

    states: [
        State {
            name: "Connected"
            PropertyChanges {
                target: connectButton
                text: "Disconnect"
                enabled: true
            }
        },
        State {
            name: "Connecting"
            PropertyChanges {
                target: connectButton
                text: "Connecting"
                enabled: false
            }
        },
        State {
            name: "NotConnected"
            PropertyChanges {
                target: connectButton
                text: "Connect"
                enabled: true
            }
        }
    ]

    SilicaFlickable {
        id: mainFlickable

        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            id: menu

            MenuItem {
                id: scanMenuItem

                text: "Scan for Pebble"
                onClicked: btDiscovery.discovery = true
            }
        }

        Column {
            id: column

            width: mainPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Skipping Stones"
            }

            TextField {
                id: pebbleLabel

                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                text: "00:17:E9:71:35:6C" //"No Pebble found yet."
            }

            Button {
                id: connectButton

                anchors.horizontalCenter: parent.horizontalCenter
                enabled: pebbleLabel.text !== "No Pebble found yet."
                text: "Connect"

                onClicked: {
                    if (mainPage.state === "NotConnected") {
                        mainPage.state = "Connecting"
                        btConnectorSerialPort.connect(pebbleLabel.text, 1)
                        btConnectorAVRemoteControl.connect(pebbleLabel.text, 23)
                    } else {
                        btConnectorSerialPort.disconnect()
                        btConnectorAVRemoteControl.disconnect()
                    }
                }
            }

            Button {
                id: sendCommandButton

                anchors.horizontalCenter: parent.horizontalCenter
                enabled: mainPage.state === "Connected"
                text: "Send Command"

                onClicked: {
                    if (hexCommand !== "") {
                        console.log("Sending hex command.")
                        btConnectorSerialPort.sendHex(hexCommand)
                    } else {
                        console.log("Sending text command.")
                        btConnectorSerialPort.sendText(commandData, endpoint, prefix)
                    }
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                text: hexCommand
            }

            ComboBox {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.7

                menu: ContextMenu {
                    MenuItem {
                        text: "Get Time"
                        onClicked: hexCommand = "0001000b00"
                    }
                    MenuItem {
                        text: "Get Version"
                        onClicked: hexCommand = "0001001000"
                    }
                    MenuItem {
                        text: "MusicControl"
                        onClicked: {
                            hexCommand = ""
                            endpoint = BtConnector.MusicControl
                            prefix = BtConnector.NowPlayingData
                            /*
                             * Expected data format:
                             * <artist>|<album>|<track>
                             */
                            commandData = customCommandTextField.text
                        }
                    }
                    MenuItem {
                        text: "SMS Notification"
                        onClicked: {
                            hexCommand = ""
                            endpoint = BtConnector.Notification
                            prefix = BtConnector.SMS
                            /*
                             * Expected data format:
                             * <sender>|<body>|<ts>
                             */
                            commandData = customCommandTextField.text
                        }
                    }
                    MenuItem {
                        text: "E-Mail Notification"
                        onClicked: {
                            hexCommand = ""
                            endpoint = BtConnector.Notification
                            prefix = BtConnector.Email
                            /*
                             * Expected data format:
                             * <sender>|<body>|<ts>|<subject>
                             */
                            commandData = customCommandTextField.text
                        }
                    }
                    MenuItem {
                        text: "Custom"
                        onClicked: hexCommand = customCommandTextField.text
                    }
                }
            }

            TextField {
                id: customCommandTextField

                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                placeholderText: "Enter Optional Parameters"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                text: "Reply:"
            }

            Label {
                id: replyLabel
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                text: ""
            }
        }
    }

    BluetoothDiscoveryModel {
        id: btDiscovery

        discovery: false
        minimalDiscovery: true

        onDiscoveryChanged: {
            console.log("Discovery changed: " + discovery)

            if(initializing)
                return

            if (discovery) {
                menu.enabled = false
                connectButton.enabled = false
            } else {
                menu.enabled = true
                connectButton.enabled = pebbleLabel.text !== "No Pebble found yet."
            }
        }

        onErrorChanged: {
            console.log("BtDiscovery ErrorChanged: " + error)
        }

        onNewServiceDiscovered: {
            console.log("Service " + service.serviceName + " found on "
                        + service.deviceName + " at address " + service.deviceAddress
                        + " on port " + service.servicePort + ".")

            // FIXME: This is wrong right now.
            // Howver, discovery is not working properly anyhow, at the moment.
            if (service.serviceName !== "Zeemote")
                return

            pebbleLabel.text = service.deviceAddress

            discovery = false
            console.log("Found Pebble. Stopped further discovery.")
        }
    }

    BtConnector {
        id: btConnectorSerialPort

        onConnected: {
            console.log("BtConnectorSerialPort connected.")
            mainPage.state = "Connected"
        }

        onDisconnected: {
            console.log("BtConnectorSerialPort disconnected.")
            mainPage.state = "NotConnected"
        }

        onError: {
            console.log("BtConnectorSerialPort error: " + errorCode)
            mainPage.state = "NotConnected"
        }

        onTextReply: {
            replyLabel.text = text
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

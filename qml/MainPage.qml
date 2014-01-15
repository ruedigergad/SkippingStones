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

    property bool initializing: true

    Component.onCompleted: {
        initializing = false
    }

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

            Label {
                id: pebbleLabel

                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
                text: "00:17:E9:71:35:6C" //"No Pebble found yet."
            }

            Button {
                id: connectButton

                anchors.horizontalCenter: parent.horizontalCenter
                enabled: pebbleLabel.text !== "No Pebble found yet."
                text: "Connect"

                onClicked: btConnector.connect(pebbleLabel.text, 1)
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

            if(service.serviceName !== "Zeemote")
                return

            pebbleLabel.text = service.deviceAddress

            discovery = false
            console.log("Found Pebble. Stopped further discovery.")
        }
    }

    BtConnector {
        id: btConnector

        onConnected: {
            console.log("BtConnector connected.")
        }

        onDisconnected: {
            console.log("BtConnector disconnected.")
        }

        onError: {
            console.log("BtConnector error: " + errorCode)
        }
    }
}

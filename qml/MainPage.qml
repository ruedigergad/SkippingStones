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
import QtBluetooth 5.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0
import harbour.skippingstones 1.0

Page {
    id: mainPage

    state: watch.state

    property string commandData;
    property int endpoint: -1
    property string hexCommand: ""
    property int prefix: -1
    property bool initializing: true

    Component.onCompleted: {
        initializing = false
        pebbleAddressInput.text = settingsAdapter.readString("PebbleAddress", "")
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
                id: pebbleAddressInput

                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                label: "Pebble Address"
                placeholderText: "No watch found yet."
                width: parent.width * 0.8
            }

            Button {
                id: connectButton

                anchors.horizontalCenter: parent.horizontalCenter
                enabled: pebbleAddressInput.acceptableInput
                text: "Connect"

                onClicked: {
                    if (mainPage.state === "NotConnected") {
                        settingsAdapter.setString("PebbleAddress", pebbleAddressInput.text)
                        watch.connect(pebbleAddressInput.text)
                    } else {
                        watch.disconnect()
                    }
                }
            }

            TextField {
                id: textA

                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                label: "Text Data A"
                text: "AAA"
                width: parent.width * 0.8
            }

            TextField {
                id: textB

                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                label: "Text Data B"
                text: "BBB"
                width: parent.width * 0.8
            }

            TextField {
                id: textC

                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                label: "Text Data C"
                text: "CCC"
                width: parent.width * 0.8
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8

                Button {
                    enabled: mainPage.state === "Connected"
                    text: "SMS"
                    width: parent.width / 3

                    onClicked: watch.notificationSms(textA.text, textB.text)
                }

                Button {
                    enabled: mainPage.state === "Connected"
                    text: "E-Mail"
                    width: parent.width / 3

                    onClicked: watch.notificationEmail(textA.text, textB.text, textC.text)
                }

                Button {
                    enabled: mainPage.state === "Connected"
                    text: "Music"
                    width: parent.width / 3

                    onClicked: watch.musicNowPlaying(textA.text, textB.text, textC.text)
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8

                Button {
                    enabled: mainPage.state === "Connected"
                    text: "AppBank"
                    width: parent.width / 3

                    onClicked: watch.getAppBankStatus()
                }

                Button {
                    enabled: mainPage.state === "Connected"
                    text: "Apps"
                    width: parent.width / 3

                    onClicked: watch.listAppsByUuid()
                }

                Button {
                    property int step: 0

                    enabled: mainPage.state === "Connected"
                    text: "Inst."
                    width: parent.width / 3
                    onClicked: {
                        var home = fileSystemHelper.getHomePath()
                        var pbwDir = home + "/.skippingStones/pbw/"
                        var targetIndex = 2

                        /*
                         * Quite a hack, for now, to manually step through all tasks in a watchface/app upload.
                         */
                        switch (step) {
                        case 0:
                            watch.uploadFile(targetIndex, BtMessage.PutBytesBinary, pbwDir + "pebble-app.bin")
                            step++
                            break
                        case 1:
                            watch.uploadFile(targetIndex, BtMessage.PutBytesResources, pbwDir + "app_resources.pbpack")
                            step++
                            break
                        case 2:
                            watch.addApp(targetIndex)
                            step = 0
                            break
                        }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8

                Button {
                    enabled: mainPage.state === "Connected"
                    text: "Call"
                    width: parent.width / 3

                    onClicked: watch.incomingCall(textA.text, textB.text)
                }

                Button {
                    enabled: mainPage.state === "Connected"
                    text: "N/A"
                    width: parent.width / 3
                }

                Button {
                    enabled: mainPage.state === "Connected"
                    text: "N/A"
                    width: parent.width / 3
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8

                Button {
                    //enabled: mainPage.state === "Connected"
                    text: "Next"
                    width: parent.width / 3

                    onClicked: fileSystemHelper.mrcHack("next")
                }

                Button {
                    //enabled: mainPage.state === "Connected"
                    text: "Prev"
                    width: parent.width / 3

                    onClicked: fileSystemHelper.mrcHack("prev")
                }

                Button {
                    //enabled: mainPage.state === "Connected"
                    text: "Foo"
                    width: parent.width / 3

                    onClicked: fileSystemHelper.mrcHack("foo")
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
                        watch.sendHex(hexCommand)
                    } else {
                        console.log("Sending text command.")
                        watch.sendTextString(commandData, endpoint, prefix)
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
                        text: "Custom"
                        onClicked: hexCommand = customCommandTextField.text
                    }
                }
            }

            TextField {
                id: customCommandTextField

                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeLarge
                label: "Command/Data"
                placeholderText: "Enter Optional Parameters"
                width: parent.width * 0.8
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
                connectButton.enabled = pebbleAddressInput.text !== ""
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

            pebbleAddressInput.text = service.deviceAddress

            discovery = false
            console.log("Found Pebble. Stopped further discovery.")
        }
    }

    Watch {
        id: watch

        onMusicControlReply: {
            console.log("Music control reply: " + code)
            switch(code) {
            case BtMessage.Next:
                mediaPlayerRemoteControl.call("executeCommand", "next")
                break
            case BtMessage.Previous:
                mediaPlayerRemoteControl.call("executeCommand", "prev")
                break
            case BtMessage.PlayPause:
                mediaPlayerRemoteControl.call("executeCommand", "toggle_pause")
                break
            }
        }

        onTextReply: replyLabel.text = text
    }

    FileSystemHelper {
        id: fileSystemHelper
    }

    DBusAdaptor {
        id: mediaPlayerNotification

        service: "com.jolla.mediaplayer.notification"
        iface: "com.jolla.mediaplayer.notification.Interface"
        path: "/com/jolla/mediaplayer/notification"

        signal nowPlaying(string track, string album, string artist)

        onNowPlaying: {
            watch.musicNowPlaying(track, album, artist)
        }
    }

    DBusInterface {
        id: mediaPlayerRemoteControl

        destination: "com.jolla.mediaplayer.remotecontrol"
        iface: "com.jolla.mediaplayer.remotecontrol.Interface"
        path: "/com/jolla/mediaplayer/remotecontrol"
    }

    DbusOfonoAdapter {
        id: ofonoAdapter

        onEmail: {
            console.log("Got e-mail notification.\nPreviewSummary: " + previewSummary + "\nPreviewBody: " + previewBody + "\nPublishedMessages: " + publishedMessages)
            watch.notificationEmail(previewSummary, previewBody === "" ? "placeholder" : previewBody, "placeholder")
        }

        onPhoneCall: {
            console.log("Phone call from number: " + number + " name: " + name)
            watch.incomingCall(number, name)
        }

        onSmsReceived: {
            console.log("SMS received, from: " + sender + " text: " + messageText)
            watch.notificationSms(sender, messageText)
        }
    }

    SettingsAdapter {
        id: settingsAdapter
    }
}

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
        autoConnectIntervalSlider.value = settingsAdapter.readInt("AutoConnectInterval", 300)
        autoConnectSwitch.checked = settingsAdapter.readBoolean("AutoConnectEnabled", false)
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

            TextSwitch {
                id: autoConnectSwitch

                description: "Try to automatically connect to the watch."
                text: "Auto Connect"

                onCheckedChanged: {
                    if (checked && pebbleAddressInput.acceptableInput && watch.state === "NotConnected") {
                        watch.connect(pebbleAddressInput.text)
                    }
                    settingsAdapter.setBoolean("AutoConnectEnabled", checked)
                }
            }

            Slider {
                id: autoConnectIntervalSlider

                label: "Auto Connect Interval"
                minimumValue: 10
                maximumValue: 1800
                stepSize: 1
                value: 300
                valueText: value + "s"
                width: parent.width * 0.8

                onValueChanged: {
                    settingsAdapter.setInt("AutoConnectInterval", value)
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
                text: "App Bank"
            }

            SilicaListView {
                id: appBankListView

                property Item contextMenu

                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                height: width
                width: parent.width * 0.6

                delegate: Item {
                    id: appBankItem

                    property bool menuOpen: appBankListView.contextMenu != null
                                            && appBankListView.contextMenu.parent === appBankItem

                    width: ListView.view.width
                    height: menuOpen ? appBankListView.contextMenu.height + appBankBackgroundItem.height
                                     : appBankBackgroundItem.height

                    BackgroundItem {
                        id: appBankBackgroundItem

                        height: appBankItemLabel.height
                        width: parent.width

                        Label {
                            id: appBankItemLabel
                            text: bankIndex + ":  " + name
                        }

                        onPressed: appBankListView.currentIndex = index

                        onPressAndHold: {
                            if (!appBankListView.contextMenu)
                                appBankListView.contextMenu = contextMenuComponent.createObject(appBankListView)
                            appBankListView.contextMenu.show(appBankItem)
                        }

                        RemorseItem { id: remorse }
                    }

                    function remove() {
                        var appId = id
                        var bankIdx = bankIndex

                        console.log("Starting remove remorse. Bank index: " + bankIdx + "; App id: " + appId)
                        remorse.execute(appBankBackgroundItem, "Removing", function() {
                            console.log("Removing. Bank index: " + bankIdx + "; App id: " + appId)
                            watch.removeApp(appId, bankIdx)
                            watch.getAppBankStatus()
                        }
                        )
                    }

                }

                Component {
                    id: contextMenuComponent

                    ContextMenu {
                        MenuItem {
                            text: "Add"
                            visible: appBankListView.model.get(appBankListView.currentIndex).id === -1

                            onClicked: {
                                var bankIndex = appBankListView.model.get(appBankListView.currentIndex).bankIndex
                                console.log("Opening add dialog for bank: " + bankIndex)
                                addAppSelectionDialog.bankIndex = bankIndex
                                addAppSelectionDialog.open()
                            }
                        }
                        MenuItem {
                            text: "Remove"
                            visible: appBankListView.model.get(appBankListView.currentIndex).id !== -1

                            onClicked: {
                                var itm = appBankListView.model.get(appBankListView.currentIndex)
                                console.log("Selected to remove app from bank: " + itm.bankIndex)
                                appBankListView.currentItem.remove()
                            }
                        }
                    }
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
                text: "\nDeveloper/Testing Tools"
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

                    enabled: mainPage.state === "Connected" && !watch.uploadInProgress
                    text: "Inst."
                    width: parent.width / 3
                    onClicked: {
                        appInstallBusyPage.startInstall()
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
                    text: "Rem."
                    width: parent.width / 3

                    onClicked: watch.removeApp(0, 0)
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
                    text: "ls pbw"
                    width: parent.width / 3

                    onClicked: addAppSelectionDialog.open()
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

        property bool firstConnect: true

        onAppBankListUpdated: {
            console.log("App bank list updated: " + appBankListModel)
            appBankListView.model = appBankListModel
        }

        onStateChanged: {
            appWindow.state = state

            if (state == "NotConnected") {
                console.log("Watch state is not connected.")
                if (autoConnectSwitch.checked) {
                    if (firstConnect) {
                        console.log("First auto connect...")
                        firstConnect = false
                        immediateConnectTimer.start()
                    } else {
                        console.log("Subsequent auto connect, using delayed timer.")
                        delayedConnectTimer.start()
                    }
                }
            } else if (state == "Connected") {
                console.log("Watch state is connected.")
                firstConnect = true
                getAppBankStatus()
            }
        }

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

        Timer {
            id: immediateConnectTimer
            interval: 2000
            repeat: false

            onTriggered: {
                if (watch.state == "NotConnected") {
                    console.log("ImmediateConnectTimer, trying to connect.")
                    watch.connect(pebbleAddressInput.text)
                }
            }
        }

        Timer {
            id: delayedConnectTimer
            interval: autoConnectIntervalSlider.value * 1000
            repeat: false

            onTriggered: {
                if (watch.state == "NotConnected") {
                    console.log("DelayedConnectTimer, trying to connect.")
                    watch.connect(pebbleAddressInput.text)
                }
            }
        }
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

    DbusAdapter {
        id: ofonoAdapter

        onCommhistoryd: {
            console.log("Got commhistoryd notification. Summary: " + summary + "; Body: " + body)
            watch.notificationSms(summary === "" ? "placeholder" : summary, body === "" ? "placeholder" : body)
        }

        onEmail: {
            console.log("Got e-mail notification.\nPreviewSummary: " + previewSummary + "\nPreviewBody: " + previewBody + "\nPublishedMessages: " + publishedMessages)
            watch.notificationEmail(previewSummary, previewBody === "" ? "placeholder" : previewBody, "placeholder")
        }

        onNotify: {
            console.log("Got notification. AppName: " + appName + "; Summary: " + summary + "; Body: " + body)
            if (appName === "harbour-mitakuuluu-server") {
                console.log("Ignoring message from harbour-mitakuuluu-server as we handle these messages somewhere else.")
            } else {
                watch.notificationEmail(appName === "" ? "placeholder" : appName, summary === "" ? "placeholder" : summary, body === "" ? "placeholder" : body)
            }
        }

        onPhoneCall: {
            console.log("Phone call from number: " + number + " name: " + name)
            watch.incomingCall(number, name)
        }

        onSmsReceived: {
            console.log("Ignoring received SMS, from: " + sender + " text: " + messageText)
            console.log("We should have gotten a notification via onCommhistoryd.")
//            console.log("SMS received, from: " + sender + " text: " + messageText)
//            watch.notificationSms(sender, messageText)
        }
    }

    SettingsAdapter {
        id: settingsAdapter
    }

    AppInstallationBusyPage {
        id: appInstallBusyPage
    }

    Dialog {
        id: addAppSelectionDialog

        property string pbwPath: fileSystemHelper.getHomePath() + "/skippingStones/pbw"
        property string pbwTmpPath: fileSystemHelper.getHomePath() + "/.skippingStones/pbw_tmp"
        property string filter: "*.pbw"

        property int bankIndex
        property string selection: ""

        canAccept: selection !== ""

        onAccepted: {
            console.log("addAppSelectionDialog accepted with selection: " + selection)
            fileSystemHelper.unzip(pbwPath + "/" + selection, pbwTmpPath)
            appInstallBusyPage.targetIndex = bankIndex
            appInstallBusyPage.startInstall()
        }

        onOpened: {
            selection = ""
            pbwFilesListView.model = fileSystemHelper.getFiles(pbwPath, filter)
        }

        DialogHeader {
            id: dialogHeader
            title: "Select File"
        }

        SilicaListView {
            id: pbwFilesListView

            anchors {
                top: dialogHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom
                margins: 40
            }

            highlightFollowsCurrentItem: true

            delegate: Item {
                id: delegateItem

                height: delegateLable.height
                width: ListView.view.width

                Label {
                    id: delegateLable

                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.primaryColor
                    text: modelData
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        pbwFilesListView.currentIndex = index
                        addAppSelectionDialog.selection = modelData
                    }
                }
            }

            highlight: Rectangle {
                color: Theme.highlightColor
                height: delegateItem.height
                opacity: 0.5
                width: delegateItem.width
            }
        }
    }
}

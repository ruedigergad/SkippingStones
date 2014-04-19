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
import Sailfish.Silica 1.0
import harbour.skippingstones 1.0

Page {
    id: appInstallBusyPage

    property string home: fileSystemHelper.getHomePath()
    property string pbwTmpDir: home + "/.skippingStones/pbw_tmp/"
    property bool running: false
    property int step: 0
    property int targetIndex: 0

    Label {
        text: "App Installation"
        anchors.bottom: appInstallBusyIndicator.top
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.primaryColor
    }

    BusyIndicator {
        id: appInstallBusyIndicator

        anchors.centerIn: parent
        running: appInstallBusyPage.running
        size: BusyIndicatorSize.Large
    }

    Label {
        id: currentActionLabel

        anchors.top: appInstallBusyIndicator.bottom
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.secondaryColor
    }

    function startInstall() {
        console.log("App install started.")
        pageStack.push(appInstallBusyPage)
        running = true
        doStep()
    }

    function installFinished() {
        console.log("App install finished.")
        running = false
        watch.getAppBankStatus()
        pageStack.pop()
    }

    function doStep() {
        console.log("App install doStep.")

        if (!running)
            return

        console.log("App install is running, going on.")
        /*
         * Quite a hack, for now, to step through all tasks in a watchface/app upload.
         */
        switch (step) {
        case 0:
            currentActionLabel.text = "Uploading app binary..."
            watch.uploadFile(targetIndex, BtMessage.PutBytesBinary, pbwTmpDir + "pebble-app.bin")
            step++
            break
        case 1:
            currentActionLabel.text = "Uploading app resources..."
            watch.uploadFile(targetIndex, BtMessage.PutBytesResources, pbwTmpDir + "app_resources.pbpack")
            step++
            break
        case 2:
            currentActionLabel.text = "Adding app..."
            watch.addApp(targetIndex)
            step = 0
            installFinishedTimer.start()
            break
        }
    }

    Connections {
        target: watch
        onUploadInProgressChanged: {
            if (! watch.uploadInProgress &&
                    appInstallBusyPage.running) {
                stepTimer.start()
            }
        }
    }

    Timer {
        id: installFinishedTimer

        interval: 1000
        repeat: false
        onTriggered: appInstallBusyPage.installFinished()
    }

    Timer {
        id: stepTimer

        interval: 100
        repeat: false
        onTriggered: appInstallBusyPage.doStep()
    }

}

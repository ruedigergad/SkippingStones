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

#include "filesystemhelper.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QProcess>

FileSystemHelper::FileSystemHelper(QObject *parent) :
    QObject(parent)
{
    QDir dir;
    dir.mkpath(QDir::homePath() + "/skippingStones/pbw");
    dir.mkpath(QDir::homePath() + "/.skippingStones/pbw_tmp");
}

/*
 * This is a hack for controlling the media player volume.
 * It worked at least with the media player being open.
 * Please note that the sink we are using for controlling the volume is
 * only present when the media player was started.
 * This hack was not tested under different conditions than just using the media player.
 * So, things can easily break.
 */
void FileSystemHelper::changeVolume(int direction) {
    qDebug("changeVolume");

    QProcess querySinkInputIdProcess;
    querySinkInputIdProcess.start("sh -c \"pactl list short | grep 'native.*s16le' | awk '{print $1}'\"");
    querySinkInputIdProcess.waitForFinished();
    QString sinkInputIdStr = querySinkInputIdProcess.readAllStandardOutput().trimmed();
    int sinkInputId = sinkInputIdStr.toInt();

    qDebug() << "Got sink input id string:" << sinkInputIdStr << "; int:" << sinkInputId;
    if (sinkInputId <= 0) {
        qDebug("Sink input id is invalid, aborting.");
        return;
    }

    QString volUpCmd = "sh -c \"pactl set-sink-input-volume " + sinkInputIdStr + " +5%\"";
    QString volDownCmd = "sh -c \"pactl set-sink-input-volume " + sinkInputIdStr + " -5%\"";
    QProcess changeVolumeProcess;
    switch (direction) {
    case VolumeUp:
        qDebug("Incrementing volume level.");
        qDebug() << "volUpCmd:" << volUpCmd;
        changeVolumeProcess.start(volUpCmd);
        break;
    case VolumeDown:
        qDebug("Decrementing volume level.");
        qDebug() << "volDownCmd:" << volDownCmd;
        changeVolumeProcess.start(volDownCmd);
        break;
    default:
        qDebug("Unknown direction: %i", direction);
        return;
    }
    changeVolumeProcess.waitForFinished();
    qDebug() << "StdOut:" << changeVolumeProcess.readAllStandardOutput();
    qDebug() << "StdErr:" << changeVolumeProcess.readAllStandardError();
}

int FileSystemHelper::getBatteryChargeLevel() {
    QProcess process;
    process.start("sh -c \"upower -i /org/freedesktop/UPower/devices/battery_battery | grep percentage\"");
    process.waitForFinished();

    QString stdOutString(process.readAllStandardOutput());
    qDebug() << "Got battery level:" << stdOutString;
    QStringList splitString = stdOutString.split(" ", QString::SkipEmptyParts);
    qDebug() << "Got battery level split strings:" << splitString;
    QString battLevel = splitString.at(1);
    battLevel.truncate(battLevel.lastIndexOf("%"));

    return battLevel.toInt();
}

QStringList FileSystemHelper::getFiles(QString dir, QString filter) {
    QDir d(dir);

    QStringList nameFilters;
    nameFilters.append(filter);

    d.setFilter(QDir::Files);
    d.setNameFilters(nameFilters);
    d.setSorting(QDir::Name);

    return d.entryList();
}

QString FileSystemHelper::getHomePath() {
    return QDir::homePath();
}

QString FileSystemHelper::readHex(const QString &fileName) {
    QFile f(fileName);
    if (! f.open(QFile::ReadOnly)) {
        return "";
    }
    return QString(f.readAll().toHex());
}

void FileSystemHelper::unzip(QString source, QString destination) {
    QProcess process;
    process.start("unzip -o " + source + " -d " + destination);
    process.waitForFinished();
}

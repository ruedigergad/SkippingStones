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

#include "settingsadapter.h"

#include <QSettings>

SettingsAdapter::SettingsAdapter(QObject *parent) :
    QObject(parent)
{
}

bool SettingsAdapter::readBoolean(const QString &key, const bool &defaultValue) {
    return QSettings().value(key, defaultValue).toBool();
}

void SettingsAdapter::setBoolean(const QString &key, const bool &value) {
    QSettings().setValue(key, value);
}

int SettingsAdapter::readInt(const QString &key, const int &defaultValue) {
    return QSettings().value(key, defaultValue).toInt();
}

void SettingsAdapter::setInt(const QString &key, const int &value) {
    QSettings().setValue(key, value);
}

QString SettingsAdapter::readString(const QString &key, const QString &defaultValue) {
    return QSettings().value(key, defaultValue).toString();
}

void SettingsAdapter::setString(const QString &key, const QString &value) {
    QSettings().setValue(key, value);
}

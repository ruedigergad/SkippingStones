/*
 * Copyright 2014 Uladzislau Vasilyeu 
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

#include "phonebook.h"


PhoneBook::PhoneBook(QObject *parent) :
    QObject(parent){
}

QString PhoneBook::NameByPhoneNumber(QString PhoneNumber) {
    QContactManager *manager = new QContactManager(this);
    QList<QContact> contactslist = manager->contacts();
    QVariantList contacts;
    QStringList phones;
    QString label = "";
    for (int i = 0; i < contactslist.size(); ++i) {
        foreach (QContactPhoneNumber number, contactslist.at(i).details<QContactPhoneNumber>()) {
            if (!number.isEmpty()) {
                QString phone = QContactPhoneNumber(number).number();
                if (!phone.isEmpty() && phone == PhoneNumber) {
                    QList<QContactDisplayLabel> labels = contactslist.at(i).details<QContactDisplayLabel>();
                    if (labels.size() > 0 && !labels.first().isEmpty()){
                        label = labels.first().label();
                        break;
                    }
                }
            }
        }
        if (label != "")
            break;
    }
    delete manager;
    return label;
}

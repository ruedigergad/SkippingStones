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

#ifndef BTMESSAGE_H
#define BTMESSAGE_H

#include <QByteArray>
#include <QObject>

class BtMessage : public QObject
{
    Q_OBJECT
    Q_ENUMS(Capabilities)
    Q_ENUMS(EndPoint)
    Q_ENUMS(MusicControlActions)
    Q_ENUMS(PhoneControlCommands)
    Q_ENUMS(Prefix)
    Q_ENUMS(PutBytesTransferTypes)
    Q_ENUMS(SmDefines)
    Q_ENUMS(AppMessageDataTypes)

public:
    /*
     * Enums
     */
    /*
     * These values were taken from:
     * https://github.com/Hexxeh/libpebble/blob/master/pebble/pebble.py
     */
    enum Capabilities {
        GammaRay = 0x80000000,
        Telephony = 16,
        CapSMS = 32,
        GPS = 64,
        BTLE = 128,
        CameraRear = 256,
        Accel = 512,
        Gyro = 1024,
        Compass = 2048,
        Unknown = 0,
        IOS = 1,
        Android = 2,
        OSX = 3,
        Linux = 4,
        Windows = 5
    };

    enum EndPoint {
        InvalidEndPoint = -1,
        Time = 11,
        Version = 16,
        PhoneVersion = 17,
        SystemMessage = 18,
        MusicControl = 32,
        PhoneControl = 33,
        ApplicationMessage = 48,
        Launcher = 49,
        Logs = 2000,
        Ping = 2001,
        LogDump = 2002,
        Reset = 2003,
        App = 2004,
        AppLogs = 2006,
        Notification = 3000,
        Resource = 4000,
        AppManager = 6000,
        Screenshot = 8000,
        PutBytes = 48879
    };

    enum MusicControlActions {
        PlayPause = 1,
        Pause = 2,
        Play = 3,
        Next = 4,
        Previous = 5,
        VolumeUp = 6,
        VolumeDown = 7,
        GetNowPlaying = 8,
        SendNowPlaying = 9
    };

    enum PhoneControlCommands {
        Answer = 1,
        Hangup = 2,
        GetState = 3,
        IncomingCall = 4,
        OutgoingCall = 5,
        MissedCall = 6,
        Ring = 7,
        Start = 8,
        End = 9
    };

    enum Prefix {
        InvalidPrefix = -1,
        Email = 0,
        SMS = 1,
        NowPlayingData = 16
    };

    enum PutBytesTransferTypes {
        PutBytesFirmware = 1,
        PutBytesRecovery = 2,
        PutBytesSysResources = 3,
        PutBytesResources = 4,
        PutBytesBinary = 5
    };

    /*
     * These values were taken from:
     * https://github.com/robhh/SmartStatus/blob/master/src/globals.h
     */
    enum SmDefines {
        SM_RECONNECT_KEY = 0xFC01,
        SM_SEQUENCE_NUMBER_KEY = 0xFC02,
        SM_OPEN_SIRI_KEY = 0xFC03,
        SM_STATUS_SCREEN_REQ_KEY = 0xFC04,
        SM_PLAYPAUSE_KEY = 0xFC05,
        SM_NEXT_TRACK_KEY = 0xFC06,
        SM_PREVIOUS_TRACK_KEY = 0xFC07,
        SM_VOLUME_UP_KEY = 0xFC08,
        SM_VOLUME_DOWN_KEY = 0xFC09,
        SM_COUNT_MAIL_KEY = 0xFC0A,
        SM_COUNT_SMS_KEY = 0xFC0B,
        SM_COUNT_PHONE_KEY = 0xFC0C,
        SM_COUNT_BATTERY_KEY = 0xFC0D,
        SM_SCREEN_ENTER_KEY = 0xFC0E,
        SM_SCREEN_EXIT_KEY = 0xFC0F,
        SM_WEATHER_COND_KEY = 0xFC10,
        SM_WEATHER_TEMP_KEY = 0xFC11,
        SM_WEATHER_ICON_KEY = 0xFC12,
        SM_STATUS_SCREEN_UPDATE_KEY = 0xFC13,
        SM_VOLUME_VALUE_KEY = 0xFC14,
        SM_PLAY_STATUS_KEY = 0xFC15,
        SM_ARTIST_KEY = 0xFC16,
        SM_ALBUM_KEY = 0xFC17,
        SM_TITLE_KEY = 0xFC18,
        SM_WEATHER_HUMID_KEY = 0xFC19,
        SM_WEATHER_WIND_KEY = 0xFC1A,
        SM_WEATHER_DAY1_KEY = 0xFC1B,
        SM_WEATHER_DAY2_KEY = 0xFC1C,
        SM_WEATHER_DAY3_KEY = 0xFC1D,
        SM_WEATHER_ICON1_KEY = 0xFC1E,
        SM_WEATHER_ICON2_KEY = 0xFC1F,
        SM_WEATHER_ICON3_KEY = 0xFC20,
        SM_CALENDAR_UPDATE_KEY = 0xFC21,
        SM_MENU_UPDATE_KEY = 0xFC22,
        SM_STOCKS_GRAPH_KEY = 0xFC23,
        SM_BITCOIN_GRAPH_KEY = 0xFC24,
        SM_BITCOIN_LOW_KEY = 0xFC25,
        SM_BITCOIN_HIGH_KEY = 0xFC26,
        SM_BITCOIN_CURR_KEY = 0xFC27,
        SM_BITCOIN_TITLE_KEY = 0xFC28,
        SM_STOCKS_LOW_KEY = 0xFC29,
        SM_STOCKS_HIGH_KEY = 0xFC2A,
        SM_STOCKS_CURR_KEY = 0xFC2B,
        SM_STOCKS_TITLE_KEY = 0xFC2C,
        SM_LAUNCH_CAMERA_KEY = 0xFC2D,
        SM_TAKE_PICTURE_KEY = 0xFC2E,
        SM_URL1_KEY = 0xFC2F,
        SM_URL2_KEY = 0xFC30,
        SM_URL1_TEXT_KEY = 0xFC31,
        SM_URL2_TEXT_KEY = 0xFC32,
        SM_GPS_1_KEY = 0xFC33,
        SM_GPS_2_KEY = 0xFC34,
        SM_GPS_3_KEY = 0xFC35,
        SM_GPS_4_KEY = 0xFC36,
        SM_RESET_DST_KEY = 0xFC37,
        SM_MESSAGES_UPDATE_KEY = 0xFC38,
        SM_CALLS_UPDATE_KEY = 0xFC38,
        SM_CAL_DETAILS_KEY = 0xFC39,
        SM_DETAILS1_KEY = 0xFC3A,
        SM_DETAILS2_KEY = 0xFC3B,
        SM_CALL_SMS_KEY = 0xFC3C,
        SM_CALL_SMS_UPDATE_KEY = 0xFC3D,
        SM_CALL_SMS_CMD_KEY = 0xFC3E,
        SM_SMS_SENT_KEY = 0xFC3F,
        SM_FIND_MY_PHONE_KEY = 0xFC40,
        SM_REMINDERS_KEY = 0xFC41,
        SM_REMINDERS_DETAILS_KEY = 0xFC42,
        SM_STATUS_CAL_TIME_KEY = 0xFC43,
        SM_STATUS_CAL_TEXT_KEY = 0xFC44,
        SM_STATUS_MUS_ARTIST_KEY = 0xFC45,
        SM_STATUS_MUS_TITLE_KEY = 0xFC46
    };

    enum AppMessageDataTypes {
        AppMessageByteArray = 0,
        AppMessageCString = 1,
        AppMessageUInt = 2,
        AppMessageInt = 3
    };

    /*
     * Constructor, Methods, etc.
     */
    explicit BtMessage(QObject *parent = 0);
    BtMessage(const QByteArray &data, QObject *parent = 0);
    BtMessage(const BtMessage &msg, QObject *parent = 0);
    BtMessage& operator = (const BtMessage &msg);

    Q_INVOKABLE void appendMessage(BtMessage *msg);

    Q_INVOKABLE void appendInt8(int i);
    Q_INVOKABLE void appendInt16(int i);
    Q_INVOKABLE void appendInt32(int i);
    Q_INVOKABLE void appendString(QString str);
    Q_INVOKABLE void appendHex(QString data);

    Q_INVOKABLE void prependInt8(int i);
    Q_INVOKABLE void prependInt16(int i);
    Q_INVOKABLE void prependInt32(int i);
    Q_INVOKABLE void prependString(QString str);

    Q_INVOKABLE int nextInt8();
    Q_INVOKABLE int nextInt16();
    Q_INVOKABLE int nextInt32();

    Q_INVOKABLE int readInt8(int index);
    Q_INVOKABLE int readInt16(int index);
    Q_INVOKABLE int readInt16le(int index);
    Q_INVOKABLE int readInt32(int index);
    Q_INVOKABLE int readInt32le(int index);
    Q_INVOKABLE QString readHexString(int index, int size);
    Q_INVOKABLE QString readString(int size);
    Q_INVOKABLE QString readString(int index, int size);

    Q_INVOKABLE int stringLength(QString str);

    Q_INVOKABLE QByteArray data();
    Q_INVOKABLE int endpoint();
    Q_INVOKABLE int payloadLength();
    Q_INVOKABLE int size();
    Q_INVOKABLE QString toHexString();

signals:

public slots:
    void resetIndex();

private:
    QByteArray _data;
    int _currentIndex;

};

#endif // BTMESSAGE_H

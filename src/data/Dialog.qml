// SPDX-FileCopyrightText: 2021 Carson Black <uhhadd@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Layouts 1.10
import org.kde.kirigami 2.14 as Kirigami
import QtQuick.Controls 2.10 as QQC2
import QtQuick.Templates 2.10 as T

QQC2.ApplicationWindow {
    id: rootWindow

    visible: true

    title: i18n("Authentication Required")
    flags: Qt.CustomizeWindowHint | Qt.Dialog | Qt.WindowTitleHint

    width: Math.max(mainContent.implicitWidth, footerItem.implicitWidth)
    height: mainContent.implicitHeight + footerItem.implicitHeight

    minimumWidth: Math.max(mainContent.implicitWidth, footerItem.implicitWidth)
    minimumHeight: mainContent.implicitHeight + footerItem.implicitHeight

    property bool normalClosing: false
    property bool showingDetails: false

    color: Kirigami.Theme.backgroundColor
    onClosing: if (!normalClosing) context.cancel()

    Connections {
        target: context
        function onComplete() {
            normalClosing = true
            rootWindow.close()
        }
    }

    component TControl : T.Control {
        implicitWidth: Math.max(
            implicitBackgroundWidth + leftInset + rightInset,
            implicitContentWidth + leftPadding + rightPadding)

        implicitHeight: Math.max(
            implicitBackgroundHeight + topInset + bottomInset,
            implicitContentHeight + topPadding + bottomPadding)

    }

    TControl {
        id: mainContent

        anchors.fill: parent
        padding: Kirigami.Units.gridUnit
        contentItem: ColumnLayout {
            spacing: Kirigami.Units.gridUnit

            Item { Layout.fillHeight: true }

            AvatarRow {}

            PasswordRow {
                id: passwordRow
                showOK: false

                QQC2.Button {
                    visible: otherUsersRepeater.count > 1
                    text: i18n("Authenticate as another user")
                    icon.name: "user-others"
                    onClicked: otherUsers.popup()

                    Layout.margins: Kirigami.Units.gridUnit
                }
            }

            Details { visible: rootWindow.showingDetails }

            Item { Layout.fillHeight: true }
        }
    }

    Kirigami.Separator {
        visible: !expander.childVisible
        anchors {
            left: parent.left
            right: parent.right
            bottom: detailsButton.top
            bottomMargin: Kirigami.Units.largeSpacing
        }
    }

    footer: TControl {
        padding: Kirigami.Units.gridUnit
        contentItem: RowLayout {
            id: footerItem

            QQC2.Button {
                id: detailsButton

                text: rootWindow.showingDetails ? i18n("Hide Details") : i18n("Show Details")
                icon.name: "documentinfo"
                onClicked: rootWindow.showingDetails = !rootWindow.showingDetails
            }

            Item { Layout.fillWidth: true }

            QQC2.Button {
                text: i18n("Cancel")
                icon.name: "dialog-cancel"
                onClicked: rootWindow.close()
            }
            QQC2.Button {
                text: i18n("Allow")
                icon.name: "dialog-ok"
                onClicked: passwordRow.submit()
            }
        }
    }


    QQC2.Menu {
        id: otherUsers
        modal: true

        Repeater {
            id: otherUsersRepeater

            model: context.identityModel

            delegate: QQC2.MenuItem {
                text: realname

                onClicked: context.useIdentity(index)
            }
        }
    }
}
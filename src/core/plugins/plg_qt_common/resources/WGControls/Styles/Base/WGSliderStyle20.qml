/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/
import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0

import WGControls 2.0

/*!
    \ingroup wgcontrols
    \brief A re-write of the default Slider style.

    Example:
    \code{.js}
    Slider {
        anchors.centerIn: parent
        style: SliderStyle {
            groove: Rectangle {
                implicitWidth: 200
                implicitHeight: 8
                color: "gray"
                radius: 8
            }
        }
    }
    \endcode
*/
Style {
    objectName: "WGSliderStyle"
    id: styleitem
    WGComponent { type: "WGSliderStyle20" }

    /*! The \l Slider this style is attached to. */
    readonly property QtObject control: __control

    property bool __horizontal: control.__horizontal

    property int vertPadding: 0
    property int horzPadding: 0

    property real __clampedLength: control.__clampedLength

    property int __multiValueDashSpacing: 9

    padding { top: vertPadding ; left: horzPadding ; right: horzPadding ; bottom: vertPadding }

    property Component groove: Item {

        //anchors.verticalCenter: parent.verticalCenter

        y: Math.round(parent.height / 2) - Math.round(height / 2)

        implicitWidth: Math.round(defaultSpacing.minimumRowHeight / 4)
        implicitHeight: Math.round(defaultSpacing.minimumRowHeight / 4)

        WGTextBoxFrame {
            id: grooveFrame
            radius: defaultSpacing.standardRadius
            anchors.fill: parent
            color: control.enabled ? palette.textBoxColor : "transparent"

            Rectangle {
                id: multivalueStyling
                color: "transparent"
                visible: control.multipleValues
                anchors.fill: parent
                anchors.margins: parent.border.width
                radius: parent.radius


                Row {
                    Repeater {
                        id: multipleValueRepeater

                        model: grooveFrame.width / __multiValueDashSpacing
                        Item {
                            height: multivalueStyling.height
                            width: __multiValueDashSpacing
                            Rectangle {
                                id: dash
                                color: palette.highlightColor
                                height: multivalueStyling.height
                                width: 3
                            }
                        }
                    }
                }
            }
        }
    }

    /*! This property holds the coloured bar of the slider.
    */
    property Component bar: Item {
        property color fillColor: control.multipleValues ? "transparent" : control.readonly ? palette.readonlyColor : control.__handlePosList[barid].barColor
        clip: true
        Rectangle {
            clip: true
            anchors.fill: parent
            anchors.margins: defaultSpacing.standardBorderSize
            border.color: control.multipleValues ? "transparent" : control.enabled ? Qt.darker(fillColor, 1.2) : palette.lighterShade
            radius: defaultSpacing.halfRadius
            color: control.enabled ? fillColor : palette.lightShade
        }
    }

    /*! This property holds the tick mark labels
    */

    property Component tickmarks: Item {
        Repeater {
            id: tickRepeater
            anchors.fill: parent
            model: control.tickmarkInterval > 0 && control.tickmarksEnabled ? 1 + (control.maximumValue - control.minimumValue) / control.tickmarkInterval : 0
            WGSeparator {
                vertical: true
                width: defaultSpacing.separatorWidth
                height: parent.height

                x: control.__handleWidth / 2 + index * ((tickRepeater.width - control.__handleWidth) / (tickRepeater.count-1)) - (defaultSpacing.separatorWidth / 2)

                Text {
                    visible: control.showTickmarkLabels
                    anchors.top: parent.bottom
                    anchors.topMargin: -1
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 9
                    color: palette.textColor

                    text: index * control.tickmarkInterval
                }
            }
        }

        Repeater {
            id: customTickRepeater
            anchors.fill: parent
            model: control.customTickmarks.length
            WGSeparator {
                vertical: true
                width: defaultSpacing.separatorWidth
                height: parent.height

                x: ((customTickRepeater.width - control.__handleWidth) / (control.maximumValue - control.minimumValue)) * (control.customTickmarks[index]  - control.minimumValue) - defaultSpacing.separatorWidth / 2 + control.__handleWidth / 2

                Text {
                    visible: control.showTickmarkLabels
                    anchors.top: parent.bottom
                    anchors.topMargin: -1
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 9
                    color: palette.textColor

                    text: typeof control.customTickmarkLabels[index] != "undefined" ? control.customTickmarkLabels[index] : "NaN"
                }
            }
        }
    }

    /*! This property holds the slider style panel.

        Note that it is generally not recommended to override this.
    */
    property Component panel: Item {
        id: root

        implicitWidth: control.width
        implicitHeight: control.height

        x: Math.round(parent.width / 2) - Math.round(width / 2)
        y: Math.round(parent.height / 2) - Math.round(height / 2)

        Item {
            objectName: "sliderFrame"
            id: sliderFrame
            x: Math.round(parent.width / 2) - Math.round(width / 2)
            y: Math.round(parent.height / 2) - Math.round(height / 2)

            height: __horizontal ? control.height : control.width
            width: __horizontal ? control.width : control.height

            rotation: __horizontal ? 0 : -90
            transformOrigin: Item.Center

            Loader {
                id: grooveLoader
                sourceComponent: groove

                width: parent.width - padding.left - padding.right

                anchors.horizontalCenter: parent.horizontalCenter

                height: groove.implicitHeight

                y: control.showTickmarkLabels ? defaultSpacing.standardBorderSize : (parent.height - grooveLoader.item.height)/2

                Repeater {
                model: control.__handleCount
                    Loader {
                        id: barLoader
                        sourceComponent: bar
                        property int barid: index
                        visible: control.__handlePosList[index].showBar

                        anchors.verticalCenter: grooveLoader.verticalCenter

                        property int barClampPadding: control.handleClamp ? control.__visualMinPos : 0

                        height: grooveLoader.height
                        width: Math.round((((control.__handlePosList[index].value - control.minimumValue) / (control.maximumValue - control.minimumValue)) * __clampedLength) + control.__visualMinPos - control.__handlePosList[index].barMinPos)

                        x: control.__handlePosList[index].barMinPos
                        z: 1
                    }
                }
            }

            Loader {
                id: tickMarkLoader
                anchors.top: grooveLoader.top
                anchors.topMargin: defaultSpacing.standardBorderSize
                anchors.horizontalCenter: parent.horizontalCenter
                height: grooveLoader.height + defaultSpacing.doubleBorderSize
                width: control.width
                sourceComponent: control.tickmarksEnabled || control.customTickmarks.length > 0 ? tickmarks : null
            }

            Repeater {
                model: control.__handleCount

                Loader {
                    id: handleLoader

                    property int handleIndex: index

                    property int handleOffset: control.__handlePosList[index].handleOffset

                    sourceComponent: control.__handlePosList[index].handleStyle

                    y: Math.round(grooveLoader.y + (grooveLoader.height / 2) - (height / 2))

                    x: Math.round((((control.__handlePosList[index].value - control.minimumValue) / (control.maximumValue - control.minimumValue)) * __clampedLength) + control.__visualMinPos + handleOffset)

                    onLoaded: {
                        handleLoader.height = item.handleHeight
                        handleLoader.width = item.handleWidth
                        control.__handleHeight = handleLoader.height
                        control.__handleWidth = handleLoader.width
                    }

                    Connections {
                        target: control.__handlePosList[index]
                        onValueChanged: {
                            control.changeValue(control.__handlePosList[index].value, index)
                        }
                    }

                    MouseArea {
                        objectName: "sliderHandleArea"
                        hoverEnabled: true
                        anchors.fill: parent

                        propagateComposedEvents: true

                        cursorShape: control.__currentCursor

                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onEntered: {
                            control.hoveredHandle = index
                        }

                        onExited: {
                            if (control.hoveredHandle == index)
                            {
                               control.hoveredHandle = -1
                            }
                        }

                        onPressed: {
                            control.__activeHandle = index
                            control.forceActiveFocus()

                            if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
                            {
                                control.__draggable = false
                            }
                            else if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ShiftModifier))
                            {
                                control.__draggable = false
                            }
                            else
                            {
                                if (!control.grooveClickable)
                                {
                                    control.__draggable = true
                                }
                            }
                            control.handleClicked(index, mouse.button, mouse.modifiers)
                            control.hoveredHandle = index
                            if (mouse.button == Qt.LeftButton)
                            {
                                mouse.accepted = false
                            }
                        }

                        onReleased: {
                            control.__draggable = control.grooveClickable
                        }
                    }
                }
            }
        }
    }
}

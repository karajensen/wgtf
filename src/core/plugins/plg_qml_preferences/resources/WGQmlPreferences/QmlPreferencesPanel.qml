import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0


import WGControls 2.0
import WGControls.Private 2.0
import WGControls.Layouts 2.0
import WGControls.Views 2.0
import WGControls.Global 2.0

WGPanel {
    id: preferencesPanel
    WGComponent { type: "QmlPreferencesPanel" }

    title: qsTr("QML Preferences Panel")
    layoutHints: { 'floatingPanel': 1.0 }

    property color newCustomWindowColor: "#000000"
    property color newCustomHighlightColor: "#FFFFFF"

    property bool customTheme: false

    property int tempTheme: 0

    property bool newTheme: tempTheme != palette.theme || customTheme ? true : false

    property bool customChanged: false

    color: palette.mainWindowColor

    focus: true

    WGScrollView {
        anchors.fill: parent
        anchors.leftMargin: defaultSpacing.doubleMargin
        anchors.rightMargin: defaultSpacing.doubleMargin
        WGDraggableColumn {
            width: parent.width
            WGSubPanel {
                text: "UI Theme"

                childObject :
                ColumnLayout {

                    WGFormLayout {

                        WGExpandingRowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: defaultSpacing.minimumRowHeight

                            label: "Current Theme "

                            WGDropDownBox {
                                id: themeDropDown

                                textRole: "label"
                                imageRole: "windowColor"

                                model: ListModel {
                                    dynamicRoles: true
                                }

                                Layout.preferredWidth: 200 + applyThemeButtons.spacing
                                Layout.preferredHeight: defaultSpacing.minimumRowHeight

                                currentIndex: tempTheme

                                onCurrentIndexChanged: {
                                    setValueHelper(preferencesPanel, "tempTheme", currentIndex)
                                    if(model.get(currentIndex)[textRole] == "Custom")
                                    {
                                        customTheme = true
                                    }
                                    else
                                    {
                                        customTheme = false
                                    }
                                }

                                imageDelegate: Rectangle {
                                    id: imageDelegate
                                    height: themeDropDown.imageMaxHeight
                                    width: themeDropDown.imageMaxHeight
                                    radius: defaultSpacing.standardRadius
                                    color: themeDropDown.model.count > 0 ? themeDropDown.model.get(themeDropDown.currentIndex).windowColor : "white"

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        radius: defaultSpacing.halfRadius
                                        color: themeDropDown.model.count > 0 ? themeDropDown.model.get(themeDropDown.currentIndex).highlightColor : "black"
                                    }
                                }

                                delegate: WGDropDownDelegate {
                                    id: listDelegate
                                    property string image: "true"
                                    parentControl: themeDropDown
                                    width: Math.max(themeDropDown.labelMaxWidth + (themeDropDown.imageRole ? themeDropDown.height : 0) + (themeDropDown.showRowIndicator ? themeDropDown.height : 0) + (defaultSpacing.doubleMargin * 2), themeDropDown.width)
                                    text: themeDropDown.textRole ? (Array.isArray(themeDropDown.model) ? modelData[themeDropDown.textRole] : model[themeDropDown.textRole]) : modelData
                                    checkable: true
                                    autoExclusive: true
                                    checked: themeDropDown.currentIndex === index
                                    highlighted: themeDropDown.highlightedIndex === index
                                    pressed: themeDropDown.highlighted && themeDropDown.pressed

                                    imageDelegate: Rectangle {
                                        id: imageDropDownDelegate
                                        height: parentControl.imageMaxHeight
                                        width: parentControl.imageMaxHeight
                                        radius: defaultSpacing.standardRadius
                                        color: parentControl.model.get(index).windowColor

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            radius: defaultSpacing.halfRadius
                                            color: parentControl.model.get(index).highlightColor
                                        }
                                    }
                                }

                                Component.onCompleted:
                                {
                                    palette.customWindowColor = palette.mainWindowColor
                                    palette.customHighlightColor = palette.highlightColor

                                    model.append({"label": "Dark", "windowColor": "#383a3d", "highlightColor": "#3399ff"})
                                    model.append({"label": "Light", "windowColor": "#d8d8d8", "highlightColor": "#438bbf"})
                                    model.append({"label": "Battle Red", "windowColor": "#333333", "highlightColor": "#b0302c"})
                                    model.append({"label": "Army Brown", "windowColor": "#2e2c27", "highlightColor": "#e5a139"})
                                    model.append({"label": "Air Force Green", "windowColor": "#27393d", "highlightColor": "#39b2cf"})
                                    model.append({"label": "Navy Blue", "windowColor": "#1d3340", "highlightColor": "#15a3d2"})
                                    model.append({"label": "Custom", "windowColor": palette.customWindowColor, "highlightColor": palette.customHighlightColor})
                                    setValueHelper(themeDropDown, "currentIndex", 0)
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: defaultSpacing.minimumRowHeight
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: defaultSpacing.minimumRowHeight
                        }

                        WGColorButton {
                            id: mwColor
                            label: "Custom Window Color "
                            color: Qt.vector4d(palette.customWindowColor.r,palette.customWindowColor.g,palette.customWindowColor.b,palette.customWindowColor.a)
                            defaultColorDialog: false

                            enabled: customTheme

                            onClicked: {
                                openDialog()
                            }

                            onColorChosen: {
                                var tempColor = Qt.rgba(mwColor.x,mwColor.y,mwColor.z,mwColor.w)
                                setValueHelper(palette, "customWindowColor", tempColor)
                                if(customTheme)themeDropDown.model.set(6, {"windowColor": tempColor})
                            }
                        }

                        WGColorButton {
                            id: hlColor
                            label: "Custom Highlight Color "
                            color: Qt.vector4d(palette.customHighlightColor.r,palette.customHighlightColor.g,palette.customHighlightColor.b,palette.customHighlightColor.a)
                            defaultColorDialog: false

                            enabled: customTheme

                            onClicked: {
                                openDialog()
                            }

                            onColorChosen: {
                                var tempColor = Qt.rgba(hlColor.x,hlColor.y,hlColor.z,hlColor.w)
                                setValueHelper(palette, "customHighlightColor", tempColor)
                                if(customTheme)themeDropDown.model.set(6, {"windowColor": tempColor})
                            }
                        }

                        WGCheckBox {
                            label: "Dark Text "
                            checked: palette.darkText

                            enabled: customTheme

                            onCheckedChanged: {
                                setValueHelper(preferencesPanel, "customChanged", true)
                                setValueHelper(palette, "darkText", checked)
                            }
                        }

                        WGExpandingRowLayout {
                            Layout.preferredHeight: defaultSpacing.minimumRowHeight
                            Layout.fillWidth: true
                            enabled: customTheme

                            label: "Dark Contrast "

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: defaultSpacing.minimumRowHeight
                                color: palette.darkShade
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: defaultSpacing.minimumRowHeight
                                color: palette.darkerShade
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: defaultSpacing.minimumRowHeight
                                color: palette.darkestShade
                            }
                        }

                        WGSliderControl {
                            Layout.fillWidth: true
                            minimumValue: 0
                            maximumValue: 100
                            stepSize: 1
                            value: palette.darkContrast
                            enabled: customTheme
                            onValueChanged: {
                                setValueHelper(preferencesPanel, "customChanged", true)
                                setValueHelper(palette, "darkContrast", value)
                            }
                        }

                        WGExpandingRowLayout {
                            Layout.preferredHeight: defaultSpacing.minimumRowHeight
                            Layout.fillWidth: true
                            enabled: customTheme

                            label: "Light Contrast"

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: defaultSpacing.minimumRowHeight
                                color: palette.lightShade
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: defaultSpacing.minimumRowHeight
                                color: palette.lighterShade
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: defaultSpacing.minimumRowHeight
                                color: palette.lightestShade
                            }
                        }

                        WGSliderControl {
                            Layout.fillWidth: true
                            minimumValue: 0
                            maximumValue: 100
                            stepSize: 1
                            value: palette.lightContrast
                            enabled: customTheme

                            onValueChanged: {
                                setValueHelper(preferencesPanel, "customChanged", true)
                                setValueHelper(palette, "lightContrast", value)
                            }
                        }
                    }

                    WGSeparator {}

                    WGExpandingRowLayout {
                        id: applyThemeButtons
                        Layout.preferredHeight: defaultSpacing.minimumRowHeight

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: defaultSpacing.minimumRowHeight
                        }

                        WGPushButton {
                            Layout.preferredWidth: 100
                            text: "Apply"

                            enabled: newTheme

                            onClicked: {
                                setValueHelper(palette, "theme", preferencesPanel.tempTheme)
                            }
                        }
                        WGPushButton {
                            Layout.preferredWidth: 100
                            text: "Cancel"

                            enabled: newTheme

                            onClicked: {
                                setValueHelper(themeDropDown, "currentIndex", preferencesPanel.tempTheme)
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: defaultSpacing.minimumRowHeight
                        }
                    }
                }
            }
        }

        WGColorPickerDialog {
            id: colorDialog

            title: "Pick a Color"

            modality: Qt.WindowModal

            visible: false

            property QtObject editingColor

            onAccepted: {
                setValueHelper(preferencesPanel, "customChanged", true)
                editingColor.color = selectedValue
                colorDialog.close()
            }
            onRejected: {
                colorDialog.close()
            }
        }

        WGAction {
            active: true
            actionId: "darkThemeAction"
            checkable: true
            checked: palette.theme == 0
            onTriggered: {
                palette.theme = 0
            }
        }

        WGAction {
            active: true
            actionId: "lightAction"
            checkable: true
            checked: palette.theme == 1
            onTriggered: {
                palette.theme = 1
            }
        }

        WGAction {
            active: true
            actionId: "battleRedAction"
            checkable: true
            checked: palette.theme == 2
            onTriggered: {
                palette.theme = 2
            }
        }

        WGAction {
            active: true
            actionId: "armyBrownAction"
            checkable: true
            checked: palette.theme == 3
            onTriggered: {
                palette.theme = 3
            }
        }

        WGAction {
            active: true
            actionId: "airForceGreenAction"
            checkable: true
            checked: palette.theme == 4
            onTriggered: {
                palette.theme = 4
            }
        }

        WGAction {
            active: true
            actionId: "navyBlueAction"
            checkable: true
            checked: palette.theme == 5
            onTriggered: {
                palette.theme = 5
            }
        }
    }
}

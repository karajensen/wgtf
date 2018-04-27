import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Layouts 1.3

import WGControls 2.0
import WGControls.Styles 2.0
import WGControls.Private 2.0

/*!
 \ingroup wgcontrols
 \brief Slider with value spinbox.
 Purpose: Provide the user with a single value clamped between min and max value

Example:
\code{.js}
WGSliderControl {
    Layout.fillWidth: true
    minimumValue: 0
    maximumValue: 100
    stepSize: 1
    value: 40
}
\endcode

 \todo Test orientation = vertical. Create vertical slider. Remove option here
       Resizing the slider could be smarter. Does not take into account content of spinner width

*/

FocusScope {
    id: sliderFrame
    objectName: "WGSliderControl"
    WGComponent { type: "WGSliderControl20" }

    /*! This property holds the maximum value of the slider.
        The default value is \c{1.0}.
    */
    property real maximumValue: 1.0

    /*! This property holds the minimum value of the slider.
        The default value is \c{0.0}.
    */
    property real minimumValue: 0.0

    /*!
        This property indicates the slider step size.

        A value of 0 indicates that the value of the slider operates in a
        continuous range between \l minimumValue and \l maximumValue.

        Any non 0 value indicates a discrete stepSize.

        The default value is \c{0.0}.
    */
    property real stepSize: 0.01

    /*!
        This property holds the layout orientation of the slider.
        The default value is \c Qt.Horizontal.
    */
    /* TODO: It is likely that this does not work. It should be tested and disabled
       A separate vertical slider should probably be made */
    property int orientation: Qt.Horizontal

    /*! This property defines what SliderStyle component will be used for the slider */
    property Component style: Qt.createComponent("Styles/Base/WGSliderStyle20.qml", sliderFrame)

    /*! This property defines what Slider Handle component will be used for the slider handle */
    property Component handleType: showTickmarkLabels ? tickmarkValueHandle : defaultSliderHandle

    /*! This property defines what frame component will be used for the numberbox text box */
    property alias textBoxStyle: sliderValue.textBoxStyle

    /*! This property defines what frame component will be used for the numberbox buttons */
    property alias buttonFrame: sliderValue.buttonFrame

    /*! property indicates if the control represetnts multiple data values */
    property bool multipleValues: false

    /*! This property defines the value indicated by the control
        The default value is \c 0.0
    */
    property real value

    /*! This property defines the colour of the slider */
    property color barColor: palette.highlightColor

    /*! This property defines whether the tickmarks are displayed or not */
    property bool tickmarksEnabled: false

    /*! The interval (in value) between equal tickmarks, best set to a whole fraction of the max value.*/
    property real tickmarkInterval: stepSize

    /*! This property indicates whether the slider should display values underneath the tickmarks. */
    property bool showTickmarkLabels: false

    /*! An array of values used for the labels for the customTickmarks */
    property var customTickmarkLabels: customTickmarks

    /*! An array of values that can be used to show tickmarks at custom intervals. */
    property var customTickmarks: []

    /*! An array of values that the slider handle will 'stick' to when dragged. */
    property var stickyValues: []

    /*! The amount of space in pixels on either side of the values where the mouse will be 'sticky' */
    property int stickyMargin: defaultSpacing.standardMargin + defaultSpacing.standardBorderSize

    /*! This property determines the prefix string displayed within the slider textbox.
        Typically used to display unit type.
        The default value is an empty string.
    */
    property string prefix: ""

    /*! This property determines the suffix string displayed within the slider textbox.
        Typically used to display unit type.
        The default value is an empty string.
    */
    property string suffix: ""


    /*! This property defines the number of decimal places displayed in the textbox
        The default value is \c 1
    */
    property int decimals: 1


    /*! This property determines whether a number box will be displayed next to the slider

      The default value is \c true
    */
    property bool showValue: true

    /*! This property determines whether a space will be made on the left of the slider
      so that it lines up with a range slider.

      The default value is \c false
    */
    property bool fakeLowerValue: false

    /*! This property can be used to give the number box(es) a set width.

      The default value is based on the implicit width of the valuebox
    */
    property int valueBoxWidth: sliderValue.implicitWidth

    /*! This property is used to define the buttons label when used in a WGFormLayout
        The default value is an empty string
    */

    /*!
        This property determines if the slider groove should have padding to fit inside the overall control size.

        This is useful to make sure the handles don't move outside the control boundaries but means the control values
        don't exactly line up with the control height/width in a linear fashion. (the value is always accurate)

        The default value is \ctrue
    */
    property var handleClamp: true

    /*! This property is used to define the slider's label when used in a WGFormLayout
        The default value is an empty string
    */
    property string label: ""

    property alias numberBox: sliderValue

    //property alias slider: sliderComponent

    /*! \internal */
    property bool __horizontal: orientation === Qt.Horizontal

    /*! This QtObject the slider will look to for data.

        By default this is the sliderFrame itself but it can be replaced with a WGDataConversion to alter the units the user sees.
    */
    property QtObject sliderData: sliderFrame

    /*! This QtObject the numberBox will look to for data.

        By default this is the sliderFrame itself but it can be replaced with a WGDataConversion to alter the units the user sees.
    */
    property QtObject numberBoxData: sliderFrame

    implicitHeight: __horizontal ? horizSlider.implicitHeight : vertSlider.implicitHeight + (sliderValue.implicitHeight * (fakeLowerValue ? 2 : 1)) + vertLayout.spacing
    implicitWidth: __horizontal ? horizSlider.implicitWidth + (sliderValue.implicitWidth * (fakeLowerValue ? 2 : 1)) + horizLayout.spacing : sliderValue.implicitWidth

    /* rounds a number to a fixed set of decimalPlaces*/
    function round(num) {
        return Number(Math.round(num+'e'+sliderFrame.decimals)+'e-'+sliderFrame.decimals);
    }

    signal changeValue (var val)

    /*!
        This signal is fired when a handle (index) on the slider has finished dragging
    */
    signal endDrag (int index)

    RowLayout {
        id: horizLayout
        anchors.fill: parent
        visible: __horizontal

        Item {
            id: horizLower
            visible: fakeLowerValue
            Layout.fillHeight: true
            Layout.preferredWidth: valueBoxWidth
        }
        Loader {
            id: horizSlider
            Layout.fillHeight: true
            Layout.fillWidth: true

            Layout.preferredHeight: __horizontal ? Math.round(sliderFrame.height) : -1

            sourceComponent: __horizontal ? slider : null
        }
        Item {
            id: horizUpper
            visible: showValue
            Layout.fillHeight: true
            Layout.preferredWidth: valueBoxWidth
        }
    }

    ColumnLayout {
        id: vertLayout
        anchors.fill: parent
        visible: !__horizontal

        Item {
            id: vertLower
            visible: fakeLowerValue
            Layout.preferredHeight: defaultSpacing.minimumRowHeight
            Layout.preferredWidth: valueBoxWidth
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }

        Loader {
            id: vertSlider
            Layout.fillHeight: true
            Layout.fillWidth: true

            Layout.preferredHeight: __horizontal ? Math.round(sliderFrame.height) : -1

            sourceComponent: __horizontal ? null : slider
        }

        Item {
            id: vertUpper
            visible: showValue
            Layout.preferredHeight: defaultSpacing.minimumRowHeight
            Layout.preferredWidth: valueBoxWidth
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }
    }

    Rectangle {
        id: fakeValue
        color: "transparent"

        parent: __horizontal ? horizLower : vertLower

        width:  valueBoxWidth
        height:  defaultSpacing.minimumRowHeight
        visible: fakeLowerValue ? true : false
    }

    property Component slider: WGSlider {
        id: slider
        opacity: 1.0

        property bool showValue: true

        stepSize: typeof sliderData.stepSize != "undefined" ? sliderData.stepSize : sliderFrame.stepSize

        activeFocusOnPress: true

        value: typeof sliderData.value != "undefined" ? sliderData.value : sliderFrame.value

        multipleValues: sliderFrame.multipleValues

        minimumValue: typeof sliderData.minimumValue != "undefined" ? sliderData.minimumValue : sliderFrame.minimumValue
        maximumValue: typeof sliderData.maximumValue != "undefined" ? sliderData.maximumValue : sliderFrame.maximumValue

        orientation: sliderFrame.orientation

        handleType: sliderFrame.handleType

        barColor: sliderFrame.barColor

        tickmarksEnabled: sliderFrame.tickmarksEnabled
        tickmarkInterval: sliderFrame.tickmarkInterval
        showTickmarkLabels: sliderFrame.showTickmarkLabels
        customTickmarkLabels: sliderFrame.customTickmarkLabels
        customTickmarks: sliderFrame.customTickmarks
        stickyValues: sliderFrame.stickyValues
        stickyMargin: sliderFrame.stickyMargin

        onEndDrag: {
            sliderFrame.endDrag(index)
        }

        onValueChanged: {
            if (typeof sliderData.stepSize != "undefined")
            {
                if (round(sliderData.value) != round(slider.value))
                {
                    sliderData.changeValue(slider.value)
                }
            }
        }

        style : sliderFrame.style

        states: [
            State {
                name: ""
                when: sliderFrame.width < sliderValue.Layout.preferredWidth + sliderHandle.width
                PropertyChanges {target: slider; opacity: 0}
                PropertyChanges {target: sliderLayout; spacing: 0}
                PropertyChanges {target: slider; visible: false}
            },
            State {
                name: "HIDDENSLIDER"
                when: sliderFrame.width >= sliderValue.Layout.preferredWidth + sliderHandle.width
                PropertyChanges {target: slider; opacity: 1}
                PropertyChanges {target: sliderLayout; spacing: defaultSpacing.rowSpacing}
                PropertyChanges {target: slider; visible: true}
            }
        ]

        transitions: [
            Transition {
                from: ""
                to: "HIDDENSLIDER"
                NumberAnimation { properties: "opacity"; duration: 200 }
            },
            Transition {
                from: "HIDDENSLIDER"
                to: ""
                NumberAnimation { properties: "opacity"; duration: 200 }
            }
        ]
    }

    WGNumberBox {
        objectName: "NumberBox"
        id: sliderValue
        parent: __horizontal ? horizUpper : vertUpper

        width:  valueBoxWidth
        height:  defaultSpacing.minimumRowHeight

        Layout.preferredHeight: defaultSpacing.minimumRowHeight
        visible: showValue
        decimals: typeof numberBoxData.decimals != "undefined" ? numberBoxData.decimals : sliderFrame.decimals

        prefix: typeof numberBoxData.prefix != "undefined" ? numberBoxData.prefix : sliderFrame.prefix
        suffix: typeof numberBoxData.suffix != "undefined" ? numberBoxData.suffix : sliderFrame.suffix

        value: typeof numberBoxData.value != "undefined" ? numberBoxData.value : sliderFrame.value
        multipleValues: sliderFrame.multipleValues

        minimumValue: typeof numberBoxData.minimumValue != "undefined" ? numberBoxData.minimumValue : sliderFrame.minimumValue
        maximumValue: typeof numberBoxData.maximumValue != "undefined" ? numberBoxData.maximumValue : sliderFrame.maximumValue

        stepSize: typeof numberBoxData.stepSize != "undefined" ? numberBoxData.stepSize : sliderFrame.stepSize

        focus: true

        //Keyboard enter key input
        onEditingFinished: {
            if (typeof numberBoxData.value != "undefined")
            {
                if (round(numberBoxData.value) != round(sliderValue.value))
                {
                    numberBoxData.changeValue(sliderValue.value)
                }
            }
        }
    }

    Component {
        id: defaultSliderHandle
        WGSliderHandle {}
    }

    Component {
        id: tickmarkValueHandle
        WGTickmarkSliderHandle {}
    }

    /*! Deprecated */
    property alias label_: sliderFrame.label

    /*! Deprecated */
    property bool timeObject: false
}

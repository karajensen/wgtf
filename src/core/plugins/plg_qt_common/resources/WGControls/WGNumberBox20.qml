import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.4
import WGControls 2.0
import WGControls.Styles 2.0
import WGControls.Global 2.0

/*!
 \ingroup wgcontrols
 \brief A reimplementation of Spinbox intended for numbers.
 Single clicked increment/decrement via stepSize property.
 Click and drag increment/decrement based on vertical linear mouse distance moved.
 Multiplier on speed of number change via keyboard toggle (Ctrl) whilst dragging.
 Releasing Ctrl drops number change rate back to default.
 User can drag up (increment) and then down (decrement) within a single click and hold event allowing for correction of overshoot.
 MouseWheel up/down will increment/decrement based on stepSize property.
 Control must be active (selected) before MouseWheel events are enabled.
 Left/Middle clicked in the Blue area will cause the text to be selected so that any keyboard entry will wipe the existing data.
 Double left click inserts a cursor at the location of the double click allowing for modification of the existing data.
 Right click in the Blue area will cause the text to be selected and bring up a context menu.
 Right clicking the up and down arrows will set the value to minimumValue.

Example:
\code{.js}
WGNumberBox {
    width: 120
    value: 25
    minimumValue: 0
    maximumValue: 100
}
\endcode

*/


/*
    \qmltype SpinBox
    \inqmlmodule QtQuick.Controls
    \since 5.1
    \brief Provides a spin box control.

    SpinBox allows the user to choose a value by clicking the up or down buttons, or by
    pressing up or down on the keyboard. The user can also type the value in manually.

    By default the SpinBox provides discrete values in the range [0-99] with a \l stepSize of 1 and 0 \l decimals.

    \code
    SpinBox {
        id: spinBox
    }
    \endcode

    Note that if you require decimal values you will need to set the \l decimals to a non 0 value.

    \code
    SpinBox {
        id: spinBox
        decimals: 2
    }
    \endcode
*/

Control {
    id: numberBox
    objectName: "WGNumberBox"
    WGComponent { type: "WGNumberBox20" }

    //property declarations

    /*!
        This property determines the width of the spinner boxes
        The default value is \c 16
    */
    property var numberBoxSpinnerSize: 16

    /*!
        This property determines the current size of the text content
    */
    property alias contentWidth: currentSizeHint.contentWidth

    /*!
        This property determines the maximum potential size of the text content
    */
    readonly property int maxContentWidth: Math.max(maxSizeHint.contentWidth, minSizeHint.contentWidth)

    /*! property indicates if the control should show a button for setting an infinite value */
    property bool showInfiniteButton: false

    /*! property indicates if the control represents an infinite value */
    property bool valueIsInfinite: false

    /*! property contains the string to be shown when valueIsInfinite is true*/
    property string __valueIsInfiniteString: "\u221E"

    /*! property indicates if the control represents multiple data values. multipleValues takes precedence over valueIsInfinite. */
    property bool multipleValues: false

    /*! property contains the string to be shown when multiple values are represented*/
    property string __multipleValuesString: "--"

    /*!
        \qmlproperty real NumberBox::value

        The value of this NumberBox, clamped to \l minimumValue and \l maximumValue.

        The default value is \c{0.0}.
    */
    property alias value: validator.value

    /*!
        \qmlproperty real NumberBox::minimumValue

        The minimum value of the NumberBox range.
        The \l value is clamped to this value.

        The default value is \c{0.0}.
    */
    property alias minimumValue: validator.minimumValue

    /*!
        \qmlproperty real NumberBox::maximumValue

        The maximum value of the NumberBox range.
        The \l value is clamped to this value. If maximumValue is smaller than
        \l minimumValue, \l minimumValue will be enforced.

        The default value is \c{99}.
    */
    property alias maximumValue: validator.maximumValue

    /*! \qmlproperty real NumberBox::stepSize
        The amount by which the \l value is incremented/decremented when a
        spin button is pressed.

        The default value is \c{1.0}.
    */
    property alias stepSize: validator.stepSize

    /*! \qmlproperty string NumberBox::suffix
        The suffix for the value. I.e "cm" */
    property alias suffix: validator.suffix

    /*! \qmlproperty string NumberBox::prefix
        The prefix for the value. I.e "$" */
    property alias prefix: validator.prefix

    /*! \qmlproperty int NumberBox::decimals
      This property indicates the amount of decimals.
      Note that if you enter more decimals than specified, they will
      be truncated to the specified amount of decimal places.
      The default value is \c{0}.
    */
    property alias decimals: validator.decimals

    /*! \qmlproperty font NumberBox::font

        This property indicates the current font used by the NumberBox.
    */
    property alias font: input.font

    /*! This property allows the control to have a default value other than the minimumValue.
        Right clicking the controls spinners will set the value to defaultValue
      */
    property real defaultValue: minimumValue <= 0 ? 0 : minimumValue

    /*!
        \qmlproperty int NumberBox::cursorPosition
        \since QtQuick.Controls 1.5

        This property holds the position of the cursor in the NumberBox.
    */
    property alias cursorPosition: input.cursorPosition

    /*! \qmlproperty enumeration horizontalAlignment
        \since QtQuick.Controls 1.1

        This property indicates how the content is horizontally aligned
        within the text field.

        The supported values are:
        \list
        \li Qt.AlignLeft
        \li Qt.AlignHCenter
        \li Qt.AlignRight
        \endlist

      The default value is style dependent.
    */
    property int horizontalAlignment: Qt.AlignLeft

    /*!
        \qmlproperty bool SpinBox::hovered

        This property indicates whether the control is being hovered.
    */
    readonly property bool hovered: upButtonMouseArea.containsMouse || downButtonMouseArea.containsMouse || input.hovered

    /*!
        \qmlproperty bool SpinBox::inputMethodComposing
        \since QtQuick.Controls 1.3

        This property holds whether the NumberBox has partial text input from an input method.

        While it is composing an input method may rely on mouse or key events from the number box
        to edit or commit the partial text. This property can be used to determine when to disable
        events handlers that may interfere with the correct operation of an input method.
    */
    readonly property bool inputMethodComposing: !!input.inputMethodComposing

    /*! \internal */
    property bool __dragging: mouseArea.drag.active

    /*! \internal */
    property alias __text: input.text

    /*! \internal */
    property alias __baselineOffset: input.baselineOffset

    /*! This property determines if the control is read only
        The default value defined by TextBox base control and is \c false
    */
    property alias readOnly: input.readOnly

    /*! This property is used to define the buttons label when used in a WGFormLayout
        The default value is an empty string
    */
    property string label: ""

    /*! This property determines if the control will show up and down spinners.
        The default value is an \c true
    */
    property bool hasArrows: true

    /*! This property determines the colour of the text displayed in the control
        The default value is determined by the base TextField control
    */
    property alias textColor: input.textColor

    /*! \internal */
    property real __originalValue: 0 //the value before dragging

    /*! \internal */
    property real __tempValueAdd: 0 //the amount to add to the original value

    /*! \internal */
    property bool __fastDrag: false //if ctrl held down increment is much faster

    /*! \internal */
    property real __fakeZero: 0  //a fake zero after ctrl is held or released

    /*! \internal */
    property bool useValidatorOnInputText: true // Let the validator update the input.text

    property Component textBoxStyle: WGTextBoxStyle{}

    property bool fadeEnabled: false

    onHoveredChanged: {
        if (hovered)
        {
            fadeEnabled = true
        }
    }

    property Component infiniteButton: WGPushButton {
        id: infiniteButton
        objectName: "infiniteButton"
        iconSource: "icons/infinite_16x16.png"
        checkable: true
        checked: valueIsInfinite

        onClicked: {
            valueIsInfinite = !valueIsInfinite
            numberBox.editingFinished()
        }
    }

    property Component buttonFrame: WGButtonFrame{
        objectName: "button"
        id: button
        radius: 0
        property bool hovered: parent.hovered
        property bool up: parent.up
        property bool pressed: parent.pressed

        Text {
            id: arrowText
            color: __fastDrag ? palette.highlightColor : palette.neutralTextColor

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            anchors.horizontalCenterOffset: 1

            font.family : "Marlett"
            font.pixelSize: Math.round(parent.height)

            renderType: Text.QtRendering
            text : button.up ? "\uF074" : "\uF075"
        }

        states: [
            State {
                name: "PRESSED"
                when: button.pressed && numberBox.enabled
                PropertyChanges {target: button; color: palette.darkShade}
                PropertyChanges {target: button; innerBorderColor: "transparent"}
            },
            State {
                name: "HOVERED"
                when: button.hovered && numberBox.enabled && !numberBox.readOnly
                PropertyChanges {target: button; highlightColor: palette.lighterShade}
                PropertyChanges {target: arrowText; color: __fastDrag ? palette.highlightColor : palette.textColor}
            },
            State {
                name: "DISABLED"
                when: !numberBox.enabled || numberBox.readOnly
                PropertyChanges {target: button; color: "transparent"}
                PropertyChanges {target: button; borderColor: palette.darkShade}
                PropertyChanges {target: button; innerBorderColor: "transparent"}
                PropertyChanges {target: arrowText; color: palette.disabledTextColor}
            }
        ]
    }

    //signal declarations

    /*!
        \qmlsignal SpinBox::editingFinished()
        \since QtQuick.Controls 1.1

        This signal is emitted when the Return or Enter key is pressed or
        the control loses focus. Note that if there is a validator
        set on the control and enter/return is pressed, this signal will
        only be emitted if the validator returns an acceptable state.

        The corresponding handler is \c onEditingFinished.
    */

    signal editingFinished()
    signal batchCommandValueUpdated()

    //functions

    /*! \internal */

    function setValue(newValue) {
        setValueHelper(numberBox, "value", newValue)
        numberBox.editingFinished();
    }

    function setValueWithoutNotify(newValue) {
        setValueHelper(numberBox, "value", newValue)
    }

    /*! Select and force the text input into focus */
    function forceInputFocus() {
        input.forceActiveFocus();
        input.selectValue();
    }

    /* selects the text inside the input box */
    function selectValue() {
        input.selectValue()
    }

    //object properties

    /*!
        This property determines the height of the control
    */
    implicitHeight: defaultSpacing.minimumRowHeight

    /*!
        This property determines the preferred width of the control
    */
    implicitWidth: Math.min (recommendedSizeHint.contentWidth + defaultSpacing.doubleMargin + (hasArrows ? numberBoxSpinnerSize : 0),
                             maxContentWidth + defaultSpacing.doubleMargin + (hasArrows ? numberBoxSpinnerSize : 0))


    Accessible.name: input.text
    Accessible.role: Accessible.SpinBox

    Text {
        id: maxSizeHint
        text: prefix + maximumValue.toFixed(decimals) + suffix
        font: input.font
        visible: false
    }

    Text {
        id: currentSizeHint
        text: input.text
        font: input.font
        visible: false
    }

    Text {
        id: recommendedSizeHint
        font: input.font
        visible: false
        text: "999.999"
    }

    Text {
        id: minSizeHint
        text: prefix + minimumValue.toFixed(decimals) + suffix
        font: input.font
        visible: false
    }

    WGTextBox {
        id: input
        objectName: "input"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: showInfiniteButton ? infiniteButtonBox.left : parent.right
        implicitWidth: parent.width
        multipleValues: numberBox.multipleValues
        multipleValuesDisplayString: numberBox.__multipleValuesString

        horizontalAlignment: numberBox.horizontalAlignment
        verticalAlignment: Qt.AlignVCenter
        inputMethodHints: Qt.ImhFormattedNumbersOnly

        focus: true

        style: textBoxStyle

        states: [
            State {
                name: "NORMAL"
                when: !valueIsInfinite && !multipleValues && useValidatorOnInputText
                PropertyChanges {
                    target: input
                    text: validator.text
                }
            },
            State {
                name: "INFINITE"
                when: valueIsInfinite && !multipleValues
                PropertyChanges {
                    target: input
                    text: __valueIsInfiniteString
                }
            },
            State {
                name: "MULTIVALUE"
                when: multipleValues
                PropertyChanges {
                    target: input
                    text: __multipleValuesString
                }
            }
        ]

        validator: WGSpinBoxValidator {
            id: validator
            property bool ready: false // Delay validation until all properties are ready

            onTextChanged:
            {
                if (ready && useValidatorOnInputText && !multipleValues)
                {
                    input.text = validator.text
                }
            }

            Component.onCompleted:
            {
                ready = true
            }
        }

        onAccepted: {
            if (useValidatorOnInputText)
            {
                input.text = validator.text
                setValue(input.text);
            }
        }

        onEditAccepted: {
            if (useValidatorOnInputText)
            {
                input.text = validator.text
            }
            setValue(input.text);
        }

        //This breaks Tab focus... but not sure if it does anything else useful. Leaving here for now.
        //Keys.forwardTo: numberBox

        function selectValue() {
            select(prefix.length, text.length - suffix.length)
        }


        Keys.onUpPressed: {
            if (!input.readOnly)
            {
                input.stopEditing();
                validator.increment();
                setValue(validator.value);
            }
        }
        Keys.onDownPressed: {
            if (!input.readOnly)
            {
                input.stopEditing();
                validator.decrement();
                setValue(validator.value);
            }
        }

        //toggle __fastDrag with Ctrl. Also set a new zero point so current value can be changed instead of the original value.
        Keys.onPressed: {
            if (event.key == Qt.Key_Control)
            {
                __fastDrag = true
                if (dragBar.Drag.active)
                {
                    setValueWithoutNotify(__originalValue + __tempValueAdd);
                    batchCommandValueUpdated()
                    __originalValue = validator.value
                    __tempValueAdd = 0
                    __fakeZero = dragBar.y
                }
            }
        }

        Keys.onReleased: {
            if (event.key == Qt.Key_Control)
            {
                __fastDrag = false
                if (dragBar.Drag.active)
                {
                    setValueWithoutNotify(__originalValue + __tempValueAdd);
                    batchCommandValueUpdated()
                    __originalValue = validator.value
                    __tempValueAdd = 0
                    __fakeZero = dragBar.y
                }
            }
        }
    }

    // Numberbox arrow buttons
    Item {
        id: arrowBox
        objectName: "numberBoxArrowButtons"
        anchors.right: input.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: numberBoxSpinnerSize

        Loader {
            id: arrowUpButtonFrame
            sourceComponent: buttonFrame
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: Math.round(-(parent.height / 4))
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: parent.opacity

            property bool up: true
            property bool hovered: upButtonMouseArea.containsMouse
            property bool pressed: false

            height: parent.height / 2

            width: parent.width

            MouseArea {
                id: upButtonMouseArea
                anchors.fill: parent
                propagateComposedEvents: true
                hoverEnabled: true
                activeFocusOnTab: false
                acceptedButtons: Qt.NoButton
            }
        }

        Loader {
            id: arrowDownButtonFrame
            sourceComponent: buttonFrame
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: Math.round(parent.height / 4)
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: parent.opacity

            property bool up: false
            property bool hovered: downButtonMouseArea.containsMouse
            property bool pressed: false

            height: parent.height / 2

            width: parent.width

            MouseArea {
                id: downButtonMouseArea
                anchors.fill: parent
                propagateComposedEvents: true
                hoverEnabled: true
                activeFocusOnTab: false
                acceptedButtons: Qt.NoButton
            }
        }

        states: [
            State {
                //default state with arrows
                name: ""
                when: (downButtonMouseArea.containsMouse || upButtonMouseArea.containsMouse || dragBar.Drag.active
                       || ((hasArrows) && (currentSizeHint.contentWidth + defaultSpacing.standardMargin
                                           <= input.width - arrowBox.width)))
                PropertyChanges {target: arrowBox; opacity: 1}
            },
            State {
                name: "NOARROWS"
                when: (!hasArrows || ((hasArrows) && (currentSizeHint.contentWidth + defaultSpacing.standardMargin
                                                      > input.width - arrowBox.width )))
                PropertyChanges {target: arrowBox; opacity: 0}
            }
        ]

        transitions: [
            Transition {
                from: ""
                to: "NOARROWS"
                enabled: fadeEnabled
                NumberAnimation { properties: "opacity"; duration: 200 }

            },
            Transition {
                from: "NOARROWS"
                to: ""
                enabled: fadeEnabled
                NumberAnimation { properties: "opacity"; duration: 200 }
            }
        ]
    }


    Item {
        id: infiniteButtonBox
        objectName: "infiniteButtonBox"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        implicitWidth: height
        visible: showInfiniteButton

        Loader {
            id: infiniteButtonLoader
            sourceComponent: infiniteButton
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    //invisible line that handles incrementing the value by dragging
    Item {
        id: dragBar
        height: 1
        width: 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        property int modifier: __fastDrag ? 1 : 10

        Drag.active: mouseArea.drag.active && mouseArea.pressedButtons & Qt.LeftButton && !input.readOnly

        states: [
            State {
                when: dragBar.Drag.active

                AnchorChanges {
                    target: dragBar
                    anchors.top: undefined
                }
            }
        ]

        //add the position of the bar to the value. Use a fakezero if fastDrag has been toggled.
        onYChanged:{
            if (Drag.active){
                if ( stepSize !== 0 ) {
                    __tempValueAdd = Math.round((__fakeZero - y) / modifier) * stepSize
                } else {
                    __tempValueAdd = (__fakeZero - y) / modifier;
                }

                setValueWithoutNotify(__originalValue + __tempValueAdd);
                batchCommandValueUpdated()
            }
        }
    }

    MouseArea {
        //Mouse area for arrowbox spinners
        id: mouseArea

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: input.right
        activeFocusOnTab: false

        anchors.left: undefined
        width: arrowBox.width

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        preventStealing: true
        propagateComposedEvents: true //Allow context menu for textbox

        drag.target: dragBar
        drag.axis: Drag.YAxis

        // Store value in string instead of var to effectively clone QtInt64
        property string tempUndoValue: "0.0"
        property string finalValue: "0.0"

        //start changing the value via dragging dragBar
        //reset the value before and after drag
        drag.onActiveChanged: {
            if (mouseArea.drag.active) {
                input.focus = true;
                __originalValue = validator.value
                WGPressAndHoldTimer.stopTimer()
            } else {
                __tempValueAdd = 0
                __originalValue = 0
                __fakeZero = 0
                numberBox.editingFinished();
            }
        }

        onWheel: {
            if (!input.readOnly && input.activeFocus)
            {
                if (wheel.angleDelta.y > 0)
                {
                    validator.increment();
                    setValue(validator.value);
                }
                else
                {
                    validator.decrement();
                    setValue(validator.value);
                }
            }

            // Returns the wheel controls back to make ScrollView happy
            wheel.accepted = false
        }

        onClicked: {
            // eat up the right click on spinners to prevent context menu on spinners
            // right click is used to zero the value
            var arrowPoint = mouseArea.mapToItem(arrowBox, mouse.x, mouse.y)

            if (arrowBox.contains(Qt.point(arrowPoint.x, arrowPoint.y)))
            {
                if(mouse.button == Qt.RightButton)
                {
                    mouse.accepted = true
                }
            }
        }

        onPressed: {
            // must give numberBox focus to capture control key events
            input.focus = true;
            input.deselect();
            input.stopEditing()
            tempUndoValue = value
            beginUndoFrame();
            if (!input.readOnly)
            {
                var arrowPoint = mouseArea.mapToItem(arrowBox, mouse.x, mouse.y)

                if (arrowBox.contains(Qt.point(arrowPoint.x, arrowPoint.y)))
                {
                    if(mouse.button == Qt.RightButton)
                    {
                        setValueWithoutNotify(defaultValue);
                    }

                    if (arrowUpButtonFrame.hovered && mouse.button == Qt.LeftButton)
                    {
                        arrowUpButtonFrame.pressed = true
                    }
                    else if (arrowDownButtonFrame.hovered && mouse.button == Qt.LeftButton)
                    {
                        arrowDownButtonFrame.pressed = true
                    }
                }
            }
        }

        property int pressAndHoldValue: 0

        Connections {
            target: WGPressAndHoldTimer
            onTimerTriggered: {
                if (mouseArea.pressAndHoldValue == 1)
                {
                    validator.increment();
                    setValueWithoutNotify(validator.value);
                    batchCommandValueUpdated()
                }
                else if (mouseArea.pressAndHoldValue == -1)
                {
                    validator.decrement();
                    setValueWithoutNotify(validator.value);
                    batchCommandValueUpdated()
                }
            }
        }

        onPressAndHold: {
            if (!input.readOnly && mouse.button == Qt.LeftButton)
            {
                var arrowPoint = mouseArea.mapToItem(arrowBox, mouse.x, mouse.y)
                if (arrowBox.contains(Qt.point(arrowPoint.x, arrowPoint.y)))
                {
                    if (arrowUpButtonFrame.hovered)
                    {
                        mouseArea.pressAndHoldValue = 1
                    }
                    else if (arrowDownButtonFrame.hovered)
                    {
                        mouseArea.pressAndHoldValue = -1
                    }

                    if (!WGPressAndHoldTimer.running)
                    {
                        WGPressAndHoldTimer.restartTimer()
                    }
                }
            }
        }

        onReleased: {
            WGPressAndHoldTimer.stopTimer();

            finalValue = value;
            abortUndoFrame();

            if (finalValue == tempUndoValue) {
                //normally single click goes here
                if (arrowUpButtonFrame.pressed)
                {
                    validator.increment();
                }
                else if (arrowDownButtonFrame.pressed)
                {
                    validator.decrement();
                }
                finalValue = value;
            }

            setValue(finalValue);
            arrowUpButtonFrame.pressed = false;
            arrowDownButtonFrame.pressed = false;
            //prevents __fastDrag getting stuck if mouse is released before key event
            __fastDrag = false
            mouseArea.pressAndHoldValue = 0
        }
    }

    /*! Deprecated */
    property alias dragging_ : numberBox.__dragging

    /*! Deprecated */
    property alias label_: numberBox.label

    /*! Deprecated */
    property alias originalValue_: numberBox.__originalValue

    /*! Deprecated */
    property alias tempValueAdd_: numberBox.__tempValueAdd

    /*! Deprecated */
    property alias fastDrag_: numberBox.__fastDrag

    /*! Deprecated */
    property alias fakeZero_: numberBox.__fakeZero
}

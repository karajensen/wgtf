import QtQuick 2.5
import QtQuick.Layouts 1.3
import WGControls.Layouts 1.0


/*!
 \ingroup wgcontrols
 \todo brief
*/
WGExpandingRowLayout {
    id: fileComponent
    objectName: "WGFileSelectBox"
    WGComponent { type: "WGFileSelectBox" }

    /*! Determines whether text in the url is readOnly and can only be copied.
      Setting readOnly to true also allows the dialog box to be opened on double click.

      The default value is true.
    */
    property alias readOnly: textField.readOnly

    /*! The text in the filename box.

      The default value points to fileUrl
    */
    property alias text: textField.text

    /*! property indicates if the control represetnts multiple data values */
    property bool multipleValues: false

    /*! the property containing the string to be displayed when multiple values are represented by the control
    */
    property string __multipleValuesString: "Multiple Values"

    /*! The folder the fileDialog will open to by default.
      The default value is empty
    */
    property url folder

    /*! The path of the file which was selected by the user.

        Note: This property is set only if exactly one file was selected. In all other cases, it will be empty.
    */
    property url fileUrl

    /*! The list of file paths which were selected by the user.
    */
    property var fileUrls

    /*! The height of the dialog box displayed.

      The default value is 600
    */
    property int dialogHeight: 600

    /*! The width of the dialog box displayed.

      The default value is 800
    */
    property int dialogWidth: 800

    /*! Whether the dialog should be shown modal with respect to the window containing the dialog's parent Item,
        modal with respect to the whole application, or non-modal.
        The default value is Qt.ApplicationModal
    */
    property var modality: Qt.ApplicationModal

    /*! This array contains a list of filename Filters in the format:
      \code{.js}
      description (*.extension1 *.extension2 ...)
      \endcode
      All files can be selected using (*)
      Default value includes the following filters:

      \code{.js}
      "All files (*)",
      "Image files (*.jpg *.png *.bmp *.dds)",
      "Model files (*.model *.primitives *.visual)",
      "Script files (*.txt *.xml *.py)",
      "Audio files (*.fsb *.fev)",
      \endcode
    */
    property var nameFilters: {
        [
            "All files (*)",
            "Image files (*.jpg *.png *.bmp *.dds)",
            "Model files (*.model *.primitives *.visual)",
            "Script files (*.txt *.xml *.py)",
            "Audio files (*.fsb *.fev)",
        ]
    }

    /*! This currently selected filename filter
      The default value is All Files (*)
    */
    property string selectedNameFilter: nameFilters[0]

    property string title: "Select a File"

    /*! The dialog QML file to open.
      The default value is WGNativeFileDialog
    */
    property Component dialog: WGNativeFileDialog {}

    /*! internal */
    property var __dialogInstance

    // Signals
    signal fileChosen(var selectedFile)
    signal fileRejected()

    implicitHeight: defaultSpacing.minimumRowHeight

    /*! This function opens the desired dialog box.
    */
    function openDialog() {
        if(!readOnly) {
            __dialogInstance.open(dialogWidth, dialogHeight,textField.text)
        }
    }

    /*! This function closes the desired dialog box depending on whether useAssetBrowser == true or not.
    */
    function closeDialog() {
        __dialogInstance.close()
    }

    Component.onCompleted: {
        __dialogInstance = dialog.createObject(fileComponent,{
                                                   "folder": fileComponent.folder,
                                                   "modality": fileComponent.modality,
                                                   "nameFilters": fileComponent.nameFilters,
                                                   "selectedNameFilter": fileComponent.selectedNameFilter,
                                                   "title": fileComponent.title
                                               });
        openButton.enabled = Qt.binding(function() { return !textField.readOnly; });
    }

    Connections {
        target: __dialogInstance
        ignoreUnknownSignals: true

        onAccepted: {
            fileChosen(selectedValue)
        }

        onRejected: {
            fileRejected()
        }
    }

    WGTextBox {
        DropArea {
            anchors.fill:parent
            keys: ["text/uri-list"]
            enabled: !textField.readOnly
            onDropped: {
                if (drop.hasUrls)
                {
                    var fileName = drop.urls[0].toString();
                    var fileExtensionIndex = fileName.lastIndexOf('.') + 1;

                    if ( fileExtensionIndex !== -1 )
                    {
                        var fileType = fileName.substring(fileExtensionIndex);

                        for ( var i in nameFilters )
                        {
                            var filter = nameFilters[i];

                            if ( filter.indexOf('(') !== -1 )
                            {
                                filter = filter.substring(filter.indexOf('(') + 1, filter.indexOf(')'));
                            }

                            if ( filter.indexOf( "*." + fileType ) !== -1 || filter === '*' )
                            {
                                fileChosen(fileName);
                                drop.accept();
                                return;
                            }
                        }
                    }
                }
            }
        }

        id: textField
        objectName: "textField"
        Layout.fillWidth: true
        Layout.preferredHeight: defaultSpacing.minimumRowHeight

        text: fileComponent.multipleValues ? fileComponent.__multipleValuesString : fileUrl
        readOnly: true

        MouseArea {
            //mousearea to allow double clicking to change the file if the text is readonly
            anchors.fill: parent
            propagateComposedEvents: true
            hoverEnabled: true

            enabled: textField.readOnly

            cursorShape: Qt.IBeamCursor

            //Difficult to make discrete text selection and open via double-click work at the same time without rewriting TextField.
            //This is a compromise so that the filename can still be copied to clipboard

            onClicked: {
                textField.selectAll()
                textField.forceActiveFocus()
            }

            onDoubleClicked: {
                openDialog()
            }
        }
    }

    WGPushButton {
        id: openButton
        objectName: "openButton"
        iconSource: "icons/open_16x16.png"
        Layout.preferredHeight: defaultSpacing.minimumRowHeight
        Layout.preferredWidth: defaultSpacing.minimumRowHeight

        enabled: false

        onClicked: {
            openDialog()
        }
    }
}


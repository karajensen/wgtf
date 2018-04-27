import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQml.Models 2.2

import WGControls 2.0
import WGControls.Styles 2.0
import WGControls.Views 2.0


/*!
 \ingroup wgcontrols
 \brief WGListView displays data from a model defined by its delegate.
 The WGListView is contructed from a WGListViewBase which creates rows and columns.

Example:
\code{.js}

ScrollView {
    anchors.top: lastControl.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    WGListView {
        id: example
        model: sourceModel
        columnWidth: 50
        columnSpacing: 1
        headerDelegates: [exampleHeaderDelegate]
        footerDelegates: [exampleFooterDelegate]
        headerDelegate: exampleHeaderDelegate
        footerDelegate: exampleFooterDelegate
        columnDelegates: [columnDelegate, exampleDelegate]

        Component {
            id: exampleHeaderDelegate

            Text {
                id: textBoxHeader
                color: palette.textColor
                text: headerData.headerText
                height: 24
            }
        }

        Component {
            id: exampleFooterDelegate

            Text {
                id: textBoxFooter
                color: palette.textColor
                text: headerData.footerText
                height: 24
            }
        }

        Component {
            id: exampleDelegate

            Text {
                id: textItem

                visible: typeof itemData.value === "string"
                text: typeof itemData.value === "string" ? itemData.value : ""
                color: palette.textColor
            }
        }
    }
}

\endcode
*/
WGListViewBase {
    id: listView
    objectName: "WGListView"
    WGComponent { type: "WGListView20" }
    
    boundsBehavior : Flickable.StopAtBounds
    contentItem.x: -originX
    contentItem.y: -originY
    clip: true
    view: itemView
    internalModel: itemView.extendedModel

    /** The style component to allow custom view appearance.*/
    property alias style: itemView.style
    /** Default role for the value used in a cell component.*/
    property alias columnRole: itemView.columnRole
    /** Specific value roles per index to expose to cell components, overriding the default columnRole.*/
    property alias columnRoles: itemView.columnRoles
    /** Default cell component used in the rows of the view body.*/
    property alias columnDelegate: itemView.columnDelegate
    /** Specific components per index for view body cells, overriding the default cell component.*/
    property alias columnDelegates: itemView.columnDelegates
    /** Alternate arrangement of model columns in the view, also allowing skipping or repeating of columns.*/
    property alias columnSequence: itemView.columnSequence
    /** Default column width if none is specified.*/
    property alias columnWidth: itemView.initialColumnWidth
    /** Specific column widths per column.*/
    property alias columnWidths: itemView.initialColumnWidths
    /** The minimum a column can be reduced to. */
    property alias minimumColumnWidth: itemView.minimumColumnWidth
    /** Size of the gap between columns.*/
    property alias columnSpacing: itemView.columnSpacing
    /** The adapted model used internally.*/
    property alias internalModel: listView.model
    /** The data model providing the view with information to display.*/
    property alias model: itemView.model
    /** The object used for sorting operations.*/
    property alias sortObject: itemView.sortObject
    /** The object used for filtering logic.*/
    property alias filterObject: itemView.filterObject
    /** Optional specific header cell components, overriding the default header cell component.*/
    property alias headerDelegates: itemView.headerDelegates
    /** Optional specific footer cell components, overriding the default footer cell component.*/
    property alias footerDelegates: itemView.footerDelegates
    /** Default header cell component.*/
    property alias headerDelegate: itemView.headerDelegate
    /** Default footer cell component.*/
    property alias footerDelegate: itemView.footerDelegate
    /** Clamp (fix) width of the view to the containing component and adjust contents when width resized.*/
    property alias clamp: itemView.clamp
    /** The model containing the selected items/indices.*/
    property alias selectionModel: itemView.selectionModel
	property alias internalSelectionModel: itemView.internalSelectionModel
    /** A replacement for ListView's currentIndex that can use either a number or a QModelIndex.*/
    property var currentIndex: itemView.selectionModel.currentIndex
    /** The combined common and view extensions.*/
    property var extensions: []

    /*Specifies if list view needs to support multiple selection, default value is true*/
    property alias supportMultiSelect: itemView.supportMultiSelect
    /*! Override this for determine if the node can be selected */
    property var allowSelect: function(rowIndexToBeSelected, exisingSelectedIndexes, modifiers) {
        return true;
    } 

    signal selectionChanged()

    onCurrentIndexChanged: {
        if (typeof(currentIndex) == "number") {
            currentRow = currentIndex
            return;
        }
        currentRow = itemView.getRow(currentIndex);
		if (itemView.selectionModel.currentIndex != currentIndex && currentIndex != null) {
			itemView.selectionModel.setCurrentIndex(currentIndex, ItemSelectionModel.NoUpdate);
		}
    }
	onCurrentRowChanged: {
        currentIndex = (currentRow < 0 || internalModel == null) ? null : internalModel.index(currentRow, 0);
    }
    onCurrentItemChanged: {
        updateScrollPosition();
    }
    Connections {
        target: itemView

        onSelectionChanged: {
			selectionChanged()
		}
        onCurrentChanged: {
            currentIndex = itemView.selectionModel.currentIndex;
        }
    }

    Keys.onUpPressed: {
        if (orientation == ListView.Vertical) {
            itemView.movePrevious(event);
        }
    }
    Keys.onDownPressed: {
        if (orientation == ListView.Vertical) {
            itemView.moveNext(event);
        }
    }
    Keys.onLeftPressed: {
        if (orientation == ListView.Horizontal) {
            itemView.movePrevious(event);
        }
    }
    Keys.onRightPressed: {
        if (orientation == ListView.Horizontal) {
            itemView.moveNext(event);
        }
    }

    property bool __skippedPress: false
    onItemPressed: {
        var selected = itemView.selectionModel.selectedIndexes;
        for ( var i = 0; i < selected.length; ++i ) {
            if ( selected[i] === rowIndex ) {
                __skippedPress = true;
                return;
            }
        }

        itemView.select(mouse, rowIndex);
        forceActiveFocus();
    }
    onItemClicked: {
        if ( __skippedPress ) {
            itemView.select(mouse, rowIndex);
            forceActiveFocus();
        }
        __skippedPress = false;
    }

    function createExtension(name)
    {
        return view.createExtension(name);
    }

    /** Common view code. */
    WGItemViewCommon {
        id: itemView
        style: WGListViewStyle {}
        viewExtension: createExtension("ListExtension")
        allowSelect: function(rowIndexToBeSelected, exisingSelectedIndexes, modifiers) {
            return listView.allowSelect(rowIndexToBeSelected, exisingSelectedIndexes, modifiers);
        }
    }

    /**
    * Moves the scroll bar to focus on the last selected list item
    */
    function updateScrollPosition() {
        if( currentItem != null ) {

            var footerHeight = footerItem && footerPositioning == ListView.OverlayFooter ? footerItem.height : 0;
            var headerHeight = headerItem && headerPositioning == ListView.OverlayHeader ? headerItem.height : 0;
            var borderHeight = headerHeight + footerHeight;

            // Move up the list to get the position of the selected item
            var itemHeight = currentItem.height;
            var topItemHeight = itemHeight;
            var itemCurrentTop = currentItem.y;
            var itemCurrentBottom = itemCurrentTop + itemHeight;

            // Convert the positions into the range the scroll expects
            var scrollStart = originY;
            var scrollEnd = scrollStart + contentItem.height - borderHeight;
            var scrollHeight = contentHeight * visibleArea.heightRatio;
            var scrollEndCap = scrollStart + contentItem.height - scrollHeight;
            var scrollDifference = scrollEnd - scrollStart;
            var listItemsEnd = contentItem.height - borderHeight;
            itemCurrentTop = ( itemCurrentTop * ( scrollDifference / listItemsEnd ) ) + scrollStart;
            itemCurrentBottom = ( itemCurrentBottom * ( scrollDifference / listItemsEnd ) ) + scrollStart;
        
            // Determine whether to scroll up or down
            var scrollVisibleStart = contentY;
            var scrollVisibleHeight = scrollHeight - borderHeight;
            var scrollVisibleEnd = scrollVisibleStart + scrollVisibleHeight;

            if( itemCurrentTop < scrollVisibleStart ) {
                contentY = Math.min( scrollEndCap, Math.max( scrollStart, itemCurrentTop ) );
            }
            else if( itemCurrentBottom > scrollVisibleEnd ) {
                contentY = Math.min( scrollEndCap, Math.max( scrollStart, itemCurrentBottom - scrollVisibleHeight ) );
            }
        }
    }
}


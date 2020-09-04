// Import the standard GUI elements from QTQuick
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.2

// Import the Uranium GUI elements, which are themed for Cura
import UM 1.2 as UM
import Cura 1.0 as Cura

// Dialog from Uranium
// create the main window
UM.Dialog
{
    id: base

    title: "Color Change Plugin"
    width: 600
    height: 400
    minimumWidth: 600
    minimumHeight: 400
    maximumWidth: 600
    maximumHeight: 400

    // this function updates the layer list model when a layer has been selected
    function updateModel() {
        model.add(manager.getInputLayer.toString())
    }

    Button
    {
        id: closeButton
        text: "Close"
        width: 90
        height: 30
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        onClicked: base.accept()
    }

    Item
    {
        id: leftBase
        height: parent.height
        width: parent.width/2
        anchors.left: parent.left

        Label
        {
            id: leftHeader
            text: "Add Color Changes"
            font: UM.Theme.getFont("large_bold")
            color: UM.Theme.getColor("text")
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 50
        }

        Rectangle
        {
            id: subheadBase
            anchors.top: parent.top
            anchors.topMargin: 65
            anchors.left: leftHeader.left
            anchors.right: leftHeader.right
            anchors.bottom: inputBase.top
            anchors.bottomMargin: 10
            color: "transparent"

            Text
            {
                id: subhead
                text: "Add a layer in the Text Field or\nselect a layer using the Select\nLayer Tool in Layer View."
                font: UM.Theme.getFont("default")
                color: "gray"
                anchors.top: parent.top
                anchors.left: parent.left
            }
        }

        Item
        {
            id: inputBase
            width: 220
            height: 50
            anchors.left: leftHeader.left
            anchors.top: parent.top
            anchors.topMargin: 140

            Rectangle
            {
                id: frame
                color: "white"
                width: 100
                height: 30
                border.color: "gray"
                border.width: 1
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                TextInput
                {
                    id: userInput
                    anchors.fill: parent
                    anchors.margins: 4
                    Keys.onReturnPressed:
                    {
                        manager.getTextInput(text)
                        userInput.clear()
                    }
                    Keys.onEnterPressed:
                    {
                        manager.getTextInput(text)
                        userInput.clear()
                    }
                }
            }

            Button
            {
                id: addLayerButton
                property string input
                text: "Add Layer"
                width: 90
                height: 30
                anchors.left: frame.right
                anchors.leftMargin: 10
                anchors.top: frame.top
                onClicked:
                {
                    input = userInput.text
                    manager.getTextInput(input)
                    userInput.clear()
                }
            }
        }

        // insert a timer before the select layer tool is opened so that the preview stage can be loaded
        Timer
        {
            id: delay
            interval: 1500
            onTriggered: manager.openSelectionView()
        }

        Button
        {
            id: selectLayerToolButton

            text: " Select Layer Tool"
            width: 170
            height: 50
            anchors.left: leftHeader.left
            anchors.top: parent.top
            anchors.topMargin: 220
            iconSource: UM.Theme.getIcon("view_layer")

            onClicked:
            {
                UM.Controller.setActiveStage("PreviewStage")
                delay.start()
            }
        }

        Item
        {
            id: soundBase
            width: 220
            height: 40
            anchors.left: leftHeader.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40

            Label
            {
                id: checkBoxLabel
                text: "Sound Notification"
                font: UM.Theme.getFont("medium")
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            CheckBox
            {
                id: soundBox
                property int checkedState: checked ? Qt.Checked : Qt.Unchecked
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.top: checkBoxLabel.top
                onClicked:
                {
                    CuraApplication.backend.stopSlicing()
                    if(checkedState == Qt.Checked)
                        manager.addBeep()
                    else if(checkedState == Qt.Unchecked)
                        manager.noBeep()
                }
            }
        }
    }


    Rectangle
    {
        id: rightBase
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.left: leftBase.right
        anchors.bottom: closeButton.top
        anchors.bottomMargin: 10
        color: "white"

        Label
        {
            id: rightHeader
            text: "Selected Layers"
            font: UM.Theme.getFont("large_bold")
            color: UM.Theme.getColor("text")
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 45
        }

        ListModel
        {
            id: model

            function add(n) {
                model.append({ "layernr": "Layer  " + n })
            }
        }

        ScrollView
        {
            id: scrollView
            style: UM.Theme.styles.scrollview

            anchors
            {
                top: rightHeader.bottom
                left: parent.left
                right: parent.right
                rightMargin: 20
                topMargin: 10
                leftMargin: 20
                bottom: parent.bottom
                bottomMargin: 20
            }

            ListView
            {
                id: selectedLayersList
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                model: model
                onCountChanged: CuraApplication.backend.stopSlicing()

                delegate: Item
                {
                    id: list
                    width: parent.width
                    height: removeButton.height + 20

                    Button
                    {
                        id: layerListButton
                        Text
                        {
                            text: layernr
                            color: "black"
                            anchors.left: parent.left
                            anchors.leftMargin: 26
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        width: parent.width
                        height: parent.height

                        style: ButtonStyle
                        {
                            background: Rectangle
                            {
                                color: "transparent"
                                width: parent.width
                                height: parent.height
                            }
                        }
                    }

                    Button
                    {
                        id: removeButton
                        text: "x"
                        width: 20
                        height: 20
                        anchors.right: parent.right
                        anchors.rightMargin: 95
                        anchors.verticalCenter: layerListButton.verticalCenter
                        style: ButtonStyle
                        {
                            label: Item
                            {
                                UM.RecolorImage
                                {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Math.round(control.width / 2.7)
                                    height: Math.round(control.height / 2.7)
                                    sourceSize.height: width
                                    color: "black"
                                    source: UM.Theme.getIcon("cross1")
                                }
                            }
                        }
                        onClicked:
                        {
                            manager.removeLayer(index)
                            selectedLayersList.model.remove(index)
                        }
                    }

                    Button {
                        id: colorButton
                        width: 45
                        height: 25
                        anchors.right: parent.right
                        anchors.rightMargin: 25
                        anchors.verticalCenter: layerListButton.verticalCenter
                        menu: colorMenu

                        Image {
                            id: colorItem
                            source: "colorIcon.svg"
                            anchors.left: parent.left
                            anchors.leftMargin: 7
                            anchors.verticalCenter: parent.verticalCenter
                            width: 17
                            height: 17
                        }

                        onClicked: colorMenu.open()
                    }

                    Menu {
                        id: colorMenu

                        MenuItem {
                            text: "No Color"
                            onTriggered:
                            {
                                colorItem.source = "colorIcon.svg"
                                manager.addColor(index, "No")
                            }
                        }
                        MenuItem {
                            text: "Black"
                            iconSource: "black.svg"
                            onTriggered:
                            {
                                colorItem.source = "black.svg"
                                manager.addColor(index, "black")
                            }
                        }
                        MenuItem {
                            text: "White"
                            iconSource: "white.svg"
                            onTriggered:
                            {
                                colorItem.source = "white.svg"
                                manager.addColor(index, "white")
                            }
                        }
                        MenuItem {
                            text: "Grey"
                            iconSource: "grey.svg"
                            onTriggered:
                            {
                                colorItem.source = "grey.svg"
                                manager.addColor(index, "grey")
                            }
                        }
                        MenuItem {
                            text: "Red"
                            iconSource: "red.svg"
                            onTriggered:
                            {
                                colorItem.source = "red.svg"
                                manager.addColor(index, "red")
                            }
                        }
                        MenuItem {
                            text: "Blue"
                            iconSource: "blue.svg"
                            onTriggered:
                            {
                                colorItem.source = "blue.svg"
                                manager.addColor(index, "blue")
                            }
                        }
                        MenuItem {
                            text: "Green"
                            iconSource: "green.svg"
                            onTriggered:
                            {
                                colorItem.source = "green.svg"
                                manager.addColor(index, "green")
                            }
                        }
                        MenuItem {
                            text: "Yellow"
                            iconSource: "yellow.svg"
                            onTriggered:
                            {
                                colorItem.source = "yellow.svg"
                                manager.addColor(index, "yellow")
                            }
                        }
                        MenuItem {
                            text: "Orange"
                            iconSource: "orange.svg"
                            onTriggered:
                            {
                                colorItem.source = "orange.svg"
                                manager.addColor(index, "orange")
                            }
                        }
                        MenuItem {
                            text: "Purple"
                            iconSource: "purple.svg"
                            onTriggered:
                            {
                                colorItem.source = "purple.svg"
                                manager.addColor(index, "purple")
                            }
                        }
                        MenuItem {
                            text: "Pink"
                            iconSource: "pink.svg"
                            onTriggered:
                            {
                                colorItem.source = "pink.svg"
                                manager.addColor(index, "pink")
                            }
                        }
                        MenuItem {
                            text: "Light Blue"
                            iconSource: "lightblue.svg"
                            onTriggered:
                            {
                                colorItem.source = "lightblue.svg"
                                manager.addColor(index, "lightblue")
                            }
                        }
                        MenuItem {
                            text: "Light Green"
                            iconSource: "lightgreen.svg"
                            onTriggered:
                            {
                                colorItem.source = "lightgreen.svg"
                                manager.addColor(index, "lightgreen")
                            }
                        }
                        MenuItem {
                            text: "Brown"
                            iconSource: "brown.svg"
                            onTriggered:
                            {
                                colorItem.source = "brown.svg"
                                manager.addColor(index, "brown")
                            }
                        }
                    }

                }
            }
        }
    }

    Rectangle
    {
        id: infoBase
        width: 30
        height: 30
        color: "transparent"
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom

        UM.SimpleButton
        {
            id: infoButton

            anchors.fill: parent
            color: UM.Theme.getColor("icon")
            iconSource: UM.Theme.getIcon("info")
        }

        MouseArea
        {
            id: infoArea
            anchors.fill: parent
            hoverEnabled: infoArea.enabled
            onEntered: tooltip.show()
            onExited: tooltip.hide()
        }
    }

    UM.PointingRectangle
    {
        id: tooltip

        width: 300
        height: tooltipLabel.height + UM.Theme.getSize("tooltip_margins").height * 2
        color: UM.Theme.getColor("tooltip")

        arrowSize: UM.Theme.getSize("default_arrow").width

        opacity: 0

        property alias text: tooltipLabel.text

        function show()
        {
            x = infoBase.x + infoBase.width + 5
            y = infoBase.y - tooltipLabel.height - 2

            tooltip.opacity = 1
            target = Qt.point(infoBase.x + 5, infoBase.y + Math.round(UM.Theme.getSize("tooltip_arrow_margins").height / 2))
        }

        function hide()
        {
            tooltip.opacity = 0
        }

        Label
        {
            id: tooltipLabel
            text: "<b>Selected Layers List</b><br>" +
                  "The printer will pause before the selected layers to enable a filament change.<br>" +
                  "<br><b>[Optional] Add a color </b><br>" +
                  "Visualize the color that starts at the selected layer. " +
                  "The color is shown on the printer LCD during the filament change.<br>" +
                  "<br><b>Sound Notification</b><br>" +
                  "If checked the printer will beep at pauses."
            anchors
            {
                top: parent.top
                topMargin: UM.Theme.getSize("tooltip_margins").height
                left: parent.left
                leftMargin: UM.Theme.getSize("tooltip_margins").width
                right: parent.right
                rightMargin: UM.Theme.getSize("tooltip_margins").width
            }
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            font: UM.Theme.getFont("default")
            color: UM.Theme.getColor("tooltip_text")
            renderType: Text.NativeRendering
        }
    }

    //create button next to slice button to reopen the main window
    Cura.SecondaryButton
    {
        objectName: "ColorChangeSaveAreaButton"
        visible: selectedLayersList.count > 0
        height: UM.Theme.getSize("action_button").height
        width: height
        tooltip: catalog.i18nc("@info:tooltip", "Change selected layers")
        onClicked: base.show()
        iconSource: "plugin.svg"
        fixedWidthMode: true
    }
}

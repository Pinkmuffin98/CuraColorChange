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
// create the needs slicing error window
UM.Dialog
{
    id: needSlicingWindow

    title: "Error"
    width: 250
    height: 150
    minimumWidth: 250
    minimumHeight: 150
    maximumWidth: 250
    maximumHeight: 150

    Button
    {
        id: okButton
        text: "Ok"
        width: 90
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        onClicked:
        {
            needSlicingWindow.close()
        }
    }

    Rectangle
    {

        id: textBase
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: 220
        height: 70
        color: "transparent"

        Text
        {
            id: info
            text: "Add an object and slice\nbefore adding a layer."
            font: UM.Theme.getFont("regular")
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
}

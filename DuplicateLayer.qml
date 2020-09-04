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
// create the duplicate layer error window
UM.Dialog
{
    id: duplicateLayerWindow

    title: "Error"
    width: 300
    height: 150
    minimumWidth: 300
    minimumHeight: 150
    maximumWidth: 300
    maximumHeight: 150

    Button
    {
        id: okButton
        text: "Ok"
        width: 90
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        onClicked:
        {
            duplicateLayerWindow.close()
        }
    }

    Text
    {
        id: info
        text: "This layer has already been selected."
        font: UM.Theme.getFont("regular")
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

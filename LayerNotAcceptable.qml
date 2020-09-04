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
// create the layer not accepted error window
UM.Dialog
{
    id: layerNotAcceptablewindow

    title: "Error"
    width: 350
    height: 150
    minimumWidth: 350
    minimumHeight: 150
    maximumWidth: 350
    maximumHeight: 150

    Button
    {
        id: okButton
        text: "Ok"
        width: 90
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        onClicked:
        {
            layerNotAcceptablewindow.close()
        }
    }

    Rectangle
    {

        id: textBase
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        width: 300
        height: 80
        color: "transparent"

        Text
        {
            id: info
            text: "The input has to be a number.\nThe input has to be higher than 0 and lower\nthan the maximum layer number of the object."
            font: UM.Theme.getFont("regular")
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
}

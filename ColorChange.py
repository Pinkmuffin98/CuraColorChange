# Imports from QT to handle signals and slots
from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
from typing import Dict, Type, TYPE_CHECKING, List, Optional, cast

# Imports from Uranium and Cura to interact with the plugin system
from UM.Extension import Extension
from UM.Application import Application
from UM.PluginRegistry import PluginRegistry
from UM.Resources import Resources
from cura.CuraApplication import CuraApplication
from cura.CuraView import CuraView

# Imports from Uranium to enable internationalization
from UM.i18n import i18nCatalog
i18n_catalog = i18nCatalog("ColorChange")

# Imports from the python standard library to build the plugin functionality
import pkgutil
import importlib.util
from code import InteractiveInterpreter
import os.path
from io import StringIO
import sys
import html



# This class is our Extension and doubles as QObject to manage the qml
class ColorChange(QObject, Extension):

    # The constructor, which calls all the super-class-contructors, registers
    # our menu items and initializes the internal instance variables
    def __init__(self, parent = None) -> None:
        QObject.__init__(self, parent)
        Extension.__init__(self)

        self.setMenuName(i18n_catalog.i18nc("@item:inmenu", "Color Change"))
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Add Color Changes"), self.showConsole)

        self._console_window = None
        self._selection_window = None
        self._duplicate_layer_window = None
        self._layer_not_accepted_window = None
        self._need_slicing_window = None

        # Selected Layers List contains integer values of selected layers. Duplicates will not be accepted into the list.
        self._selected_layers_list = []
        # Color list contains the colors that have been selected for the layer. If none has been selected the value is "No".
        self._color_list = []
        # Input Layer is the last selected layer number.
        self._input_layer = None
        # Beep shows if the sound notification of the printer is selected.
        self._beep = False
        # Gcode List contains the gcode List of the active buildplate.
        self._gcode_list = []
        # Current Layer contains the layer that is currently selected with the upper handle of the slider in Layer View.
        self._current_layer = None
        # Max Layer contains the number of layers of the loaded object.
        self._max_layer = None

        # When the main window is created, create the view so that we can display the Color Change icon if necessary.
        CuraApplication.getInstance().mainWindowChanged.connect(self._createDialogue)
        # When the gcode is saved by the user the selected color changes are inserted in the gcode before the download.
        Application.getInstance().getOutputDeviceManager().writeStarted.connect(self.execute)

    # This method gets called when the menu item for our plugin is clicked and
    # shows the console window if it has already been loaded
    def showConsole(self) -> None:
        if self._console_window is None:
            self._createDialogue()
        self._console_window.show()

    # This method builds our main dialog from the qml file and registers this class as the manager variable
    def _createDialogue(self)-> None:
        # Create the plugin dialog component
        path = os.path.join(cast(str, PluginRegistry.getInstance().getPluginPath("ColorChange")), "ConsoleSelection.qml")
        self._console_window = CuraApplication.getInstance().createQmlComponent(path, {"manager": self})
        if self._console_window is None:
            return
        # Create the save are button component
        CuraApplication.getInstance().addAdditionalComponent("saveButton", self._console_window.findChild(QObject, "ColorChangeSaveAreaButton"))

    # This method executes selected color changes on the gcode.
    def execute(self, output_device):
        scene = Application.getInstance().getController().getScene()
        # If the scene does not have a gcode, do nothing
        if not hasattr(scene, "gcode_dict"):
            return
        gcode_dict = getattr(scene, "gcode_dict")
        if not gcode_dict:
            return

        # get gcode list for the active build plate
        active_build_plate_id = CuraApplication.getInstance().getMultiBuildPlateModel().activeBuildPlate
        gcode_list = gcode_dict[active_build_plate_id]
        if not gcode_list:
            return

        # generate the gcode that is inserted in the gcode list before the selected layers
        if ";COLOR CHANGES ADDED" not in gcode_list[0]:

            # check if layer is within range
            if len(self._selected_layers_list) > 0:
                for layer_num in self._selected_layers_list:
                    layer_num = layer_num + 1 #Needs +1 because the 1st layer is reserved for start gcode.
                    if 0 < layer_num < len(gcode_list):

                        info = "; Generated by ColorChange Plugin\n"
                        sound = "M300 S440 P2000\nM300 S440 P2000\nM300 S440 P2000\n"

                        # add the color selection in the gcode if selected
                        index = self._selected_layers_list.index(layer_num - 1)
                        if self._color_list[index] != "No":
                            color = self._color_list[index]

                            gcode = ("M82 ;Set Extruder to Relative Mode\n"
                                    "G1 E-5 ;Retract 5 mm\n"
                                    "G91 ;Set Relative Mode\n"
                                    "G1 Z10 ;Move head up 10 mm\n"
                                    "G90 ;Set Absolute Mode\n"
                                    "G1 X20 Y20 F5000 ;Move to park position\n"
                                    "G91 ;Set Relative Mode\n"
                                    "G1 E-50 ;Retract old filament\n"
                                    "M117 Change filament to " + color + " ;LCD Message\n"
                                    "M0 ;Pause\n"
                                    "G1 E80 F100 ;Extrude old filament\n"
                                    "M117 Remove filament rest ;LCD Message\n"
                                    "M0 ;Pause\n"
                                    "G90 ;Set Absolute Mode\n"
                                    "G1 F5000 ;Set feedrate\n"
                                    "G28 X0 Y0 ;Home X Y\n"
                                    "M82 ;Set Extruder to Absolute Mode\n"
                                    "G92 E0 ;Set Extruder position to 0\n")

                        else:
                            gcode = ("M82 ;Set Extruder to Relative Mode\n"
                                    "G1 E-5 ;Retract 5 mm\n"
                                    "G91 ;Set Relative Mode\n"
                                    "G1 Z10 ;Move head up 10 mm\n"
                                    "G90 ;Set Absolute Mode\n"
                                    "G1 X20 Y20 F5000 ;Move to park position\n"
                                    "G91 ;Set Relative Mode\n"
                                    "G1 E-50 ;Retract old filament\n"
                                    "M117 Change filament ;LCD Message\n"
                                    "M0 ;Pause\n"
                                    "G1 E80 F100 ;Extrude old filament\n"
                                    "M117 Remove filament rest ;LCD Message\n"
                                    "M0 ;Pause\n"
                                    "G90 ;Set Absolute Mode\n"
                                    "G1 F5000 ;Set feedrate\n"
                                    "G28 X0 Y0 ;Home X Y\n"
                                    "M82 ;Set Extruder to Absolute Mode\n"
                                    "G92 E0 ;Set Extruder position to 0\n")

                        # add sound to the gcode if selected
                        if self._beep == True:
                            color_change = info + sound + gcode
                        else:
                            color_change = info + gcode

                        gcode_list[layer_num] = color_change + gcode_list[layer_num]

                gcode_list[0] += ";COLOR CHANGES ADDED\n"
                gcode_dict[active_build_plate_id] = gcode_list
                setattr(scene, "gcode_dict", gcode_dict)

    # This method checks the text input and adds the layer to the layer list if the input is valid
    @pyqtSlot(str)
    def getTextInput(self, text: str):
        if self._selection_window is not None:
            self._selection_window.hide()
            self._console_window.show()

        if self.checkSliceState() == False:
            self.openNeedSlicingWindow()

        else:
            input = 0
            try:
                input = int(text)
            except:
                self.openLayerNotAcceptedWindow()

            if input < 1 or input > (len(self._gcode_list) - 4):
                self.openLayerNotAcceptedWindow()
            else:
                if input in self._selected_layers_list:
                    self.openDuplicateLayerWindow()
                else:
                    self._input_layer = input
                    self._selected_layers_list.append(self._input_layer)
                    self._color_list.append("No")
                    self._console_window.updateModel()

    # This method returns false if no object has been added or the object has not been sliced and true if an object has been sliced.
    def checkSliceState(self) -> bool:
        state = True
        scene = Application.getInstance().getController().getScene()
        if not hasattr(scene, "gcode_dict"):
            state = False
        else:
            gcode_dict = getattr(scene, "gcode_dict")
            active_build_plate_id = CuraApplication.getInstance().getMultiBuildPlateModel().activeBuildPlate
            try:
                self._gcode_list = gcode_dict[active_build_plate_id]
                if len(self._gcode_list) == 0:
                    state = False
            except:
                state = False
        return state

    # This method returns the input layer
    inputLayerChanged = pyqtSignal()
    @pyqtProperty(int, notify=inputLayerChanged)
    def getInputLayer(self) -> int:
        return self._input_layer

    # This method returns the layer that is currently selected with the slider in preview stage
    currentLayerChanged = pyqtSignal()
    @pyqtProperty(int, notify=currentLayerChanged)
    def getCurrentLayer(self) -> int:
        self._current_layer = Application.getInstance().getPluginRegistry().getPluginObject("SimulationView").getCurrentLayer()
        return self._current_layer

    # This method returns the max layer number of the current object
    maxLayerChanged = pyqtSignal()
    @pyqtProperty(int, notify=maxLayerChanged)
    def getMaxLayers(self) -> int:
        self._max_layer = Application.getInstance().getPluginRegistry().getPluginObject("SimulationView").getMaxLayers()
        return self._max_layer

    # This method sets the color of a layer to the selected color
    @pyqtSlot(int, str)
    def addColor(self, index: int, color: str):
        self._color_list[index] = color

    # This method removes a layer from the layer list and the corresponding color from the color list
    @pyqtSlot(int)
    def removeLayer(self, index: int):
        self._selected_layers_list.pop(index)
        self._color_list.pop(index)

    # This method sets beep to true if the sound notification is selected.
    @pyqtSlot()
    def addBeep(self):
        self._beep = True

    # This method sets beep to false if the sound notification is unselected.
    @pyqtSlot()
    def noBeep(self):
        self._beep = False

    # This method hides the main window and opens the selection window.
    @pyqtSlot()
    def openSelectionView(self):
        if self.checkSliceState() == False:
            self.openNeedSlicingWindow()
        else:
            self._console_window.hide()
            if self._selection_window is None:
                qml_file_path = os.path.join(PluginRegistry.getInstance().getPluginPath(self.getPluginId()), "SelectLayerinPreviewMode.qml")
                self._selection_window = Application.getInstance().createQmlComponent(qml_file_path, {"manager": self})
            self._selection_window.show()

    # This method opens the duplicate layer error window.
    def openDuplicateLayerWindow(self):
        if self._duplicate_layer_window is None:
            qml_file_path = os.path.join(PluginRegistry.getInstance().getPluginPath(self.getPluginId()), "DuplicateLayer.qml")
            self._duplicate_layer_window = Application.getInstance().createQmlComponent(qml_file_path, {"manager": self})
        self._duplicate_layer_window.show()

    # This method opens the layer not accepted error window.
    def openLayerNotAcceptedWindow(self):
        if self._layer_not_accepted_window is None:
            qml_file_path = os.path.join(PluginRegistry.getInstance().getPluginPath(self.getPluginId()), "LayerNotAcceptable.qml")
            self._layer_not_accepted_window = Application.getInstance().createQmlComponent(qml_file_path, {"manager": self})
        self._layer_not_accepted_window.show()

    # This method opens the need slicing error window.
    def openNeedSlicingWindow(self):
        if self._need_slicing_window is None:
            qml_file_path = os.path.join(PluginRegistry.getInstance().getPluginPath(self.getPluginId()), "NeedSlicingWindow.qml")
            self._need_slicing_window = Application.getInstance().createQmlComponent(qml_file_path, {"manager": self})
        self._need_slicing_window.show()

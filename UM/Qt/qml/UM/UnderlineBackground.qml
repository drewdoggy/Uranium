//Copyright (c) 2022 Ultimaker B.V.
//Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2

import UM 1.5 as UM

Rectangle
{
    property alias liningColor: lining.color

    color:  UM.Theme.getColor("detail_background")
    anchors.fill: parent;

    Rectangle
    {
        id: lining
        anchors.bottom: parent.bottom
        width: parent.width
        height: UM.Theme.getSize("default_lining").height
        color: UM.Theme.getColor("border_field_light")
    }
}
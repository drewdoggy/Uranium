// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.2

import UM 1.1 as UM

Item {
    id: base;

    width: 0;
    height: 0;

    property variant position: mapToItem(null, 0, 0)

    property int currentIndex;

    Rectangle {
        id: settingsPanel;

        z: 3;

        width: UM.Theme.sizes.per_object_settings_panel.width;
        height: items.height;

        opacity: 0;
        Behavior on opacity { NumberAnimation { } }

        border.width: UM.Theme.sizes.per_object_settings_panel_border.width;
        border.color: UM.Theme.colors.per_object_settings_panel_border;

        color: UM.Theme.colors.per_object_settings_panel_background;

        DropArea {
            anchors.fill: parent;
        }

        Column {
            id: items

            anchors {
                left: parent.left;
                leftMargin: UM.Theme.sizes.default_margin
                right: parent.right;
                rightMargin: UM.Theme.sizes.default_margin
                top: parent.top;
                topMargin: UM.Theme.sizes.default_margin
            }

            spacing: UM.Theme.sizes.default_margin.width;

            UM.SettingItem {
                id: profileSelection

                x: UM.Theme.sizes.per_object_settings_panel_border.width;

                width: UM.Theme.sizes.setting.width;
                height: UM.Theme.sizes.setting.height;

                name: catalog.i18nc("@label", "Profile")
                type: "enum"

                style: UM.Theme.styles.setting_item;

                options: UM.ProfilesModel { addUseGlobal: true }

                value: UM.ActiveTool.properties.Model.getItem(base.currentIndex).profile

                onItemValueChanged: {
                    var item = UM.ActiveTool.properties.Model.getItem(base.currentIndex);
                    UM.ActiveTool.properties.Model.setObjectProfile(item.id, value)
                }
            }

            Repeater {
                id: settings;

                model: UM.ActiveTool.properties.Model.getItem(base.currentIndex).settings

                UM.SettingItem {
                    width: UM.Theme.sizes.setting.width;
                    height: UM.Theme.sizes.setting.height;

                    name: model.label;
                    type: model.type;
                    value: model.value;
                    description: model.description;
                    unit: model.unit;
                    valid: model.valid;

                    style: UM.Theme.styles.setting_item;

                    onItemValueChanged: {
                        settings.model.setSettingValue(model.key, value)
                    }

                    Button {
                        anchors.left: parent.right;
                        text: "x";

                        width: UM.Theme.sizes.setting.height;
                        height: UM.Theme.sizes.setting.height;

                        opacity: parent.hovered || hovered ? 1 : 0;
                        onClicked: UM.ActiveTool.properties.Model.removeSettingOverride(UM.ActiveTool.properties.Model.getItem(base.currentIndex).id, model.key)

                        style: ButtonStyle { }
                    }
                }
            }

            Button
            {
                anchors.right: profileSelection.right;

                text: catalog.i18nc("@action:button", "Customize Settings");

                style: ButtonStyle
                {
                    background: Rectangle
                    {
                        width: control.width;
                        height: control.height;
                        color: control.hovered ? UM.Theme.colors.load_save_button_hover : UM.Theme.colors.load_save_button;
                    }
                    label: Label
                    {
                        text: control.text;
                        color: UM.Theme.colors.load_save_button_text;
                    }
                }

                onClicked: settingPickDialog.visible = true;
            }
        }

        UM.I18nCatalog { id: catalog; name: "uranium"; }
    }

    Repeater {
        model: UM.ActiveTool.properties.Model;
        delegate: Button {
            x: ((model.x + 1.0) / 2.0) * UM.Application.mainWindow.width - base.position.x - width / 2
            y: -((model.y + 1.0) / 2.0) * UM.Application.mainWindow.height + (UM.Application.mainWindow.height - base.position.y) + height / 2

            width: UM.Theme.sizes.per_object_settings_button.width
            height: UM.Theme.sizes.per_object_settings_button.height

            tooltip: catalog.i18nc("@info:tooltip", "Customise settings for this object");

            checkable: true;
            onClicked: {
                base.currentIndex = index;

                settingsPanel.anchors.left = right;
                settingsPanel.anchors.top = top;

                settingsPanel.opacity = 1;
            }

            style: ButtonStyle
            {
                background: Rectangle
                {
                    width: control.width;
                    height: control.height;

                    color: control.hovered ? UM.Theme.colors.button_active : UM.Theme.colors.button_hover;
                }
                label: Image {
                    width: control.width;
                    height: control.height;
                    sourceSize.width: width;
                    sourceSize.height: height;
                    source: UM.Theme.icons.plus;
                }
            }
        }
    }

    UM.Dialog {
        id: settingPickDialog

        title: catalog.i18nc("@title:window", "Pick a Setting to Customize")

        ScrollView {
            anchors.fill: parent;

            Column {
                width: childrenRect.width;
                height: childrenRect.height;

                Repeater {
                    id: settingList;

                    model: UM.SettingCategoriesModel { }

                    delegate: Item {
                        id: delegateItem;

                        width: childrenRect.width;
                        height: childrenRect.height;

                        ToolButton {
                            id: categoryHeader;
                            text: model.name;
                            checkable: true;
                            onCheckedChanged: settingsColumn.state != "" ? settingsColumn.state = "" : settingsColumn.state = "collapsed";

                            style: ButtonStyle {
                                background: Item { }
                                label: Row {
                                    spacing: UM.Theme.sizes.default_margin.width;
                                    Label { text: control.checked ? ">" : "v"; }
                                    Label { text: control.text; font.bold: true; }
                                }
                            }
                        }

                        property variant settingsModel: model.settings;

                        visible: model.visible;

                        Column {
                            id: settingsColumn;

                            anchors.top: categoryHeader.bottom;

                            width: childrenRect.width;
                            height: childrenRect.height;
                            Repeater {
                                model: delegateItem.settingsModel;

                                delegate: ToolButton {
                                    x: model.depth * UM.Theme.sizes.default_margin.width;
                                    text: model.name;
                                    visible: model.visible;

                                    onClicked: {
                                        var object_id = UM.ActiveTool.properties.Model.getItem(base.currentIndex).id;
                                        UM.ActiveTool.properties.Model.addSettingOverride(object_id, model.key);
                                        settingPickDialog.visible = false;
                                    }
                                }
                            }

                            states: State {
                                name: "collapsed";

                                PropertyChanges { target: settingsColumn; opacity: 0; height: 0; }
                            }
                        }
                    }
                }
            }
        }

        rightButtons: [
            Button {
                text: catalog.i18nc("@action:button", "Cancel");
                onClicked: {
                    settingPickDialog.visible = false;
                }
            }
        ]
    }
}

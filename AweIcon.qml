import QtQuick
import QtQuick.Effects

Item {
    id: root
    property string name: ""
    property color color: "#FFFFFF"
    property real size: 16

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size

    Item {
        id: iconSrc
        anchors.fill: parent
        visible: false
        Image {
            anchors.fill: parent
            source: root.name ? ("icons/" + root.name + ".svg") : ""
            sourceSize: Qt.size(Math.round(root.size * 2), Math.round(root.size * 2))
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: iconSrc
        colorization: 1.0
        colorizationColor: root.color
    }
}

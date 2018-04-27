import QtQuick 2.5
import QtQuick.Layouts 1.3
import WGControls.Private 2.0

/*!
 \ingroup wgcontrols
 \brief A vector4 variation of the vectorN control
*/

WGVectorN {
    id: vector4
    objectName: "WGVector4"
    WGComponent { type: "WGVector4" }

    property vector4d value

    vectorData: [value.x, value.y, value.z, value.w]
    vectorLabels: ["X:", "Y:", "Z:", "W:"]

    onElementChanged: {
        var temp_value = Qt.vector4d( vectorData[0], vectorData[1], vectorData[2], vectorData[3]);
        setValueHelper(vector4, "value", temp_value);
    }
}

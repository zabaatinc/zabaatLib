import QtQuick 2.5
QtObject {
    id : rootObject

    //kinda experimental function , use carefully. It will move the sourceItem!!
    function capture(sourceItem, subRect, cb, safetyDelay, dontRenderOffscreen) {
        if(!Qt.isQtObject(sourceItem))
            return cb({err:"sourceItem is not a Qt Object" });

        function isValidToGrab(a) {
            return a && a.width > 0 && a.height > 0 && a.x !== undefined && a.y !== undefined
        }

        if(!isValidToGrab(sourceItem))
            return cb({err:"sourceItem has invalid dimensions" });


        cb = cb || function() {}
        safetyDelay = safetyDelay || 10;

        if(!isValidToGrab(subRect))
            return sourceItem.grabToImage(cb);


        var r    = shaderFactory.createObject(sourceItem);
        if(!dontRenderOffscreen)
            r.x = r.y = Number.MAX_VALUE;   //draw it off screen!!

        r.width  = subRect.width;
        r.height = subRect.height;

        r.sourceItem = sourceItem;
        r.startX     = subRect.x / sourceItem.width;
        r.startY     = subRect.y / sourceItem.height;
        r.endX       = (subRect.x + subRect.width) / sourceItem.width;
        r.endY       = (subRect.y + subRect.height) / sourceItem.height;

        r.ready.connect(function() {
            r.grabToImage(function(result){
                if(typeof cb === 'function')
                    cb(result);

                r.destroy();
            })
        });
        r.begin(safetyDelay);
    }

    property Item _members : Item {
        id : _members

        Component { id : itemFactory; Item {} }


        Component {
            id : shaderFactory;
            Item {
                id : shaderInstance;
                property alias sourceItem : ses.sourceItem
                property alias startX     : sEffect.startX
                property alias startY     : sEffect.startY
                property alias endX       : sEffect.endX
                property alias endY       : sEffect.endY
                function begin(interval) {
                    readyTimer.interval = interval;
                    readyTimer.start();
                }

                signal ready();

                ShaderEffect {
                    id : sEffect
                    anchors.fill: parent
                    property variant source: ShaderEffectSource {
                       id : ses
                       smooth      : true
                       anchors.fill: parent
                    }
                    property real startX : 0
                    property real startY : 0
                    property real endX : 1
                    property real endY : 1

                    fragmentShader: "#ifdef GL_ES
                                         precision mediump float;
                                     #else
                                     #   define lowp
                                     #   define mediump
                                     #   define highp
                                     #endif // GL_ES
                                     uniform sampler2D source;
                                     uniform lowp float qt_Opacity;
                                     uniform lowp float startX;
                                     uniform lowp float startY;
                                     uniform lowp float endX;
                                     uniform lowp float endY;
                                     varying vec2 qt_TexCoord0;
                                     void main()
                                     {
                                         vec2 start = vec2(startX,startY);
                                         vec2 end   = vec2(endX, endY);
                                         if(end.x < start.x)
                                            end.x = start.x;
                                         if(end.y < start.y)
                                            end.y = start.y;
                                         vec2 uv = qt_TexCoord0.xy;

                                         float myX = (end.x - start.x) * uv.x + start.x;
                                         float myY = (end.y - start.y) * uv.y + start.y;

                                         vec4 c  = texture2D(source, vec2(myX,myY));
                                         gl_FragColor = qt_Opacity * c;
                                     }"

                }
                Timer {
                    id : readyTimer
                    interval: 10
                    repeat : true
                    onTriggered:  {
                        shaderInstance.ready();
                        stop();
                    }
                }

            }

        }

    }

}

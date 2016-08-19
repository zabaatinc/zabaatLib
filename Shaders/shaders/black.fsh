/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd and/or its subsidiary(-ies).
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:LGPL21$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 or version 3 as published by the Free
** Software Foundation and appearing in the file LICENSE.LGPLv21 and
** LICENSE.LGPLv3 included in the packaging of this file. Please review the
** following information to ensure the GNU Lesser General Public License
** requirements will be met: https://www.gnu.org/licenses/lgpl.html and
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** As a special exception, The Qt Company gives you certain additional
** rights. These rights are described in The Qt Company LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** $QT_END_LICENSE$
**
****************************************************************************/



uniform sampler2D source;
uniform lowp float qt_Opacity;
varying vec2 qt_TexCoord0;
uniform float dividerValue;

uniform float hardness;
uniform float depth;
uniform float shadowR;
uniform float shadowG;
uniform float shadowB;

void main()
{
//    float pi = 3.1415926535897932384626433832795;
    vec2 uv = qt_TexCoord0.xy;
    vec4 c = texture2D(source, qt_TexCoord0);
    if(uv.x <= dividerValue) {
        //this gives us a range of 0 - 1    (radiating from the center)
        //we must turn this into a range of softness - 1
        c.r = shadowR * c.a;
        c.g = shadowG * c.a;
        c.b = shadowB * c.a;



        float distance = length(0.5 - uv.xy);
//        c.a = hardness - distance;
//        c.a = 0;
        c.a = ((1-hardness) * (depth - distance) + hardness) * c.a;
    }
    gl_FragColor = c ;
}

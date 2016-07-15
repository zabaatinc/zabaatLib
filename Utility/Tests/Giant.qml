import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import Zabaat.Material 1.0
import Zabaat.Utility 1.1


Item {
    width : Screen.width
    height : Screen.height - 300




    Component.onCompleted: {
        sourceModel.append(testObject)
    }

    Row {
        Button {
            text : "add"
            onClicked: logic.randomAdd()
        }
        Button {
            text : "delete"
            onClicked : logic.randomRemove()
        }
        Button {
            text : 'move'
            onClicked: logic.randomMove()
        }
    }



    QtObject {
        id : logic
        property ListModel sourceModel : ListModel { id : sourceModel;  }

        //prime exapmle of awesome sauce
//        property var queryTerm : ({first:""})
//        property var queryTerm : ({"$or":[{first:"Hector"},{last:"Hector"}] })
        property var queryTerm : ({"$or":[ {first:"Hector"},
                                            {"$and":[{first:"Mector"},{last:"Hector"}]}
                                          ]
                                  })
//        property var queryTerm : ({"$or":[{first:"Hector"},{last:"Hector"}] })

           //{first:"Coletta" 	,last:"Jasik" },

        function getRandIdx(){
            return Math.floor(Math.random() * sourceModel.count)
        }

        function randomAdd(){
            var idx = getRandIdx()
            var text = Math.floor(Math.random() * 10).toString()
            sourceModel.insert(idx,{ first : text, last:"rnd"});
        }

        function randomRemove(){
//            sourceModel.remove(sourceModel.count - 1)
            sourceModel.remove(getRandIdx())
//            sourceModel.remove(2)
        }

        function randomMove(){
            sourceModel.move(0,1,3)
        }

        function formQueryObject(key,op,value){
//            console.log(key,op,value)
            if(key !== ""){
                var obj = {}
                if(op === ""){
                    obj[key] = value;
                }
                else{
                    obj[key] = {}
                    obj[key][op] = value;
                }

                logic.queryTerm = obj
//                console.log(JSON.stringify(obj,null,2))
            }
            else
                logic.queryTerm = {}

//            console.log("queryTerm = " , JSON.stringify(queryTerm))
        }
    }





    Item {
        id : gui
        anchors.fill: parent

        Row {
            id : searchContainer
            width : parent.width
            height : parent.height * 0.1

            ZTextBox{
                id : searchKey
                label : "Search Key"
                width : parent.width * 0.4
                height : parent.height
                onTextChanged : logic.formQueryObject(searchKey.text,searchOp.text,searchBox.text)
            }
            ZTextBox{
                id : searchOp
                label : "Search Key"
                width : parent.width * 0.2
                height : parent.height
                onTextChanged :  logic.formQueryObject(searchKey.text,searchOp.text,searchBox.text)
            }
            ZTextBox{
                id : searchBox
                label : "SearchTerm"
                width : parent.width * 0.4
                height : parent.height
                onTextChanged :  logic.formQueryObject(searchKey.text,searchOp.text,searchBox.text)
            }

        }


        Row {
            id : listContainer
            width : parent.width
            height: parent.height * 0.9
            anchors.bottom: parent.bottom

            ListView {
                id : unfilteredList
                width : parent.width/2
                height : parent.height
                model : sourceModel
                delegate : delegateCmp;
                header : headerCmp;
//                add    : Transition {NumberAnimation{ properties : "x,y"; duration : 333; from : -100; to : 0 } }
//                remove : Transition {NumberAnimation{ properties : "scale"; duration : 333; from : 1; to : 0 }  }
//                move   : Transition {NumberAnimation{ properties : "scale"; duration : 333; from : 0; to : 1 }  }
            }

            ListView {
                id : filteredList
                width : parent.width/2
                height : parent.height
                model : subModel

                ZSubModel{
                    id : subModel
                    sourceModel: sourceModel
                    queryTerm  : logic.queryTerm
                    sortRoles  : ["first","last"]
//                    compareFunction: function(a,b) {
////                        console.log("CUSTOM CMP FUNCT") . reverts order!
//                        return a.first < b.first
//                    }

                }
                delegate : delegateCmp;
                header : headerCmp;
//                add    : Transition {NumberAnimation{ properties : "x,y"; duration : 333; from : -100; to : 0 } }
//                remove : Transition {NumberAnimation{ properties : "scale"; duration : 333; from : 1; to : 0 }  }
//                move   : Transition {NumberAnimation{ properties : "scale"; duration : 333; from : 0; to : 1 }  }
            }
        }

        Component {
            id : delegateCmp
            Rectangle {
                id : delItem
                width  : lvPtr ? lvPtr.width : 100
                height : lvPtr ? lvPtr.height * 0.1 : 100
                border.width: 1
                property var lvPtr : parent.parent ? parent.parent : null
                property var m : lvPtr && lvPtr.model ? lvPtr.model.get(index) : {error:"happens"}
                property int ind : m && !_.isUndefined(m.__relatedIndex) ? m.__relatedIndex : index
//                onMChanged: if(m) console.log(JSON.stringify(m,null,2))

                clip : true
                Flickable {
                    width : parent.width - parent.height
                    height : parent.height
                    contentWidth: text.paintedWidth
                    contentHeight: text.paintedHeight
                    Text {
                        id : text

    //                    horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: delItem.height * 1/6
                        text   : delItem.ind + ":" + JSON.stringify(Functions.object.modelObjectToJs(delItem.m),null,2)
    //                    Component.onCompleted: console.log(delItem.parent.parent)
                    }

                    Text {
                        id : textBig
                        width : delItem.width -  parent.parent.height
                        height : delItem.height
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: delItem.height * 1/3
                        text   : delItem.m ? delItem.ind + ":" + delItem.m.first + " " + delItem.m.last : ""
    //                    Component.onCompleted: console.log(delItem.parent.parent)
                    }
                }
                ZButton{
                    width    : height
                    height   : parent.height
                    text     : "+"
                    onClicked: delItem.m.first += "s"
                    anchors.right: parent.right
                }


            }


        }
        Component {
            id : headerCmp
            Rectangle {
                id : delItem
                width  : lvPtr ? lvPtr.width : 100
                height : lvPtr ? lvPtr.height * 0.1 : 100
                border.width: 1
                property var lvPtr : parent.parent ? parent.parent : null
                Text {
                    id : text
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: delItem.height * 1/3
                    text   : delItem.lvPtr.count
//                    Component.onCompleted: console.log(delItem.parent.parent)
                }
            }
        }


    }



    //http://listofrandomnames.com/index.cfm?textarea
    property var testObject : [
        {first:"Hector" 	,last:"Flippen" },
        {first:"Mector" 	,last:"Hector" },
        {first:"Norene" 	,last:"Shunk" },
        {first:"Tillie" 	,last:"Screen" },
        {first:"Nanette" 	,last:"Mcguigan" },
        {first:"Humberto" 	,last:"Osterman" },
        {first:"Willena" 	,last:"Harville" },
        {first:"Leonardo" 	,last:"Mcconnell" },
        {first:"Elvia" 		,last:"Dube" },
        {first:"Brandon" 	,last:"Liller" },
        {first:"Janita" 	,last:"Kerrick" },
        {first:"Lillian" 	,last:"Scoggin" },
        {first:"Joannie" 	,last:"Gosney" },
        {first:"William" 	,last:"Powers" },
        {first:"Lanita" 	,last:"Mendoza" },
        {first:"Vernice" 	,last:"Gaskin" },
        {first:"Chance" 	,last:"Eakle" },
        {first:"Latia" 		,last:"An" },
        {first:"Queen" 		,last:"Wiles" },
        {first:"Marylou" 	,last:"Blakeslee" },
        {first:"Izetta" 	,last:"Yon" },
        {first:"Joi" 		,last:"Carty" },
        {first:"Karyn" 		,last:"Mcgrory" },
        {first:"Sade" 		,last:"Vescio" },
        {first:"Rosamond" 	,last:"Sapienza" },
        {first:"Christy" 	,last:"Wessels" },
        {first:"Chassidy" 	,last:"Lofthouse" },
        {first:"Rosamaria" 	,last:"Kendra" },
        {first:"Mandi" 		,last:"Castagna" },
        {first:"Lenny" 		,last:"Gaulke" },
        {first:"Rosalinda" 	,last:"Mcqueeney" },
        {first:"Marcella" 	,last:"Mcgarr" },
        {first:"Ahmed" 		,last:"Yandell" },
        {first:"Deanne" 	,last:"Bugg" },
        {first:"Alva" 		,last:"Maddocks" },
        {first:"Daisy" 		,last:"Shelburne" },
        {first:"Chris" 		,last:"Dehne" },
        {first:"Roy" 		,last:"Kimmell" },
        {first:"Eboni" 		,last:"Cordero" },
        {first:"Pearly" 	,last:"Yoo" },
        {first:"Inez" 		,last:"Simms" },
        {first:"Tanisha" 	,last:"Fitch" },
        {first:"Virgie" 	,last:"Hinchman" },
        {first:"Nobuko" 	,last:"Papke" },
        {first:"Evelyne" 	,last:"Hansel" },
        {first:"Tamisha" 	,last:"Chappel" },
        {first:"Jaunita" 	,last:"Blane" },
        {first:"Geneva" 	,last:"Spenser" },
        {first:"Jackeline" 	,last:"Fike" },
        {first:"Suellen" 	,last:"Chairez" },
        {first:"Moira" 		,last:"Blakney" },
        {first:"Samuel" 	,last:"Blakes" },
        {first:"Sueann" 	,last:"Dunneback" },
        {first:"Shala" 		,last:"Swafford" },
        {first:"Jenni" 		,last:"Crase" },
        {first:"Carissa" 	,last:"Footman" },
        {first:"Dagmar" 	,last:"Fines" },
        {first:"Irma" 		,last:"Kesterson" },
        {first:"Karina" 	,last:"Damato" },
        {first:"Siobhan" 	,last:"Peppers" },
        {first:"Olimpia" 	,last:"Done" },
        {first:"Amalia" 	,last:"Wigley" },
        {first:"Melissa" 	,last:"Mends" },
        {first:"Darcy" 		,last:"Guess" },
        {first:"Elfrieda" 	,last:"Miraglia" },
        {first:"Sybil" 		,last:"Accetta" },
        {first:"Tanner" 	,last:"Dimeo" },
        {first:"Sam" 		,last:"Bowler" },
        {first:"Earlie" 	,last:"Solar" },
        {first:"Kimberly" 	,last:"Gessner" },
        {first:"Ruthann" 	,last:"Barish" },
        {first:"Fernando" 	,last:"Midgett" },
        {first:"Francoise" 	,last:"Estabrook" },
        {first:"Norma" 		,last:"Thatcher" },
        {first:"Jaime" 		,last:"Gazaway" },
        {first:"Rolf" 		,last:"Mcbeath" },
        {first:"Nenita" 	,last:"Rimmer" },
        {first:"Garry" 		,last:"Engelking" },
        {first:"Cinda" 		,last:"Bal" },
        {first:"Arden" 		,last:"Cansler" },
        {first:"Delorse" 	,last:"Eland" },
        {first:"Tynisha" 	,last:"Mosteller" },
        {first:"Apolonia" 	,last:"Lawhon" },
        {first:"Graciela" 	,last:"Strum" },
        {first:"Morris" 	,last:"Priddy" },
        {first:"Yong" 		,last:"Connell" },
        {first:"Winnie" 	,last:"Minjares" },
        {first:"Tajuana" 	,last:"Schnabel" },
        {first:"Madelene" 	,last:"Nissen" },
        {first:"Eddie" 		,last:"Tienda" },
        {first:"Otelia" 	,last:"Ashby" },
        {first:"Lavera" 	,last:"Tippens" },
        {first:"Rosita" 	,last:"Heenan" },
        {first:"Shandra" 	,last:"Stebbins" },
        {first:"Catherin" 	,last:"Arnone" },
        {first:"Emily" 		,last:"Prokop" },
        {first:"Florinda" 	,last:"Cheever" },
        {first:"Mariette" 	,last:"Artis" },
        {first:"Meda" 		,last:"Siers" },
        {first:"Hanh" 		,last:"Kluender" },
        {first:"Ellsworth" 	,last:"Pilarski" },
        {first:"Abby" 		,last:"Basquez" },
        {first:"Jeannette" 	,last:"Towell" },
        {first:"Sage" 		,last:"Fregoe" },
        {first:"Meta" 		,last:"Chambers" },
        {first:"Karleen" 	,last:"Rickey" },
        {first:"Genia" 		,last:"Brough" },
        {first:"Signe" 		,last:"Jolin" },
        {first:"Martine" 	,last:"Leonard" },
        {first:"Felice" 	,last:"Primm" },
        {first:"Marlyn" 	,last:"Schnur" },
        {first:"Talia" 		,last:"Getz" },
        {first:"Tiana" 		,last:"Lamberti" },
        {first:"Alysa" 		,last:"Bigler" },
        {first:"Jaunita" 	,last:"Sadowski" },
        {first:"Chan" 		,last:"Halle" },
        {first:"Kellee" 	,last:"Huston" },
        {first:"Carolynn" 	,last:"Rouse" },
        {first:"Jenise" 	,last:"Scott" },
        {first:"Michele" 	,last:"Fiore" },
        {first:"Deana" 		,last:"Simental" },
        {first:"Nicole" 	,last:"Woolridge" },
        {first:"Darnell" 	,last:"Farago" },
        {first:"Georgeanna" ,last:"Babcock" },
        {first:"Jeane" 		,last:"Loomis" },
        {first:"Arturo" 	,last:"Leeds" },
        {first:"Doreatha" 	,last:"Beaton" },
        {first:"Sylvia" 	,last:"Didonna" },
        {first:"Lai" 		,last:"Claire" },
        {first:"Cathern" 	,last:"Belz" },
        {first:"Randi" 		,last:"Crowther" },
        {first:"Bo" 		,last:"Mosier" },
        {first:"Penney" 	,last:"Ehrmann" },
        {first:"Coletta" 	,last:"Jasik" },
        {first:"Aimee" 		,last:"Morris" },
        {first:"Nicol" 		,last:"Sitton" },
        {first:"Anita" 		,last:"Gutierres" },
        {first:"Sue" 		,last:"Coggins" },
        {first:"Corazon" 	,last:"Broughton" },
        {first:"Jule" 		,last:"Fikes" },
        {first:"Giovanni" 	,last:"Mcloud" },
        {first:"Joanna" 	,last:"Hare" },
        {first:"Denna" 		,last:"Cliett" },
        {first:"Marshall" 	,last:"Montag" },
        {first:"Shawna" 	,last:"Oh" },
        {first:"Columbus" 	,last:"Durden" },
        {first:"Cami" 		,last:"Merle" },
        {first:"Katrina" 	,last:"Dysart" },
        {first:"Dian" 		,last:"Grayer" },
        {first:"Elijah" 	,last:"Metro" },
        {first:"Katerine" 	,last:"Justice" },
        {first:"Vince" 		,last:"Ridenhour" },
        {first:"Azucena" 	,last:"Viola" },
        {first:"Mireya" 	,last:"Bechard" },
        {first:"Lakenya" 	,last:"Wurm" },
        {first:"Kati" 		,last:"Kesterson" },
        {first:"Benjamin" 	,last:"Casillas" },
        {first:"Yong" 		,last:"Mayton" },
        {first:"Benny" 		,last:"Ehrenberg" },
        {first:"Daniela" 	,last:"Bardin" },
        {first:"Cleveland" 	,last:"Pinder" },
        {first:"Tai" 		,last:"Knoles" },
        {first:"Annika" 	,last:"Mailhot" },
        {first:"Lashanda" 	,last:"Fimbres" },
        {first:"Althea" 	,last:"Cadena" },
        {first:"Ophelia" 	,last:"Luebbert" },
        {first:"Chris" 		,last:"Coley" },
        {first:"Laticia" 	,last:"Zemke" },
        {first:"Fatima" 	,last:"Laskowski" },
        {first:"Nellie" 	,last:"Heffington" },
        {first:"Aleshia" 	,last:"Mazon" },
        {first:"Emelda" 	,last:"Lovering" },
        {first:"Rozella" 	,last:"Holms" },
        {first:"Diedra" 	,last:"Borel" },
        {first:"Lina" 		,last:"Bachand" },
        {first:"Eryn" 		,last:"Dejarnette" },
        {first:"Takisha" 	,last:"Pippins" },
        {first:"Dionna" 	,last:"Whitlow" },
        {first:"Mabelle" 	,last:"Wiers" },
        {first:"Waldo" 		,last:"Fairall" },
        {first:"Claud" 		,last:"Oden" },
        {first:"Ken" 		,last:"Kunkel" },
        {first:"Zada" 		,last:"Pankey" },
        {first:"Renate" 	,last:"Ackles" },
        {first:"Hyo" 		,last:"Laidlaw" },
        {first:"Tona" 		,last:"Gayhart" },
        {first:"Shanika" 	,last:"Brodnax" },
        {first:"Ethelyn" 	,last:"Carlos" },
        {first:"Peg" 		,last:"Heald" },
        {first:"Leena" 		,last:"Hutcheson" },
        {first:"Deshawn" 	,last:"Hasegawa" },
        {first:"Jonelle" 	,last:"Carballo" },
        {first:"Albertine" 	,last:"Wismer" },
        {first:"Kiera" 		,last:"Teamer" },
        {first:"Valeria" 	,last:"Fiorillo" },
        {first:"Loma" 		,last:"Halstead" },
        {first:"Dorris" 	,last:"Papadopoulos" },
        {first:"George" 	,last:"Estabrook" },
        {first:"Wynona" 	,last:"Mcguckin" },
        {first:"Zackary" 	,last:"Hoda" },
        {first:"Meridith" 	,last:"Dickerson"}
    ]




}

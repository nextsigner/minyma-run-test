import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import unik.UnikQProcess 1.0

ApplicationWindow{
    id: app
    visible: true
    visibility: "Maximized"
    color: 'black'
    width: Screen.width
    height: Screen.height
    property bool closeWhenFinished: false
    Row{
        spacing: 18
        anchors.centerIn: parent
        Column{
            spacing: 18
            Text{
                text: 'Comando:'
                font.pixelSize: 18
                color: 'white'
            }
            Rectangle{
                width: ta.width+10
                height: ta.height+10
                color: 'transparent'
                border.width: 2
                border.color: 'white'
                TextArea{
                    id: ta
                    width: app.closeWhenFinished?app.width*0.8:app.width*0.8-taLog.parent.width
                    height: app.height*0.8
                    color: 'white'
                    anchors.centerIn: parent
                    Keys.onReturnPressed: app.run()
                }
                Button{
                    id: bot1
                    text:'Enviar'
                    anchors.top: parent.bottom
                    anchors.topMargin: 5
                    anchors.right: parent.right
                    onClicked: app.run()
                }
                CheckBox{
                    id: cb1
                    checked: app.closeWhenFinished
                    onCheckStateChanged: app.closeWhenFinished=checked
                    anchors.verticalCenter: bot1.verticalCenter
                    anchors.right: bot1.left
                    anchors.rightMargin: 10
                }
                Text{
                    text: 'Cerrar al terminar'
                    width: contentWidth
                    color: 'white'
                    anchors.verticalCenter: cb1.verticalCenter
                    anchors.right: cb1.left
                    anchors.rightMargin: 10
                }
            }
        }
        Column{
            spacing: 18
            visible: !app.closeWhenFinished
            Text{
                text: 'Salida:'
                font.pixelSize: 18
                color: 'white'
            }
            Rectangle{
                width: taLog.width+10
                height: ta.parent.height//+10
                color: 'transparent'
                border.width: 2
                border.color: 'white'
                clip: true
                Flickable{
                    id: flk
                    width: parent.width
                    height: parent.height
                    contentWidth: taLog.width
                    contentHeight: taLog.contentHeight//+parent.height*0.5
                    anchors.centerIn: parent
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar{}
                    TextArea{
                        id: taLog
                        width: app.closeWhenFinished?app.width*0.8:app.width*0.4
                        height: contentHeight
                        color: 'white'

                        //Keys.onReturnPressed: app.run()
                    }
                }
            }
        }
    }
    MinymaClient{
        id: minymaClient
        loginUserName: 'minyma-run-test'
        host: 'ws://192.168.1.35'
        onNewMessage: {
            //let json=JSON.parse(data)
            //log.ls('Minyma Recibe: '+data, 0, 500)
        }
        onNewMessageForMe: {
            console.log(loginUserName+' received from '+from+': '+data)
            taLog.text+=loginUserName+' received from '+from+': '+data+'\n'
            flk.contentY=flk.contentHeight-flk.height
            if(from==='minyma-run' && data==='finished' && app.closeWhenFinished){
                Qt.quit()
            }
        }
    }
    Timer{
        id: tRun
        running: false
        repeat: true
        interval: 200
        onTriggered: {
            if(minymaClient.logued){
                app.run()
                stop()
            }
        }
    }
    Shortcut{
        sequence: 'Ctrl+Enter'
        onActivated: {
            run()
        }
    }


    Component.onCompleted: {
        let args = Qt.application.arguments
        for(var i=0;i<args.length;i++){
            if(args[i]==='kill'){
                app.closeWhenFinished=true
            }
            if(args[i].indexOf('-cmd=')===0){
                let m0=args[i].split('-cmd=')
                ta.text=m0[1]
                tRun.start()
                //app.run()
            }
        }
        console.log('Minyma Run Test Arguments: '+args)
    }
    function run(){
        minymaClient.sendData(minymaClient.loginUserName, 'minyma-run', ta.text)
        //Qt.quit()
    }
}

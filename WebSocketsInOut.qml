import QtQuick 2.3
import QtWebSockets 1.0

Item {
    id: r
    property string host: "ws://localhost"
    property int port: 1337
    property string userId: 'undefined'
    signal dataReceived(string from, string data, int ms)
    signal serverClosed()
    WebSocket {
        id: socket
        url: r.host+":"+r.port

        onTextMessageReceived: {
            let json=JSON.parse(message)
            //console.log('zool_data recibe: '+message)
             console.log('zool_data recibe: '+json.data)
             if(!json.from===r.userId){
                 dataReceived(json.from, json.data, json.ms)
             }
        }
        onStatusChanged: if (socket.status == WebSocket.Error) {
                             console.log("Error: " + socket.errorString)
                         } else if (socket.status == WebSocket.Open) {
                             //socket.sendTextMessage("Hello World")
                             sendData(r.userId, "wssio", "Inicio de aplicación "+r.userId+".")
                         } else if (socket.status == WebSocket.Closed) {
                             let d = new Date(Date.now())
                             serverClosed()
                         }
        active: false
    }
    function toogleConn(){
        socket.active = !socket.active
    }
    function socketToActive(){
        socket.active = true
    }
    function socketToInActive(){
        socket.active = false
    }
    function sendData(from, to, data){
        let d = new Date(Date.now())
        socket.sendTextMessage(JSON.stringify({from: from, to: to, data: data, ms: d.getTime()}).replace(/\n/g, ' '), 322)
    }
}

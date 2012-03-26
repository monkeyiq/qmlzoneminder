import QtQuick 1.1
import QtWebKit 1.0
import "script"
import "script/ajaxmee.js"    as Ajaxmee
import "script/array2json.js" as ArrayToJson
import "script/strftime.js"   as Strftime
import "script/storage.js"    as Storage

Rectangle {
    id: container
    width: 854; height: 480
    color: "#222222"
    z: -100 

    TextInput { 
	id: currentMonitorID
	text: ""
	visible: false
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:   parent.verticalCenter
	id: config
	width: 854; height: 480
	visible: false
	color: "#aaaaaa"
	opacity: 1
	z: 200

	MouseArea { anchors.fill:parent; }
	Column {
	    spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter
	    Grid {
		columns: 2
		spacing: 10
		Text { 
		    text: "Server URL" 
		    font.pixelSize: 30
		    horizontalAlignment: Text.AlignRight
		}
		TextInput { 
		    id: serverURL
		    text: "http://" 
		    font.pixelSize: 30
		}
		Text { 
		    text: "Password" 
		    font.pixelSize: 30
		    horizontalAlignment: Text.AlignRight
		}
		TextInput { 
		    id: password
		    text: "http://" 
		    font.pixelSize: 30
		}
		Text { 
		    text: "Username" 
		    font.pixelSize: 30
		    horizontalAlignment: Text.AlignRight
		}
		TextInput { 
		    id: username
		    text: "http://" 
		    font.pixelSize: 30
		}
	    }
            TextButton {
                anchors.horizontalCenter: parent.horizontalCenter
		width: 200
		height: 40
		text: "Done"
		onClicked: { 
		    config.visible = false; 
		    if( serverURL.text.substring(0, 7) != "http://"
			&& serverURL.text.substring(0, 7) != "https:/" )
		    {
			serverURL.text = "http://" + serverURL.text;
		    }
		    Storage.setSetting( "serverurl", serverURL.text );
		    Storage.setSetting( "password",  password.text );
		    Storage.setSetting( "username",  username.text );
		}
	    }
	}
    }

    /////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////

    XmlListModel {
	id: eventsModel
	query: ""; // /ZM_XML/MONITOR_LIST/MONITOR[STATE='OK']";
	source: "";

	XmlRole { name: "id";        query: "ID/string()" }
	XmlRole { name: "name";      query: "NAME/string()" }
	XmlRole { name: "time";      query: "TIME/string()" }
	XmlRole { name: "duration";  query: "DURATION/string()" }
	XmlRole { name: "fps";       query: "FPS/string()" }
	XmlRole { name: "frames";    query: "FRAMES/string()" }
    }
    Component {
        id: eventsDelegate
        
        Item {
            width: listView.width; height: 72
            clip: true
	    ListView.onAdd: { 
		if( eventView.source == "" )
		{
		    console.log("add(1) " + eventsView.currentIndex ); 
		    var eventid   = eventsModel.get(index).id;
		    console.log("add(2) " + eventid ); 
		    playEvent( index );
		}
	    }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

		Grid {
		    columns: 3
		    spacing: 10
		    Column {
			width: 96;
			Image {
			    width: 64; height: 64;
			    source: "images/play.png"
			    MouseArea { 
				anchors.fill:parent; 
				onClicked: {
				    playEvent(index)
//				    eventsView.positionViewAtIndex( index, ListView.Beginning );
				}
			    }
			}
		    }
		    // Column {
		    // 	Row {
		    // 	    Text { 
		    // 		width: 70
		    // 		text: id
		    // 		font.pixelSize: 15
		    // 		color: "white"
		    // 	    }
		    // 	}
		    // }
		    Column {
			Text { 
			    text: time
			    font.pixelSize: 15
			    color: "white"
			}
			Text { 
			    text: duration
			    font.pixelSize: 20
			    font.bold: true
			    color: "white"
			}
		    }

		}
	    }
	}
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:   parent.verticalCenter
	id: events
	width: 854; height: 480
	visible: false
//	color: "#aaaaaa"
	color: "#222222"
	opacity: 1
	z: 200
	
	TextInput { 
	    id: eventListForMonitorID
	    text: ""
	    visible: false
	}
	TextInput { 
	    id: eventListCurrentEventID
	    text: ""
	    visible: false
	}
	TextInput { 
	    id: eventListCurrentFrame
	    text: ""
	    visible: false
	}
	TextInput { 
	    id: eventListTotalFrames
	    text: ""
	    visible: false
	}
	TextInput { 
	    id: eventListFramesIncrement
	    text: ""
	    visible: false
	}
	Timer {
	    id: playEventTimer
            interval: 1000; running: false; repeat: true
            onTriggered: { onPlayEventTimer(); }
	}

	MouseArea { anchors.fill:parent; }
	Row {
	    ListView {
		id: eventsView
		z: 0
		y: 20; x: 20
		width: 414; height: 350
		model: eventsModel
		delegate: eventsDelegate
//		highlight: Rectangle { color: "#333333"; radius: 5 }
//		highlightFollowsCurrentItem: false
//		focus: true
	    }
	    Column {
		Image {
		    id: eventView
		    width: 400; height: 400;
		    MouseArea { anchors.fill:parent; }
		}
		ProgressBar {
		    id: eventFrameBar
		    anchors.left: parent.left
		    height: 30
		    width: 400
		    minimum: 0
		    maximum: eventListTotalFrames.text
		    color: "#665555"
		    secondColor: "#887777"
		    value: eventListCurrentFrame.text
		}

	    }
	}

        Row {
	    anchors { left: parent.left; bottom: parent.bottom; margins: 20 }
            TextButton {
		anchors.horizontalCenter: parent.horizontalCenter
		width: 200
		height: 40
		text: "Back to Cameras"
		onClicked: { 
		    playEventTimer.running = false;
		    events.visible = false; 
		    currentmonitorimgtimer.running = true;
		    eventView.source = "";
		}
	    }
	}
    }

    /////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////

    Rectangle {
	id: busycontainer
	width: 100; height: 100
	x: 300; y:190; z:200;
	color: "#222222"
	visible : busy.on;

	BusyIndicator {
	    anchors.fill: parent
	    id: busy
	    on: false
	}
    }


    XmlListModel {
	id: resultsModel
//	query: "/ZM_XML/MONITOR_LIST/MONITOR"
	query: "/ZM_XML/MONITOR_LIST/MONITOR[STATE='OK']";
	
	XmlRole { name: "id";    query: "ID/string()" }
	XmlRole { name: "name";  query: "NAME/string()" }
	XmlRole { name: "camstate"; query: "STATE/string()" }

	
    }

    Component {
        id: listDelegate
        
        Item {
            id: delegateItem
            width: listView.width; height: 82
            clip: true

	    ListView.onAdd: { 
	    	if( currentMonitorID.text == "" )
	    	{
	    	    viewCamera( index );
	    	}
	    }

            Row {
		id: r
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

		Grid {
		    columns: 3
		    spacing: 10
		    Column {
			width: 96;
			Image {
			    width: 96; height: 82;
			    source: "images/events.png"
			    MouseArea { 
				anchors.fill:parent; 
				onClicked: viewEvents(index)
			    }
			}
		    }
		    Column {
			width: 96;
			Image {
			    width: 80;
			    height: 80;
			    source: "images/play.png"
			    MouseArea { 
				anchors.fill:parent; 
				onClicked: viewCamera(index)
			    }
			}
		    }

		    Column {
			Row {
			    Text { 
				width: 40
				text: id
				font.pixelSize: 15
				color: "white"
			    }
			    Text { 
				width: 70
				text: name
				font.pixelSize: 15
				color: { return camstate=="OK" ? "#aaffaa" : "#ff7777" }
				font.bold: { return camstate=="OK" }
				MouseArea { 
				    anchors.fill:parent; 
				    onClicked: viewCamera(index) 
				}

			    }
			}
			Text { 
			    width: 110
			    text: camstate
			    font.pixelSize: 15
			    color: "white"
			}
		    }


		    // Column {
		    // 	Text { 
		    // 	    text: url
		    // 	    font.pixelSize: 15
		    // 	    color: "white"
		    // 	}
		    // 	Text { 
		    // 	    text: { return resultsModel.get(index).annotation; }
		    // 	    font.pixelSize: 20
		    // 	    font.bold: true
		    // 	    color: "white"
		    // 	}
		    // }

		}
	    }
	}
    }

    Rectangle {
    	x: 0
    	y: 0
    	width: 854
    	height: 40
    	z: 1
    	gradient: Gradient {
    	    GradientStop { position: 0.0;  color: "#111111" }
    	    GradientStop { position: 0.6;  color: "#222222" }
    	    GradientStop { position: 1.0;  color: "#222222" }
    	}
    }

    Column {
	id: searchcol
	z: 20
	visible : false
	Row {
	    z: 20
	    Text { 
		z: 20
		text: "Search:" 
		color: "#ddddaa"
		font.pixelSize: 30
	    }
	    TextInput { 
		id: query
		z: 20
		width: 400
		color: "#ddddaa"
		text: "           " 
		font.pixelSize: 30
		height: 40
		onAccepted: { 
		    closeSoftwareInputPanel(); 
		    listView.forceActiveFocus(); 
		    busy.on = true; 
		}
	    }
	    

	}
    }


    Row {

	ListView {
            id: listView
	    z: 0
	    y: 60; x: 20
	    width: 414; height: 350
            model: resultsModel
            delegate: listDelegate
	}

	Image {
	    id: preview
	    source: ""
	    width: 400; height: 400;
	    MouseArea { anchors.fill:parent; }
	}


    }

    Rectangle {
	x: 0
	y: 430
	width: 854
	height: 50
	z: 1
	gradient: Gradient {
	    GradientStop { position: 0.0;  color: "#222222" }
	    GradientStop { position: 0.2;  color: "#222222" }
	    GradientStop { position: 1.0;  color: "#111111" }
	}
    }

    Row {
        anchors { left: parent.left; bottom: parent.bottom; margins: 20 }
        spacing: 10
	z: 20
	Text { 
	    id: statuscount
	    text: "        " 
	    color: "#ddddaa"
	    font.pixelSize: 22
	}

	Text { 
	    id: status
	    text: "" 
	    color: "#aaaaaa"
	    font.pixelSize: 22
//	    anchors.fill : parent
//	    anchors.right : parent
	}

        TextButton {
	    height: 30
	    width:  130
	    text: "Config"
	    onClicked: config.visible = true	    
	}


	Timer {
	    id: twosecspin
            interval: 2000; running: false; repeat: false
            onTriggered: { busy.on = false; }
	}
	Timer {
	    id: currentmonitorimgtimer
            interval: 2000; running: true; repeat: true
            onTriggered: { updateCurrentCameraView(); }
	}
    }

    function updateCameraList()
    {
 	var earl = serverURL.text + "/index.php";
	earl = earl + "?skin=xml";
	earl = earl + "&view=console";
	earl = earl + "&numEvents=25";
	earl = earl + "&foo=bar"

	var data = {};
	console.log('calling earl:' + earl)
	Ajaxmee.ajaxmee('GET', earl, data,
		function(data) {
		    busy.on = false;
		    console.log('ok', 'data:' + data)
		    resultsModel.xml = data;
		    eventsModel.xml = data;
		    var resultCount = 0;
		    statusToNow();
		    statuscount.text = "" + resultCount + " Results";
		},
		function(status, statusText) {
		    busy.on = false;
		    console.log('error', status, statusText)
		})
    }    

    function viewCamera( x ) 
    {
	var monitorid = resultsModel.get(x).id;
	currentMonitorID.text = monitorid;
	updateCurrentCameraView();
    }

    function viewEvents( x ) 
    {
	var monitorid = resultsModel.get(x).id;
	events.visible = true;
	currentmonitorimgtimer.running = false;

	eventListForMonitorID.text = monitorid;
	eventsModel.query = "/ZM_XML/MONITOR_LIST/MONITOR[ID=" + monitorid + "]/EVENTS/EVENT";

//	console.log("top id:" + eventsModel.get(1).id );
//	currentMonitorID.text = monitorid;
//	updateCurrentCameraView();
    }

    function playEvent( x ) 
    {
	var monitorid = eventListForMonitorID.text;
	var eventid   = eventsModel.get(x).id;
	var fps       = eventsModel.get(x).fps;
	var frames    = eventsModel.get(x).frames;

	eventListCurrentEventID.text = eventid;
	eventListCurrentFrame.text = 0;
	eventListTotalFrames.text = frames;
	eventListFramesIncrement.text = fps;
	onPlayEventTimer();
	playEventTimer.running = true;
    }

    function onPlayEventTimer() 
    {
	var eventid   = eventListCurrentEventID.text;
	var frame     = Math.floor(eventListCurrentFrame.text);
	frame += Math.floor(eventListFramesIncrement.text);
	if( frame > eventListTotalFrames.text )
	    frame = 0;
	eventListCurrentFrame.text = frame;

 	var earl      = serverURL.text + "/index.php";
	earl = earl + "?skin=xml";
	earl = earl + "&view=actions";
	earl = earl + "&action=vframe";
	earl = earl + "&eid=" + eventid;
	earl = earl + "&frame=" + frame;
	earl = earl + "&foo=bar"
	console.log("URL:    " + earl );
	eventView.source = earl;
    }

    function updateCurrentCameraView() 
    {
	var monitorid = currentMonitorID.text;
	if( monitorid == "" )
	    return;

 	var earl = serverURL.text + "/index.php";
	earl = earl + "?skin=xml";
	earl = earl + "&view=actions";
	earl = earl + "&action=feed";
	earl = earl + "&monitor=" + monitorid;
	earl = earl + "&vcodec=mjpeg";
	earl = earl + "&fps=0";
	earl = earl + "&foo=bar"
	console.log( "play URL:   " + earl );

	var data = {};
	console.log('calling earl:' + earl)
	Ajaxmee.ajaxmee('GET', earl, data,
		function(data) {
		    busy.on = false;
//		    console.log('ok', 'data:' + data)

		    // "liveStream" src="
		    var img = data.match(/liveStream" src="([^"]*)"/m)[1];
		    img = img.replace(/&amp;/g,'&');
		    console.log('img URL:' + img)
		    preview.source = img;
		    statusToNow();
		},
		function(status, statusText) {
		    busy.on = false;
		    console.log('error', status, statusText)
		})
    }


    function statusToNow() 
    {
	var data;
	status.text = "Updated at:" + formatDate( new Date() );
    }


    function startupFunction() 
    {
	status.text = "started";
	statusToNow();

        Storage.initialize();
	serverURL.text = Storage.getSetting( "serverurl" );
	password.text  = Storage.getSetting( "password" );
	username.text  = Storage.getSetting( "username" );

 	var earl = serverURL.text + "/index.php";
	earl = earl + "?action=login";
	earl = earl + "&username=" + username.text;
	earl = earl + "&password=" + password.text + "&foo=bar"

	busy.on = true;
	var data = {};
	console.log('calling earl:' + earl)
	Ajaxmee.ajaxmee('GET', earl, data,
		function(data) {
		    updateCameraList();
		},
		function(status, statusText) {
		    busy.on = false;
		    console.log('error', status, statusText)
		})

    }
    Component.onCompleted: startupFunction();

    function formatsz( sz ) {
	if( !sz ) { 
	    return " ";
	}
	if( sz > 1024 * 1024 * 1024 ) {
	    return Number( (sz / (1024 * 1024 * 1024))).toFixed(1) + "g";
	}
	if( sz > 1024 * 1024 ) {
	    return Number( (sz / (1024 * 1024))).toFixed(1) + "m";
	}
	if( sz > 1024 ) {
	    return Number( (sz / 1024)).toFixed(1) + "k";
	}
	return Number( sz ).toFixed(0) + "b";
    }

    function formatDate( d ) {
	var extension = "th ";
	var day = d.getDate();
	if( day == 1 || day == 11 || day == 21 || day == 31 )
	    extension = "st ";
	if( day == 2 || day == 12 || day == 22 )
	    extension = "nd ";
	if( day == 3 || day == 13 || day == 23 )
	    extension = "rd ";
	var dateStr = padStr(d.getDate()) + "th "
            + padStr(d.getHours()) + ":"
            + padStr(d.getMinutes());
	return dateStr;
    }

    function padStr(i) {
	return (i < 10) ? "0" + i : "" + i;
    }
}


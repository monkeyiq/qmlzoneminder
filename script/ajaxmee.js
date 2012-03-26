var ajaxmee_id = 1;

var ajaxmee = function(method, url, params, successCallback, errorCallback) {

    var size = function(ar) {
        var len = ar.length ? --ar.length : -1;
            for (var k in ar) {
                len++;
            }
        return len;
    }

    var serialize = function(obj, prefix) {
        var str = [];
        for(var p in obj) {
            var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
            str.push(typeof v == "object" ?
                serialize(v, k) :
                encodeURIComponent(k) + "=" + encodeURIComponent(v));
        }
        return str.join("&");
    }

    var init = function(method, url, params, successCallback, errorCallback) {

//	var json = {"method":"auth.login","params":["xxx"],"id":3};
	var json = params;
	ajaxmee_id++;
	params['id'] = ajaxmee_id;
	var params = JSON.stringify( json );

// //	params = '{"success"}';
// //	params = JSON.stringify(['e', {pluribus: 'unum'}]);
// 	console.log("testing1.")
// 	console.log("testing params:" + params )
// 	var a = 2;
// 	eval( "a=1" );
// 	console.log("testing2.")
// //        params = serialize(params)
// 	console.log("ajaxme.params:" + params)

        var doc = new XMLHttpRequest();
        console.log(method + " " + url);
        if (method == 'GET') {
            url = url +'?'+ params
            params = ''
        }

        doc.onreadystatechange = function() {

            if (doc.readyState == XMLHttpRequest.UNSENT) {
//		console.log('unsent')
	    }
            if (doc.readyState == XMLHttpRequest.OPENED) {
//		console.log('opened!')
	    }
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                var status = doc.status;
//		console.log('status', status)
                if(status!=200) {
                    errorCallback(status, doc.statusText)
                }
            }
	    if (doc.readyState == XMLHttpRequest.DONE) {
//		console.log('status-done:', doc.status)

//		console.log( "headers: " + doc.getAllResponseHeaders () );
                var data;
                var contentType = doc.getResponseHeader("Content-Type");
                data = doc.responseText;
//		console.log('ct-done:', contentType)
                successCallback(data);
            }
        }

//	console.log( "method: " + method + " url: " + url )
        doc.open(method, url);
        if (params.length > 0) {
            doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            doc.setRequestHeader("Content-Length", String(params.length));
            doc.send(params);
        } else {
            doc.send();
        }
    }

    init(method, url, params, successCallback, errorCallback);
}

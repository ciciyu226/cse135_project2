
//var productHeader = document.getElementById('salesTable').rows[0].cells;



function getXML(){
	console.log("POINT A");
	var xmlHttp = new XMLHttpRequest();
	xmlHttp.onreadystatechange = function() {
		if(xmlHttp.readyState == 4 && xmlHttp.status == 200){
			console.log("DOING doUpdate");
			doUpdate(xmlHttp);
		}	
	};
	console.log("POINT B");
	xmlHttp.open("GET", "getUpdateXML.jsp", true);
	//xmlHttp.reponseType='document';
	//xmlHttp.overrideMimeType('text/xml');
	xmlHttp.send();
	console.log("POINT C");
}

function doUpdate(xml){	
	var currRow = 0; //get from json
	var currColumn = 0; //get from json
	var currCell = null;
	var totalSale = 0; //get from json
	
	var currProductHeaderID;
	var currProductHeaderName;
	var currProductHeaderValue;	
	var currStateHeaderID;
	var currStateHeaderName;
	var currStateHeaderValue;	
	var currInnerCellID;
	var currInnerCellValue;
	
	var xmlDoc = xml.responseXML.documentElement;
	var rows = xmlDoc.getElementsByTagName("currentRow");
	//TODO: Change color of number to red while the cell is updated
	//TODO: if some top 50 product ranks lower than 50, make the entire column purple,
	//and add a sentence saying the new top50 product and its total sale.
	
	//added
	var numOfProducts = rows.length/56;
	var state_update = false;
	//console.log(xmlDoc);
	
	//loop over all updated products
	for (var i = 0; i < rows.length; i++){
		
		if(i%numOfProducts == 0){ //Next state
			state_update = false;
		}
		
		currProductHeaderID = xmlDoc.getElementsByTagName("productHeaderCellID")[i].firstChild.nodeValue;	
		currProductHeaderName = xmlDoc.getElementsByTagName("productHeaderName")[i].firstChild.nodeValue;
		currProductHeaderValue = xmlDoc.getElementsByTagName("productHeaderValue")[i].firstChild.nodeValue;
		currStateHeaderID = xmlDoc.getElementsByTagName("stateHeaderCellID")[i].firstChild.nodeValue;
		currStateHeaderName = xmlDoc.getElementsByTagName("stateHeaderName")[i].firstChild.nodeValue;
		currStateHeaderValue = xmlDoc.getElementsByTagName("stateHeaderValue")[i].firstChild.nodeValue;
		currInnerCellID = xmlDoc.getElementsByTagName("innerCellID")[i].firstChild.nodeValue;
		currInnerCellValue = xmlDoc.getElementsByTagName("innerCellValue")[i].firstChild.nodeValue;
		
		//Check top products only


		//update the cells if needed
		if(document.getElementById(currInnerCellID) != null){
			console.log("not null");
			if( document.getElementById(currInnerCellID).innerHTML < currInnerCellValue){
				document.getElementById(currInnerCellID).innerHTML = currInnerCellValue;
				if(i%numOfProducts>50){
					//it is not top 50 prod
					document.getElementById(currInnerCellID).style.color = "purple";
				}
				else{
					document.getElementById(currInnerCellID).style.color = "red";
				}
			}
			else{
				document.getElementById(currInnerCellID).style.color = "black";
			}
		}
		//Handle state headers
		if(document.getElementById(currStateHeaderID).children[2].innerHTML < currStateHeaderValue){
			document.getElementById(currStateHeaderID).children[0].innerHTML = currStateHeaderName;
			document.getElementById(currStateHeaderID).children[2].innerHTML = currStateHeaderValue;
			document.getElementById(currStateHeaderID).children[2].style.color = "red";
			state_update = true;
		}
		else if( state_update == false && document.getElementById(currStateHeaderID).children[2].innerHTML == currStateHeaderValue){
			document.getElementById(currStateHeaderID).children[2].style.color = "black";
		}
		//Handle product headers
		/*
		if( i<numOfProducts ){
			if( document.getElementById(currProductHeaderID).children[2].innerHTML < currProductHeaderValue && i<50){
				document.getElementById(currProductHeaderID).children[0].innerHTML = currProductHeaderName;
				document.getElementById(currProductHeaderID).children[2].innerHTML = currProductHeaderValue;
				document.getElementById(currProductHeaderID).children[2].style.color = "red"
			}
			else if( document.getElementById(currProductHeaderID).children[2].innerHTML < currProductHeaderValue && i >= 50 ){
				document.getElementById(currProductHeaderID).children[0].innerHTML = currProductHeaderName;
				document.getElementById(currProductHeaderID).children[2].innerHTML = currProductHeaderValue;
				document.getElementById(currProductHeaderID).children[2].style.color = "purple"
			}
			else{
				document.getElementById(currProductHeaderID).children[2].style.color = "black"
			}
		} */
	}
}
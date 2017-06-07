
//var productHeader = document.getElementById('salesTable').rows[0].cells;



function getXML(){
	var xmlHttp = new XMLHttpRequest();
	xmlHttp.onreadystatechange = function() {
		if(xmlHttp.readyState == 4 && xmlHttp.status == 200){
			doUpdate(xmlHttp);
		}	
	};
	xmlHttp.open("GET", "getUpdateXML.jsp", true);
	xmlHttp.send();
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

	//loop over all updated products
	for (var i = 0; i < rows.length; i++){		
		currProductHeaderID = xmlDoc.getElementsByTagName("productHeaderCellID")[i].firstChild.nodeValue;	
		currProductHeaderName = xmlDoc.getElementsByTagName("productHeaderName")[i].firstChild.nodeValue;
		currProductHeaderValue = xmlDoc.getElementsByTagName("productHeaderValue")[i].firstChild.nodeValue;
		
		currStateHeaderID = xmlDoc.getElementsByTagName("stateHeaderCellID")[i].firstChild.nodeValue;
		currStateHeaderName = xmlDoc.getElementsByTagName("stateHeaderName")[i].firstChild.nodeValue;
		currStateHeaderValue = xmlDoc.getElementsByTagName("stateHeaderValue")[i].firstChild.nodeValue;
		
		currInnerCellID = xmlDoc.getElementsByTagName("innerCellID")[i].firstChild.nodeValue;
		currInnerCellValue = xmlDoc.getElementsByTagName("innerCellValue")[i].firstChild.nodeValue;
		
		//update the cells if needed
		if(document.getElementByID(currInnerCellID).innerHTML != currInnerCellValue){
			document.getElementByID(currInnerCellID).innerHTML = currInnerCellValue;
			document.getElementByID(currInnerCellID).style.color = "red";
			
			document.getElementByID(currProductHeaderID).children[0].innerHTML = currProductHeaderName;
			document.getElementByID(currProductHeaderID).children[1].innerHTML = currProductHeaderValue;
			document.getElementByID(currProductHeaderID).children[1].style.color = "red";
			
			document.getElementByID(currStateHeaderID).children[0].innerHTML = currStateHeaderName;
			document.getElementByID(currStateHeaderID).children[1].innerHTML = currStateHeaderValue;
			document.getElementByID(currStateHeaderID).children[1].style.color = "red";

		}
	}
//		var products = document.getElementByClassName("products");
//		while(var i = 0; i < 50 ; i++) {
//			if(){
//			products[i].children[0].innerHTML
//			}
//		}
//		if(product.isNewTop50){
//		   document.getElementById('newProduct').innerHTML("The new top 50 product is: " + product.name + " And its sales is " + product.total);
//		}	
	
}
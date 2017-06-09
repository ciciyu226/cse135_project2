//var productHeader = document.getElementById('salesTable').rows[0].cells;



function getXML(cat){
	console.log("POINT A");
	var xmlHttp = new XMLHttpRequest();
	xmlHttp.onreadystatechange = function() {
		if(xmlHttp.readyState == 4 && xmlHttp.status == 200){
			console.log("DOING doUpdate");
			doUpdate(xmlHttp,cat);
		}	
	};
	console.log("POINT B");
	xmlHttp.open("GET", "getUpdateXML.jsp", true);
	//xmlHttp.reponseType='document';
	//xmlHttp.overrideMimeType('text/xml');
	xmlHttp.send();
	console.log("POINT C");
}

function doUpdate(xml,cat){	
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
	
	var currProductHeaderID1;
	var currProductHeaderName1;
	var currProductHeaderValue1;
	
	var xmlDoc = xml.responseXML.documentElement;
	var rows = xmlDoc.getElementsByTagName("currentRow");
	var productHeaders = xmlDoc.getElementsByTagName("currentProduct");
	var categoryHeaders = xmlDoc.getElementsByTagName("currentState");
	//TODO: Change color of number to red while the cell is updated
	//TODO: if some top 50 product ranks lower than 50, make the entire column purple,
	//and add a sentence saying the new top50 product and its total sale.
	
	//added
	var numOfProducts = rows.length/56;
	var state_update = false;
	var purple_tracker = [];
	var counter = 0;
	var counter1 = 0;
	//console.log(xmlDoc);
	
	//loop over all updated products
	
		
		//Check top products only
  if(cat == -1){
		//Handle product headers for all products
	for (var j = 0 ; j < productHeaders.length; j++ ){
		currProductHeaderID1 = xmlDoc.getElementsByTagName("productHeaderCellID1")[j].firstChild.nodeValue;	
		currProductHeaderName1 = xmlDoc.getElementsByTagName("productHeaderName1")[j].firstChild.nodeValue;
		currProductHeaderValue1 = xmlDoc.getElementsByTagName("productHeaderValue1")[j].firstChild.nodeValue;
				if(j<50) {
					if(document.getElementById(currProductHeaderID1) != null){ //if current xml product found in html table
						if(document.getElementById(currProductHeaderID1).children[2].innerHTML< currProductHeaderValue1){
							document.getElementById(currProductHeaderID1).children[2].innerHTML = currProductHeaderValue1;
							document.getElementById(currProductHeaderID1).style.color = "black";
							document.getElementById(currProductHeaderID1).children[2].style.color = "red";
							//TODO: IF CHANGED TO RED, NEVER CHANGE BACK TO BLACK AGAIN
							
						}else if (document.getElementById(currProductHeaderID1).children[2].innerHTML ==  currProductHeaderValue1){
							
							document.getElementById(currProductHeaderID1).style.color = "black";
							
						}
					}else {  //else if current xml product is not found in the html table, meaning that this product is now in top-50.
						var li = document.createElement('li');
						li.textContent = "New top-50 product: " + currProductHeaderName1 + " Total sale: " + currProductHeaderValue1;
						document.getElementById("newProduct").appendChild(li);
					}
				}else if (j>= 50) {
					if(document.getElementById(currProductHeaderID1) != null) {
						document.getElementById(currProductHeaderID1).style.color = "purple";
						purple_tracker.push(currProductHeaderID1);
						if(document.getElementById(currProductHeaderID1).children[2].innerHTML< currProductHeaderValue1){
							document.getElementById(currProductHeaderID1).children[2].innerHTML = currProductHeaderValue1;
						}
					}
				}		
	}	
  }
	else if (cat != -1) { //handle product headers when category is selected
		for(j = 0; j < productHeaders.length; j++){
			var currCategory = xmlDoc.getElementsByTagName("productCategoryID")[j].firstChild.nodeValue;	
			if(cat == currCategory){
				console.log("currCategory= " + currCategory);
				currProductHeaderID1 = xmlDoc.getElementsByTagName("productHeaderCellID1")[j].firstChild.nodeValue;	
				currProductHeaderName1 = xmlDoc.getElementsByTagName("productHeaderName1")[j].firstChild.nodeValue;
				currProductHeaderValue1 = xmlDoc.getElementsByTagName("productHeaderValue1")[j].firstChild.nodeValue;
				if(counter< 50){
					if(document.getElementById(currProductHeaderID1) != null){ //if current xml product found in html table
						if(document.getElementById(currProductHeaderID1).children[2].innerHTML< currProductHeaderValue1){
							document.getElementById(currProductHeaderID1).children[2].innerHTML = currProductHeaderValue1;
							document.getElementById(currProductHeaderID1).style.color = "black";
							document.getElementById(currProductHeaderID1).children[2].style.color = "red";
							//TODO: IF CHANGED TO RED, NEVER CHANGE BACK TO BLACK AGAIN
							
						}else if (document.getElementById(currProductHeaderID1).children[2].innerHTML ==  currProductHeaderValue1){
							document.getElementById(currProductHeaderID1).style.color = "black";
							
						}
						
					}else {  //else if current xml product is not found in the html table, meaning that this product is now in top-50.
						var li = document.createElement('li');
						li.textContent = "New top-50 product: " + currProductHeaderName1 + " Total sale: " + currProductHeaderValue1;
						document.getElementById("newProduct").appendChild(li);
						//document.getElementById("newProduct").innerHTML += "New top-50 product: " + currProductHeaderName1 + " Total sale: " + currProductHeaderValue1;
						//document.getElementById("newProduct").style.display = "block";
					}
				}else if (counter>= 50) {
					if(document.getElementById(currProductHeaderID1) != null) {
						document.getElementById(currProductHeaderID1).style.color = "purple";
						purple_tracker.push(currProductHeaderID1);
						if(document.getElementById(currProductHeaderID1).children[2].innerHTML< currProductHeaderValue1){
							document.getElementById(currProductHeaderID1).children[2].innerHTML = currProductHeaderValue1;
						}
					}
				}
			
				counter++;
			}
		}
	}
	console.log("NUM OF ROWS: " + rows.length);

	   if(cat != -1){ 
			outerLoop:
		   for (var s = 0; s < categoryHeaders.length; s++){ 
				var currStateCategory = xmlDoc.getElementsByTagName("stateCategoryID")[s].firstChild.nodeValue;
				if(cat == currStateCategory){ 
					
					for(counter1 = 0; counter1 < 56; counter1++){ 
							currStateHeaderID = xmlDoc.getElementsByTagName("stateHeaderCellID1")[s+counter1].firstChild.nodeValue;
							currStateHeaderValue = xmlDoc.getElementsByTagName("stateHeaderValue1")[s+counter1].firstChild.nodeValue;
							console.log("Curr header Cell ID is: " + currStateHeaderID );
							console.log( "CURRValue IS :" + currStateHeaderValue);
							
						if(document.getElementById(currStateHeaderID).children[2].innerHTML < currStateHeaderValue){
							console.log("current state's total sale should increase");
							document.getElementById(currStateHeaderID).children[2].innerHTML = currStateHeaderValue;
							document.getElementById(currStateHeaderID).children[2].style.color = "red";
						}
						else{
							console.log("No sale occurs for current state, it should stay the same");
							document.getElementById(currStateHeaderID).children[2].style.color = "black";
						}
					}
					break outerLoop;
				}
				
				
		    }
		}
	
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
		//update the cells if needed
		if(document.getElementById(currInnerCellID) != null){
		
			//console.log("CELL IS: " + document.getElementById(currInnerCellID));
			//console.log("XML cell ID and value :" + currInnerCellID + " " + currInnerCellValue);
			//console.log("not null");
			
			if( document.getElementById(currInnerCellID).innerHTML < currInnerCellValue){
				document.getElementById(currInnerCellID).innerHTML = currInnerCellValue;
				document.getElementById(currInnerCellID).style.color = "red";
				//console.log("XML cell ID and value :" + currInnerCellID + " " + currInnerCellValue + " red");
			}
			else{
				document.getElementById(currInnerCellID).style.color = "black";
				//console.log("XML cell ID and value :" + currInnerCellID + " " + currInnerCellValue + " blk");
				if(purple_tracker.includes(currProductHeaderID)){
					document.getElementById(currInnerCellID).style.color = "purple";
				}
			}

		}
		
		//Handle state headers
		if(cat==-1){
		if(document.getElementById(currStateHeaderID).children[2].innerHTML < currStateHeaderValue){
			document.getElementById(currStateHeaderID).children[0].innerHTML = currStateHeaderName;
			document.getElementById(currStateHeaderID).children[2].innerHTML = currStateHeaderValue;
			document.getElementById(currStateHeaderID).children[2].style.color = "red";
			state_update = true;
		}
		else if( state_update == false && document.getElementById(currStateHeaderID).children[2].innerHTML == currStateHeaderValue){
			document.getElementById(currStateHeaderID).children[2].style.color = "black";
		}
		}
	} 

	
}
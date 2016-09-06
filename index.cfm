<html> 
  <head>
   <title>Engineering Technical Test 2 - Amaysim</title>
   <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
   <script src="https://code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>
   <link rel="stylesheet" type="text/css" href="https://code.jquery.com/ui/1.12.0/themes/base/jquery-ui.css">   
   <style>
    body {font-family: Arial, Verdana, Calibri}
    fieldset { border: 0;}
    label { display: block;margin: 0;}
   </style>
  </head>
  <!--- Item Product Selection --->
  <body>
   <div>
    <div style="float:left">
    <fieldset>
     <label for="productCode">Product</label>
     <select id="productCode">
      <option disabled>Select a Product</option>
      <option value="ult_small">Unlimited 1GB</option>
      <option value="ult_medium">Unlimited 2GB</option>
      <option value="ult_large">Unlimited 5GB</option>
      <option value="1gb">1 GB Data-pack</option>    
     </select>
     </fieldset>
    </div>
    <div  style="float:left">
     <fieldset>
      <label for="prodQty">Quantity</label>
      <input type="text" id="prodQty" value="0">
     </fieldset>
    </div>
    <div  style="float:left">
     <fieldset>      
      <button id="addProd" onclick="getProduct();">Add Product</button>
     </fieldset>
    </div>
   </div>
   <div style="clear:both">&nbsp;</div>
   <div>
    <div  style="float:left">
     <fieldset>
      <label for="pCode">Promo Code</label>
      <input type="text" id="pCode">
     </fieldset>
    </div>
    <div  style="float:left">
     <fieldset>      
      <button id="applyPCode" onclick="applyPCode();">Apply Promo Code</button>
     </fieldset>
    </div>
   </div>
   <div style="clear:both">&nbsp;</div>
   <div>
    <div>
     <fieldset>      
      <button id="btnClearItems" onclick="clearItems();">Clear</button>
     </fieldset>
    </div>
   </div>
   <div style="clear:both">&nbsp;</div>
   <!--- Product Table --->
   <table border="0" style="border:1px solid black">
    <thead>
     <tr>
      <th style="width:200px">Items</th>
      <th>Total</th>
     </tr>
    </thead>
    <tbody id="cart-items"></tbody>
    <tfoot>
     <tr>
      <td style="border-top: 1px black solid;">Total Amount</td>
      <td style="border-top: 1px black solid;font-weight:bold;text-align:right" id="tAmout"></td>
     </tr>
    </tfoot>
   </table> 


  <script language="javascript">
   var cartArray = [];
   function clearItems() {
    cartArray = [];
    $("#cart-items").empty();
    $("#tAmout").text("");
    return ;
   }
   
   function applyPCode() {
    var prCode = $("#pCode").val(); 
    var iExists = false;
     $.each(cartArray, function(i, e){
      if(prCode == e.productCode){
        iExists = true; 
	return false;
      }
    });
    if(!iExists){
     var obj= {
       "prodCode": prCode, 
       "iQty": 1, 
       "iMethod":"getProductSpecs"};
     $.ajax({
       url: 'api/getProduct.cfm',
       type: 'POST',
       contentType: 'application/JSON',
       dataType: 'json',
       data: JSON.stringify(obj),
       success: function (data1) {
        data1 = data1[0];
        $.each(data1, function(i, e){
         updateCart(cartArray, e);
        });
	createDataTable();
       },
       error:function (data1) {}});
    }
    $("#pCode").val('');
   }
   
   function getProduct() {
    var pcode = $("#productCode").val();
    var pQty = $("#prodQty").val();
    $.each(cartArray, function(i, e){
      if(pcode == e.productCode){
        pQty = parseInt(pQty)+parseInt(e.productQty);
      }
    });
    var obj= {
       "prodCode": pcode, 
       "iQty": pQty, 
       "iMethod":"getProductSpecs"};
     $.ajax({
       url: 'api/getProduct.cfm',
       type: 'POST',
       contentType: 'application/JSON',
       dataType: 'json',
       data: JSON.stringify(obj),
       success: function (data1) {
        data1 = data1[0];
        $.each(data1, function(i, e){
         updateCart(cartArray, e);
        });
	createDataTable();
       },
       error:function (data1) {}});
       $("#productCode").val('');
       $("#prodQty").val('');
     }
    
    function updateCart(oArray, iElem) {
      var retExists=false;
      $.each(oArray, function(i, e){
        if(iElem.productCode == e.productCode){
          retExists=true;
          e.productTotAmt = iElem.productTotAmt;
	  e.productQty = iElem.productQty;
        }
      });
      if(!retExists) oArray.push(iElem);
    }

    function createDataTable() {
      var totAmt=0.0;
      var pcodeApplied = 0;
      $("#cart-items").empty();
      $.each(cartArray, function(i, e){
        if(e.productType != "prod-promo") totAmt=parseFloat(totAmt) + parseFloat(e.productTotAmt);
	else pcodeApplied = parseFloat(e.productTotAmt)/100;
        if(e.productType != "prod-promo")  { 
	 if(e.productType == "prod-item") $("#cart-items").append("<tr><td>" + e.productQty + "x " + e.productName + "</td><td style='text-align:right'>" + parseFloat(e.productTotAmt).toFixed(2) + "</td></tr>");
	 else $("#cart-items").append("<tr><td>" + e.productQty + "x " + e.productName + "</td><td style='text-align:right'>&nbsp;</td></tr>");
	} else {
	      $("#cart-items").append("<tr><td>" + e.productName + "</td><td style='text-align:right'>&nbsp;</td></tr>");
	}
      });
      if(pcodeApplied!=0) totAmt = parseFloat(totAmt) - parseFloat(totAmt*pcodeApplied);
      $("#tAmout").text(totAmt.toFixed(2));
    }
    

  </script>
  </body>
</html>
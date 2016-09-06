<cfcontent type="text/json">
 <cfset requestBody = toString( getHttpRequestData().content ) />  
 <cfset data = []/>
 <cfprocessingdirective suppresswhitespace="Yes">
 <cfif isJSON( requestBody )> 
   <!--- get  JSON request --->
   <cfset cfData=DeserializeJSON(requestBody)>
   <cfset productCode= structkeyExists(cfData, "prodCode")?#cfData["prodCode"]#:"">
   <cfset iMethod = structkeyExists(cfData, "iMethod")?#cfData["iMethod"]#:"">
   <cfset iQty = structkeyExists(cfData, "iQty")?#cfData["iQty"]#:"1">
   <cfset iPromoCode = structkeyExists(cfData, "iPromoCode")?#cfData["iPromoCode"]#:"">
   
   <cfif iMethod NEQ "">
     <cfswitch expression="#Trim(iMethod)#">  
       <!--- getProductSpecs --->
       <cfcase value="getProductSpecs"> 
          <cfif productCode NEQ "">
           <cfset obj = getProductSpec("#Trim(productCode)#", iQty)>
           <cfset arrayAppend(data, obj) />
          <cfelse>
	   <cfset data = BadRequest("Invalid Request")>
	  </cfif>
       </cfcase>
       <cfcase value="applyPromoCode"> 
           <cfset obj = applyPromoCode("#Trim(iPromoCode)#")>
           <cfset arrayAppend(data, obj) />
       </cfcase>
      <!--- DEFAULTCASE --->
      <cfdefaultcase>
         <cfset data = BadRequest("Invalid Method")>
      </cfdefaultcase> 
     </cfswitch>
   <cfelse>
     <!--- Invalid Request --->
     <cfset data = BadRequest("Invalid Request")>
   </cfif>
 <cfelse>
   <!--- Invalid Request --->
   <cfset data = BadRequest("Invalid Request")>
 </cfif>
 <cfoutput>#serializeJSON(data)#</cfoutput>
 </cfprocessingdirective>

<!--- General Functions --->
 <cffunction name="BadRequest" output="false" access="public" returnType="array">
  <cfargument name="ServiceMessage" type="string" required="true" default="Invalid Request" />
  <cfset idata = []/>
  <cfset obj = {"response" = "#ServiceMessage#"} />
  <cfset arrayAppend(idata, obj) />
  <cfreturn idata>
 </cffunction>

 <cffunction name="applyPromoCode" output="false" access="public" returnType="array">
  <cfargument name="promoCode" type="string" required="true"/>
   <cfset idata = []/>
   <cfset pDisc = 0>
   <cfswitch expression="#Trim(productCode)#">   
    <cfcase value="I<3AMAYSIM"> 
      <cfset pDisc = 10>
    </cfcase>
   </cfswitch>
   <cfset obj = {"promoDisc" = #pDisc#}>
   <cfset arrayAppend(idata, obj) />
   <cfreturn idata>
 </cffunction>
 
 <cffunction name="getProductSpec" output="false" access="public" returnType="array">
  <cfargument name="productCode" type="string" required="true"/>
  <cfargument name="productQty" type="numeric" required="true"/>
  <cfset idata = []/>
   <cfswitch expression="#Trim(productCode)#">   
     <cfcase value="ult_small">
      <cfset usProdCode = "ult_small">
      <cfset usProdName = "Unlimited 1GB">
      <cfset itype = "prod-item">
      <cfset usProdPrice = 24.90>
      <cfset qty_limit = 3> <!--- limiter of how many items a product in a promo --->
      <cfset qty_disc = 2> <!--- quantity to be used if a promo is applied  --->

      <cfset dPQty = productQty \ qty_limit> 
      <cfset dRQty = productQty % qty_limit> 
      <cfset dTotAmt = ((usProdPrice*qty_disc)*dPQty) + (usProdPrice*dRQty)>
      <cfset obj = {
         "productCode" = "#usProdCode#",  
         "productName" = "#usProdName#",
	 "productType" = "#itype#",
         "productQty" = #productQty#,
         "productTotAmt" = #NumberFormat(dTotAmt,"9.99")#
       }>
     </cfcase>
     <cfcase value="ult_medium">
      <cfset umProdCode = "ult_medium">
      <cfset umProdName = "Unlimited 2GB">
      <cfset itype = "prod-item">
      <cfset umProdPrice = 29.90>
      <!--- add ult_medium --->
      <cfset dTotAmt = umProdPrice*productQty>        
      <cfset obj = {
         "productCode" = "#umProdCode#",  
         "productName" = "#umProdName#",
	 "productType" = "#itype#",
	 "productQty" = #productQty#,
         "productTotAmt" = #NumberFormat(dTotAmt,"9.99")#
       }>
      <cfset arrayAppend(idata, obj) />
      <cfset obj = {
         "productCode" = "1gb",  
         "productName" = "1 GB Data-pack",
	 "productType" = "prod-item-promo",
	 "productQty" = #productQty#,
         "productTotAmt" = 0
       }>
     </cfcase>
     <cfcase value="ult_large">
      <cfset ulProdCode = "ult_large">
      <cfset ulProdName = "Unlimited 5GB">
      <cfset itype = "prod-item">
      <cfset ulProdPrice = 44.90> <!--- regular price --->
      <cfset ulDiscPrice = 39.90> <!--- discounted price --->
      <cfset qty_limit = 3> <!--- limiter of how many items a product in a promo --->

      <cfif productQty GT qty_limit>
       <cfset dTotAmt = ulDiscPrice*productQty>        
      <cfelse>
       <cfset dTotAmt = ulProdPrice*productQty> 
      </cfif>
      <cfset obj = {
         "productCode" = "#ulProdCode#",  
         "productName" = "#ulProdName#",
	 "productType" = "#itype#",
	 "productQty" = #productQty#,
         "productTotAmt" = #NumberFormat(dTotAmt,"9.99")#
       }>
     </cfcase>
     <cfcase value="1gb">
      <cfset u1GProdCode = "1gb">
      <cfset u1GProdName = "1 GB Data-pack">
      <cfset itype = "prod-item">
      <cfset u1GProdPrice = 9.90> <!--- regular price --->
      <cfset dTotAmt = u1GProdPrice*productQty>
      <cfset obj = {
         "productCode" = "#u1GProdCode#",  
         "productName" = "#u1GProdName#",
	 "productType" = "#itype#",
	 "productQty" = #productQty#,
         "productTotAmt" = #NumberFormat(dTotAmt,"9.99")#
       }>
     </cfcase>
     <cfcase value="I<3AMAYSIM">
      <cfset u1GProdCode = "I<3AMAYSIM">
      <cfset u1GProdName = "'I<3AMAYSIM' Promo Applied">
      <cfset itype = "prod-promo">
      <cfset u1GProdPrice = 10> 
      <cfset obj = {
         "productCode" = "#u1GProdCode#",  
         "productName" = "#u1GProdName#",
	 "productType" = "#itype#",
	 "productQty" = #productQty#,
         "productTotAmt" = #NumberFormat(u1GProdPrice,"9.99")#
       }>
     </cfcase>
   </cfswitch> 
   <cfset arrayAppend(idata, obj) />
  <cfreturn idata>
 </cffunction>
<%@page import="ucsd.shoppingApp.*, java.util.*, java.sql.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.sql.Connection, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Online Shopping Application</title>
</head>
<body>
	<%
//Check to see if logged in or not.
if(session.getAttribute("personName")==null) {
	session.setAttribute("error","PLEASE LOG IN BEFORE ENTERING OTHER PAGES");
	response.sendRedirect("login.jsp");
	return;
}
//Check to see role
%>
<div class="wrapper">
  <header>
  	<h2>Hello <%=session.getAttribute("personName") %>!</h2>
  </header>
  <main>
  
    <%-- Import the java.sql package --%>
    <%@ page import="java.sql.*"%>
    <%-- -------- Open Connection Code -------- --%>
    <%
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    PreparedStatement pstmt1 = null;
    PreparedStatement pstmt2 = null;
    PreparedStatement pstmt3 = null;
    PreparedStatement pstmt3_product = null;
    Statement statement4 = null;

    ResultSet rs = null;
    ResultSet rs3 = null;
    ResultSet rs4 = null;
    ResultSet rs_row = null;
    ResultSet rs_product = null;
    ResultSet rs3_product = null;
    int offset_row = 0;
    int offset_column = 0;    
    int row_size = 0;
	int product_size= 0;
    Boolean isCustomer = true;
    Boolean isState = false;
    Boolean isAlphabetical = true;
    Boolean isTopk = false;
    Boolean isCategory = false;
    String name = "";
    String currName = ""; 
    
    
    try {
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/postgres?" +
            "user=postgres&password=");
    	
        
       
        /*----------------------------Main Table------------------------------------------*/
        /*variables */
        String select_variable = "";
        String select_customer = " p.id AS person_id, p.person_name,";
        String select_state = " s.id AS state_id, s.state_name,";
        String select_category = " c.category_name,";
        
        String groupBy_variable = "";
        String groupBy_customer = " p.id,";
        String groupBy_state = " s.id,";
        String groupBy_category = "c.category_name,";
        
        String orderBy_variable = "";
        String orderBy_customer = " p.person_name,";
        String orderBy_state = " s.state_name,";
        
        String searchBy_variable = "";
        String searchByCustomerName = " AND p.person_name = ?";
        String searchByStateName = " AND s.state_name = ?";
        String searchByCategoryName = " AND c.category_name = ?";
        
        String join_variable ="";  /* customer uses this */
        String join_state = " INNER JOIN state s ON (s.id = p.id)";
        String join_category = " INNER JOIN category c ON (pd.category_id = c.id)";
        
        String searchByCat = " WHERE category_name = ?";
        
        String small_table_row = "";
        String small_table_column = "";
       
        /*--------------------CUSTOMER ----------------------- */
        /* Small table that applies sort_order: alphebatical + no sort_category on customer_query */
        String alpha_customer = " SELECT p.person_name AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN person p ON (T.person_name = p.person_name) GROUP BY p.person_name ORDER BY p.person_name";
        /* Small table that applies sort_order: Top-K + no sort_category on customer_query */
        String topk_customer=  "SELECT p.person_name AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN person p ON (T.person_name = p.person_name) GROUP BY p.person_name ORDER BY totalPerItem DESC NULLS LAST, p.person_name";
        /* Small table that applies sort_order: alphabetical + sort_category: a category on customer_query */
       
        
        /*--------------------STATE ----------------------- */       
       /* Small table that applies sort_order: alphabetical + NO sort_category on the big table state_query */
       String alpha_state = " SELECT s.state_name AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN state s ON (T.state_name = s.state_name) GROUP BY s.state_name ORDER BY s.state_name";
       /* Small table that applies sort_order: Top-K + NO sort_category on the big table state_query */
       String topk_state = " SELECT s.state_name AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN state s ON (T.state_name = s.state_name ) GROUP BY s.state_name ORDER BY totalPerItem DESC NULLS LAST, s.state_name";
       
       /*----------------------PRODUCT ----------------------*/
       String alpha_product = " SELECT LEFT(pd.product_name, 10) AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN product pd ON (T.product = pd.id) GROUP BY pd.product_name, pd.id ORDER BY pd.product_name, pd.id";
       
       String topk_product = " SELECT LEFT(pd.product_name, 10) AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN product pd ON (T.product = pd.id) GROUP BY pd.product_name, pd.id ORDER BY totalPerItem DESC NULLS LAST, pd.id";
       
       String cat_alpha_product = " SELECT LEFT(pd.product_name, 10) AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN product pd ON (T.product = pd.id) INNER JOIN category c ON (pd.category_id = c.id) WHERE c.category_name= ? GROUP BY pd.product_name, pd.id ORDER BY pd.product_name, pd.id";
       String cat_topk_product = " SELECT LEFT(pd.product_name, 10) AS name, SUM(total) AS totalPerItem FROM T RIGHT OUTER JOIN product pd ON (T.product = pd.id) INNER JOIN category c ON (pd.category_id = c.id) WHERE c.category_name = ? GROUP BY pd.product_name, pd.id ORDER BY totalPerItem DESC NULLS LAST, pd.id";

        
        
       /* set default options: customer, alphabetical, no category */
	   	select_variable = select_customer;
	   	groupBy_variable = groupBy_customer;
	   	orderBy_variable = orderBy_customer;
	   	small_table_row = alpha_customer;
		small_table_column = alpha_product;
       
   	/*----------------------------SET USER CHOICE ------------------------------------------*/
       if(request.getParameter("sort_row") != null && request.getParameter("sort_order") != null 
            && request.getParameter("sort_category") != null ){
       isCustomer = request.getParameter("sort_row").equals("person_name");
       isState = request.getParameter("sort_row").equals("state");
       isAlphabetical = request.getParameter("sort_order").equals("alphabetical");
       isTopk = request.getParameter("sort_order").equals("top_k");
       isCategory = !request.getParameter("sort_category").equals("all");	
       	
       /* parameter set for pstmt and pstmt */
    
          if(isCustomer && isTopk && !isCategory){
       	   select_variable = select_customer;
	       	groupBy_variable = groupBy_customer;
	       	orderBy_variable = orderBy_customer;
	        small_table_row = topk_customer;
	        small_table_column = topk_product;
	        	
	        	
          }
          if(isCustomer && isAlphabetical && isCategory){
       	   select_variable = select_customer + select_category;
	        	groupBy_variable = groupBy_customer + groupBy_category;
	        	orderBy_variable = orderBy_customer;
	        	searchBy_variable = searchByCategoryName; 
	        	join_variable = join_category;
	        	small_table_row = alpha_customer;
	        	small_table_column = cat_alpha_product;
          }
          if(isCustomer && isTopk && isCategory){
          	   select_variable = select_customer + select_category;
   	        	groupBy_variable = groupBy_customer + groupBy_category;
   	        	orderBy_variable = orderBy_customer;
   	        	searchBy_variable = searchByCategoryName; 
   	        	join_variable = join_category;
   	        	small_table_row = topk_customer;
   	        	small_table_column = cat_topk_product;
             }
          if(isState && isAlphabetical && !isCategory){ 
       		    select_variable = select_state;
	        	groupBy_variable = groupBy_state;
	        	orderBy_variable = orderBy_state;
	        	join_variable = join_state;
	        	small_table_row = alpha_state;
	    		small_table_column = alpha_product;
       	  }
          if(isState && isTopk && !isCategory){ 
     		    select_variable = select_state;
	        	groupBy_variable = groupBy_state;
	        	orderBy_variable = orderBy_state;
	        	join_variable = join_state;
	        	small_table_row = topk_state;
	    		small_table_column = topk_product;
     	}
          if (isState && isAlphabetical && isCategory){
       		/* big table variables */
       		select_variable = select_state + select_category;
	        	groupBy_variable = groupBy_state + groupBy_category;
	        	orderBy_variable = orderBy_state;
	        	searchBy_variable = searchByCategoryName; 
	        	join_variable = join_state + join_category;
	        	small_table_row = alpha_state;
	    		small_table_column = cat_alpha_product;
	        	
       	   }
          if (isState && isTopk && isCategory){
         		/* big table variables */
         		select_variable = select_state + select_category;
  	        	groupBy_variable = groupBy_state + groupBy_category;
  	        	orderBy_variable = orderBy_state;
  	        	searchBy_variable = searchByCategoryName; 
  	        	join_variable = join_state + join_category;
  	        	small_table_row = topk_state;
  	    		small_table_column = cat_topk_product;  	        	
          }
       }

    /* Big table that small tables apply their filters on: */
    	
    String main_query_search= "SELECT" + select_variable +" pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
     		 " shopping_cart sc"+
     		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
     		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
     		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
     		    join_variable + 
     		" WHERE sc.is_purchased = 't'" + searchBy_variable + " GROUP BY" + groupBy_variable  + " pd.id, pic.price ORDER BY" + orderBy_variable +" pd.id";
     	    
    String main_view = "WITH T AS (" + main_query_search +  ")";
    
        
        /* -------------------SET UP (PREPARED) STATEMENTS------------------------------------------------- */      
          Statement statement_row  = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY);
       	  Statement statement_product  = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY);
        /*  This is the small table for customer or state and for product */        
 	 
           if(!isCategory){
        	 pstmt3_product = conn.prepareStatement(main_view + small_table_column + " OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
                  	    ResultSet.CONCUR_READ_ONLY );
        	 if(request.getParameter("offset_column") != null){
             	offset_column = Integer.parseInt(request.getParameter("offset_column"));
             	pstmt3_product.setInt(1, offset_column);      
             }
             else {
             	pstmt3_product.setInt(1, 0);	
             }
             pstmt3_product.setInt(2, 10);

            pstmt3 = conn.prepareStatement(main_view + small_table_row + " OFFSET ? LIMIT ?");
        	if(request.getParameter("offset_row") != null){
             	offset_row = Integer.parseInt(request.getParameter("offset_row"));
             	pstmt3.setInt(1, offset_row);      
             }
             else {
             	pstmt3.setInt(1, 0);	
             }
      	    pstmt3.setInt(2, 20);
          }else if (isCategory) {
        	  
        	  pstmt3_product = conn.prepareStatement(main_view + small_table_column + " OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
                 	    ResultSet.CONCUR_READ_ONLY );
        	  if(request.getParameter("sort_category") != null){
        	  pstmt3_product.setString(1, request.getParameter("sort_category"));
        	  pstmt3_product.setString(2, request.getParameter("sort_category"));
        	  }
        	  
        	  if(request.getParameter("offset_column") != null){
               	offset_column = Integer.parseInt(request.getParameter("offset_column"));
               	pstmt3_product.setInt(3, offset_column);      
               }
               else {
               	pstmt3_product.setInt(3, 0);	
               }
               pstmt3_product.setInt(4, 10);
	
              pstmt3 = conn.prepareStatement(main_view + small_table_row + " OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
               	    ResultSet.CONCUR_READ_ONLY);
              if(request.getParameter("sort_category") != null){
            	  pstmt3.setString(1, request.getParameter("sort_category"));
            	  }
              if(request.getParameter("offset_row") != null){
               	offset_row = Integer.parseInt(request.getParameter("offset_row"));
               	pstmt3.setInt(2, offset_row);      
               }
               else {
               	pstmt3.setInt(2, 0);	
               }
        	    pstmt3.setInt(3, 20);  
          }
        %>
 
  <h3 style="text-align: center">Sales Report</h3>
  <table border="1" style="color:blue">
     <%if(offset_row == 0 && offset_column == 0){ %>
     <form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="runQuery">
     <input type="hidden" name="offset_row" value="<%=0 %>">
     <input type="hidden" name="offset_column" value="<%=0 %>">
	  	<tr>
	  	  <td>  	
	  	    <select name="sort_row">
	  	    <%
	  	    if(request.getParameter("sort_row")!=null 
	  	    	&& request.getParameter("sort_row").equals("state")){
	  	    	%>
	  	    	<option value="state">State</option>
	  	        <option value="person_name">Customer</option>
	  	    	<% 
	  	    }
	  	    else{
	  	    %>
	  	    	<option value="person_name">Customer</option>
	  	    	<option value="state">State</option>
	     <% } %>
	  	    </select>
	  	  </td>
	  	  <td>
	  	    <select name="sort_order">
	  	   	<%
	  	    if(request.getParameter("sort_order")!=null 
	  	    	&& request.getParameter("sort_order").equals("top_k")){
	  	    	%>
	  	    	<option value="top_k">Top-K</option>
	  	        <option value="alphabetical">Alphabetical</option>
	  	    	<% 
	  	    }
	  	    else{
	  	    %>
	  	    	<option value="alphabetical">Alphabetical</option>
	  	    	<option value="top_k">Top-K</option>
	  	 <% } %>
	  	    </select>
	  	  </td>
	  	  <td>
	  	  <select name="sort_category">
	  	  <%if(request.getParameter("sort_category")!=null && !request.getParameter("sort_category").equals("all")){
	  		  %>
			<option value="<%=request.getParameter("sort_category")%>"><%=request.getParameter("sort_category")%></option>
	  	  <%} %>
	  	    <option value="all">All</option>
		  	<% statement4 = conn.createStatement();
		  	rs4 = statement4.executeQuery("SELECT * FROM category");
		  	while(rs4.next()){
		  		if( request.getParameter("sort_category")!=null && !request.getParameter("sort_category").equals("all")
		  				&& rs4.getString("category_name").equals(request.getParameter("sort_category"))){
		  		}
		  		else{
		  		%>
		  		<option value="<%=rs4.getString("category_name")%>"><%=rs4.getString("category_name")%></option>
		  	<%	}  
		  	}%>
	  	  </select>
	  	  </td>
	  	  <td>
	  	  
	  	  <input type="submit" value="Run Query">
	  	  </td>
	  	</tr>
	  	<tr>
  	</form>
  	
  	<%
    }
  	if(request.getParameter("action")!= null && request.getParameter("action").equals("runQuery")){
  		
 	    if(isCategory){
 		pstmt1 = conn.prepareStatement(main_view+ small_table_row, ResultSet.TYPE_SCROLL_SENSITIVE,
         	    ResultSet.CONCUR_READ_ONLY);
 		pstmt1.setString(1, request.getParameter("sort_category"));
 	    pstmt2 = conn.prepareStatement(main_view+ small_table_column, ResultSet.TYPE_SCROLL_SENSITIVE,
         	    ResultSet.CONCUR_READ_ONLY);
 		pstmt2.setString(1, request.getParameter("sort_category"));
 	    pstmt2.setString(2, request.getParameter("sort_category"));
 	    
 		rs_row = pstmt1.executeQuery();
 		rs_product = pstmt2.executeQuery();
 	    }else {
 		rs_row = statement_row.executeQuery(main_view + small_table_row);
 	    rs_product = statement_product.executeQuery(main_view+ small_table_column);	    
 	    }
 	    rs_row.last();
		row_size = rs_row.getRow();
		rs_product.last();
		product_size = rs_product.getRow();  		 
		session.setAttribute("row_size", row_size );
		session.setAttribute("product_size", product_size);
		System.out.println("Queries for counting size are running...");
  	}
  	if(request.getParameter("action")!= null && (request.getParameter("action").equals("runQuery") 
  	      || request.getParameter("action").equals("next_20_rows") 
  	      || request.getParameter("action").equals("next_10_columns"))) { 

  		rs3 = pstmt3.executeQuery();
    	rs3_product = pstmt3_product.executeQuery();
  	    System.out.println("Queries for populating rows and columns are running...");
    	%>
  	
  	  	 <th>customer\product</th>
  	 <!-- populate columns -->
  <form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="next_10_columns">
     <!-- row offsets that columns need to keep when going to next 10 products -->
     <input type="hidden" name="offset_row" value="<%=Integer.parseInt(request.getParameter("offset_row")) %>">    
  <% 
    while (rs3_product.next()) {  %>
  	 
  	<% 	/* if person's totalSale has value in the small table, do this */ 	   
  	if(rs3_product.getInt("totalPerItem") != 0){  		 %>  	
  	 	<th><%=rs3_product.getString("name") %><br><span style="color: black">($ <%= rs3_product.getInt("totalPerItem")%>)</span></th>         
  	<%  
  	  }else { %>
	  		<th><%=rs3_product.getString("name") %><br><span style="color: black">($ 0)</span></th>    
	  <%    
      } 		
   } %>
 
    <input type="hidden" name="sort_row" value="<%=request.getParameter("sort_row")%>"/>
    <input type="hidden" name="sort_order" value="<%=request.getParameter("sort_order")%>"/>
    <input type="hidden" name="sort_category" value="<%=request.getParameter("sort_category")%>"/>

    <%if(offset_column + 10 < (Integer)session.getAttribute("product_size") ){ %>
  	<% if(request.getParameter("offset_column") != null){ %>
    <input type="hidden" name="offset_column" value="<%=Integer.parseInt(request.getParameter("offset_column")) + 10 %>">
    <% } %>

  	<th>
  	  <input type="submit" name="action" value="Next 10 Products">
  	</th>
  	<%} %>
  	</form>
  	<!-- populate rows -->
  	<form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="next_20_rows">
  	<% 
  	
  	while(rs3.next()) { 
  	rs3_product.beforeFirst();%>
  	<tr>
  	 <!-- ROW header -->
  
  	 <th><span><%= rs3.getString("name") %> </span><br>
	 
  	 <%   
  	 if(isCustomer){  	 	
  	 	searchBy_variable = searchByCustomerName;
  	 	
  	 }else if (isState){  		 
  		searchBy_variable = searchByStateName;
  		
  	 }
  	 //System.out.println("row item name in rs3: "+ rs3.getString("name"));	
  		/* if row item has totalsale value found in the small table, do this */	 
  	  if(rs3.getInt("totalPerItem") != 0){ 			
  		 %>
  	 	<span style="color: black">($ <%= rs3.getInt("totalPerItem")%>)</span></th> 
  	 	
  	 <% /* big table for searching products */
        
  	    pstmt = conn.prepareStatement("SELECT" + select_variable +" pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
        		 " shopping_cart sc"+
        		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
        		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
        		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
        		    join_variable + 
        		" WHERE sc.is_purchased = 't'" + searchBy_variable + " AND pd.product_name= ? GROUP BY" + groupBy_variable  + " pd.id, pic.price ORDER BY" + orderBy_variable +" pd.id", ResultSet.TYPE_SCROLL_SENSITIVE,
           	    ResultSet.CONCUR_READ_ONLY);
  			 
  	   /* populate product cells in current row*/  
        	while(rs3_product.next()){         	       	 	
         	 	/* search in the big table */	 	
		  	 	pstmt.setString(1, rs3.getString("name"));
		  		pstmt.setString(2, rs3_product.getString("name"));
		        rs = pstmt.executeQuery();
		        if(rs.next()){
         	 %>
          	 <td><%= rs.getInt("total")%></td>
     	    <%  }else{ %>
     	    	<td> 0</td>
     	    <%	}   
        	}	
         } else if (rs3.getInt("totalPerItem") == 0) {  /* if row item have null totalsale in the small table, do this */
  			 %>
  			 <!-- set total per row item to 0 -->
  			<span style="color: black">($ 0)</span></th>
  		 
  		 <%	/* populate the product cells with all 0s */
  		    while(rs3_product.next()){ %>
  			<td>0</td> 		
  	     <% } 
  	     }
  	    }%>  	
  	</tr>
  	
    <input type="hidden" name="sort_row" value="<%=request.getParameter("sort_row")%>"/>
    <input type="hidden" name="sort_order" value="<%=request.getParameter("sort_order")%>"/>
    <input type="hidden" name="sort_category" value="<%=request.getParameter("sort_category")%>"/>
    <!-- column offsets that rows need to keep when going to next 20 customers -->
    <input type="hidden" name="offset_column" value="<%=Integer.parseInt(request.getParameter("offset_column")) %>">
    
    
    <%if(offset_row + 20 < (Integer)session.getAttribute("row_size")){ 
        if(request.getParameter("offset_row") != null){ %>
    <input type="hidden" name="offset_row" value="<%=Integer.parseInt(request.getParameter("offset_row")) + 20 %>">
	  <%  }
    	if (isCustomer){   %>    
    <tr><td><input type="submit" value="NEXT 20 CUSTOMERS"></td></tr>
  	<% 
    	}else if (isState) { %>
    <tr><td><input type="submit" value="NEXT 20 STATES"></td></tr>
    <%	}
    } %>
  	</form> 
  </table>
  <%-- -------- Close Connection Code -------- --%>
    <%  
  	  conn.close();
  	  }
    }catch (SQLException e) {
      throw new RuntimeException(e);
    
    }finally {
        // Release resources in a finally block in reverse-order of
        // their creation

        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) { } // Ignore
            rs = null;
        }
        if (rs_product != null) {
            try {
                rs_product.close();
            } catch (SQLException e) { } // Ignore
            rs_product = null;
        }
        if (rs_row != null) {
            try {
                rs_row.close();
            } catch (SQLException e) { } // Ignore
            rs_row = null;
        }
        if (rs3 != null) {
            try {
                rs3.close();
            } catch (SQLException e) { } // Ignore
            rs3 = null;
        }
        if (rs3_product != null) {
            try {
                rs3_product.close();
            } catch (SQLException e) { } // Ignore
            rs3_product = null;
        }
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException e) { } // Ignore
            pstmt = null;
        }
        if (pstmt1 != null) {
            try {
                pstmt1.close();
            } catch (SQLException e) { } // Ignore
            pstmt1 = null;
        }
        if (pstmt2 != null) {
            try {
                pstmt2.close();
            } catch (SQLException e) { } // Ignore
            pstmt2 = null;
        }
        if (pstmt3 != null) {
            try {
                pstmt3.close();
            } catch (SQLException e) { } // Ignore
            pstmt3 = null;
        }
        if (pstmt3_product != null) {
            try {
                pstmt3_product.close();
            } catch (SQLException e) { } // Ignore
            pstmt3_product = null;
        }        
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) { } // Ignore
            conn = null;
        }
    }
    %>
</main>
</div>
</body>
</html>
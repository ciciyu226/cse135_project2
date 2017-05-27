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
    Statement statement3 = null;
    Statement statement4 = null;

    ResultSet rs = null;
    ResultSet rs1 = null;
    ResultSet rs2 = null;
    ResultSet rs3 = null;
    ResultSet rs4 = null;
    ResultSet rs_small = null;
    ResultSet rs_person = null;
    ResultSet rs_product = null;
    int offset_row = 0;
    int offset_column = 0;
    int offset_sale = 0;
    int person_size = 0;
	int product_size= 0;
    int person_count = 0;
    int currCustomerSale = 0;
    int offset_alphabetical = 0;
    Boolean isCustomer = true;
    Boolean isState = false;
    Boolean isAlphabetical = true;
    Boolean isTopk = false;
    Boolean isCategory = false;
    String name = "";
    String currName = ""; 
    int currSale = 0;
    
    
    try {
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/postgres?" +
            "user=postgres&password=");
    	
        /* select all products */
        /* if (request.getParameter("action") == null){  */
        Statement statement_person  = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY);
        Statement statement_product  = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY);
        Statement statement_small  = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY);
        Statement statement1 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY);
        /* Statement statement2 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY); */
        /* } */
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
        
       /* set default options: customer, alphabetical, no category */
    	select_variable = select_customer;
    	groupBy_variable = groupBy_customer;
    	orderBy_variable = orderBy_customer;
    	searchBy_variable = searchByCustomerName;

        
    	/*----------------------------SET USER CHOICE ------------------------------------------*/
        if(request.getParameter("sort_row") != null && request.getParameter("sort_order") != null 
             && request.getParameter("sort_category") != null ){
        isCustomer = request.getParameter("sort_row").equals("person_name");
        isState = request.getParameter("sort_row").equals("state");
        isAlphabetical = request.getParameter("sort_order").equals("alphabetical");
        isTopk = request.getParameter("sort_order").equals("top_k");
        isCategory = !request.getParameter("sort_category").equals("all");	
        	
/* 	        if(isCustomer && isAlphabetical && !isCategory){
	        	//default options
	        	select_variable = select_customer;
	        	groupBy_variable = groupBy_customer;
	        	orderBy_variable = orderBy_customer;
	        	searchBy_variable = searchByCustomerName;
	        	
	        } */
        /* parameter set for pstmt */
           if(isCustomer && isAlphabetical && isCategory){
        	   select_variable = select_customer + select_category;
	        	groupBy_variable = groupBy_customer + groupBy_category;
	        	orderBy_variable = orderBy_customer;
	        	searchBy_variable = searchByCustomerName;
	        	join_variable = join_state + join_category;
           }
           if(isState && isAlphabetical && !isCategory){ 
        		select_variable = select_state;
	        	groupBy_variable = groupBy_state;
	        	orderBy_variable = orderBy_state;
	        	searchBy_variable = searchByStateName;
	        	join_variable = join_state;
 	
        	}
           if (isState && isAlphabetical && isCategory){
        		/* big table variables */
        		select_variable = select_state + select_category;
	        	groupBy_variable = groupBy_state + groupBy_category;
	        	orderBy_variable = orderBy_state;
	        	searchBy_variable = searchByStateName;
	        	join_variable = join_state + join_category;
	        	
        	}
        } 

        System.out.println("select_variable: " + select_variable);
    	System.out.println("groupBy_variable: " + groupBy_variable);
    	System.out.println("orderBy_variable: " + orderBy_variable);
    	System.out.println("join_variable: " + join_variable);
    	System.out.println("searchBy_variable: " + searchBy_variable);
    	
    	
        /* Big table that small tables apply their filters on: */
        String main_query_view = "SELECT" + select_variable +" pd.id AS product, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
        		 " shopping_cart sc"+
        		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
        		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
        		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
        		    join_variable + 
        		" WHERE sc.is_purchased = 't' GROUP BY" + groupBy_variable  + " pd.id, pic.price ORDER BY" + orderBy_variable +" pd.id";
        	
        String main_query= "SELECT" + select_variable +" pd.id AS product, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
         		 " shopping_cart sc"+
         		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
         		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
         		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
         		    join_variable + 
         		" WHERE sc.is_purchased = 't'" + searchBy_variable + " GROUP BY" + groupBy_variable  + " pd.id, pic.price ORDER BY" + orderBy_variable +" pd.id";
         	
        /*--------------------CUSTOMER ----------------------- */
        String main_view = "WITH T AS (" + main_query_view + ")";
        /* Small table that applies sort_order: alphebatical + no sort_category on customer_query */
        String alpha_customer = " SELECT person_name, SUM(total) AS totalPerPerson FROM T GROUP BY person_name ORDER BY person_name";
        /* Small table that applies sort_order: Top-K + no sort_category on customer_query */
        String topk_customer=  "SELECT person_name, SUM(total) AS totalPerPerson FROM T GROUP BY person_name ORDER BY totalPerPerson DESC";
        /* Small table that applies sort_order: alphabetical + sort_category: a category on customer_query */
        String alpha_cat_customer = "SELECT person_name, SUM(total) AS totalPerCategoryPerPerson FROM T WHERE category_name = ? GROUP BY person_name ORDER BY person_name";
        /* Small table that applies sort_order: Top-k + sort_category: a category on customer_query */
        String cat_customer = "SELECT person_name, SUM(total) AS totalPerCategoryPerPerson FROM T WHERE category_name =? GROUP BY person_name ORDER BY totalPerCategoryPerPerson DESC";
        
        
        /*--------------------STATE ----------------------- */       
       /* Small table that applies sort_order: alphabetical + NO sort_category on the big table state_query */
       String alpha_state = " SELECT state_name, SUM(total) AS totalPerState FROM T GROUP BY state_name ORDER BY state_name";
       /* Small table that applies sort_order: Top-K + NO sort_category on the big table state_query */
       String topk_state = " SELECT state_name, SUM(total) AS totalPerState FROM T GROUP BY state_name ORDER BY totalPerState DESC";
       /* Small table that applies sort_order: alphabetical + sort_category: a category on state_query */
       String alpha_cat_state = " SELECT state_name, SUM(total) AS totalPerCategoryPerState FROM T WHERE category_name = ?" + 
       							" GROUP BY state_name ORDER BY state_name";
 
       /* Small table that applies sort_order: Top-k + sort_category: a category on state_query */
       String topk_cat_state = " SELECT state_name, SUM(total) AS totalPerCategoryPerState FROM T WHERE category_name = ?" +
       								" GROUP BY state_name ORDER BY totalPerCategoryPerState DESC";
       
       
        
        
        
        /* -------------------QUERIES EXECUTION------------------------------------------------- */
  
        rs_product = statement_product.executeQuery("SELECT * FROM product ORDER BY id");
        rs_product.last();
    	product_size = rs_product.getRow();
    	System.out.println("Total number of product: " + product_size);
    	rs_product.beforeFirst();
        
    	rs_person =  statement_person.executeQuery("SELECT * FROM person ORDER BY id");
    	rs_person.last();
    	person_size = rs_person.getRow();
    	System.out.println("Total number of people: " + person_size);
    	rs_person.beforeFirst();
    	
    	rs1 = statement1.executeQuery("SELECT * FROM product ORDER BY id");
    	
        pstmt2 = conn.prepareStatement("SELECT * FROM person ORDER BY person_name OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
           	    ResultSet.CONCUR_READ_ONLY);
        if (request.getParameter("sort_row") != null && request.getParameter("sort_row").equals("state")){
     	pstmt2 = conn.prepareStatement("SELECT * FROM state ORDER BY state_name OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
             	    ResultSet.CONCUR_READ_ONLY);	
        }
        if(request.getParameter("offset_row") != null){
        	offset_row = Integer.parseInt(request.getParameter("offset_row"));
        	pstmt2.setInt(1, offset_row);
        }
        else {
        	pstmt2.setInt(1, 0);	
        }
        	pstmt2.setInt(2, 20);
        	rs2 = pstmt2.executeQuery();
       
        /*  This is the small table */
        /* default choice: customer+alphabetical + All */
        	pstmt3 = conn.prepareStatement(main_view + alpha_customer + " OFFSET ?");
        	if(request.getParameter("offset_alphabetical") != null){
             	offset_alphabetical = Integer.parseInt(request.getParameter("offset_alphabetical"));
             	pstmt3.setInt(1, offset_alphabetical);      
             }
             else {
             	pstmt3.setInt(1, 0);	
             }
       	if (request.getParameter("sort_row")!= null && isCustomer && isAlphabetical && isCategory){
           	pstmt3 = conn.prepareStatement(main_view + alpha_cat_customer + " OFFSET ?");	
           	System.out.println("hahahahah");
           	pstmt3.setString(1, request.getParameter("sort_category"));
           	System.out.println("hahahahah2");
           	if(request.getParameter("offset_alphabetical") != null){
                	offset_alphabetical = Integer.parseInt(request.getParameter("offset_alphabetical"));
                	pstmt3.setInt(2, offset_alphabetical);      
                }
                else {
                	pstmt3.setInt(2, 0);	
                	System.out.println("hahahahah3");
                }
        }
            
        if (request.getParameter("sort_row")!= null && isState && isAlphabetical){
        	pstmt3 = conn.prepareStatement(main_view + alpha_state + " OFFSET ?");	
        	 if(request.getParameter("offset_alphabetical") != null){
             	offset_alphabetical = Integer.parseInt(request.getParameter("offset_alphabetical"));
             	pstmt3.setInt(1, offset_alphabetical);      
             }
             else {
             	pstmt3.setInt(1, 0);	
             }
        }
        if (request.getParameter("sort_row")!= null && isState && isAlphabetical && isCategory){
        	pstmt3 = conn.prepareStatement(main_view + alpha_cat_state + " OFFSET ?");	
        	System.out.println("hahahahah");
        	pstmt3.setString(1, request.getParameter("sort_category"));
        	System.out.println("hahahahah2");
        	if(request.getParameter("offset_alphabetical") != null){
             	offset_alphabetical = Integer.parseInt(request.getParameter("offset_alphabetical"));
             	pstmt3.setInt(2, offset_alphabetical);      
             }
             else {
             	pstmt3.setInt(2, 0);	
             	System.out.println("hahahahah3");
             }
        }
        
        
        if(pstmt3!= null){
    	rs3 = pstmt3.executeQuery();
    	System.out.println("third point");
        } 
        System.out.println("third point");
        %>
  <h3 style="text-align: center">Sales Report</h3>
  <table border="1" style="color:blue">
     <form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="runQuery">
     <% if(request.getParameter("offset_row")==null 
     		&& request.getParameter("offset_alphabetical")==null )
    	{ %>
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
       	<%
        }%>
  	</form>
  	
  	<%if(request.getParameter("action")!= null && (request.getParameter("action").equals("runQuery") 
  	      || request.getParameter("action").equals("next_20_rows"))) { %>
  	<form action="salesAnalytics.jsp" method="GET">
    <input type="hidden" name="action" value="next_20_rows">
  	  	 <th>customer\product</th>
  	 <!-- populate columns -->
  <% while (rs1.next()) {  %>
  	 <th><%=rs1.getInt("id") %><br>($total sale)</th>
  <% 
  	} %> 
  	</tr>
  	<!-- populate rows -->
  	<% 
  	
  	while(rs2.next()) { 
  	rs1.beforeFirst(); %>
  	<tr>
  	 <!-- ROW header -->
  	 <%
  	if(request.getParameter("sort_row").equals("person_name")){
  	 	currName = rs2.getString("person_name");
  	 }else if (request.getParameter("sort_row").equals("state")){
  		currName = rs2.getString("state_name"); 
  	 }
  	 %>
  	 <th><span><%= currName %> </span><br>
	 
  	 <% if(rs3.isBeforeFirst()){
  	       rs3.next();
  	 }   
  	 if(request.getParameter("sort_row").equals("person_name")){
  	 	name = rs3.getString("person_name");
  	 }else if (request.getParameter("sort_row").equals("state")){
  		name = rs3.getString("state_name"); 
  	 }
  	System.out.println("name in rs3: "+ name);	
  		/* if person has found in the small table, do this */
  	  if(name.equals(currName)){
  		if(isCustomer && !isCategory){
  			currSale = rs3.getInt("totalPerPerson");
  	  	 }
  		else if (isCustomer && isCategory){
  			currSale = rs3.getInt("totalPerCategoryPerPerson");
  		}
  		else if (isState && !isCategory){
  	  		currSale = rs3.getInt("totalPerState");
  	  	 }
  		else if (isState && isCategory) {
  			currSale = rs3.getInt("totalPerCategoryPerState");
  	  		System.out.println("herehrhehre");
  		}
  		 %>
  	 	<span style="color: black">($ <%= currSale%>)</span></th> 
  	 	
  	 <% /* big table for searching */
        pstmt = conn.prepareStatement(main_query, ResultSet.TYPE_SCROLL_SENSITIVE,
           	    ResultSet.CONCUR_READ_ONLY);
  	 	/* search in the big table */	 	
  	 	pstmt.setString(1, name);
   
        rs = pstmt.executeQuery();	
  	 	
       /* populate product cells in current row*/
         while(rs1.next()){
          if(rs.isBeforeFirst()){
            rs.next();
          }

          	if(rs1.getInt("id") == rs.getInt("product")){ 
         	 	//currCustomerSale += rs.getInt("price") * rs.getInt("sum");
         	 %>
          	 <td><%= rs.getInt("total")%></td>
     	    <%  if(!rs.isLast()){ 
     	          rs.next();
     	        }
          	}else{  %>
          	 <td>0</td>
          <% } 
         } 
  	 	 if(!rs3.isLast()){
  				rs3.next();
  			}
  		}else {  /* if person has not found in the small table, do this */
  			currSale = 0; %>
  			<span style="color: black">($ <%= currSale%>)</span></th>
  		 <%	while(rs1.next()){ %>
  			<td>0</td>
  		<%	} %>
  	<% 	}
  	 
  	 %>
  	  
  	
  	</tr>
  	<!-- end of while loop of row -->
  <%  
  	} 
  	rs2.previous();
  	   
  	offset_row = offset_row + rs2.getRow();  	
    //offset_sale = offset_sale + rs.getRow();
    offset_alphabetical = offset_alphabetical + rs3.getRow();  	
    
    System.out.println("rs2 out of loop is at: "+ rs2.getRow());
  	System.out.println("rs is at: "+ rs.getRow());
    System.out.println("offset_row: "+ offset_row);
    System.out.println("rs is really at: "+ offset_sale); %>
    
    <input type="hidden" name="sort_row" value="<%=request.getParameter("sort_row")%>"/>
    <input type="hidden" name="sort_order" value="<%=request.getParameter("sort_order")%>"/>
    <input type="hidden" name="sort_category" value="<%=request.getParameter("sort_category")%>"/>
     <%	System.out.println("sort_row: " + request.getParameter("sort_row"));
       	System.out.println("sort_order: " + request.getParameter("sort_order"));
       	System.out.println("sort_category: " + request.getParameter("sort_category"));  	%>
    <input type="hidden" name="offset_row" value="<%=offset_row %>">
    <%-- <input type="hidden" name="offset_sale" value="<%=offset_sale-1 %>"> --%>
    <input type="hidden" name="offset_alphabetical" value="<%=offset_alphabetical-1 %>">
   <%  System.out.println("current offset_row: "+ offset_row); %>
    <%if(offset_row < person_size ){ %>
    <tr><td><input type="submit" value="NEXT 20 CUSTOMERS"></td></tr>
  	<% } %>
  	</form>
  	<%} %>
  
  </table>
  <%-- -------- Close Connection Code -------- --%>
    <%
        if(rs3.isAfterLast()){
        // Close the ResultSet
        rs3.close();

        // Close the Statement
       // statement.close();

        // Close the Connection
        conn.close();
        }
    } catch (SQLException e) {
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
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException e) { } // Ignore
            pstmt = null;
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
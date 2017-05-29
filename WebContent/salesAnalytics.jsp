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
    ResultSet rs3_product = null;
    int offset_row = 0;
    int offset_column = 0;
    
    int person_size = 0;
	int product_size= 0;
    int person_count = 0;
    int currCustomerSale = 0;
    int offset_alphabetical_row = 0;
    int offset_alphabetical_column = 0;
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
        /* parameter set for pstmt and pstmt */
           if(isCustomer && isAlphabetical && isCategory){
        	   select_variable = select_customer + select_category;
	        	groupBy_variable = groupBy_customer + groupBy_category;
	        	orderBy_variable = orderBy_customer;
	        	/* searchBy_variable = searchByCustomerName + searchByCategoryName; */
	        	join_variable = join_category;
           }
           if(isState && isAlphabetical && !isCategory){ 
        		select_variable = select_state;
	        	groupBy_variable = groupBy_state;
	        	orderBy_variable = orderBy_state;
	        	/* searchBy_variable = searchByStateName; */
	        	join_variable = join_state;
 	
        	}
           if (isState && isAlphabetical && isCategory){
        		/* big table variables */
        		select_variable = select_state + select_category;
	        	groupBy_variable = groupBy_state + groupBy_category;
	        	orderBy_variable = orderBy_state;
	        	/* searchBy_variable = searchByStateName; */
	        	join_variable = join_state + join_category;
	        	
        	}
        } 

        System.out.println("select_variable: " + select_variable);
    	System.out.println("groupBy_variable: " + groupBy_variable);
    	System.out.println("orderBy_variable: " + orderBy_variable);
    	System.out.println("join_variable: " + join_variable);
    	System.out.println("searchBy_variable: " + searchBy_variable);
    	
    	
        /* Big table that small tables apply their filters on: */
        /* String main_query_generic = "SELECT" + select_variable +" pd.id AS product, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
        		 " shopping_cart sc"+
        		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
        		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
        		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
        		    join_variable + 
        		" WHERE sc.is_purchased = 't' GROUP BY" + groupBy_variable  + " pd.id, pic.price ORDER BY" + orderBy_variable +" pd.id"; */
        	
        String main_query_search= "SELECT" + select_variable +" pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
         		 " shopping_cart sc"+
         		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
         		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
         		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
         		    join_variable + 
         		" WHERE sc.is_purchased = 't'" + searchBy_variable + " GROUP BY" + groupBy_variable  + " pd.id, pic.price ORDER BY" + orderBy_variable +" pd.id";
         	
        /*--------------------CUSTOMER ----------------------- */
        /* String main_view = "WITH T AS (" + main_query_generic + ")"; */
        String main_view = "WITH T AS (" + main_query_search +  ")";
        /* Small table that applies sort_order: alphebatical + no sort_category on customer_query */
        String alpha_customer = " SELECT person_name, SUM(total) AS totalPerPerson FROM T GROUP BY person_name ORDER BY person_name";
        /* Small table that applies sort_order: Top-K + no sort_category on customer_query */
        String topk_customer=  "SELECT person_name, SUM(total) AS totalPerPerson FROM T GROUP BY person_name ORDER BY totalPerPerson DESC";
        /* Small table that applies sort_order: alphabetical + sort_category: a category on customer_query */
       
        
        /*--------------------STATE ----------------------- */       
       /* Small table that applies sort_order: alphabetical + NO sort_category on the big table state_query */
       String alpha_state = " SELECT state_name, SUM(total) AS totalPerState FROM T GROUP BY state_name ORDER BY state_name";
       /* Small table that applies sort_order: Top-K + NO sort_category on the big table state_query */
       String topk_state = " SELECT state_name, SUM(total) AS totalPerState FROM T GROUP BY state_name ORDER BY totalPerState DESC";
       
       /*----------------------PRODUCT ----------------------*/
       String alpha_product = " SELECT product_name, SUM(total) AS totalPerProduct FROM T GROUP BY product_name, product ORDER BY product_name, product";
       
       String topk_product = " SELECT product_name, SUM(total) AS totalPerProduct FROM T GROUP BY product_name ORDER BY totalPerProduct DESC";
       
        
        /* searching back in big table */
       /*  TODO: pstmt */
        
        
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
    	
    	/* rs_state =  statement_person.executeQuery("SELECT * FROM state ORDER BY id");
    	rs_state.last();
    	state_size = rs_state.getRow();
    	System.out.println("Total number of state: " + state_size);
    	rs_state.beforeFirst(); */    	
    	
    	pstmt1 = conn.prepareStatement("SELECT * FROM product ORDER BY product_name, id OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
           	    ResultSet.CONCUR_READ_ONLY);
    	if(request.getParameter("offset_column") != null ) {
    		offset_column = Integer.parseInt(request.getParameter("offset_column"));
    		pstmt1.setInt(1, offset_column);
    	}else {
    		pstmt1.setInt(1, 0);
    	}
    	pstmt1.setInt(2, 10);
    	rs1 = pstmt1.executeQuery();
    	
    	pstmt2 = conn.prepareStatement("SELECT * FROM person ORDER BY person_name OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
           	    ResultSet.CONCUR_READ_ONLY);
    	
        if (request.getParameter("sort_row") != null && isState){
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
        /* default choice: product + alphabetical + All */
        	pstmt3_product = conn.prepareStatement(main_view + alpha_product + " OFFSET ?", ResultSet.TYPE_SCROLL_SENSITIVE,
               	    ResultSet.CONCUR_READ_ONLY );
        	 
             if(request.getParameter("offset_alphabetical_column") != null){
             	offset_alphabetical_column = Integer.parseInt(request.getParameter("offset_alphabetical_column"));
             	System.out.println("rs3_product offset: " +  offset_alphabetical_column);
             	pstmt3_product.setInt(1, offset_alphabetical_column);      
             }
             else {
             	pstmt3_product.setInt(1, 0);	
             }
            
        /* default choice: customer+alphabetical + All */
        	pstmt3 = conn.prepareStatement(main_view + alpha_customer + " OFFSET ?");
        	if(request.getParameter("offset_alphabetical_row") != null){
             	offset_alphabetical_row = Integer.parseInt(request.getParameter("offset_alphabetical_row"));
             	pstmt3.setInt(1, offset_alphabetical_row);      
             }
             else {
             	pstmt3.setInt(1, 0);	
             }
       	
        if (request.getParameter("sort_row")!= null && isCustomer && isAlphabetical && isCategory){
        	searchBy_variable = searchByCategoryName;
        	
        	main_query_search= "SELECT" + select_variable +" pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
            		 " shopping_cart sc"+
            		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
            		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
            		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
            		    join_variable + 
            		" WHERE sc.is_purchased = 't'" + searchBy_variable + " GROUP BY" + groupBy_variable  + " pd.id, pic.price ORDER BY" + orderBy_variable +" pd.id";
        	main_view = "WITH T AS (" + main_query_search +  ")";
        	
        	pstmt3_product = conn.prepareStatement(main_view + alpha_product + " OFFSET ?", ResultSet.TYPE_SCROLL_SENSITIVE,
               	    ResultSet.CONCUR_READ_ONLY );
        	pstmt3_product.setString(1, request.getParameter("sort_category"));
             if(request.getParameter("offset_alphabetical_column") != null){
             	offset_alphabetical_column = Integer.parseInt(request.getParameter("offset_alphabetical_column"));
             	System.out.println("rs3_product offset: " +  offset_alphabetical_column);
             	pstmt3_product.setInt(2, offset_alphabetical_column);      
             }
             else {
             	pstmt3_product.setInt(2, 0);	
             }
        	
        	
        	pstmt3 = conn.prepareStatement(main_view + alpha_customer + " OFFSET ?");	
        	System.out.println(main_view + alpha_customer + " OFFSET ?");
        	System.out.println("hahahahah");
           	pstmt3.setString(1, request.getParameter("sort_category"));
           	System.out.println("hahahahah2");
           	if(request.getParameter("offset_alphabetical_row") != null){
                	offset_alphabetical_row = Integer.parseInt(request.getParameter("offset_alphabetical_row"));
                	pstmt3.setInt(2, offset_alphabetical_row);      
                }
                else {
                	pstmt3.setInt(2, 0);	
                	System.out.println("hahahahah3");
                }
        }
            
        if (request.getParameter("sort_row")!= null && isState && isAlphabetical && !isCategory){
        	pstmt3 = conn.prepareStatement(main_view + alpha_state + " OFFSET ?");	
        	 if(request.getParameter("offset_alphabetical_row") != null){
             	offset_alphabetical_row = Integer.parseInt(request.getParameter("offset_alphabetical_row"));
             	pstmt3.setInt(1, offset_alphabetical_row);      
             }
             else {
             	pstmt3.setInt(1, 0);	
             }
        }
        if (request.getParameter("sort_row")!= null && isState && isAlphabetical && isCategory){
        	searchBy_variable = searchByCategoryName;        	
        	main_query_search= "SELECT" + select_variable +" pd.id AS product, pd.product_name, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
            		 " shopping_cart sc"+
            		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
            		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
            		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
            		    join_variable + 
            		" WHERE sc.is_purchased = 't'" + searchBy_variable + " GROUP BY" + groupBy_variable  + " pd.id, pic.price ORDER BY" + orderBy_variable +" pd.id";
        	main_view = "WITH T AS (" + main_query_search +  ")";
        	
        	pstmt3_product = conn.prepareStatement(main_view + alpha_product + " OFFSET ?", ResultSet.TYPE_SCROLL_SENSITIVE,
               	    ResultSet.CONCUR_READ_ONLY );
        	pstmt3_product.setString(1, request.getParameter("sort_category"));
            if(request.getParameter("offset_alphabetical_column") != null){
            	offset_alphabetical_column = Integer.parseInt(request.getParameter("offset_alphabetical_column"));
            	System.out.println("rs3_product offset: " +  offset_alphabetical_column);
            	pstmt3_product.setInt(2, offset_alphabetical_column);      
            }
            else {
            	pstmt3_product.setInt(2, 0);	
            }
            
        	pstmt3 = conn.prepareStatement(main_view + alpha_state + " OFFSET ?");	
        	System.out.println("hahahahah");
        	pstmt3.setString(1, request.getParameter("sort_category"));
        	System.out.println("hahahahah2");
        	if(request.getParameter("offset_alphabetical_row") != null){
             	offset_alphabetical_row = Integer.parseInt(request.getParameter("offset_alphabetical_row"));
             	pstmt3.setInt(2, offset_alphabetical_row);      
             }
             else {
             	pstmt3.setInt(2, 0);	
             	System.out.println("hahahahah3");
             }
        }
        
        
        if(pstmt3 != null && pstmt3_product != null){
    	rs3 = pstmt3.executeQuery();
    	rs3_product = pstmt3_product.executeQuery();
    	
    	System.out.println("third point");
        } 
        System.out.println("third point");
        %>
  <h3 style="text-align: center">Sales Report</h3>
  <table border="1" style="color:blue">
     <form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="runQuery">
     <input type="hidden" name="offset_row" value="<%=0 %>">
     <input type="hidden" name="offset_column" value="<%=0 %>">
     <input type="hidden" name="offset_alphabetical_column" value="<%= 0 %>">
     <input type="hidden" name="offset_alphabetical_row" value="<%= 0 %>">
     <% if(request.getParameter("offset_row")==null 
     		&& request.getParameter("offset_alphabetical_row")==null )
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
  	      || request.getParameter("action").equals("next_20_rows") 
  	      || request.getParameter("action").equals("next_10_columns"))) { %>
  	
  	  	 <th>customer\product</th>
  	 <!-- populate columns -->
  <form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="next_10_columns">
     <!-- row offsets that columns need to keep when going to next 10 products -->
     <input type="hidden" name="offset_row" value="<%=Integer.parseInt(request.getParameter("offset_row")) %>">
     <input type="hidden" name="offset_alphabetical_row" value="<%=Integer.parseInt(request.getParameter("offset_alphabetical_row"))%>">
   
    
  <% while (rs1.next()) {  %>
  	 <th><%=rs1.getString("product_name") %><br>
  	<% 	/* if person has found in the small table, do this */
  	  if(rs3_product.isBeforeFirst()){
  		  rs3_product.next();
  	  	} 	  
  	  if(rs3_product.getString("product_name").equals(rs1.getString("product_name"))){
  		 %> 
  	 	<span style="color: black">($ <%= rs3_product.getInt("totalPerProduct")%>)</span></th>         
  	<%  if(!rs3_product.isLast()){
			rs3_product.next();  		
  		}
  	  }else { %>
  		<span style="color: black">($ 0)</span></th>  
  	<% } 
  	}
    
 %>
    
    <input type="hidden" name="sort_row" value="<%=request.getParameter("sort_row")%>"/>
    <input type="hidden" name="sort_order" value="<%=request.getParameter("sort_order")%>"/>
    <input type="hidden" name="sort_category" value="<%=request.getParameter("sort_category")%>"/>
     <%	System.out.println("sort_row product: " + request.getParameter("sort_row"));
       	System.out.println("sort_order product: " + request.getParameter("sort_order"));
       	System.out.println("sort_category product: " + request.getParameter("sort_category"));  	%>
   
   
    <%if(offset_column + 10 < product_size ){ %>
  	<% if(request.getParameter("offset_column") != null){ %>
    <input type="hidden" name="offset_column" value="<%=Integer.parseInt(request.getParameter("offset_column")) + 10 %>">
    <% } %>
  	<input type="hidden" name="offset_alphabetical_column" value="<%=Integer.parseInt(request.getParameter("offset_alphabetical_column")) + rs3_product.getRow() -1 %>">
   <% 
   System.out.println("rs3_product is at: "+ rs3_product.getRow());
   System.out.println("offset_column: "+ offset_column);
   System.out.println("offset_alphabetical_column: "+ offset_alphabetical_column); 
   
    %>
  	<th>
  	  <input type="submit" name="action" value="Next 10 Products">
  	</th>
  	<%} %>
  	</form>
  	<!-- populate rows -->
  	<form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="next_20_rows">
  	<% 
  	
  	while(rs2.next()) { 
  	rs1.beforeFirst();
  	rs3_product.beforeFirst();%>
  	<tr>
  	 <!-- ROW header -->
  	 <%
  	if(isCustomer){
  	 	currName = rs2.getString("person_name");
  	 }else if (isState){
  		currName = rs2.getString("state_name"); 
  	 }
  	 %>
  	 <th><span><%= currName %> </span><br>
	 
  	 <% if(rs3.isBeforeFirst()){
  	       rs3.next();
  	 }   
  	 if(isCustomer){
  	 	name = rs3.getString("person_name");
  	 	searchBy_variable = searchByCustomerName;
  	 	//System.out.println("searching by customer name");
  	 }else if (isState){
  		name = rs3.getString("state_name"); 
  		searchBy_variable = searchByStateName;
  		//System.out.println("searching by state name");
  	 }
  	//System.out.println("name in rs3: "+ name);	
  		/* if person has found in the small table, do this */
  	  if(name.equals(currName)){
  		if(isCustomer) {
  			currSale = rs3.getInt("totalPerPerson");
  		}else if (isState) {
  			currSale = rs3.getInt("totalPerState");
  		}
  		 %>
  	 	<span style="color: black">($ <%= currSale%>)</span></th> 
  	 	
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
         while(rs1.next()){
            if(rs3_product.isBeforeFirst()){
            	rs3_product.next();
            }
            System.out.println("name in rs1: " + rs1.getString("product_name"));
            System.out.println("name in rs3_product: " + rs3_product.getString("product_name"));
          	if(rs1.getString("product_name").equals(rs3_product.getString("product_name"))){ 
         	 	//currCustomerSale += rs.getInt("price") * rs.getInt("sum");
         	 	/* search in the big table */	 	
		  	 	pstmt.setString(1, name);
		  		pstmt.setString(2, rs3_product.getString("product_name"));
		        //System.out.println(rs3_product.getString("product_name"));
		        rs = pstmt.executeQuery();
		        if(rs.next()){
         	 %>
          	 <td><%= rs.getInt("total")%></td>
     	    <%  }else{ %>
     	    	<td> 0</td>
     	    <%	}   
		        if(!rs3_product.isLast()){
		        	rs3_product.next();
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
  	
  	if(request.getParameter("action").equals("runQuery") || request.getParameter("action").equals("next_20_rows")){   
  	//offset_row = offset_row + 20;  	
    //offset_sale = offset_sale + rs.getRow();
    //offset_alphabetical_row = offset_alphabetical_row + rs3.getRow();  	
  	}
    
  	
  	System.out.println("rs3 is at: "+ rs3.getRow());
    System.out.println("offset_row: "+ offset_row);
    System.out.println("offset_alphabetical_row: "+ offset_alphabetical_row);
    %>
    
    <input type="hidden" name="sort_row" value="<%=request.getParameter("sort_row")%>"/>
    <input type="hidden" name="sort_order" value="<%=request.getParameter("sort_order")%>"/>
    <input type="hidden" name="sort_category" value="<%=request.getParameter("sort_category")%>"/>
     <%	System.out.println("sort_row: " + request.getParameter("sort_row"));
       	System.out.println("sort_order: " + request.getParameter("sort_order"));
       	System.out.println("sort_category: " + request.getParameter("sort_category"));  	%>
 
 
    <%-- <input type="hidden" name="offset_sale" value="<%=offset_sale-1 %>"> --%>
    
   <%  System.out.println("current offset_row: "+ request.getParameter("offset_row")); %>
    <!-- column offsets that rows need to keep when going to next 20 customers -->
    <input type="hidden" name="offset_column" value="<%=Integer.parseInt(request.getParameter("offset_column")) %>">
    <input type="hidden" name="offset_alphabetical_column" value="<%=Integer.parseInt(request.getParameter("offset_alphabetical_column"))%>">
   
    
    
    <%if(offset_row + 20 < person_size ){ %>
    <%   if(request.getParameter("offset_row") != null){ %>
    <input type="hidden" name="offset_row" value="<%=Integer.parseInt(request.getParameter("offset_row")) + 20 %>">
	  <%  } %>
	<input type="hidden" name="offset_alphabetical_row" value="<%=Integer.parseInt(request.getParameter("offset_alphabetical_row")) + rs3.getRow() -1 %>">
   
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
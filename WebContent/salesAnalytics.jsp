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
	response.sendRedirect("http://localhost:9999/CSE135Project1_eclipse");
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
    int offset_row = 0;
    int offset_column = 0;
    int offset_sale = 0;
    int person_size = 0;
    int person_count = 0;
    int currCustomerSale = 0;
    int offset_totalPerPerson = 0;
    
    try {
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/postgres?" +
            "user=postgres&password=");
    	
        /* select all products */
        /* if (request.getParameter("action") == null){  */
        /* Statement statement  = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY); */
        Statement statement1 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY);
        /* Statement statement2 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
        	    ResultSet.CONCUR_READ_ONLY); */
        /* } */
        /*--------------------CUSTOMER ----------------------- */
        /* Big table that small tables apply their filters on: */
        String customer_query= "SELECT p.id AS person_id, p.person_name, pd.id AS product, pd.category_id, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
         		 " shopping_cart sc"+
         		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
         		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
         		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +      		  
         		" WHERE sc.is_purchased = 't' GROUP BY p.id, pd.id, pic.price ORDER BY p.person_name, pd.id";
        /* Small table that applies sort_order: alphebatical + no sort_category on customer_query */
        String alpha_customer = "WITH T AS (" + customer_query + ")"
     			 + " SELECT person_name, SUM(total) AS totalPerPerson FROM T GROUP BY person_name ORDER BY person_name";
        /* Small table that applies sort_order: Top-K + no sort_category on customer_query */
        String topk_customer= "SELECT person_name, SUM(total) AS totalPerPerson FROM T GROUP BY person_name ORDER BY totalPerPerson DESC";
        /* Small table that applies sort_order: alphabetical + sort_category: a category on customer_query */
        String alpha_cat_customer = "SELECT person_name, category_id, SUM(total) AS totalPerCategoryPerPerson FROM T GROUP BY person_name," +
        							" category_id ORDER BY category_id, person_name";
        /* Small table that applies sort_order: Top-k + sort_category: a category on customer_query */
        String topk_cat_customer = "SELECT person_name, category_id, SUM(total) AS totalPerCategoryPerPerson FROM T GROUP BY person_name," +
        							" category_id ORDER BY category_id, totalPerCategoryPerPerson DESC";
        
        /*--------------------STATE ----------------------- */
       /*  Big table that small tables apply their filters on: */
        String state_query = "SELECT s.id AS state_id, s.state_name, pd.id AS product, pd.category_id, pic.price, sum(pic.quantity), (pic.price*sum(pic.quantity)) AS total FROM" +
        		 " shopping_cart sc"+
        		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
        		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
        		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +
        		  " INNER JOIN state s ON (s.id = p.id)" +
        		" WHERE sc.is_purchased = 't' GROUP BY s.id, pd.id, pic.price ORDER BY s.state_name, pd.id";
       /* Small table that applies sort_order: alphabetical + NO sort_category on the big table state_query */
       String alpha_state = "SELECT state_name, SUM(total) AS totalPerState FROM T GROUP BY state_name ORDER BY state_name";
       /* Small table that applies sort_order: Top-K + NO sort_category on the big table state_query */
       String topk_state = "SELECT state_name, SUM(total) AS totalPerState FROM T GROUP BY state_name ORDER BY totalPerState DESC";
       /* Small table that applies sort_order: alphabetical + sort_category: a category on state_query */
       String alpha_cat_state = "SELECT state_name, category_id, SUM(total) AS totalPerCategoryPerState FROM T GROUP BY state_name," +
       						" category_id ORDER BY category_id, state_name";
       /* Small table that applies sort_order: Top-k + sort_category: a category on state_query */
       String topk_cat_state = "SELECT state_name, category_id, SUM(total) AS totalPerCategoryPerState FROM T GROUP BY state_name," +
       						" category_id ORDER BY category_id, totalPerCategoryPerState DESC";
       
       
        
        /* -------------------QUERIES EXECUTION------------------------------------------------- */
        
        pstmt = conn.prepareStatement(customer_query + " OFFSET ? ROWS", ResultSet.TYPE_SCROLL_SENSITIVE,
           	    ResultSet.CONCUR_READ_ONLY);
        
        if(request.getParameter("offset_sale") != null){
        offset_sale = Integer.parseInt(request.getParameter("offset_sale"));
        pstmt.setInt(1, offset_sale);      
        }
        else {
        pstmt.setInt(1, 0);	
        }
        rs = pstmt.executeQuery();
        
        rs1 = statement1.executeQuery("SELECT * FROM product ORDER BY id");
        
        pstmt2 = conn.prepareStatement("SELECT * FROM person ORDER BY person_name OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
           	    ResultSet.CONCUR_READ_ONLY);
        if(request.getParameter("offset_row") != null){
        offset_row = Integer.parseInt(request.getParameter("offset_row"));
        pstmt2.setInt(1, offset_row);
        }
        else {
        pstmt2.setInt(1, 0);	
        }
        pstmt2.setInt(2, 20);
        rs2 = pstmt2.executeQuery();
        
        if(request.getParameter("offset_row") == null){       
        rs2.last();
        person_size = rs2.getRow();
        System.out.println("Total number of people: " + person_size);
        rs2.beforeFirst();
        }
        
        pstmt3 = conn.prepareStatement(alpha_customer + " OFFSET ?");
        if(request.getParameter("offset_totalPerPerson") != null){
         offset_totalPerPerson = Integer.parseInt(request.getParameter("offset_totalPerPerson"));
         pstmt3.setInt(1, offset_totalPerPerson);      
         }
         else {
         pstmt3.setInt(1, 0);	
         }
    	rs3 = pstmt3.executeQuery();
        
        
        /* rs = statement.executeQuery("SELECT p.id AS person, pd.id AS product, pic.price, sum(pic.quantity) FROM" +
       		 " shopping_cart sc"+
   		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
   		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
   		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +      		  
   		" WHERE sc.is_purchased = 't' GROUP BY p.id, pd.id, pic.price ORDER BY p.id"); */
        rs1.beforeFirst();
        
       // int count_row = 0;
        //int count_column = 0;
        
    %>
  <h3 style="text-align: center">Sales Report</h3>
  <table border="1" style="color:blue">
     <form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="runQuery">
     <% if(request.getParameter("offset_row")==null &&request.getParameter("offset_sale")==null
     		&& request.getParameter("offset_totalPerPerson")==null )
    	{ %>
	  	<tr>
	  	  <td>  	
	  	    <select name="sort_row">
	  	      <option value="person_name">Customer</option>
	  	      <option value="state">State</option>
	  	    </select>
	  	  </td>
	  	  <td>
	  	    <select name="sort_order">
	  	      <option value="alphabetical">Alphabetical</option>
	  	      <option value="top_k">Top-K</option>
	  	    </select>
	  	  </td>
	  	  <td>
	  	  <select name="sort_category">
	  	    <option value="all">All</option>
		  	<% statement4 = conn.createStatement();
		  	rs4 = statement4.executeQuery("SELECT * FROM category");
		  	while(rs4.next()){%>
		  		<option value="<%=rs4.getInt("id")%>"><%=rs4.getString("category_name")%></option>
		  	<%  
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
  	 <!-- side header -->
  	 <% String currCustomerName = rs2.getString("person_name"); 
  	 	
  	 
  	 
  	 if(rs3.isBeforeFirst()){
  	       rs3.next();
  	 }   
  	System.out.println("name in rs3: "+ rs3.getString("person_name"));	
  		if(rs3.getString("person_name").equals(currCustomerName)){
  	 	currCustomerSale = rs3.getInt("totalPerPerson");
  			if(!rs3.isLast()){
  				rs3.next();
  			}
  		}else {
  			currCustomerSale = 0;
  		}
  	 %>
  	 <th><span><%= currCustomerName %> <br><span style="color: black">($ <%= currCustomerSale%>)</span></span></th> 
  	 <!-- cells in current row -->
   <%  while(rs1.next()){
     if(rs.isBeforeFirst()){
       rs.next();
     }
     if(currCustomerName.equals(rs.getString("person_name"))){
     	//System.out.println("herehrehre");
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
     }else { %>
        <td>0</td>    
    <%}  
    } %>
  	</tr>
  	<!-- end of while loop of row -->
  <%  
  	} 
  	rs2.previous();
  	   
  	offset_row = offset_row + rs2.getRow();  	
    offset_sale = offset_sale + rs.getRow();
    offset_totalPerPerson = offset_totalPerPerson + rs3.getRow();  	
    
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
    <input type="hidden" name="offset_sale" value="<%=offset_sale-1 %>">
    <input type="hidden" name="offset_totalPerPerson" value="<%=offset_totalPerPerson-1 %>">
     
     
    <tr><td><input type="submit" value="NEXT 20 CUSTOMERS"></td></tr>
  	</form>
  	<%} %>
  
  </table>
  <%-- -------- Close Connection Code -------- --%>
    <%
        if(rs.isAfterLast()){
        // Close the ResultSet
        rs.close();

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
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
    ResultSet rs = null;
    ResultSet rs1 = null;
    ResultSet rs2 = null;
    int offset_row = 0;
    int offset_column = 0;
    int offset_sale = 0;
    int person_size = 0;
    int person_count = 0;
    
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
        pstmt = conn.prepareStatement("SELECT p.id AS person, pd.id AS product, pic.price, sum(pic.quantity) FROM" +
          		 " shopping_cart sc"+
          		  " INNER JOIN products_in_cart pic ON (pic.cart_id = sc.id)" +
          		  " RIGHT OUTER JOIN product pd ON (pd.id = pic.product_id)" +
          		  " RIGHT JOIN person p ON (p.id = sc.person_id)" +      		  
          		" WHERE sc.is_purchased = 't' GROUP BY p.id, pd.id, pic.price ORDER BY p.id OFFSET ? ROWS", ResultSet.TYPE_SCROLL_SENSITIVE,
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
        
        pstmt2 = conn.prepareStatement("SELECT * FROM person ORDER BY id OFFSET ? LIMIT ?", ResultSet.TYPE_SCROLL_SENSITIVE,
           	    ResultSet.CONCUR_READ_ONLY);
        if(request.getParameter("offset_row") != null){
        pstmt2.setInt(1, Integer.parseInt(request.getParameter("offset_row")));
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
  	<tr>
  	 <th>customer\product </th>
  	 <!-- populate columns -->
  <% while (rs1.next()) {  %>
  	 <th><%=rs1.getInt("id") %><br>($total sale)</th>
  <% 
  	} %> 
  	</tr>
  	<!-- populate rows -->
    <form action="salesAnalytics.jsp" method="GET">
     <input type="hidden" name="action" value="next_20_rows">
  	<% 
  	while(rs2.next()) { 
  	rs1.beforeFirst(); %>
  	<tr>
  	 <!-- side header -->
  	 <% int currCustomerid = rs2.getInt("id"); %>
  	 <th><span><%= currCustomerid %>($)</span></th> 
  	 <!-- cells in current row -->
   <%  while(rs1.next()){
     if(rs.isBeforeFirst()){
       rs.next();
     }
     if(currCustomerid == rs.getInt("person")){
     	if(rs1.getInt("id") == rs.getInt("product")){ %>
     	 <td><%= rs.getInt("price") * rs.getInt("sum")%></td>
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
  System.out.println("rs2 is at: "+ rs2.getRow());
  	} 
  	rs2.previous();
  	System.out.println("rs2 out of loop is at: "+ rs2.getRow());
  	System.out.println("rs is at: "+ rs.getRow());
    
  	offset_row = offset_row + 20;
    offset_sale = offset_sale + rs.getRow();
    System.out.println("rs is really at: "+ offset_sale); %>
    
    <input type="hidden" name="offset_row" value="<%=offset_row %>">
     <input type="hidden" name="offset_sale" value="<%=offset_sale-1 %>">
    <tr><td><input type="submit" value="NEXT 20 CUSTOMERS"></td></tr>
  	</form>
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
</body>
</html>